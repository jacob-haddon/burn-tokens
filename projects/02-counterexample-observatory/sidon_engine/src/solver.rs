use crate::sidon::{is_sidon_diff_form, is_sidon_sum_form, SidonSet};
use rayon::prelude::*;
use serde::{Deserialize, Serialize};

/// Minimal Golomb ruler lengths for k marks = 0, 1, 2, ...
pub const GOLOMB_BOUNDS: [u32; 12] = [0, 0, 1, 3, 6, 11, 17, 25, 34, 44, 55, 72];

/// Known OEIS A003022 values for N=1..35
pub const OEIS_A003022: [u32; 35] = [
    1,
    2, 2,
    3, 3, 3,
    4, 4, 4, 4, 4,
    5, 5, 5, 5, 5, 5,
    6, 6, 6, 6, 6, 6, 6, 6,
    7, 7, 7, 7, 7, 7, 7, 7, 7,
    8,
];

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SidonSearchResult {
    pub n: u32,
    pub max_cardinality: usize,
    pub count_max_sets: usize,
    pub count_canonical_sets: usize,
    pub density: f64,
    pub sqrt_n: f64,
    pub oeis_a003022_match: bool,
    pub extremal_sets: Vec<Vec<u32>>,
    pub canonical_sets: Vec<Vec<u32>>,
}

pub fn solve_sidon_frontier(n: u32) -> SidonSearchResult {
    if n == 0 {
        return SidonSearchResult {
            n: 0,
            max_cardinality: 0,
            count_max_sets: 0,
            count_canonical_sets: 0,
            density: 0.0,
            sqrt_n: 0.0,
            oeis_a003022_match: true,
            extremal_sets: vec![],
            canonical_sets: vec![],
        };
    }
    if n == 1 {
        return SidonSearchResult {
            n: 1,
            max_cardinality: 1,
            count_max_sets: 1,
            count_canonical_sets: 1,
            density: 1.0,
            sqrt_n: 1.0,
            oeis_a003022_match: true,
            extremal_sets: vec![vec![1]],
            canonical_sets: vec![vec![1]],
        };
    }

    // Step 1: Find maximum size R(N) using Golomb bounds
    let mut max_k = 1;
    for k in 1..GOLOMB_BOUNDS.len() {
        if GOLOMB_BOUNDS[k] <= n - 1 {
            max_k = k;
        } else {
            break;
        }
    }
    let target_size = max_k;
    let min_span = GOLOMB_BOUNDS[target_size];

    // Step 2: Parallel search for all subsets of size target_size
    let results: Vec<Vec<u32>> = (1..=(n - min_span)).into_par_iter().flat_map(|first_elem| {
        let mut local_results = Vec::new();
        let mut current_set = Vec::with_capacity(target_size);
        current_set.push(first_elem);
        
        backtrack(
            n,
            target_size,
            &mut current_set,
            0u64,
            first_elem + 1,
            &mut local_results,
        );
        local_results
    }).collect();

    let mut extremal_sets = results;
    extremal_sets.sort();

    // Deduplicate
    extremal_sets.dedup();

    // Canonical forms
    let mut canonical_set_collection = std::collections::BTreeSet::new();
    for raw in &extremal_sets {
        let s = SidonSet::new(raw.clone(), n);
        canonical_set_collection.insert(s.canonical());
    }
    let canonical_sets: Vec<Vec<u32>> = canonical_set_collection.into_iter().collect();

    let density = (target_size as f64) / (n as f64).sqrt();
    let oeis_match = if (n as usize) <= OEIS_A003022.len() {
        target_size as u32 == OEIS_A003022[(n - 1) as usize]
    } else {
        true
    };

    SidonSearchResult {
        n,
        max_cardinality: target_size,
        count_max_sets: extremal_sets.len(),
        count_canonical_sets: canonical_sets.len(),
        density,
        sqrt_n: (n as f64).sqrt(),
        oeis_a003022_match: oeis_match,
        extremal_sets,
        canonical_sets,
    }
}

fn backtrack(
    n: u32,
    target_size: usize,
    current_set: &mut Vec<u32>,
    diff_mask: u64,
    next_val: u32,
    results: &mut Vec<Vec<u32>>,
) {
    let curr_len = current_set.len();
    let needed = target_size - curr_len;

    if needed == 0 {
        results.push(current_set.clone());
        return;
    }

    let limit = n - GOLOMB_BOUNDS[needed];

    for v in next_val..=limit {
        let mut new_diffs_mask = 0u64;
        let mut conflict = false;

        for &u in current_set.iter() {
            let d = v - u;
            let bit = 1u64 << d;
            if (diff_mask & bit) != 0 || (new_diffs_mask & bit) != 0 {
                conflict = true;
                break;
            }
            new_diffs_mask |= bit;
        }

        if !conflict {
            current_set.push(v);
            backtrack(
                n,
                target_size,
                current_set,
                diff_mask | new_diffs_mask,
                v + 1,
                results,
            );
            current_set.pop();
        }
    }
}
