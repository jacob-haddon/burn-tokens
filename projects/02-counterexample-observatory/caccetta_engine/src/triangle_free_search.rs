use crate::digraph::Digraph;
use serde::{Deserialize, Serialize};
use std::time::Instant;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExtremalDigraphRecord {
    pub n: usize,
    pub min_out_degree: usize,
    pub max_out_degree: usize,
    pub out_degrees: Vec<usize>,
    pub num_edges: usize,
    pub girth: usize,
    pub description: String,
    pub adjacency_matrix: Vec<Vec<u8>>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TriangleFreeFrontierStats {
    pub n: usize,
    pub ch_threshold_k: usize, // ceil(n / 3)
    pub max_min_out_degree_found: usize,
    pub count_maximal_graphs: usize,
    pub strictly_satisfies_ch: bool,
    pub execution_time_ms: u128,
}

pub struct TriangleFreeSearcher {
    pub n: usize,
    pub k: usize, // required exact or min out-degree
    pub adj: Vec<u32>,
    pub maximal_found: Vec<Digraph>,
    pub max_delta_found: usize,
    pub break_sym_root: bool,
    pub exact_k_only: bool,
}

impl TriangleFreeSearcher {
    pub fn new(n: usize, k: usize, break_sym_root: bool, exact_k_only: bool) -> Self {
        Self {
            n,
            k,
            adj: vec![0; n],
            maximal_found: Vec::new(),
            max_delta_found: 0,
            break_sym_root,
            exact_k_only,
        }
    }

    /// Search for triangle-free digraphs with out_degree >= k
    pub fn search(&mut self) -> bool {
        self.backtrack(0)
    }

    fn compute_forbidden(&self, u: usize) -> u32 {
        let mut forbidden = 1u32 << u;

        // 2-cycles with fixed vertices v < u:
        for v in 0..u {
            if (self.adj[v] & (1 << u)) != 0 {
                forbidden |= 1 << v;
            }
        }

        // 3-cycles with fixed vertices v, w < u:
        // if v -> w and w -> u, then u -> v is forbidden.
        for v in 0..self.n {
            if v == u {
                continue;
            }
            for w in 0..u {
                if (self.adj[w] & (1 << u)) != 0 && (self.adj[v] & (1 << w)) != 0 {
                    forbidden |= 1 << v;
                }
            }
        }

        forbidden
    }

    fn check_future_degree_pruning(&self, current_u: usize) -> bool {
        let full_mask = (1u32 << self.n) - 1;
        for v in current_u..self.n {
            let mut forbidden = 1u32 << v;
            for w in 0..current_u {
                if (self.adj[w] & (1 << v)) != 0 {
                    forbidden |= 1 << w;
                }
                for x in 0..current_u {
                    if (self.adj[x] & (1 << v)) != 0 && (self.adj[w] & (1 << x)) != 0 {
                        forbidden |= 1 << w;
                    }
                }
            }
            let allowed = (!forbidden) & full_mask;
            if (allowed.count_ones() as usize) < self.k {
                return false;
            }
        }
        true
    }

    fn backtrack(&mut self, u: usize) -> bool {
        if u == self.n {
            let d = Digraph {
                n: self.n,
                adj: self.adj.clone(),
            };
            let delta = d.min_out_degree();
            if delta >= self.k {
                if delta > self.max_delta_found {
                    self.max_delta_found = delta;
                    self.maximal_found.clear();
                }
                if delta == self.max_delta_found && self.maximal_found.len() < 10 {
                    self.maximal_found.push(d);
                }
                return true;
            }
            return false;
        }

        if !self.check_future_degree_pruning(u) {
            return false;
        }

        let forbidden = self.compute_forbidden(u);
        let allowed: u32 = (!forbidden) & ((1u32 << self.n) - 1);
        let allowed_count = allowed.count_ones() as usize;
        if allowed_count < self.k {
            return false;
        }

        // Root symmetry breaking: fix first k out-edges of vertex 0 to 1..=k
        if self.break_sym_root && u == 0 {
            let mut row = 0u32;
            for v in 1..=self.k {
                row |= 1 << v;
            }
            self.adj[0] = row;
            let found = self.backtrack(1);
            self.adj[0] = 0;
            return found;
        }

        let mut found_any = false;
        let allowed_bits: Vec<usize> = (0..self.n).filter(|&v| (allowed & (1 << v)) != 0).collect();

        // If exact_k_only, only generate subsets of size k
        let max_size = if self.exact_k_only { self.k } else { allowed_count };
        let total_combos = 1 << allowed_bits.len();

        for mask in 0..total_combos {
            let count = (mask as u32).count_ones() as usize;
            if count >= self.k && count <= max_size {
                let mut row = 0u32;
                for (idx, &bit) in allowed_bits.iter().enumerate() {
                    if (mask & (1 << idx)) != 0 {
                        row |= 1 << bit;
                    }
                }

                // Check: does row create any 3-cycles with existing edges?
                let mut valid = true;
                for v in 0..u {
                    if (row & (1 << v)) != 0 {
                        for w in 0..u {
                            if (self.adj[v] & (1 << w)) != 0 && (self.adj[w] & (1 << u)) != 0 {
                                valid = false;
                                break;
                            }
                        }
                    }
                    if !valid {
                        break;
                    }
                }

                if valid {
                    self.adj[u] = row;
                    if self.backtrack(u + 1) {
                        found_any = true;
                        if self.maximal_found.len() >= 10 || self.break_sym_root {
                            self.adj[u] = 0;
                            return true;
                        }
                    }
                }
            }
        }

        self.adj[u] = 0;
        found_any
    }
}

/// Computes the triangle-free frontier for a given n
pub fn analyze_triangle_free_frontier(n: usize) -> (TriangleFreeFrontierStats, Vec<ExtremalDigraphRecord>) {
    let start = Instant::now();
    let ch_k = (n + 2) / 3; // ceil(n / 3)

    // First search for any triangle-free graph with delta+ >= ch_k (which would be a counterexample!)
    // If ANY triangle-free graph with out_degree >= ch_k exists, one with out_degree == ch_k exists!
    let mut searcher_cex = TriangleFreeSearcher::new(n, ch_k, true, true);
    let has_cex = searcher_cex.search();

    assert!(!has_cex, "COUNTEREXAMPLE FOUND AT n={}, k={}", n, ch_k);

    // Now find the maximum delta+ <= ch_k - 1 and catalog extremal graphs
    let max_possible_k = if ch_k > 0 { ch_k - 1 } else { 0 };
    let mut best_delta = 0;
    let mut extremal_graphs = Vec::new();

    for target_k in (1..=max_possible_k).rev() {
        let mut searcher = TriangleFreeSearcher::new(n, target_k, false, true);
        if searcher.search() {
            best_delta = target_k;
            for g in searcher.maximal_found {
                let girth = g.compute_girth().unwrap_or(0);
                extremal_graphs.push(ExtremalDigraphRecord {
                    n,
                    min_out_degree: g.min_out_degree(),
                    max_out_degree: g.max_out_degree(),
                    out_degrees: g.out_degrees(),
                    num_edges: g.count_edges(),
                    girth,
                    description: format!(
                        "Extremal girth-{} digraph on n={} with delta^+={}",
                        girth, n, g.min_out_degree()
                    ),
                    adjacency_matrix: g.to_matrix(),
                });
            }
            break;
        }
    }

    let stats = TriangleFreeFrontierStats {
        n,
        ch_threshold_k: ch_k,
        max_min_out_degree_found: best_delta,
        count_maximal_graphs: extremal_graphs.len(),
        strictly_satisfies_ch: !has_cex,
        execution_time_ms: start.elapsed().as_millis(),
    };

    (stats, extremal_graphs)
}
