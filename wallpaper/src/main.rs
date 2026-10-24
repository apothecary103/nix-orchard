//! orchard-wallpaper: colours from the wallpaper sway is showing.
//!
//!   orchard-wallpaper palette (--image PATH [--mode fill] [--size WxH] | --color HEX) [scheme options]
//!   orchard-wallpaper render --config FILE (--image PATH … | --color HEX)
//!   orchard-wallpaper apply --config FILE
//!   orchard-wallpaper watch --config FILE
//!
//! Scheme options: --flavor auto|dark|light, --tint 0..1, --accent auto|HEX,
//! --fallback-accent HEX. `palette` prints orchard's grouped palette as JSON;
//! `render` prints every configured file as it would be written for a picture.

mod analyse;
mod colour;
mod palette;
mod sample;
mod scheme;
mod sway;
mod template;

use colour::Rgb;
use sample::{Layer, Mode, Picture, Sample};
use scheme::{Flavor, Settings};
use serde_json::Value;
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::process::ExitCode;
use std::time::SystemTime;
#[cfg(target_os = "linux")]
use std::time::Duration;
use sway::{Background, Ipc};

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let result = match args.first().map(String::as_str) {
        Some("palette") => palette_command(&args[1..]),
        Some("render") => render_command(&args[1..]),
        Some("apply") => config_from(&args[1..]).and_then(|c| Daemon::new(c).apply_once()),
        Some("watch") => config_from(&args[1..]).and_then(|c| Daemon::new(c).watch()),
        _ => Err("usage: orchard-wallpaper palette|apply|watch …".into()),
    };
    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("orchard-wallpaper: {e}");
            ExitCode::FAILURE
        }
    }
}

fn flag<'a>(args: &'a [String], name: &str) -> Option<&'a str> {
    args.iter().position(|a| a == name).and_then(|i| args.get(i + 1)).map(String::as_str)
}

fn settings_from(get: impl Fn(&str) -> Option<String>) -> Result<Settings, String> {
    let flavor = match get("flavor").as_deref() {
        None | Some("auto") => Flavor::Auto,
        Some("dark") => Flavor::Dark,
        Some("light") => Flavor::Light,
        Some(other) => return Err(format!("flavor {other} is not auto, dark or light")),
    };
    let colour = |key: &str| -> Result<Option<Rgb>, String> {
        match get(key).as_deref() {
            None | Some("auto") => Ok(None),
            Some(hex) => Rgb::parse(hex).map(Some).ok_or(format!("{key}: {hex} is not a colour")),
        }
    };
    Ok(Settings {
        flavor,
        tint: get("tint").map(|t| t.parse().map_err(|_| format!("tint: {t}"))).transpose()?.unwrap_or(1.0),
        fixed_accent: colour("accent")?,
        // Catppuccin macchiato's blue, orchard's own default accent.
        fallback_accent: colour("fallbackAccent")?.unwrap_or(Rgb([0x8a, 0xad, 0xf4])),
    })
}

fn palette_command(args: &[String]) -> Result<(), String> {
    let settings = settings_from(|k| {
        let cli = match k {
            "fallbackAccent" => "--fallback-accent".to_string(),
            other => format!("--{other}"),
        };
        flag(args, &cli).map(String::from)
    })?;
    let analysis = analyse::analyse(&samples_from(args)?);
    if args.iter().any(|a| a == "--debug") {
        for c in &analysis.clusters {
            let lch = c.lab.lch();
            eprintln!("{} share {:.3} Lr {:.2} C {:.3} h {:.0}", Rgb::from_lab(c.lab).hex(), c.share, colour::toe(lch.l), lch.c, lch.h);
        }
        eprintln!("lightness {:.2?} vividness {:.3} cast {:.3}", analysis.lightness, analysis.vividness, analysis.cast);
    }
    let scheme = scheme::build(&analysis, &settings);
    println!("{}", serde_json::to_string_pretty(&palette::json(&scheme)).unwrap());
    Ok(())
}

