//! The scheme spelt the way orchard spells a palette (lib/palette.nix), with
//! its default roles, so templates name colours exactly as Nix configs do.

use crate::colour::Rgb;
use crate::scheme::{HUES, SURFACES, Scheme};
use serde_json::{Map, Value, json};
use std::collections::BTreeMap;

/// Every `group.name` key a template may use, to its colour.
pub fn flatten(s: &Scheme) -> BTreeMap<String, Rgb> {
    let mut c: BTreeMap<&str, Rgb> = BTreeMap::new();
    for (name, rgb) in SURFACES.iter().zip(s.surfaces) {
        c.insert(name, rgb);
    }
    for (name, rgb) in HUES.iter().zip(s.hues) {
        c.insert(name, rgb);
    }
    let g = |k: &str| c[k];

    let mut out = BTreeMap::new();
    let mut put = |k: &str, v: Rgb| {
        out.insert(k.to_string(), v);
    };

    let surface = [
        ("shadow", "crust"),
        ("panel", "mantle"),
        ("background", "base"),
        ("neutral0", "surface0"),
        ("neutral1", "surface1"),
        ("neutral2", "surface2"),
        ("neutral3", "overlay0"),
        ("neutral4", "overlay1"),
        ("neutral5", "overlay2"),
        ("textDim", "subtext0"),
        ("textMuted", "subtext1"),
        ("text", "text"),
    ];
    for (public, own) in surface {
        put(&format!("surface.{public}"), g(own));
    }
    for name in HUES {
        put(&format!("hue.{name}"), g(name));
    }

    // lib/palette.nix `roles`, with the accent the wallpaper picked.
    let accent = s.accent;
    let ok = g("green");
    let syntax = [
        ("keyword", g("red")),
        ("function", g("green")),
        ("macro", g("cherry")),
        ("type", g("yellow")),
        ("constant", g("pink")),
        ("number", g("pink")),
        ("string", g("lime")),
        ("escape", g("yellow")),
        ("escapeAlt", g("red")),
        ("inlineCode", g("red")),
        ("special", g("aqua")),
        ("variable", g("text")),
        ("property", g("skye")),
        ("module", g("snow")),
        ("annotation", g("cherry")),
        ("operator", g("subtext0")),
        ("punctuation", g("overlay1")),
        ("comment", g("overlay2")),
    ];
    for (k, v) in syntax {
        put(&format!("syntax.{k}"), v);
    }
    let ui = [
        ("accent", accent),
        ("secondaryAccent", g("blue")),
        ("cursor", accent),
        ("selection", g("surface1")),
        ("cursorLine", g("surface0")),
        ("search", g("snow")),
        ("match", g("orange")),
        ("title", g("cherry")),
    ];
    for (k, v) in ui {
        put(&format!("ui.{k}"), v);
    }
    let status = [
        ("error", g("red")),
        ("errorMuted", g("red")),
        ("warning", g("yellow")),
        ("info", g("aqua")),
        ("hint", g("skye")),
        ("success", ok),
        ("diffAdded", ok),
        ("diffDeleted", g("red")),
        ("diffChanged", g("aqua")),
    ];
    for (k, v) in status {
        put(&format!("status.{k}"), v);
    }
    let bar = [
        ("background", g("mantle")),
        ("foreground", g("text")),
        ("inactive", g("subtext0")),
        ("dim", g("overlay1")),
        ("mode.foreground", g("base")),
        ("mode.normal", accent),
        ("mode.insert", ok),
        ("mode.select", g("aqua")),
    ];
    for (k, v) in bar {
        put(&format!("statusBar.{k}"), v);
    }
    for (i, v) in ansi(s, &c).into_iter().enumerate() {
        put(&format!("terminal.ansi.{i}"), v);
    }
    out
}

fn ansi(s: &Scheme, c: &BTreeMap<&str, Rgb>) -> [Rgb; 16] {
    let g = |k: &str| c[k];
    let l = s.is_light;
    [
        if l { g("subtext1") } else { g("surface1") },
        g("red"),
        g("green"),
        g("yellow"),
        g("blue"),
        g("pink"),
        g("aqua"),
        if l { g("surface2") } else { g("subtext0") },
        g("overlay1"),
        g("red"),
        g("green"),
        g("yellow"),
        g("blue"),
        g("pink"),
        g("aqua"),
        if l { g("surface0") } else { g("subtext1") },
    ]
}

/// The grouped palette as JSON, the shape `config.orchard.palette` has.
pub fn json(s: &Scheme) -> Value {
    let mut root = Map::new();
    for (key, rgb) in flatten(s) {
        let mut parts: Vec<&str> = key.split('.').collect();
        // terminal.ansi.N becomes a list below.
        if parts[0] == "terminal" {
            continue;
        }
        let last = parts.pop().unwrap();
        let mut node = &mut root;
        for p in parts {
            node = node.entry(p).or_insert_with(|| Value::Object(Map::new())).as_object_mut().unwrap();
        }
        node.insert(last.to_string(), json!(rgb.hex()));
    }
    let flat = flatten(s);
    let ansi: Vec<Value> = (0..16).map(|i| json!(flat[&format!("terminal.ansi.{i}")].hex())).collect();
    root.insert("terminal".into(), json!({ "ansi": ansi }));
    root.insert("isLight".into(), json!(s.is_light));
    Value::Object(root)
}
