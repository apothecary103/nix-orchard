//! The scheme itself: a ramp of greys leaning the wallpaper's way, its own
//! colour as the accent, and twelve hues that bend toward it without giving
//! up what they mean. Every step is checked for contrast on the final hex.

use crate::analyse::{Analysis, TINT_ANCHORS, accent};
use crate::colour::{Lch, Rgb, apca, hue_delta, lerp, max_chroma, smoothstep, toe, toe_inv, wcag};

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Flavor {
    Auto,
    Dark,
    Light,
}

pub struct Settings {
    pub flavor: Flavor,
    /// Scales how far the greys lean toward the wallpaper; 0 is pure grey.
    pub tint: f64,
    /// Accent for a wallpaper with no colour of its own to offer.
    pub fallback_accent: Rgb,
    /// Keep this accent whatever the wallpaper, if set.
    pub fixed_accent: Option<Rgb>,
}

pub const SURFACES: [&str; 12] = [
    "crust", "mantle", "base", "surface0", "surface1", "surface2", "overlay0", "overlay1", "overlay2", "subtext0",
    "subtext1", "text",
];

pub const HUES: [&str; 12] =
    ["red", "orange", "yellow", "lime", "green", "aqua", "skye", "snow", "blue", "purple", "pink", "cherry"];

/// Where each hue sits in OKLCH and how far it may turn toward the accent.
/// `lift` and `chroma` shape the pair that share a neighbourhood: snow is a
/// paler, lighter blue, cherry a lighter, softer red.
struct Slot {
    hue: f64,
    turn: f64,
    lift: f64,
    chroma: f64,
}

const SLOTS: [Slot; 12] = [
    Slot { hue: 22.0, turn: 8.0, lift: 0.0, chroma: 1.0 },    // red
    Slot { hue: 55.0, turn: 8.0, lift: 0.02, chroma: 1.0 },   // orange
    Slot { hue: 95.0, turn: 7.0, lift: 0.06, chroma: 0.95 },  // yellow
    Slot { hue: 125.0, turn: 7.0, lift: 0.04, chroma: 0.9 },  // lime
    Slot { hue: 148.0, turn: 9.0, lift: 0.02, chroma: 0.95 }, // green
    Slot { hue: 182.0, turn: 9.0, lift: 0.02, chroma: 0.85 }, // aqua
    Slot { hue: 215.0, turn: 8.0, lift: 0.03, chroma: 0.85 }, // skye
    Slot { hue: 238.0, turn: 8.0, lift: 0.06, chroma: 0.55 }, // snow
    Slot { hue: 262.0, turn: 8.0, lift: -0.02, chroma: 1.0 }, // blue
    Slot { hue: 302.0, turn: 10.0, lift: 0.0, chroma: 1.0 },  // purple
    Slot { hue: 345.0, turn: 8.0, lift: 0.03, chroma: 0.9 },  // pink
    Slot { hue: 8.0, turn: 6.0, lift: 0.07, chroma: 0.6 },    // cherry
];

pub struct Scheme {
    pub is_light: bool,
    pub surfaces: [Rgb; 12],
    pub hues: [Rgb; 12],
    pub accent: Rgb,
}

pub fn build(analysis: &Analysis, settings: &Settings) -> Scheme {
    let median = analysis.lightness[5];
    let is_light = match settings.flavor {
        Flavor::Dark => false,
        Flavor::Light => true,
        // Dark unless the screen is plainly light; a dark subject on a light
        // ground still asks for dark (more than a third of it in shadow).
        Flavor::Auto => median > 0.62 && analysis.lightness[3] > 0.3,
    };

    let surfaces = neutrals(analysis, settings, is_light);
    let base = surfaces[2];

    let picked = settings
        .fixed_accent
        .map(|rgb| rgb.lab().lch())
        .or_else(|| accent(&analysis.clusters))
        .unwrap_or_else(|| settings.fallback_accent.lab().lch());

    let vivid = smoothstep(0.03, 0.16, analysis.vividness);
    let accent = settle(picked.h, lerp(0.11, 0.16, vivid).max(picked.c.min(0.16)), hue_level(is_light), base, &surfaces, is_light, 4.5);
    let hues = hues(picked.h, vivid, is_light, base, &surfaces);

    Scheme { is_light, surfaces, hues, accent }
}

fn hue_level(is_light: bool) -> f64 {
    if is_light { 0.5 } else { 0.76 }
}

/// Toe lightness of each surface, as steps from the base. These are
/// Catppuccin macchiato's and latte's own steps measured in toe lightness,
/// which are close to even (about 0.075 apart); only the base moves, a
/// little, toward the wallpaper's shadows (or highlights, when light) so the
/// scheme sits in the same key as the picture.
fn ramp(analysis: &Analysis, is_light: bool) -> [f64; 12] {
    const DARK: [f64; 12] = [-0.06, -0.03, 0.0, 0.081, 0.161, 0.238, 0.315, 0.391, 0.464, 0.535, 0.605, 0.674];
    const LIGHT: [f64; 12] =
        [-0.06, -0.028, 0.0, -0.117, -0.174, -0.232, -0.291, -0.353, -0.414, -0.476, -0.539, -0.603];
    let (base, steps) = if is_light {
        (lerp(0.951, analysis.lightness[8], 0.2).clamp(0.93, 0.965), LIGHT)
    } else {
        (lerp(0.176, analysis.lightness[2], 0.2).clamp(0.14, 0.18), DARK)
    };
    steps.map(|s| base + s)
}