fn render_command(args: &[String]) -> Result<(), String> {
    let daemon = Daemon::new(config_from(args)?);
    let scheme = scheme::build(&analyse::analyse(&samples_from(args)?), &daemon.settings()?);
    let colours = palette::flatten(&scheme);
    for t in &daemon.config.targets {
        let text = template::render(&t.template, &colours).map_err(|e| format!("{}: {e}", t.name))?;
        println!("==> {} ({})\n{text}", t.name, t.path.display());
    }
    Ok(())
}

fn samples_from(args: &[String]) -> Result<Vec<Sample>, String> {
    let (width, height) = match flag(args, "--size") {
        Some(s) => {
            let (w, h) = s.split_once('x').ok_or("--size wants WxH")?;
            (w.parse().map_err(|_| "--size wants WxH")?, h.parse().map_err(|_| "--size wants WxH")?)
        }
        None => (1920.0, 1200.0),
    };
    let samples = if let Some(hex) = flag(args, "--color") {
        let rgb = Rgb::parse(hex).ok_or("--color wants a hex colour")?;
        sample::sample(&Layer::Solid(rgb), width, height, 1.0)
    } else {
        let path = flag(args, "--image").ok_or("palette wants --image or --color")?;
        let mode = Mode::parse(flag(args, "--mode").unwrap_or("fill")).ok_or("unknown --mode")?;
        let picture = Picture::open(Path::new(path))?;
        sample::sample(&Layer::Image { picture: &picture, mode, fallback: Rgb([0, 0, 0]) }, width, height, 1.0)
    };
    Ok(samples)
}

/// What orchard's module hands over: scheme settings and the files to keep.
struct Config {
    raw: Value,
    state_dir: PathBuf,
    targets: Vec<Target>,
}

struct Target {
    name: String,
    template: String,
    /// The same template filled from the configured theme, for when there is
    /// no wallpaper to read.
    fallback: String,
    path: PathBuf,
    sway: bool,
    reload: Vec<String>,
}

fn config_from(args: &[String]) -> Result<Config, String> {
    let path = flag(args, "--config").ok_or("missing --config FILE")?;
    let text = std::fs::read_to_string(path).map_err(|e| format!("{path}: {e}"))?;
    let raw: Value = serde_json::from_str(&text).map_err(|e| format!("{path}: {e}"))?;
    let read = |p: &str| std::fs::read_to_string(p).map_err(|e| format!("{p}: {e}"));
    let targets = raw["targets"]
        .as_array()
        .into_iter()
        .flatten()
        .map(|t| {
            Ok(Target {
                name: t["name"].as_str().unwrap_or("?").to_string(),
                template: read(t["template"].as_str().ok_or("target without a template")?)?,
                fallback: read(t["fallback"].as_str().ok_or("target without a fallback")?)?,
                path: PathBuf::from(t["path"].as_str().ok_or("target without a path")?),
                sway: t["sway"].as_bool().unwrap_or(false),
                reload: t["reload"].as_array().into_iter().flatten().filter_map(|a| a.as_str().map(String::from)).collect(),
            })
        })
        .collect::<Result<_, String>>()?;
    Ok(Config {
        state_dir: PathBuf::from(raw["stateDir"].as_str().ok_or("config without a stateDir")?),
        raw,
        targets,
    })
}

struct Daemon {
    config: Config,
    /// The last screen we themed for, so respawns of the same swaybg are free.
    last: Option<String>,
    pictures: HashMap<(PathBuf, Option<SystemTime>), Picture>,
}

impl Daemon {
    fn new(config: Config) -> Daemon {
        Daemon { config, last: None, pictures: HashMap::new() }
    }

    fn settings(&self) -> Result<Settings, String> {
        let raw = &self.config.raw;
        settings_from(|k| match &raw[k] {
            Value::String(s) => Some(s.clone()),
            Value::Number(n) => Some(n.to_string()),
            _ => None,
        })
    }

