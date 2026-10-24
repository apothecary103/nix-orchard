//! What the scheme needs to know about the visible screen: how light it is,
//! which way its greys lean at each lightness, how vivid it is, and which
//! colour it is about.

use crate::colour::{Lab, Lch, gaussian, hue_delta, smoothstep, toe};
use crate::sample::Sample;

pub struct Analysis {
    /// Weighted percentiles of toe lightness, by tenths (p0, p10 … p100).
    pub lightness: [f64; 11],
    /// Mean (a, b) of the pixels near each `TINT_ANCHORS` lightness.
    pub tint: [(f64, f64); TINT_ANCHORS.len()],
    /// Chroma of the screen as a whole, the 80th percentile.
    pub vividness: f64,
    /// Length of the mean (a, b): how far the screen leans one way overall.
    pub cast: f64,
    pub clusters: Vec<Cluster>,
}

#[derive(Clone, Copy, Debug)]
pub struct Cluster {
    pub lab: Lab,
    /// Share of the screen, 0..1.
    pub share: f64,
}

/// Toe lightnesses the neutral ramp reads its tint from.
pub const TINT_ANCHORS: [f64; 5] = [0.1, 0.3, 0.5, 0.7, 0.9];

pub fn analyse(samples: &[Sample]) -> Analysis {
    let total: f64 = samples.iter().map(|s| s.weight).sum::<f64>().max(1e-12);

    let lightness = percentiles(samples.iter().map(|s| (toe(s.lab.l), s.weight)).collect());
    let chroma = percentiles(samples.iter().map(|s| (s.lab.lch().c, s.weight)).collect());

    let (ga, gb) = samples.iter().fold((0.0, 0.0), |(a, b), s| (a + s.lab.a * s.weight, b + s.lab.b * s.weight));
    let global = (ga / total, gb / total);

    // Each band borrows the lean of the pixels near its lightness; a band
    // the picture barely has leans on the whole picture instead.
    let tint = TINT_ANCHORS.map(|anchor| {
        let (mut a, mut b, mut mass) = (0.0, 0.0, 0.0);
        for s in samples {
            let w = s.weight * gaussian(toe(s.lab.l) - anchor, 0.12);
            a += s.lab.a * w;
            b += s.lab.b * w;
            mass += w;
        }
        let prior = 0.08 * total;
        ((a + global.0 * prior) / (mass + prior), (b + global.1 * prior) / (mass + prior))
    });

    Analysis {
        lightness,
        tint,
        vividness: chroma[8],
        cast: global.0.hypot(global.1),
        clusters: cluster(samples, total),
    }
}

fn percentiles(mut values: Vec<(f64, f64)>) -> [f64; 11] {
    values.sort_by(|x, y| x.0.total_cmp(&y.0));
    let total: f64 = values.iter().map(|v| v.1).sum();
    let mut out = [0.0; 11];
    let (mut seen, mut i) = (0.0, 0);
    for (k, slot) in out.iter_mut().enumerate() {
        let want = total * k as f64 / 10.0;
        while i + 1 < values.len() && seen + values[i].1 < want {
            seen += values[i].1;
            i += 1;
        }
        *slot = values.get(i).map_or(0.0, |v| v.0);
    }
    out
}

