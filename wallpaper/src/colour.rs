//! OKLab and friends: conversions, the toe-corrected lightness, gamut mapping
//! and the two contrast measures the scheme is checked against.


#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Lab {
    pub l: f64,
    pub a: f64,
    pub b: f64,
}

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Lch {
    pub l: f64,
    pub c: f64,
    /// Degrees, 0..360.
    pub h: f64,
}

impl Lab {
    pub fn lch(self) -> Lch {
        Lch {
            l: self.l,
            c: self.a.hypot(self.b),
            h: self.b.atan2(self.a).to_degrees().rem_euclid(360.0),
        }
    }

    pub fn distance(self, other: Lab) -> f64 {
        ((self.l - other.l).powi(2) + (self.a - other.a).powi(2) + (self.b - other.b).powi(2)).sqrt()
    }
}

impl Lch {
    pub fn lab(self) -> Lab {
        let h = self.h.to_radians();
        Lab { l: self.l, a: self.c * h.cos(), b: self.c * h.sin() }
    }
}

pub fn srgb_to_linear(c: f64) -> f64 {
    if c <= 0.04045 { c / 12.92 } else { ((c + 0.055) / 1.055).powf(2.4) }
}

pub fn linear_to_srgb(c: f64) -> f64 {
    if c <= 0.0031308 { c * 12.92 } else { 1.055 * c.powf(1.0 / 2.4) - 0.055 }
}

/// Björn Ottosson's matrices, https://bottosson.github.io/posts/oklab/.
pub fn linear_to_oklab([r, g, b]: [f64; 3]) -> Lab {
    let l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b;
    let m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b;
    let s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b;
    let (l, m, s) = (l.cbrt(), m.cbrt(), s.cbrt());
    Lab {
        l: 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
        a: 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
        b: 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
    }
}

pub fn oklab_to_linear(c: Lab) -> [f64; 3] {
    let l = c.l + 0.3963377774 * c.a + 0.2158037573 * c.b;
    let m = c.l - 0.1055613458 * c.a - 0.0638541728 * c.b;
    let s = c.l - 0.0894841775 * c.a - 1.2914855480 * c.b;
    let (l, m, s) = (l * l * l, m * m * m, s * s * s);
    [
        4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    ]
}

// OKLab's L runs high near black; the toe (from Ottosson's OKHSV post) maps
// it onto a lightness that tracks CIELAB L*, so ramps can be spaced evenly.
const K1: f64 = 0.206;
const K2: f64 = 0.03;
const K3: f64 = (1.0 + K1) / (1.0 + K2);

pub fn toe(l: f64) -> f64 {
    0.5 * (K3 * l - K1 + ((K3 * l - K1).powi(2) + 4.0 * K2 * K3 * l).sqrt())
}

pub fn toe_inv(lr: f64) -> f64 {
    (lr * lr + K1 * lr) / (K3 * (lr + K2))
}

fn in_gamut([r, g, b]: [f64; 3]) -> bool {
    const E: f64 = 1e-6;
    (-E..=1.0 + E).contains(&r) && (-E..=1.0 + E).contains(&g) && (-E..=1.0 + E).contains(&b)
}

/// Largest chroma sRGB can show at this lightness and hue.
pub fn max_chroma(l: f64, h: f64) -> f64 {
    let (mut lo, mut hi) = (0.0, 0.5);
    for _ in 0..32 {
        let mid = (lo + hi) / 2.0;
        if in_gamut(oklab_to_linear(Lch { l, c: mid, h }.lab())) { lo = mid } else { hi = mid }
    }
    lo
}