/// How much chroma a grey may carry at this toe lightness before it stops
/// reading as grey: most in the dark middle, little in near-white, and less
/// for warm hues, which turn muddy sooner than cool ones.
fn neutral_chroma(lr: f64, hue: f64, is_light: bool) -> f64 {
    let shape = if is_light {
        0.35 + 0.65 * (1.0 - smoothstep(0.55, 0.97, lr))
    } else {
        1.0 - 0.55 * smoothstep(0.55, 0.92, lr)
    };
    let warm = (hue - 70.0).to_radians().cos().max(0.0);
    let cool = (hue - 270.0).to_radians().cos().max(0.0);
    let temperament = 1.0 - 0.2 * warm + 0.15 * cool;
    0.026 * shape * temperament
}

fn neutrals(analysis: &Analysis, settings: &Settings, is_light: bool) -> [Rgb; 12] {
    let levels = ramp(analysis, is_light);
    // How strongly the picture leans at all; a balanced or grey picture gives grey.
    let overall = smoothstep(0.004, 0.05, analysis.cast);

    let mut out = [Rgb([0, 0, 0]); 12];
    for (i, lr) in levels.iter().enumerate() {
        let (a, b) = tint_at(analysis, *lr);
        let lean = a.hypot(b);
        let hue = b.atan2(a).to_degrees().rem_euclid(360.0);
        let strength = smoothstep(0.003, 0.06, lean).max(overall * 0.5) * settings.tint;
        let c = (neutral_chroma(*lr, hue, is_light) * strength).min(lean.max(0.0) * 1.5);
        out[i] = Rgb::from_lch(Lch { l: toe_inv(*lr), c, h: hue });
    }
    enforce_text(&mut out, is_light);
    out
}

/// The tint vector at a toe lightness, linear between the anchors. Mixing
/// vectors, not hues, lets a band with no lean fade out instead of spinning.
fn tint_at(analysis: &Analysis, lr: f64) -> (f64, f64) {
    let n = TINT_ANCHORS.len();
    if lr <= TINT_ANCHORS[0] {
        return analysis.tint[0];
    }
    for i in 1..n {
        if lr <= TINT_ANCHORS[i] {
            let t = (lr - TINT_ANCHORS[i - 1]) / (TINT_ANCHORS[i] - TINT_ANCHORS[i - 1]);
            let (x, y) = (analysis.tint[i - 1], analysis.tint[i]);
            return (lerp(x.0, y.0, t), lerp(x.1, y.1, t));
        }
    }
    analysis.tint[n - 1]
}

/// Push the readable end of the ramp until it reads: text at WCAG 7 and
/// APCA 75 (macchiato's text clears both), subtext 5.5 and 4.5, and the
/// overlay comments sit on at 3.5.
fn enforce_text(surfaces: &mut [Rgb; 12], is_light: bool) {
    let base = surfaces[2];
    let floors = [(11, 7.0, 75.0), (10, 5.5, 65.0), (9, 4.5, 55.0), (8, 3.5, 45.0)];
    for (i, ratio, lc) in floors {
        let mut lch = surfaces[i].lab().lch();
        for _ in 0..80 {
            let rgb = Rgb::from_lch(lch);
            if wcag(rgb, base) >= ratio && apca(rgb, base) >= lc {
                break;
            }
            lch.l += if is_light { -0.005 } else { 0.005 };
            if !(0.0..=1.0).contains(&lch.l) {
                break;
            }
        }
        surfaces[i] = Rgb::from_lch(lch);
    }
}

/// Place a hue at a toe lightness and chroma, then move it away from the
/// base until it clears `ratio` against the base and 3:1 against the
/// panels, giving chroma back to the gamut as it goes.
fn settle(h: f64, c: f64, lr: f64, base: Rgb, surfaces: &[Rgb; 12], is_light: bool, ratio: f64) -> Rgb {
    let mut lr = lr;
    let mut best = Rgb([0, 0, 0]);
    for _ in 0..60 {
        let l = toe_inv(lr);
        let lch = Lch { l, c: c.min(0.92 * max_chroma(l, h)), h };
        best = Rgb::from_lch(lch);
        if wcag(best, base) >= ratio && wcag(best, surfaces[1]) >= 3.0 && wcag(best, surfaces[4]) >= 2.0 {
            break;
        }
        lr += if is_light { -0.01 } else { 0.01 };
        if !(0.05..=0.98).contains(&lr) {
            break;
        }
    }
    best
}

