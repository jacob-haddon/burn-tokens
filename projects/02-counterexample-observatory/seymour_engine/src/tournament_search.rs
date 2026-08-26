use crate::digraph::OrientedGraph;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::sync::atomic::{AtomicUsize, Ordering};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TournamentSearchStats {
    pub num_vertices: usize,
    pub total_tournaments_tested: usize,
    pub counterexamples: usize,
    pub min_seymour_vertices_found: usize,
    pub tournaments_with_one_seymour_vertex: usize,
    pub min_outdeg_not_seymour_count: usize,
}

pub fn search_all_tournaments(n: usize) -> TournamentSearchStats {
    let num_pairs = n * (n - 1) / 2;
    let total_tournaments = 1usize << num_pairs;

    let mut pairs = Vec::new();
    for u in 0..n {
        for v in (u + 1)..n {
            pairs.push((u, v));
        }
    }

    let tested = AtomicUsize::new(0);
    let cex = AtomicUsize::new(0);
    let one_sey_count = AtomicUsize::new(0);
    let min_deg_not_sey = AtomicUsize::new(0);
    let min_sey_found = AtomicUsize::new(n);

    // Limit to 2M if n > 7
    let max_to_test = total_tournaments.min(2_097_152);
    let step = if total_tournaments > max_to_test {
        total_tournaments / max_to_test
    } else {
        1
    };

    let indices: Vec<usize> = (0..total_tournaments).step_by(step).collect();

    indices.par_iter().for_each(|&mask| {
        let mut g = OrientedGraph::new(n);
        for (i, &(u, v)) in pairs.iter().enumerate() {
            if (mask & (1 << i)) != 0 {
                g.add_edge(u, v);
            } else {
                g.add_edge(v, u);
            }
        }

        tested.fetch_add(1, Ordering::Relaxed);

        let sey_count = g.seymour_count();
        if sey_count == 0 {
            cex.fetch_add(1, Ordering::Relaxed);
        }
        if sey_count == 1 {
            one_sey_count.fetch_add(1, Ordering::Relaxed);
        }

        let mut current_min = min_sey_found.load(Ordering::Relaxed);
        while sey_count < current_min {
            match min_sey_found.compare_exchange_weak(
                current_min,
                sey_count,
                Ordering::Relaxed,
                Ordering::Relaxed,
            ) {
                Ok(_) => break,
                Err(val) => current_min = val,
            }
        }

        let (_, _, min_is_sey) = g.min_out_degree_analysis();
        if !min_is_sey {
            min_deg_not_sey.fetch_add(1, Ordering::Relaxed);
        }
    });

    TournamentSearchStats {
        num_vertices: n,
        total_tournaments_tested: tested.load(Ordering::Relaxed),
        counterexamples: cex.load(Ordering::Relaxed),
        min_seymour_vertices_found: min_sey_found.load(Ordering::Relaxed),
        tournaments_with_one_seymour_vertex: one_sey_count.load(Ordering::Relaxed),
        min_outdeg_not_seymour_count: min_deg_not_sey.load(Ordering::Relaxed),
    }
}
