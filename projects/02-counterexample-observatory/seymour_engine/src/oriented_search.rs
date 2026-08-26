use crate::digraph::OrientedGraph;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OrientedSearchStats {
    pub num_vertices: usize,
    pub total_graphs_tested: usize,
    pub counterexamples: usize,
    pub min_seymour_vertices_found: usize,
    pub graphs_with_one_seymour_vertex: usize,
    pub graphs_with_delta_ge_1: usize,
    pub delta_ge_1_counterexamples: usize,
}

pub fn search_oriented_graphs(n: usize, max_samples: usize) -> OrientedSearchStats {
    let num_pairs = n * (n - 1) / 2;
    let mut pairs = Vec::new();
    for u in 0..n {
        for v in (u + 1)..n {
            pairs.push((u, v));
        }
    }

    let tested = AtomicUsize::new(0);
    let cex = AtomicUsize::new(0);
    let one_sey_count = AtomicUsize::new(0);
    let min_sey_found = AtomicUsize::new(n);
    let delta_ge_1_count = AtomicUsize::new(0);
    let delta_ge_1_cex = AtomicUsize::new(0);

    // If 3^num_pairs <= max_samples, do exact ternary enumeration
    let total_graphs_possible = 3usize.pow(num_pairs as u32);
    let is_exhaustive = total_graphs_possible <= max_samples;
    let num_to_run = if is_exhaustive {
        total_graphs_possible
    } else {
        max_samples
    };

    let chunk_size = 10_000;
    let num_chunks = (num_to_run + chunk_size - 1) / chunk_size;

    (0..num_chunks).into_par_iter().for_each(|chunk_idx| {
        let mut rng = 987654321u64 ^ ((chunk_idx as u64) * 0x517cc1b727220a95);
        let start = chunk_idx * chunk_size;
        let end = (start + chunk_size).min(num_to_run);

        let mut local_tested = 0;
        let mut local_cex = 0;
        let mut local_one = 0;
        let mut local_min_sey = n;
        let mut local_delta1 = 0;
        let mut local_delta1_cex = 0;

        for idx in start..end {
            let mut g = OrientedGraph::new(n);
            if is_exhaustive {
                let mut temp = idx;
                for &(u, v) in &pairs {
                    let choice = temp % 3;
                    temp /= 3;
                    if choice == 1 {
                        g.add_edge(u, v);
                    } else if choice == 2 {
                        g.add_edge(v, u);
                    }
                }
            } else {
                for &(u, v) in &pairs {
                    rng = rng.wrapping_mul(6364136223846793005).wrapping_add(1);
                    let choice = (rng >> 32) % 3;
                    if choice == 1 {
                        g.add_edge(u, v);
                    } else if choice == 2 {
                        g.add_edge(v, u);
                    }
                }
            }

            local_tested += 1;
            let sey_count = g.seymour_count();
            if sey_count == 0 {
                local_cex += 1;
            }
            if sey_count == 1 {
                local_one += 1;
            }
            if sey_count < local_min_sey {
                local_min_sey = sey_count;
            }

            // Check if minimum out-degree delta+ >= 1
            let has_sink = (0..n).any(|v| g.out_degree(v) == 0);
            if !has_sink {
                local_delta1 += 1;
                if sey_count == 0 {
                    local_delta1_cex += 1;
                }
            }
        }

        tested.fetch_add(local_tested, Ordering::Relaxed);
        cex.fetch_add(local_cex, Ordering::Relaxed);
        one_sey_count.fetch_add(local_one, Ordering::Relaxed);
        delta_ge_1_count.fetch_add(local_delta1, Ordering::Relaxed);
        delta_ge_1_cex.fetch_add(local_delta1_cex, Ordering::Relaxed);

        let mut current_min = min_sey_found.load(Ordering::Relaxed);
        while local_min_sey < current_min {
            match min_sey_found.compare_exchange_weak(
                current_min,
                local_min_sey,
                Ordering::Relaxed,
                Ordering::Relaxed,
            ) {
                Ok(_) => break,
                Err(val) => current_min = val,
            }
        }
    });

    OrientedSearchStats {
        num_vertices: n,
        total_graphs_tested: tested.load(Ordering::Relaxed),
        counterexamples: cex.load(Ordering::Relaxed),
        min_seymour_vertices_found: min_sey_found.load(Ordering::Relaxed),
        graphs_with_one_seymour_vertex: one_sey_count.load(Ordering::Relaxed),
        graphs_with_delta_ge_1: delta_ge_1_count.load(Ordering::Relaxed),
        delta_ge_1_counterexamples: delta_ge_1_cex.load(Ordering::Relaxed),
    }
}