fn hues(accent_h: f64, vivid: f64, is_light: bool, base: Rgb, surfaces: &[Rgb; 12]) -> [Rgb; 12] {
    // Muted wallpapers get softer hues, vivid ones fuller; never neon.
    let chroma = if is_light { lerp(0.12, 0.17, vivid) } else { lerp(0.085, 0.145, vivid) };
    let level = hue_level(is_light);

    // Turn toward the accent like material's Blend.harmonize, half the gap,
    // capped per slot, and fading out for hues far from it.
    let mut angles: Vec<f64> = SLOTS
        .iter()
        .map(|slot| {
            let d = hue_delta(slot.hue, accent_h);
            let reach = 1.0 - smoothstep(25.0, 90.0, d.abs());
            slot.hue + d.signum() * (d.abs() * 0.5).min(slot.turn) * reach
        })
        .collect();

    // The slot the accent falls in takes the accent's own hue.
    let nearest = (0..SLOTS.len())
        .filter(|&i| i != 7 && i != 11)
        .min_by(|&x, &y| hue_delta(SLOTS[x].hue, accent_h).abs().total_cmp(&hue_delta(SLOTS[y].hue, accent_h).abs()))
        .unwrap();
    if hue_delta(SLOTS[nearest].hue, accent_h).abs() <= 2.0 * SLOTS[nearest].turn {
        angles[nearest] = accent_h;
    }

    // Keep neighbours apart; snow and cherry differ by lightness and chroma
    // from blue and red, so they are left out of the spacing.
    let order = [0usize, 1, 2, 3, 4, 5, 6, 8, 9, 10];
    for _ in 0..20 {
        for w in 0..order.len() {
            let (i, j) = (order[w], order[(w + 1) % order.len()]);
            let gap = hue_delta(angles[i], angles[j]);
            if gap < 16.0 {
                let push = (16.0 - gap) / 2.0;
                angles[i] -= push;
                angles[j] += push;
            }
        }
    }

    let mut out = [Rgb([0, 0, 0]); 12];
    for (i, slot) in SLOTS.iter().enumerate() {
        let lift = if is_light { -slot.lift } else { slot.lift };
        out[i] = settle(angles[i].rem_euclid(360.0), chroma * slot.chroma, level + lift, base, surfaces, is_light, 4.5);
    }
    // Green a touch lighter than red, so the pair survives red-green
    // colour blindness on lightness alone.
    let (red, green) = (out[0].lab(), out[4].lab());
    if (toe(green.l) - toe(red.l)).abs() < 0.04 {
        let shifted = if is_light { -0.04 } else { 0.04 };
        out[4] = settle(angles[4].rem_euclid(360.0), chroma * SLOTS[4].chroma, toe(red.l) + shifted, base, surfaces, is_light, 4.5);
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::analyse::analyse;
    use crate::sample::Sample;

    fn settings() -> Settings {
        Settings { flavor: Flavor::Auto, tint: 1.0, fallback_accent: Rgb([0x8a, 0xad, 0xf4]), fixed_accent: None }
    }

    fn solid(rgb: Rgb) -> Analysis {
        analyse(&[Sample { lab: rgb.lab(), weight: 1.0 }])
    }

    #[test]
    fn grey_wallpaper_gives_grey_scheme() {
        let s = build(&solid(Rgb([40, 40, 40])), &settings());
        assert!(!s.is_light);
        for c in s.surfaces {
            assert!(c.lab().lch().c < 0.004, "{}", c.hex());
        }
    }

    #[test]
    fn neutrals_stay_neutral_on_a_loud_wallpaper() {
        let s = build(&solid(Rgb([200, 20, 160])), &settings());
        for c in s.surfaces {
            assert!(c.lab().lch().c < 0.03, "{}", c.hex());
        }
        // And they lean its way.
        let h = s.surfaces[2].lab().lch().h;
        assert!(hue_delta(h, Rgb([200, 20, 160]).lab().lch().h).abs() < 10.0);
    }

    #[test]
    fn everything_reads() {
        for wall in [Rgb([10, 30, 60]), Rgb([230, 225, 210]), Rgb([90, 140, 60]), Rgb([0, 0, 0]), Rgb([255, 255, 255])] {
            let s = build(&solid(wall), &settings());
            let base = s.surfaces[2];
            assert!(wcag(s.surfaces[11], base) >= 7.0, "text on {}", wall.hex());
            for h in s.hues.iter().chain([&s.accent]) {
                assert!(wcag(*h, base) >= 4.5, "{} on {} ({})", h.hex(), base.hex(), wall.hex());
            }
        }
    }

    #[test]
    fn red_stays_red() {
        // Even with a blue-violet accent pulling everything its way.
        let s = build(&solid(Rgb([60, 40, 200])), &settings());
        let red = s.hues[0].lab().lch().h;
        assert!(hue_delta(22.0, red).abs() <= 8.5, "{red}");
    }

    #[test]
    fn light_wallpaper_gives_light_scheme() {
        let s = build(&solid(Rgb([235, 232, 225])), &settings());
        assert!(s.is_light);
    }
}
