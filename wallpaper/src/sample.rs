//! What the screen actually shows: the wallpaper laid out the way swaybg lays
//! it out for each output's buffer, sampled on a grid in linear light.

use crate::colour::{Lab, Rgb, linear_to_oklab, srgb_to_linear};
use std::path::Path;

#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum Mode {
    Stretch,
    Fill,
    Fit,
    Center,
    Tile,
}

impl Mode {
    pub fn parse(text: &str) -> Option<Mode> {
        Some(match text {
            "stretch" => Mode::Stretch,
            "fill" => Mode::Fill,
            "fit" => Mode::Fit,
            "center" => Mode::Center,
            "tile" => Mode::Tile,
            _ => return None,
        })
    }
}

/// One weighted pixel of the visible screen.
#[derive(Clone, Copy, Debug)]
pub struct Sample {
    pub lab: Lab,
    pub weight: f64,
}

/// The wallpaper reduced to at most `MAX_SIDE` pixels a side, with a summed
/// area table so any rectangle's mean colour costs four lookups.
pub struct Picture {
    pub width: usize,
    pub height: usize,
    /// How many original pixels one reduced pixel spans.
    pub factor: f64,
    /// Premultiplied linear RGB and alpha.
    sums: Vec<[f64; 4]>,
}

const MAX_SIDE: usize = 1024;

impl Picture {
    pub fn open(path: &Path) -> Result<Picture, String> {
        let img = image::ImageReader::open(path)
            .map_err(|e| format!("{}: {e}", path.display()))?
            .with_guessed_format()
            .map_err(|e| format!("{}: {e}", path.display()))?
            .decode()
            .map_err(|e| format!("{}: {e}", path.display()))?
            .into_rgba8();
        let (w, h) = (img.width() as usize, img.height() as usize);
        if w == 0 || h == 0 {
            return Err(format!("{}: empty image", path.display()));
        }

        // Box-reduce in linear light, premultiplied: swaybg paints the image
        // over its fallback colour, so alpha has to survive to the end.
        let step = w.max(h).div_ceil(MAX_SIDE).max(1);
        let (rw, rh) = (w.div_ceil(step), h.div_ceil(step));
        let lut: Vec<f64> = (0..256).map(|v| srgb_to_linear(v as f64 / 255.0)).collect();
        let mut reduced = vec![[0.0f64; 4]; rw * rh];
        let mut counts = vec![0u32; rw * rh];
        for (x, y, px) in img.enumerate_pixels() {
            let i = (y as usize / step) * rw + x as usize / step;
            let alpha = px[3] as f64 / 255.0;
            for c in 0..3 {
                reduced[i][c] += lut[px[c] as usize] * alpha;
            }
            reduced[i][3] += alpha;
            counts[i] += 1;
        }
        for (px, n) in reduced.iter_mut().zip(&counts) {
            for c in px.iter_mut() {
                *c /= *n as f64;
            }
        }

        let mut sums = vec![[0.0f64; 4]; (rw + 1) * (rh + 1)];
        for y in 0..rh {
            for x in 0..rw {
                let here = reduced[y * rw + x];
                let up = sums[y * (rw + 1) + x + 1];
                let left = sums[(y + 1) * (rw + 1) + x];
                let diag = sums[y * (rw + 1) + x];
                sums[(y + 1) * (rw + 1) + x + 1] =
                    std::array::from_fn(|c| here[c] + up[c] + left[c] - diag[c]);
            }
        }
        Ok(Picture { width: w, height: h, factor: step as f64, sums })
    }

    fn reduced(&self) -> (usize, usize) {
        let w = (self.width as f64 / self.factor).ceil() as usize;
        let h = (self.height as f64 / self.factor).ceil() as usize;
        (w, h)
    }

    /// Mean premultiplied colour over a rectangle in original image pixels,
    /// clamped to the image, with the share of the rectangle that lies on it;
    /// None when it misses the image entirely.
    fn mean(&self, x0: f64, y0: f64, x1: f64, y1: f64) -> Option<([f64; 4], f64)> {
        let (rw, rh) = self.reduced();
        let f = self.factor;
        let cx0 = (x0 / f).floor().clamp(0.0, rw as f64) as usize;
        let cy0 = (y0 / f).floor().clamp(0.0, rh as f64) as usize;
        let mut cx1 = (x1 / f).ceil().clamp(0.0, rw as f64) as usize;
        let mut cy1 = (y1 / f).ceil().clamp(0.0, rh as f64) as usize;
        if x1 <= 0.0 || y1 <= 0.0 || x0 >= self.width as f64 || y0 >= self.height as f64 {
            return None;
        }
        if cx1 <= cx0 {
            cx1 = (cx0 + 1).min(rw);
        }
        if cy1 <= cy0 {
            cy1 = (cy0 + 1).min(rh);
        }
        let at = |x: usize, y: usize| self.sums[y * (rw + 1) + x];
        let (a, b, c, d) = (at(cx1, cy1), at(cx0, cy1), at(cx1, cy0), at(cx0, cy0));
        let n = ((cx1 - cx0) * (cy1 - cy0)) as f64;
        let rgb = std::array::from_fn(|i| (a[i] - b[i] - c[i] + d[i]) / n);
        // Share of the asked-for rectangle that lies on the image.
        let ix = (x1.min(self.width as f64) - x0.max(0.0)).max(0.0);
        let iy = (y1.min(self.height as f64) - y0.max(0.0)).max(0.0);
        let cover = (ix * iy) / ((x1 - x0) * (y1 - y0)).max(1e-9);
        Some((rgb, cover.clamp(0.0, 1.0)))
    }
}

