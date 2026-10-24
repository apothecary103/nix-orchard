//! Finding out what sway is showing. Sway never reports the background over
//! IPC, so the truth is swaybg's own command line, which sway rebuilds and
//! respawns on every `output … bg` change; outputs come from the IPC.

use crate::colour::Rgb;
use crate::sample::Mode;
use serde_json::Value;
use std::io::{Read, Write};
use std::os::unix::net::UnixStream;
use std::path::{Path, PathBuf};

pub const RUN_COMMAND: u32 = 0;
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
pub const SUBSCRIBE: u32 = 2;
pub const GET_OUTPUTS: u32 = 3;
pub const GET_BAR_CONFIG: u32 = 6;

pub struct Ipc(UnixStream);

impl Ipc {
    pub fn connect() -> Result<Ipc, String> {
        let path = std::env::var_os("SWAYSOCK").ok_or("SWAYSOCK is not set")?;
        UnixStream::connect(&path).map(Ipc).map_err(|e| format!("sway IPC: {e}"))
    }

    #[cfg_attr(not(target_os = "linux"), allow(dead_code))]
    pub fn stream(&self) -> &UnixStream {
        &self.0
    }

    pub fn send(&mut self, kind: u32, payload: &str) -> Result<(), String> {
        let mut msg = b"i3-ipc".to_vec();
        msg.extend((payload.len() as u32).to_ne_bytes());
        msg.extend(kind.to_ne_bytes());
        msg.extend(payload.as_bytes());
        self.0.write_all(&msg).map_err(|e| format!("sway IPC: {e}"))
    }

    /// The next reply or event, as (type, body).
    pub fn receive(&mut self) -> Result<(u32, Value), String> {
        let mut head = [0u8; 14];
        self.0.read_exact(&mut head).map_err(|e| format!("sway IPC: {e}"))?;
        if &head[..6] != b"i3-ipc" {
            return Err("sway IPC: bad magic".into());
        }
        let len = u32::from_ne_bytes(head[6..10].try_into().unwrap()) as usize;
        let kind = u32::from_ne_bytes(head[10..14].try_into().unwrap());
        let mut body = vec![0u8; len];
        self.0.read_exact(&mut body).map_err(|e| format!("sway IPC: {e}"))?;
        let value = serde_json::from_slice(&body).map_err(|e| format!("sway IPC: {e}"))?;
        Ok((kind, value))
    }

    pub fn ask(&mut self, kind: u32, payload: &str) -> Result<Value, String> {
        self.send(kind, payload)?;
        loop {
            let (got, value) = self.receive()?;
            // Events carry the high bit; a subscribed socket may interleave them.
            if got & 0x8000_0000 == 0 {
                return Ok(value);
            }
        }
    }
}

#[derive(Clone, Debug, PartialEq)]
pub struct Output {
    pub name: String,
    /// The buffer swaybg draws: logical size times scale.
    pub width: f64,
    pub height: f64,
}

pub fn outputs(ipc: &mut Ipc) -> Result<Vec<Output>, String> {
    let reply = ipc.ask(GET_OUTPUTS, "")?;
    Ok(reply
        .as_array()
        .into_iter()
        .flatten()
        .filter(|o| o["active"].as_bool().unwrap_or(false))
        .map(|o| {
            let scale = o["scale"].as_f64().unwrap_or(1.0);
            Output {
                name: o["name"].as_str().unwrap_or_default().to_string(),
                width: o["rect"]["width"].as_f64().unwrap_or(1920.0) * scale,
                height: o["rect"]["height"].as_f64().unwrap_or(1080.0) * scale,
            }
        })
        .collect())
}

#[derive(Clone, Debug, PartialEq)]
pub enum Background {
    Image { path: PathBuf, mode: Mode, fallback: Rgb },
    Solid(Rgb),
}

/// One running swaybg and what it paints on which output ("*" for the rest).
#[derive(Debug)]
pub struct Swaybg {
    #[cfg_attr(not(target_os = "linux"), allow(dead_code))]
    pub pid: i32,
    pub started: u64,
    pub layers: Vec<(String, Background)>,
}

