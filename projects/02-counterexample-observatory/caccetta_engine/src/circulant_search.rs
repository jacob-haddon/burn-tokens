use crate::digraph::Digraph;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CirculantAuditResult {
    pub n: usize,
    pub jump_set: Vec<usize>,
    pub degree: usize,
    pub ch_bound: usize,
    pub girth: usize,
    pub satisfies_ch: bool,
    pub is_extremal: bool, // girth == ch_bound
}

/// Construct a circulant digraph on Z_n with jump set S
pub fn make_circulant(n: usize, jumps: &[usize]) -> Digraph {
    let mut d = Digraph::new(n);
    for u in 0..n {
        for &s in jumps {
            let v = (u + s) % n;
            if v != u {
                d.add_edge(u, v);
            }
        }
    }
    d
}

/// Audit all circulant digraphs on n vertices up to max_n
pub fn audit_circulants(max_n: usize) -> Vec<CirculantAuditResult> {
    let mut results = Vec::new();

    for n in 3..=max_n {
        let max_jump = n - 1;
        let num_possible = max_jump;
        let total_subsets = 1 << num_possible;

        for mask in 1..total_subsets {
            let jumps: Vec<usize> = (1..=max_jump)
                .filter(|&s| (mask & (1 << (s - 1))) != 0)
                .collect();

            let deg = jumps.len();
            if deg == 0 {
                continue;
            }

            let ch_bound = (n + deg - 1) / deg; // ceil(n / deg)
            let g = make_circulant(n, &jumps);
            let girth = g.compute_girth().unwrap_or(0);

            let satisfies = girth > 0 && girth <= ch_bound;
            let is_extremal = girth == ch_bound;

            // Only record non-trivial or extremal circulants to keep output clean
            if deg <= n / 2 {
                results.push(CirculantAuditResult {
                    n,
                    jump_set: jumps,
                    degree: deg,
                    ch_bound,
                    girth,
                    satisfies_ch: satisfies,
                    is_extremal,
                });
            }
        }
    }

    results
}
