use serde::{Deserialize, Serialize};
use std::collections::BTreeSet;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TripleAnalysis {
    pub set_a: Vec<i64>,
    pub set_b: Vec<i64>,
    pub set_c: Vec<i64>,
    pub card_a: usize,
    pub card_b: usize,
    pub card_c: usize,
    pub card_diff_ab: usize,
    pub card_diff_ac: usize,
    pub card_diff_bc: usize,
    pub lhs: u64, // |A| * |B - C|
    pub rhs: u64, // |A - B| * |A - C|
    pub ratio: f64,
    pub is_valid_inequality: bool,
    pub dist_ab: f64,
    pub dist_ac: f64,
    pub dist_bc: f64,
    pub triangle_slack: f64, // d(A,B) + d(A,C) - d(B,C) >= 0
}

pub fn difference_set(x: &[i64], y: &[i64]) -> Vec<i64> {
    let mut diff = BTreeSet::new();
    for &a in x {
        for &b in y {
            diff.insert(a - b);
        }
    }
    diff.into_iter().collect()
}

pub fn ruzsa_distance(x: &[i64], y: &[i64]) -> f64 {
    let diff_sz = difference_set(x, y).len() as f64;
    let denom = ((x.len() * y.len()) as f64).sqrt();
    (diff_sz / denom).ln()
}

pub fn analyze_triple(a: &[i64], b: &[i64], c: &[i64]) -> TripleAnalysis {
    let mut sa = a.to_vec();
    sa.sort_unstable();
    sa.dedup();

    let mut sb = b.to_vec();
    sb.sort_unstable();
    sb.dedup();

    let mut sc = c.to_vec();
    sc.sort_unstable();
    sc.dedup();

    let diff_ab = difference_set(&sa, &sb);
    let diff_ac = difference_set(&sa, &sc);
    let diff_bc = difference_set(&sb, &sc);

    let na = sa.len() as u64;
    let nb = sb.len() as u64;
    let nc = sc.len() as u64;

    let nab = diff_ab.len() as u64;
    let nac = diff_ac.len() as u64;
    let nbc = diff_bc.len() as u64;

    let lhs = na * nbc;
    let rhs = nab * nac;

    let ratio = if rhs > 0 { (lhs as f64) / (rhs as f64) } else { 0.0 };
    let is_valid = lhs <= rhs;

    let d_ab = ruzsa_distance(&sa, &sb);
    let d_ac = ruzsa_distance(&sa, &sc);
    let d_bc = ruzsa_distance(&sb, &sc);
    let slack = d_ab + d_ac - d_bc;

    TripleAnalysis {
        set_a: sa,
        set_b: sb,
        set_c: sc,
        card_a: na as usize,
        card_b: nb as usize,
        card_c: nc as usize,
        card_diff_ab: nab as usize,
        card_diff_ac: nac as usize,
        card_diff_bc: nbc as usize,
        lhs,
        rhs,
        ratio,
        is_valid_inequality: is_valid,
        dist_ab: d_ab,
        dist_ac: d_ac,
        dist_bc: d_bc,
        triangle_slack: slack,
    }
}