/// Weighted k-means in OKLab over a coarse histogram, seeded deterministically
/// by farthest-point from the heaviest bin, so a wallpaper always gives the
/// same scheme.
fn cluster(samples: &[Sample], total: f64) -> Vec<Cluster> {
    use std::collections::HashMap;

    // 0.01 bins are below a just-noticeable difference (0.02) in OKLab.
    let mut bins: HashMap<(i32, i32, i32), (Lab, f64)> = HashMap::new();
    for s in samples {
        let key = ((s.lab.l * 100.0) as i32, (s.lab.a * 100.0) as i32, (s.lab.b * 100.0) as i32);
        let e = bins.entry(key).or_insert((Lab { l: 0.0, a: 0.0, b: 0.0 }, 0.0));
        e.0.l += s.lab.l * s.weight;
        e.0.a += s.lab.a * s.weight;
        e.0.b += s.lab.b * s.weight;
        e.1 += s.weight;
    }
    let mut points: Vec<(Lab, f64)> = bins
        .into_values()
        .map(|(sum, w)| (Lab { l: sum.l / w, a: sum.a / w, b: sum.b / w }, w))
        .collect();
    points.sort_by(|x, y| y.1.total_cmp(&x.1).then(x.0.l.total_cmp(&y.0.l)));
    if points.is_empty() {
        return Vec::new();
    }

    const K: usize = 16;
    let mut centres = vec![points[0].0];
    while centres.len() < K.min(points.len()) {
        // Weight distance by population a little, so seeds land on real areas.
        let next = points
            .iter()
            .map(|(p, w)| {
                let d = centres.iter().map(|c| c.distance(*p)).fold(f64::MAX, f64::min);
                (d * d * w.powf(0.25), *p)
            })
            .max_by(|x, y| x.0.total_cmp(&y.0))
            .unwrap();
        if next.0 <= 0.0 {
            break;
        }
        centres.push(next.1);
    }

    let mut assign = vec![0usize; points.len()];
    for _ in 0..24 {
        for (i, (p, _)) in points.iter().enumerate() {
            assign[i] = (0..centres.len())
                .min_by(|&x, &y| centres[x].distance(*p).total_cmp(&centres[y].distance(*p)))
                .unwrap();
        }
        let mut moved = 0.0f64;
        for (k, centre) in centres.iter_mut().enumerate() {
            let (mut sum, mut w) = (Lab { l: 0.0, a: 0.0, b: 0.0 }, 0.0);
            for (i, (p, pw)) in points.iter().enumerate() {
                if assign[i] == k {
                    sum.l += p.l * pw;
                    sum.a += p.a * pw;
                    sum.b += p.b * pw;
                    w += pw;
                }
            }
            if w > 0.0 {
                let new = Lab { l: sum.l / w, a: sum.a / w, b: sum.b / w };
                moved = moved.max(new.distance(*centre));
                *centre = new;
            }
        }
        if moved < 1e-4 {
            break;
        }
    }

    let mut out: Vec<Cluster> = centres
        .iter()
        .enumerate()
        .map(|(k, c)| Cluster {
            lab: *c,
            share: points.iter().zip(&assign).filter(|(_, a)| **a == k).map(|(p, _)| p.1).sum::<f64>() / total,
        })
        .filter(|c| c.share > 0.0)
        .collect();
    out.sort_by(|x, y| y.share.total_cmp(&x.share));
    out
}

/// The wallpaper's own colour, in the spirit of material-color-utilities'
/// Score: a hue wins by how much of the screen sits near it and by how
/// vivid it is, and never from a sliver or a near-grey.
pub fn accent(clusters: &[Cluster]) -> Option<Lch> {
    let chromatic: Vec<(Lch, f64)> = clusters
        .iter()
        .map(|c| (c.lab.lch(), c.share))
        // Hue means nothing in near-greys, near-black or blown highlights.
        .filter(|(lch, _)| lch.c >= 0.035 && (0.12..=0.97).contains(&toe(lch.l)))
        .collect();

    chromatic
        .iter()
        .filter_map(|(lch, share)| {
            // Area counts by how coloured it is: pale washes and skin tones
            // (C 0.04-0.06) cover a lot of many pictures without being what
            // the picture is about.
            let near: f64 = chromatic
                .iter()
                .filter(|(other, _)| hue_delta(lch.h, other.h).abs() <= 15.0)
                .map(|(other, s)| s * smoothstep(0.03, 0.1, other.c))
                .sum();
            if near < 0.01 || *share < 0.004 {
                return None;
            }
            // Material's (C - 48) * (0.1 | 0.3) in CAM16 units, as OKLCH.
            let vivid = if lch.c < 0.12 { (lch.c - 0.12) * 40.0 } else { (lch.c - 0.12) * 120.0 };
            // Mid-tones carry hue best; shadows and pastels are quieter evidence.
            let tone = 0.6 + 0.4 * smoothstep(0.15, 0.4, toe(lch.l)) * (1.0 - smoothstep(0.85, 0.97, toe(lch.l)));
            Some((70.0 * near * tone + vivid, *lch))
        })
        .max_by(|x, y| x.0.total_cmp(&y.0))
        .map(|(_, lch)| lch)
}