/// Keep lightness and hue and give up chroma until the colour fits sRGB.
pub fn fit(c: Lch) -> Lch {
    let l = c.l.clamp(0.0, 1.0);
    Lch { l, c: c.c.min(max_chroma(l, c.h)), h: c.h }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
pub struct Rgb(pub [u8; 3]);

impl Rgb {
    pub fn hex(self) -> String {
        format!("#{:02x}{:02x}{:02x}", self.0[0], self.0[1], self.0[2])
    }

    pub fn parse(text: &str) -> Option<Rgb> {
        let t = text.trim().trim_start_matches('#');
        let t = if t.len() == 8 { &t[..6] } else { t };
        if t.len() != 6 {
            return None;
        }
        let at = |i: usize| u8::from_str_radix(&t[i..i + 2], 16).ok();
        Some(Rgb([at(0)?, at(2)?, at(4)?]))
    }

    pub fn linear(self) -> [f64; 3] {
        self.0.map(|v| srgb_to_linear(v as f64 / 255.0))
    }

    pub fn lab(self) -> Lab {
        linear_to_oklab(self.linear())
    }

    pub fn from_lab(c: Lab) -> Rgb {
        // Colours on the gamut's surface (sRGB primaries) come back a hair
        // outside it from rounding; only map what is really outside.
        let direct = oklab_to_linear(c);
        let near = direct.iter().all(|v| (-1e-4..=1.0 + 1e-4).contains(v));
        let linear = if near { direct } else { oklab_to_linear(fit(c.lch()).lab()) };
        Rgb(linear.map(|v| (linear_to_srgb(v.clamp(0.0, 1.0)) * 255.0).round() as u8))
    }

    pub fn from_lch(c: Lch) -> Rgb {
        Rgb::from_lab(c.lab())
    }

    /// WCAG 2 relative luminance.
    pub fn luminance(self) -> f64 {
        let [r, g, b] = self.linear();
        0.2126 * r + 0.7152 * g + 0.0722 * b
    }
}

/// WCAG 2 contrast ratio, 1..21.
pub fn wcag(a: Rgb, b: Rgb) -> f64 {
    let (x, y) = (a.luminance(), b.luminance());
    (x.max(y) + 0.05) / (x.min(y) + 0.05)
}

/// APCA 0.0.98G-4g lightness contrast of text on a background, as |Lc|.
pub fn apca(text: Rgb, background: Rgb) -> f64 {
    fn y(c: Rgb) -> f64 {
        let [r, g, b] = c.0.map(|v| (v as f64 / 255.0).powf(2.4));
        let y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * b;
        if y < 0.022 { y + (0.022 - y).powf(1.414) } else { y }
    }
    let (yt, yb) = (y(text), y(background));
    if (yb - yt).abs() < 0.0005 {
        return 0.0;
    }
    let lc = if yb > yt {
        let s = (yb.powf(0.56) - yt.powf(0.57)) * 1.14;
        if s < 0.1 { 0.0 } else { s - 0.027 }
    } else {
        let s = (yb.powf(0.65) - yt.powf(0.62)) * 1.14;
        if s > -0.1 { 0.0 } else { s + 0.027 }
    };
    (lc * 100.0).abs()
}

/// Signed shortest rotation from `from` to `to`, in degrees.
pub fn hue_delta(from: f64, to: f64) -> f64 {
    (to - from + 540.0).rem_euclid(360.0) - 180.0
}

pub fn smoothstep(edge0: f64, edge1: f64, x: f64) -> f64 {
    let t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

pub fn lerp(a: f64, b: f64, t: f64) -> f64 {
    a + (b - a) * t
}

pub fn gaussian(x: f64, sigma: f64) -> f64 {
    (-(x * x) / (2.0 * sigma * sigma)).exp()
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn white_is_one() {
        let w = Rgb([255, 255, 255]).lab();
        assert!((w.l - 1.0).abs() < 1e-4 && w.a.abs() < 1e-4 && w.b.abs() < 1e-4);
    }

    #[test]
    fn round_trips() {
        for c in [[12, 200, 99], [255, 0, 0], [0, 0, 255], [30, 30, 46], [250, 179, 135]] {
            assert_eq!(Rgb::from_lab(Rgb(c).lab()), Rgb(c));
        }
    }

    #[test]
    fn toe_inverts() {
        for l in [0.0, 0.1, 0.3, 0.6, 0.9, 1.0] {
            assert!((toe_inv(toe(l)) - l).abs() < 1e-9);
        }
        assert!((toe(1.0) - 1.0).abs() < 1e-9);
    }

    #[test]
    fn apca_reference() {
        // The APCA reference implementation's published extremes.
        let (black, white) = (Rgb([0, 0, 0]), Rgb([255, 255, 255]));
        assert!((apca(black, white) - 106.04).abs() < 0.1);
        assert!((apca(white, black) - 107.88).abs() < 0.1);
        assert!((apca(Rgb([0x88, 0x88, 0x88]), white) - 63.06).abs() < 0.1);
    }

    #[test]
    fn wcag_reference() {
        assert!((wcag(Rgb([0, 0, 0]), Rgb([255, 255, 255])) - 21.0).abs() < 1e-9);
    }

    #[test]
    fn red_hue() {
        // sRGB red sits at h 29 in OKLCH.
        assert!((Rgb([255, 0, 0]).lab().lch().h - 29.2).abs() < 0.5);
    }
}