/// How one output shows its background.
pub enum Layer<'a> {
    Image { picture: &'a Picture, mode: Mode, fallback: Rgb },
    Solid(Rgb),
}

/// The visible screen of one output, `width`x`height` buffer pixels, as a
/// grid of samples whose weights sum to `share`.
pub fn sample(layer: &Layer, width: f64, height: f64, share: f64) -> Vec<Sample> {
    const GRID: f64 = 160.0;
    let (gw, gh) = if width >= height {
        (GRID, (GRID * height / width).round().max(1.0))
    } else {
        ((GRID * width / height).round().max(1.0), GRID)
    };
    let (gw, gh) = (gw as usize, gh as usize);
    let weight = share / (gw * gh) as f64;

    let (picture, mode, fallback) = match layer {
        Layer::Solid(rgb) => {
            return vec![Sample { lab: rgb.lab(), weight: share }];
        }
        Layer::Image { picture, mode, fallback } => (*picture, *mode, *fallback),
    };
    let (iw, ih) = (picture.width as f64, picture.height as f64);
    let fallback = fallback.linear();

    // Buffer pixel -> image pixel, as cairo does it in background-image.c.
    let (scale_x, scale_y, off_x, off_y) = match mode {
        Mode::Stretch => (width / iw, height / ih, 0.0, 0.0),
        Mode::Fill | Mode::Fit => {
            let wide = width / height > iw / ih;
            let s = if wide == (mode == Mode::Fill) { width / iw } else { height / ih };
            (s, s, (width - iw * s) / 2.0, (height - ih * s) / 2.0)
        }
        Mode::Center => (1.0, 1.0, (width - iw) / 2.0, (height - ih) / 2.0),
        Mode::Tile => (1.0, 1.0, 0.0, 0.0),
    };

    let (cw, ch) = (width / gw as f64, height / gh as f64);
    let mut out = Vec::with_capacity(gw * gh);
    for gy in 0..gh {
        for gx in 0..gw {
            let (bx0, by0) = (gx as f64 * cw, gy as f64 * ch);
            let (mut x0, mut y0) = ((bx0 - off_x) / scale_x, (by0 - off_y) / scale_y);
            let (mut x1, mut y1) = (x0 + cw / scale_x, y0 + ch / scale_y);
            if mode == Mode::Tile {
                // The cell is far smaller than a tile; fold its corner in.
                let (fx, fy) = (x0.rem_euclid(iw), y0.rem_euclid(ih));
                (x1, y1) = ((fx + x1 - x0).min(iw), (fy + y1 - y0).min(ih));
                (x0, y0) = (fx, fy);
            }
            let rgb = match picture.mean(x0, y0, x1, y1) {
                Some((rgba, cover)) => {
                    let opaque = rgba[3] * cover;
                    std::array::from_fn(|i| rgba[i] * cover + fallback[i] * (1.0 - opaque))
                }
                None => fallback,
            };
            out.push(Sample { lab: linear_to_oklab(rgb), weight });
        }
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    fn two_tone(dir: &Path) -> std::path::PathBuf {
        // Left half red, right half blue, 400x100.
        let mut img = image::RgbImage::new(400, 100);
        for (x, _, px) in img.enumerate_pixels_mut() {
            *px = if x < 200 { image::Rgb([255, 0, 0]) } else { image::Rgb([0, 0, 255]) };
        }
        let path = dir.join("two-tone.png");
        img.save(&path).unwrap();
        path
    }

    fn red_share(samples: &[Sample]) -> f64 {
        let red = Rgb([255, 0, 0]).lab();
        let total: f64 = samples.iter().map(|s| s.weight).sum();
        samples.iter().filter(|s| s.lab.distance(red) < 0.05).map(|s| s.weight).sum::<f64>() / total
    }

    #[test]
    fn fill_crops_the_sides() {
        let dir = std::env::temp_dir().join("orchard-wallpaper-test-fill");
        std::fs::create_dir_all(&dir).unwrap();
        let picture = Picture::open(&two_tone(&dir)).unwrap();
        let fallback = Rgb([0, 0, 0]);
        // A square screen sees only the middle 100 columns: half red, half blue.
        let fill = sample(&Layer::Image { picture: &picture, mode: Mode::Fill, fallback }, 100.0, 100.0, 1.0);
        assert!((red_share(&fill) - 0.5).abs() < 0.02);
        // A screen shifted to show more of one side would not; center on a
        // 100-wide screen shows only the seam region too.
        let center = sample(&Layer::Image { picture: &picture, mode: Mode::Center, fallback }, 100.0, 100.0, 1.0);
        assert!((red_share(&center) - 0.5).abs() < 0.02);
        // Fit on a square screen letterboxes: the image takes a quarter of the height.
        let fit = sample(&Layer::Image { picture: &picture, mode: Mode::Fit, fallback }, 100.0, 100.0, 1.0);
        assert!((red_share(&fit) - 0.125).abs() < 0.03);
    }
}