/// Every swaybg of ours, oldest first.
pub fn find_swaybg() -> Vec<Swaybg> {
    let uid = unsafe { libc::getuid() };
    let mut found: Vec<Swaybg> = std::fs::read_dir("/proc")
        .into_iter()
        .flatten()
        .flatten()
        .filter_map(|entry| {
            let pid: i32 = entry.file_name().to_str()?.parse().ok()?;
            let dir = entry.path();
            if std::fs::read_to_string(dir.join("comm")).ok()?.trim() != "swaybg" {
                return None;
            }
            let status = std::fs::read_to_string(dir.join("status")).ok()?;
            let owner: u32 = status.lines().find(|l| l.starts_with("Uid:"))?.split_whitespace().nth(1)?.parse().ok()?;
            if owner != uid {
                return None;
            }
            let cmdline = std::fs::read(dir.join("cmdline")).ok()?;
            let args: Vec<String> = cmdline
                .split(|b| *b == 0)
                .filter(|a| !a.is_empty())
                .map(|a| String::from_utf8_lossy(a).into_owned())
                .collect();
            let cwd = std::fs::read_link(dir.join("cwd")).unwrap_or_else(|_| "/".into());
            // Field 22 of stat is the start time; comm may hold spaces, so count from ')'.
            let stat = std::fs::read_to_string(dir.join("stat")).ok()?;
            let started = stat.rsplit_once(')')?.1.split_whitespace().nth(19)?.parse().ok()?;
            Some(Swaybg { pid, started, layers: parse_args(&args[1..], &cwd) })
        })
        .collect();
    found.sort_by_key(|s| s.started);
    found
}

/// swaybg's own reading of its arguments (main.c): options before the first
/// -o belong to "*", later ones to the last -o, merging when repeated; an
/// image without a mode is stretched.
pub fn parse_args(args: &[String], cwd: &Path) -> Vec<(String, Background)> {
    struct Partial {
        output: String,
        image: Option<String>,
        colour: Option<Rgb>,
        mode: Option<String>,
    }
    let mut all: Vec<Partial> = Vec::new();
    let mut current = Partial { output: "*".into(), image: None, colour: None, mode: None };
    let store = |p: Partial, all: &mut Vec<Partial>| {
        if let Some(old) = all.iter_mut().find(|o| o.output == p.output) {
            old.image = p.image.or(old.image.take());
            old.colour = p.colour.or(old.colour);
            old.mode = p.mode.or(old.mode.take());
        } else {
            all.push(p);
        }
    };

    let mut i = 0;
    while i < args.len() {
        let (flag, value) = match args[i].split_once('=') {
            Some((f, v)) if f.starts_with("--") => (f.to_string(), Some(v.to_string())),
            _ => (args[i].clone(), None),
        };
        let mut take = || {
            value.clone().or_else(|| {
                i += 1;
                args.get(i).cloned()
            })
        };
        match flag.as_str() {
            "-o" | "--output" => {
                let next = Partial { output: take().unwrap_or_default(), image: None, colour: None, mode: None };
                store(std::mem::replace(&mut current, next), &mut all);
            }
            "-i" | "--image" => current.image = take(),
            "-c" | "--color" => current.colour = take().and_then(|c| Rgb::parse(&c)),
            "-m" | "--mode" => current.mode = take(),
            _ => {}
        }
        i += 1;
    }
    store(current, &mut all);

    all.into_iter()
        .filter_map(|p| {
            let mode = p.mode.as_deref();
            let background = match (&p.image, mode) {
                (Some(image), m) if m != Some("solid_color") => {
                    let path = if Path::new(image).is_absolute() { PathBuf::from(image) } else { cwd.join(image) };
                    let mode = m.and_then(Mode::parse).unwrap_or(Mode::Stretch);
                    Background::Image { path, mode, fallback: p.colour.unwrap_or(Rgb([0, 0, 0])) }
                }
                _ => Background::Solid(p.colour?),
            };
            Some((p.output, background))
        })
        .collect()
}

/// What each output shows, with later swaybg instances winning, as swaybg
/// itself has a specific output beat "*".
pub fn backgrounds(all: &[Swaybg], outputs: &[Output]) -> Vec<(Output, Background)> {
    outputs
        .iter()
        .filter_map(|o| {
            let mut chosen = None;
            for bg in all {
                let exact = bg.layers.iter().find(|(name, _)| *name == o.name);
                let any = bg.layers.iter().find(|(name, _)| name == "*");
                if let Some((_, b)) = exact.or(any) {
                    chosen = Some(b.clone());
                }
            }
            chosen.map(|b| (o.clone(), b))
        })
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn args(s: &str) -> Vec<String> {
        s.split_whitespace().map(String::from).collect()
    }

    #[test]
    fn reads_what_sway_spawns() {
        let got = parse_args(&args("-o eDP-1 -i /w.png -m fill -c #112233 -o HDMI-A-1 -c #445566"), Path::new("/"));
        assert_eq!(got.len(), 2);
        assert_eq!(got[0].1, Background::Image { path: "/w.png".into(), mode: Mode::Fill, fallback: Rgb([0x11, 0x22, 0x33]) });
        assert_eq!(got[1].1, Background::Solid(Rgb([0x44, 0x55, 0x66])));
    }

    #[test]
    fn bare_image_stretches_relative_to_cwd() {
        let got = parse_args(&args("--image=w.jpg"), Path::new("/home/x"));
        assert_eq!(got[0].0, "*");
        assert_eq!(got[0].1, Background::Image { path: "/home/x/w.jpg".into(), mode: Mode::Stretch, fallback: Rgb([0, 0, 0]) });
    }
}
