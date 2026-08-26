use crate::digraph::Digraph;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::time::Instant;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ExhaustiveLevelStats {
    pub n: usize,
    pub k: usize,
    pub ch_bound: usize,
    pub total_graphs_with_min_outdeg: usize,
    pub total_graphs_with_2cycle: usize,
    pub total_graphs_with_3cycle: usize,
    pub satisfied_conjecture: usize,
    pub counterexamples: usize,
    pub execution_time_ms: u128,
}

/// Generate all valid bitmasks for row u on n vertices with out-degree >= k
pub fn valid_row_masks(n: usize, u: usize, k: usize) -> Vec<u32> {
    let mut masks = Vec::new();
    let num_other = n - 1;
    for combo in 0..(1 << num_other) {
        if (combo as u32).count_ones() >= k as u32 {
            let mut row_mask = 0u32;
            let mut bit_idx = 0;
            for v in 0..n {
                if v == u {
                    continue;
                }
                if (combo & (1 << bit_idx)) != 0 {
                    row_mask |= 1 << v;
                }
                bit_idx += 1;
            }
            masks.push(row_mask);
        }
    }
    masks
}

/// Exhaustively searches all digraphs on n vertices with minimum out-degree >= k
pub fn run_exhaustive_search_level(n: usize, k: usize) -> ExhaustiveLevelStats {
    let start = Instant::now();
    let ch_bound = (n + k - 1) / k; // ceil(n / k)

    let masks: Vec<Vec<u32>> = (0..n).map(|u| valid_row_masks(n, u, k)).collect();

    // Check sizes
    let total_candidates: usize = masks.iter().map(|m| m.len()).product();

    // Parallel search using Rayon on the outer rows
    let (total_sat, total_cex, total_2cyc, total_3cyc) = match n {
        3 => {
            let mut sat = 0;
            let mut cex = 0;
            let mut c2 = 0;
            let mut c3 = 0;
            for &r0 in &masks[0] {
                for &r1 in &masks[1] {
                    for &r2 in &masks[2] {
                        let mut d = Digraph::new(3);
                        d.adj[0] = r0;
                        d.adj[1] = r1;
                        d.adj[2] = r2;

                        let has_2c = d.has_2cycle();
                        let has_3c = d.has_directed_triangle();
                        if has_2c {
                            c2 += 1;
                        }
                        if has_3c {
                            c3 += 1;
                        }

                        let girth = d.compute_girth();
                        match girth {
                            Some(g) if g <= ch_bound => sat += 1,
                            _ => cex += 1,
                        }
                    }
                }
            }
            (sat, cex, c2, c3)
        }
        4 => {
            masks[0]
                .par_iter()
                .map(|&r0| {
                    let mut sat = 0;
                    let mut cex = 0;
                    let mut c2 = 0;
                    let mut c3 = 0;
                    for &r1 in &masks[1] {
                        for &r2 in &masks[2] {
                            for &r3 in &masks[3] {
                                let mut d = Digraph::new(4);
                                d.adj[0] = r0;
                                d.adj[1] = r1;
                                d.adj[2] = r2;
                                d.adj[3] = r3;

                                let has_2c = d.has_2cycle();
                                let has_3c = d.has_directed_triangle();
                                if has_2c {
                                    c2 += 1;
                                }
                                if has_3c {
                                    c3 += 1;
                                }

                                let girth = d.compute_girth();
                                match girth {
                                    Some(g) if g <= ch_bound => sat += 1,
                                    _ => cex += 1,
                                }
                            }
                        }
                    }
                    (sat, cex, c2, c3)
                })
                .reduce(|| (0, 0, 0, 0), |a, b| (a.0 + b.0, a.1 + b.1, a.2 + b.2, a.3 + b.3))
        }
        5 => {
            masks[0]
                .par_iter()
                .map(|&r0| {
                    let mut sat = 0;
                    let mut cex = 0;
                    let mut c2 = 0;
                    let mut c3 = 0;
                    for &r1 in &masks[1] {
                        for &r2 in &masks[2] {
                            for &r3 in &masks[3] {
                                for &r4 in &masks[4] {
                                    let mut d = Digraph::new(5);
                                    d.adj[0] = r0;
                                    d.adj[1] = r1;
                                    d.adj[2] = r2;
                                    d.adj[3] = r3;
                                    d.adj[4] = r4;

                                    let has_2c = d.has_2cycle();
                                    let has_3c = d.has_directed_triangle();
                                    if has_2c {
                                        c2 += 1;
                                    }
                                    if has_3c {
                                        c3 += 1;
                                    }

                                    let girth = d.compute_girth();
                                    match girth {
                                        Some(g) if g <= ch_bound => sat += 1,
                                        _ => cex += 1,
                                    }
                                }
                            }
                        }
                    }
                    (sat, cex, c2, c3)
                })
                .reduce(|| (0, 0, 0, 0), |a, b| (a.0 + b.0, a.1 + b.1, a.2 + b.2, a.3 + b.3))
        }
        6 => {
            // Flatten 2 outer rows for Rayon parallelism
            let outer_pairs: Vec<(u32, u32)> = masks[0]
                .iter()
                .flat_map(|&r0| masks[1].iter().map(move |&r1| (r0, r1)))
                .collect();

            outer_pairs
                .par_iter()
                .map(|&(r0, r1)| {
                    let mut sat = 0;
                    let mut cex = 0;
                    let mut c2 = 0;
                    let mut c3 = 0;
                    for &r2 in &masks[2] {
                        for &r3 in &masks[3] {
                            for &r4 in &masks[4] {
                                for &r5 in &masks[5] {
                                    let mut d = Digraph::new(6);
                                    d.adj[0] = r0;
                                    d.adj[1] = r1;
                                    d.adj[2] = r2;
                                    d.adj[3] = r3;
                                    d.adj[4] = r4;
                                    d.adj[5] = r5;

                                    let has_2c = d.has_2cycle();
                                    let has_3c = d.has_directed_triangle();
                                    if has_2c {
                                        c2 += 1;
                                    }
                                    if has_3c {
                                        c3 += 1;
                                    }

                                    if has_2c || has_3c {
                                        sat += 1;
                                    } else {
                                        let girth = d.compute_girth();
                                        match girth {
                                            Some(g) if g <= ch_bound => sat += 1,
                                            _ => cex += 1,
                                        }
                                    }
                                }
                            }
                        }
                    }
                    (sat, cex, c2, c3)
                })
                .reduce(|| (0, 0, 0, 0), |a, b| (a.0 + b.0, a.1 + b.1, a.2 + b.2, a.3 + b.3))
        }
        _ => panic!("Exhaustive level {} not supported directly", n),
    };

    ExhaustiveLevelStats {
        n,
        k,
        ch_bound,
        total_graphs_with_min_outdeg: total_candidates,
        total_graphs_with_2cycle: total_2cyc,
        total_graphs_with_3cycle: total_3cyc,
        satisfied_conjecture: total_sat,
        counterexamples: total_cex,
        execution_time_ms: start.elapsed().as_millis(),
    }
}