    fn apply_once(&mut self) -> Result<(), String> {
        let mut ipc = Ipc::connect()?;
        self.apply(&mut ipc)
    }

    fn apply(&mut self, ipc: &mut Ipc) -> Result<(), String> {
        let outputs = sway::outputs(ipc)?;
        let shown = sway::backgrounds(&sway::find_swaybg(), &outputs);

        let mtime = |p: &Path| std::fs::metadata(p).and_then(|m| m.modified()).ok();
        let fingerprint = format!(
            "{:?}",
            shown
                .iter()
                .map(|(o, b)| {
                    let stamp = match b {
                        Background::Image { path, .. } => mtime(path),
                        Background::Solid(_) => None,
                    };
                    (o, b, stamp)
                })
                .collect::<Vec<_>>()
        );
        if self.last.as_deref() == Some(fingerprint.as_str()) {
            return Ok(());
        }

        let rendered: Vec<String> = if shown.is_empty() {
            self.config.targets.iter().map(|t| t.fallback.clone()).collect()
        } else {
            let scheme = scheme::build(&analyse::analyse(&self.samples(&shown)?), &self.settings()?);
            let colours = palette::flatten(&scheme);
            write_if_changed(
                &self.config.state_dir.join("palette.json"),
                &serde_json::to_string_pretty(&palette::json(&scheme)).unwrap(),
            )?;
            self.config
                .targets
                .iter()
                .map(|t| template::render(&t.template, &colours).map_err(|e| format!("{}: {e}", t.name)))
                .collect::<Result<_, _>>()?
        };

        for (target, text) in self.config.targets.iter().zip(&rendered) {
            if !write_if_changed(&target.path, text)? && self.last.is_some() {
                continue;
            }
            if target.sway {
                apply_sway(ipc, text);
            }
            if let Some((program, args)) = target.reload.split_first() {
                // A reload that fails (its program not running yet) is not ours to fix.
                let _ = std::process::Command::new(program).args(args).status();
            }
        }
        self.last = Some(fingerprint);
        Ok(())
    }

    /// Every output's visible wallpaper, weighted by its share of all pixels.
    fn samples(&mut self, shown: &[(sway::Output, Background)]) -> Result<Vec<Sample>, String> {
        let area: f64 = shown.iter().map(|(o, _)| o.width * o.height).sum::<f64>().max(1.0);
        let mut out = Vec::new();
        for (output, background) in shown {
            let share = output.width * output.height / area;
            match background {
                Background::Solid(rgb) => out.extend(sample::sample(&Layer::Solid(*rgb), output.width, output.height, share)),
                Background::Image { path, mode, fallback } => {
                    let key = (path.clone(), std::fs::metadata(path).and_then(|m| m.modified()).ok());
                    if !self.pictures.contains_key(&key) {
                        self.pictures.retain(|(p, _), _| p != path);
                        self.pictures.insert(key.clone(), Picture::open(path)?);
                    }
                    let picture = &self.pictures[&key];
                    let layer = Layer::Image { picture, mode: *mode, fallback: *fallback };
                    out.extend(sample::sample(&layer, output.width, output.height, share));
                }
            }
        }
        Ok(out)
    }

    #[cfg(not(target_os = "linux"))]
    fn watch(&mut self) -> Result<(), String> {
        Err("watching swaybg needs Linux".into())
    }

