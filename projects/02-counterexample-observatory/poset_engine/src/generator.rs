use crate::poset::Poset;
use rayon::prelude::*;
use std::collections::HashMap;

/// Generate all non-isomorphic posets on `n` elements.
/// Uses canonical augmentation and invariant-guided canonical deduplication.
pub fn generate_all_posets_up_to(max_n: usize) -> Vec<Vec<Poset>> {
    let mut levels: Vec<Vec<Poset>> = Vec::with_capacity(max_n + 1);
    levels.push(Vec::new()); // n = 0

    if max_n == 0 {
        return levels;
    }

    // n = 1: single poset with 1 element and no relations
    let p1 = Poset::new(1);
    levels.push(vec![p1]);

    for k in 1..max_n {
        let current_level = &levels[k];

        // Parallel generation of (k+1)-element posets from k-element posets
        let next_posets: Vec<Poset> = current_level
            .par_iter()
            .flat_map(|pk| {
                let mut candidates = Vec::new();
                let ideals = pk.order_ideals();

                // Compute up-sets of pk
                // A bitmask U is an up-set if for all x in U and x < y, y is in U
                let max_mask = 1 << k;
                let mut upsets = Vec::new();
                for mask in 0..max_mask {
                    let mut is_upset = true;
                    for v in 0..k {
                        if (mask & (1 << v)) != 0 {
                            if (pk.less_than[v] & !mask) != 0 {
                                is_upset = false;
                                break;
                            }
                        }
                    }
                    if is_upset {
                        upsets.push(mask as u16);
                    }
                }

                // For each down-set L and up-set U:
                for &l_mask in &ideals {
                    for &u_mask in &upsets {
                        // Check compatibility: L and U must be disjoint, and L x U must be in <_pk
                        if (l_mask & u_mask) != 0 {
                            continue;
                        }

                        let mut valid = true;
                        for x in 0..k {
                            if (l_mask & (1 << x)) != 0 {
                                // Every y in U must satisfy x < y
                                if (u_mask & !pk.less_than[x]) != 0 {
                                    valid = false;
                                    break;
                                }
                            }
                        }

                        if !valid {
                            continue;
                        }

                        // Construct new poset on k + 1 elements
                        let mut next_p = Poset::new(k + 1);
                        // Copy existing relations
                        for i in 0..k {
                            for j in 0..k {
                                if pk.is_less(i, j) {
                                    next_p.less_than[i] |= 1 << j;
                                    next_p.greater_than[j] |= 1 << i;
                                }
                            }
                        }
                        // Add element k: predecessors are L, successors are U
                        for x in 0..k {
                            if (l_mask & (1 << x)) != 0 {
                                next_p.less_than[x] |= 1 << k;
                                next_p.greater_than[k] |= 1 << x;
                            }
                            if (u_mask & (1 << x)) != 0 {
                                next_p.less_than[k] |= 1 << x;
                                next_p.greater_than[x] |= 1 << k;
                            }
                        }

                        // Compute canonical form
                        let (canon_p, _) = next_p.canonical_form();
                        candidates.push(canon_p);
                    }
                }

                candidates
            })
            .collect();

        // Deduplicate canonically across all generated candidates
        let mut map: HashMap<(u64, u64, u64, u64), Poset> = HashMap::new();
        for p in next_posets {
            let code = p.adjacency_code();
            map.entry(code).or_insert(p);
        }

        let mut deduped: Vec<Poset> = map.into_values().collect();
        // Sort stably by canonical code
        deduped.sort_by_key(|p| p.adjacency_code());

        levels.push(deduped);
    }

    levels
}
