use crate::poset::Poset;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PairStats {
    pub u: usize,
    pub v: usize,
    pub e_u_less_v: u64,
    pub e_v_less_u: u64,
    pub total: u64,
    pub is_incomparable: bool,
}

impl PairStats {
    /// Return the balance ratio min(e(u<v), e(v<u)) / total as (numerator, denominator)
    #[allow(dead_code)]
    pub fn balance_ratio(&self) -> (u64, u64) {
        let min_count = self.e_u_less_v.min(self.e_v_less_u);
        (min_count, self.total)
    }

    /// Check if the pair is 1/3-2/3 balanced: e(P) <= 3 * min(e(u<v), e(v<u))
    #[allow(dead_code)]
    pub fn is_balanced_1_3(&self) -> bool {
        let min_count = self.e_u_less_v.min(self.e_v_less_u);
        3 * min_count >= self.total
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PosetExtensionStats {
    pub n: usize,
    pub total_extensions: u64,
    pub num_incomparable_pairs: usize,
    pub pair_stats: Vec<PairStats>,
}

/// Compute exact linear extensions and pair extension counts via Dynamic Programming over the order ideal lattice.
pub fn compute_extension_stats_dp(poset: &Poset) -> PosetExtensionStats {
    let n = poset.n;
    if n == 0 {
        return PosetExtensionStats {
            n: 0,
            total_extensions: 1,
            num_incomparable_pairs: 0,
            pair_stats: Vec::new(),
        };
    }

    let ideals = poset.order_ideals();
    let num_ideals = ideals.len();
    let full_mask = (1 << n) - 1;

    // Map ideal bitmask to index in lookup table (up to 1 << 16 = 65536)
    let mut mask_to_idx = vec![usize::MAX; 1 << n];
    for (i, &mask) in ideals.iter().enumerate() {
        mask_to_idx[mask as usize] = i;
    }

    // Sort ideals by size (popcount)
    let mut ideals_by_size = ideals.clone();
    ideals_by_size.sort_by_key(|&mask| mask.count_ones());

    // N_prefix[idx]: number of linear extensions of ideal mask
    let mut n_prefix = vec![0u64; num_ideals];
    let empty_idx = mask_to_idx[0];
    n_prefix[empty_idx] = 1;

    for &mask in &ideals_by_size {
        if mask == 0 {
            continue;
        }
        let cur_idx = mask_to_idx[mask as usize];
        let max_elements = poset.maximal_in_ideal(mask);
        let mut sum = 0u64;
        for v in 0..n {
            if (max_elements & (1 << v)) != 0 {
                let prev_mask = mask ^ (1 << v);
                let prev_idx = mask_to_idx[prev_mask as usize];
                sum += n_prefix[prev_idx];
            }
        }
        n_prefix[cur_idx] = sum;
    }

    // N_suffix[idx]: number of linear extensions of complement V \ ideal mask
    let mut n_suffix = vec![0u64; num_ideals];
    let full_idx = mask_to_idx[full_mask as usize];
    n_suffix[full_idx] = 1;

    for &mask in ideals_by_size.iter().rev() {
        if mask == full_mask as u16 {
            continue;
        }
        let cur_idx = mask_to_idx[mask as usize];
        let min_elements = poset.minimal_in_complement(mask);
        let mut sum = 0u64;
        for v in 0..n {
            if (min_elements & (1 << v)) != 0 {
                let next_mask = mask | (1 << v);
                let next_idx = mask_to_idx[next_mask as usize];
                sum += n_suffix[next_idx];
            }
        }
        n_suffix[cur_idx] = sum;
    }

    let total_extensions = n_prefix[full_idx];

    // Compute pair counts e(u < v)
    // For each ideal I and maximal element v in I:
    // weight = N_prefix(I \ {v}) * N_suffix(I)
    // for all u in I \ {v}: e(u < v) += weight
    let mut pair_matrix = vec![vec![0u64; n]; n];

    for &mask in &ideals {
        if mask == 0 {
            continue;
        }
        let i_idx = mask_to_idx[mask as usize];
        let suf = n_suffix[i_idx];
        if suf == 0 {
            continue;
        }
        let max_elements = poset.maximal_in_ideal(mask);
        for v in 0..n {
            if (max_elements & (1 << v)) != 0 {
                let prev_mask = mask ^ (1 << v);
                let prev_idx = mask_to_idx[prev_mask as usize];
                let pre = n_prefix[prev_idx];
                let weight = pre * suf;
                if weight > 0 {
                    for u in 0..n {
                        if (prev_mask & (1 << u)) != 0 {
                            pair_matrix[u][v] += weight;
                        }
                    }
                }
            }
        }
    }

    let mut pair_stats = Vec::new();
    let mut num_incomp = 0;

    for u in 0..n {
        for v in (u + 1)..n {
            let e_u_v = pair_matrix[u][v];
            let e_v_u = pair_matrix[v][u];
            let incomp = poset.is_incomparable(u, v);
            if incomp {
                num_incomp += 1;
            }
            pair_stats.push(PairStats {
                u,
                v,
                e_u_less_v: e_u_v,
                e_v_less_u: e_v_u,
                total: total_extensions,
                is_incomparable: incomp,
            });
        }
    }

    PosetExtensionStats {
        n,
        total_extensions,
        num_incomparable_pairs: num_incomp,
        pair_stats,
    }
}

/// Compute exact linear extensions and pair counts using full backtracking DFS (Topological Sort generator).
/// Serves as an independent algorithm to cross-verify the DP engine.
pub fn compute_extension_stats_backtrack(poset: &Poset) -> PosetExtensionStats {
    let n = poset.n;
    if n == 0 {
        return PosetExtensionStats {
            n: 0,
            total_extensions: 1,
            num_incomparable_pairs: 0,
            pair_stats: Vec::new(),
        };
    }

    let mut in_degrees = vec![0u32; n];
    for v in 0..n {
        in_degrees[v] = poset.greater_than[v].count_ones();
    }

    let mut total_extensions = 0u64;
    let mut pair_matrix = vec![vec![0u64; n]; n];
    let mut current_seq = vec![0usize; n];
    let chosen_mask = 0u16;

    fn dfs(
        step: usize,
        n: usize,
        poset: &Poset,
        in_degrees: &mut [u32],
        chosen_mask: u16,
        current_seq: &mut [usize],
        total: &mut u64,
        pair_matrix: &mut [Vec<u64>],
    ) {
        if step == n {
            *total += 1;
            // Record all pairs (current_seq[i] < current_seq[j] for i < j)
            for i in 0..n {
                let u = current_seq[i];
                for j in (i + 1)..n {
                    let v = current_seq[j];
                    pair_matrix[u][v] += 1;
                }
            }
            return;
        }

        for v in 0..n {
            if (chosen_mask & (1 << v)) == 0 && in_degrees[v] == 0 {
                // Pick v
                current_seq[step] = v;
                // Decrement in-degree for all successors of v
                for succ in 0..n {
                    if poset.is_less(v, succ) {
                        in_degrees[succ] -= 1;
                    }
                }

                dfs(
                    step + 1,
                    n,
                    poset,
                    in_degrees,
                    chosen_mask | (1 << v),
                    current_seq,
                    total,
                    pair_matrix,
                );

                // Backtrack
                for succ in 0..n {
                    if poset.is_less(v, succ) {
                        in_degrees[succ] += 1;
                    }
                }
            }
        }
    }

    dfs(
        0,
        n,
        poset,
        &mut in_degrees,
        chosen_mask,
        &mut current_seq,
        &mut total_extensions,
        &mut pair_matrix,
    );

    let mut pair_stats = Vec::new();
    let mut num_incomp = 0;

    for u in 0..n {
        for v in (u + 1)..n {
            let e_u_v = pair_matrix[u][v];
            let e_v_u = pair_matrix[v][u];
            let incomp = poset.is_incomparable(u, v);
            if incomp {
                num_incomp += 1;
            }
            pair_stats.push(PairStats {
                u,
                v,
                e_u_less_v: e_u_v,
                e_v_less_u: e_v_u,
                total: total_extensions,
                is_incomparable: incomp,
            });
        }
    }

    PosetExtensionStats {
        n,
        total_extensions,
        num_incomparable_pairs: num_incomp,
        pair_stats,
    }
}