    /// Theme now, then again whenever swaybg is replaced (its pidfd turns
    /// readable as it exits) or sway reports output changes.
    #[cfg(target_os = "linux")]
    fn watch(&mut self) -> Result<(), String> {
        use std::os::fd::{AsRawFd, FromRawFd, OwnedFd};

        let mut ipc = Ipc::connect()?;
        let mut events = Ipc::connect()?;
        events.ask(sway::SUBSCRIBE, r#"["output","shutdown"]"#)?;

        loop {
            if let Err(e) = self.apply(&mut ipc) {
                eprintln!("orchard-wallpaper: {e}");
            }

            let watched: Vec<OwnedFd> = sway::find_swaybg()
                .iter()
                .filter_map(|s| {
                    let fd = unsafe { libc::syscall(libc::SYS_pidfd_open, s.pid, 0) };
                    (fd >= 0).then(|| unsafe { OwnedFd::from_raw_fd(fd as i32) })
                })
                .collect();
            let mut fds: Vec<libc::pollfd> = std::iter::once(events.stream().as_raw_fd())
                .chain(watched.iter().map(|f| f.as_raw_fd()))
                .map(|fd| libc::pollfd { fd, events: libc::POLLIN, revents: 0 })
                .collect();
            // Without a swaybg to wait on, look again soon for one sway did not start.
            let timeout = if watched.is_empty() { 3_000 } else { 60_000 };
            let ready = unsafe { libc::poll(fds.as_mut_ptr(), fds.len() as libc::nfds_t, timeout) };
            if ready < 0 {
                let err = std::io::Error::last_os_error();
                if err.kind() == std::io::ErrorKind::Interrupted {
                    continue;
                }
                return Err(format!("poll: {err}"));
            }
            if fds[0].revents & (libc::POLLHUP | libc::POLLERR) != 0 {
                return Ok(());
            }
            if fds[0].revents & libc::POLLIN != 0 {
                let (kind, _) = events.receive()?;
                // 0x80000008: sway is exiting.
                if kind == 0x8000_0008 {
                    return Ok(());
                }
            }
            // Let sway finish respawning swaybg before looking.
            std::thread::sleep(Duration::from_millis(250));
        }
    }
}

/// Run a sway snippet live: every non-comment line is a command sway accepts
/// both at runtime and in a config file, so the same file serves `include`.
fn apply_sway(ipc: &mut Ipc, text: &str) {
    // At runtime `bar <id> …` creates and spawns a bar when the id is new,
    // so leave out lines for bars this sway does not have.
    let bars: Vec<String> = match ipc.ask(sway::GET_BAR_CONFIG, "") {
        Ok(Value::Array(ids)) => ids.iter().filter_map(|i| i.as_str().map(String::from)).collect(),
        _ => Vec::new(),
    };
    let known = |line: &str| match line.strip_prefix("bar ") {
        Some(rest) => bars.iter().any(|b| rest.split_whitespace().next() == Some(b.as_str())),
        None => true,
    };
    let commands: Vec<&str> =
        text.lines().map(str::trim).filter(|l| !l.is_empty() && !l.starts_with('#') && known(l)).collect();
    if commands.is_empty() {
        return;
    }
    match ipc.ask(sway::RUN_COMMAND, &commands.join("; ")) {
        Ok(Value::Array(results)) => {
            for (cmd, r) in commands.iter().zip(results) {
                if r["success"].as_bool() != Some(true) {
                    eprintln!("orchard-wallpaper: sway rejected `{cmd}`: {}", r["error"].as_str().unwrap_or("?"));
                }
            }
        }
        Ok(_) => {}
        Err(e) => eprintln!("orchard-wallpaper: {e}"),
    }
}

/// Atomically replace a file whose contents differ; says whether it did.
fn write_if_changed(path: &Path, text: &str) -> Result<bool, String> {
    if std::fs::read_to_string(path).ok().as_deref() == Some(text) {
        return Ok(false);
    }
    if let Some(dir) = path.parent() {
        std::fs::create_dir_all(dir).map_err(|e| format!("{}: {e}", dir.display()))?;
    }
    let tmp = path.with_extension("orchard-tmp");
    std::fs::write(&tmp, text).map_err(|e| format!("{}: {e}", tmp.display()))?;
    std::fs::rename(&tmp, path).map_err(|e| format!("{}: {e}", path.display()))?;
    Ok(true)
}
