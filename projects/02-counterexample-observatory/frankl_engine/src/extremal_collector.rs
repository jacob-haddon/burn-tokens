use crate::closure_generator::{
    dualize_moore_to_union_closed, evaluate_frankl_union_mask, intersection_closure,
    precompute_element_masks,
};
use crate::family::{BitSet, Family};
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::collections::HashSet;
use std::sync::Mutex;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtremalRecord {
    pub ground_set_size: usize,
    pub family_size: usize,
    pub max_degree: usize,
    pub frankl_ratio: f64,
    pub is_separating: bool,
    pub element_degrees: Vec<usize>,
    pub member_sets: Vec<BitSet>,
    pub minimal_basis: Vec<BitSet>,
}

/// Collect all non-isomorphic extremal families (rho = 1/2) for ground set size m <= 5.
pub fn collect_non_isomorphic_extremal_families(m: usize) -> Vec<ExtremalRecord> {
    let n_subsets = 1 << m;
    let elem_masks = precompute_element_masks(m);
    let initial_closure = intersection_closure(0, m);

    let extremal_masks = Mutex::new(Vec::new());

    let mut first_level_children = Vec::new();
    for i in 0..n_subsets {
        if (initial_closure & (1 << i)) == 0 {
            let next_cand = initial_closure | (1 << i);
            let next_closed = intersection_closure(next_cand, m);
            let diff = next_closed & !initial_closure;
            let prefix_mask = (1 << i) - 1;
            if (diff & prefix_mask) == 0 {
                first_level_children.push((next_closed, i));
            }
        }
    }

    // Process root
    check_and_add_extremal(initial_closure, m, &elem_masks, &extremal_masks);

    // Parallel search
    first_level_children.par_iter().for_each(|&(child_mask, last_i)| {
        dfs_extremal_collector(
            child_mask,
            last_i,
            m,
            n_subsets,
            &elem_masks,
            &extremal_masks,
        );
    });

    let raw_masks = extremal_masks.into_inner().unwrap();

    // Deduplicate up to S_m isomorphism
    let mut seen_canonicals = HashSet::new();
    let mut unique_records = Vec::new();

    for union_mask in raw_masks {
        let mut sets = Vec::new();
        for s in 0..n_subsets {
            if (union_mask & (1 << s)) != 0 {
                sets.push(s as BitSet);
            }
        }
        let fam = Family::new(m, sets);
        let canonical = fam.canonical_form();
        if seen_canonicals.insert(canonical) {
            let (max_deg, _) = fam.max_degree();
            let basis = find_minimal_union_basis(&fam);
            unique_records.push(ExtremalRecord {
                ground_set_size: m,
                family_size: fam.sets.len(),
                max_degree: max_deg,
                frankl_ratio: fam.frankl_ratio(),
                is_separating: fam.is_separating(),
                element_degrees: fam.element_degrees(),
                member_sets: fam.sets.clone(),
                minimal_basis: basis,
            });
        }
    }

    unique_records.sort_by_key(|r| (r.family_size, r.member_sets.clone()));
    unique_records
}

fn dfs_extremal_collector(
    current_closed: u32,
    last_i: usize,
    m: usize,
    n_subsets: usize,
    elem_masks: &[u32],
    extremal_masks: &Mutex<Vec<u32>>,
) {
    check_and_add_extremal(current_closed, m, elem_masks, extremal_masks);

    for i in (last_i + 1)..n_subsets {
        if (current_closed & (1 << i)) == 0 {
            let next_cand = current_closed | (1 << i);
            let next_closed = intersection_closure(next_cand, m);
            let diff = next_closed & !current_closed;
            let prefix_mask = (1 << i) - 1;
            if (diff & prefix_mask) == 0 {
                dfs_extremal_collector(
                    next_closed,
                    i,
                    m,
                    n_subsets,
                    elem_masks,
                    extremal_masks,
                );
            }
        }
    }
}

#[inline(always)]
fn check_and_add_extremal(
    moore_mask: u32,
    m: usize,
    elem_masks: &[u32],
    extremal_masks: &Mutex<Vec<u32>>,
) {
    let union_mask = dualize_moore_to_union_closed(moore_mask, m);
    let (_, size, _, is_extremal) = evaluate_frankl_union_mask(union_mask, m, elem_masks);
    if size >= 2 && is_extremal {
        extremal_masks.lock().unwrap().push(union_mask);
    }
}

/// Find minimal basis of union-irreducible elements (excluding empty set) that generates the family.
pub fn find_minimal_union_basis(fam: &Family) -> Vec<BitSet> {
    let mut basis = Vec::new();
    for &s in &fam.sets {
        if s == 0 {
            continue;
        }
        // Check if s is union of two strictly smaller sets in fam
        let mut is_irreducible = true;
        for &a in &fam.sets {
            if a == 0 || a == s || (a & !s) != 0 {
                continue;
            }
            for &b in &fam.sets {
                if b == 0 || b == s || (b & !s) != 0 {
                    continue;
                }
                if (a | b) == s {
                    is_irreducible = false;
                    break;
                }
            }
            if !is_irreducible {
                break;
            }
        }
        if is_irreducible {
            basis.push(s);
        }
    }
    basis
}
