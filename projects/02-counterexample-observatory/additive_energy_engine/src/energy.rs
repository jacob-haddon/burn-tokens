use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct WitnessSet {
    pub energy: usize,
    pub set: Vec<i64>,
    pub sumset_size: usize,
    pub cauchy_schwarz_lower_bound: f64,
    pub energy_ratio_e_over_k3: f64,
    pub set_type: String, // e.g. "arithmetic_progression", "sidon_set", "intermediate"
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct OrderLevelReport {
    pub k: usize,
    pub theoretical_min_energy: usize,
    pub theoretical_max_energy: usize,
    pub min_energy_observed: usize,
    pub max_energy_observed: usize,
    pub bounds_exact_match: bool,
    pub distinct_realizable_energies_found: usize,
    pub realizable_energies: Vec<usize>,
    pub min_witness: WitnessSet,
    pub max_witness: WitnessSet,
    pub sample_witnesses: Vec<WitnessSet>,
    pub elapsed_ms: u128,
}

/// Compute additive energy E(A) = sum_{s} r_{A+A}(s)^2
pub fn compute_additive_energy(set: &[i64]) -> usize {
    let mut sum_counts: BTreeMap<i64, usize> = BTreeMap::new();
    for &x in set {
        for &y in set {
            *sum_counts.entry(x + y).or_insert(0) += 1;
        }
    }
    sum_counts.values().map(|&c| c * c).sum()
}

/// Compute sumset size |A+A|
pub fn compute_sumset_size(set: &[i64]) -> usize {
    let mut sums = BTreeSet::new();
    for &x in set {
        for &y in set {
            sums.insert(x + y);
        }
    }
    sums.len()
}

/// Directly count quadruples (a, b, c, d) in A^4 with a + b == c + d
pub fn count_additive_quadruples(set: &[i64]) -> usize {
    let mut count = 0;
    for &a in set {
        for &b in set {
            for &c in set {
                for &d in set {
                    if a + b == c + d {
                        count += 1;
                    }
                }
            }
        }
    }
    count
}

/// Theoretical minimum additive energy for a k-element set: 2k^2 - k
pub fn theoretical_min_energy(k: usize) -> usize {
    2 * k * k - k
}

/// Theoretical maximum additive energy for a k-element set: (2k^3 + k) / 3
pub fn theoretical_max_energy(k: usize) -> usize {
    (2 * k * k * k + k) / 3
}

/// Build arithmetic progression of length k: {0, 1, ..., k-1}
pub fn make_arithmetic_progression(k: usize) -> Vec<i64> {
    (0..k as i64).collect()
}

/// Build dissociated / Sidon set (powers of 2): {1, 2, 4, ..., 2^(k-1)}
pub fn make_dissociated_set(k: usize) -> Vec<i64> {
    (0..k).map(|i| 1i64 << i).collect()
}
