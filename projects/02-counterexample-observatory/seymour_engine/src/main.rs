mod digraph;
mod oriented_search;
mod regular_digraphs;
mod tournament_search;

use oriented_search::{search_oriented_graphs, OrientedSearchStats};
use regular_digraphs::{audit_paley_tournaments, PaleyTournamentResult};
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::Write;
use std::time::Instant;
use tournament_search::{search_all_tournaments, TournamentSearchStats};

#[derive(Debug, Serialize, Deserialize)]
pub struct SeymourRunOutput {
    pub timestamp: String,
    pub tournament_results: Vec<TournamentSearchStats>,
    pub oriented_graph_results: Vec<OrientedSearchStats>,
    pub paley_tournament_results: Vec<PaleyTournamentResult>,
    pub total_graphs_checked: usize,
    pub total_counterexamples: usize,
    pub execution_time_ms: u128,
}

fn main() {
    println!("===============================================================");
    println!("    SEYMOUR SECOND NEIGHBORHOOD CONJECTURE AUDIT SUITE        ");
    println!("===============================================================");

    let start_time = Instant::now();
    let mut total_checked = 0usize;
    let mut total_cex = 0usize;

    // 1. Tournaments exhaustive search (n = 3..=7)
    println!("\n--- 1. TOURNAMENT EXHAUSTIVE SEARCH (n = 3..7) ---");
    let mut tourn_results = Vec::new();
    for n in 3..=7 {
        let t_start = Instant::now();
        let stats = search_all_tournaments(n);
        total_checked += stats.total_tournaments_tested;
        total_cex += stats.counterexamples;
        println!(
            "n = {}: Tournaments Tested = {:>8} | Min Seymour Vertices = {} | 1-Seymour Graphs = {:>6} | Min-OutDeg != Seymour = {:>6} | CEx = {} | Time = {:?}",
            stats.num_vertices,
            stats.total_tournaments_tested,
            stats.min_seymour_vertices_found,
            stats.tournaments_with_one_seymour_vertex,
            stats.min_outdeg_not_seymour_count,
            stats.counterexamples,
            t_start.elapsed()
        );
        tourn_results.push(stats);
    }

    // 2. General oriented graphs search (n = 3..=8)
    println!("\n--- 2. GENERAL ORIENTED GRAPHS SEARCH (n = 3..8) ---");
    let mut oriented_results = Vec::new();
    for &(n, samples) in &[
        (3, 100_000),
        (4, 100_000),
        (5, 100_000),
        (6, 15_000_000),
        (7, 500_000),
        (8, 500_000),
    ] {
        let o_start = Instant::now();
        let stats = search_oriented_graphs(n, samples);
        total_checked += stats.total_graphs_tested;
        total_cex += stats.counterexamples;
        println!(
            "n = {}: Graphs Tested = {:>8} | delta+ >= 1 Graphs = {:>8} | Min Seymour Vertices = {} | 1-Seymour Graphs = {:>6} | CEx = {} | Time = {:?}",
            stats.num_vertices,
            stats.total_graphs_tested,
            stats.graphs_with_delta_ge_1,
            stats.min_seymour_vertices_found,
            stats.graphs_with_one_seymour_vertex,
            stats.counterexamples,
            o_start.elapsed()
        );
        oriented_results.push(stats);
    }

    // 3. Paley tournament vertex-transitive audit
    println!("\n--- 3. PALEY TOURNAMENTS VERTEX-TRANSITIVE AUDIT ---");
    let paley_results = audit_paley_tournaments();
    for p in &paley_results {
        println!(
            "Paley T_{:<2}: d+(v) = {:>2} | d++(v) = {:>2} | Seymour = {:<5} | Strictly Extremal (|N++| == d+) = {}",
            p.prime_p,
            p.out_degree,
            p.second_out_degree,
            p.is_seymour,
            p.is_strictly_extremal
        );
    }

    let elapsed = start_time.elapsed();
    println!("\n===============================================================");
    println!("TOTAL COMPUTATION TIME: {:?}", elapsed);
    println!("TOTAL GRAPHS & TOURNAMENTS CHECKED: {}", total_checked);
    println!("TOTAL COUNTEREXAMPLES FOUND: {}", total_cex);
    println!("===============================================================");

    let output = SeymourRunOutput {
        timestamp: "2026-08-26T00:27:00+02:00".to_string(),
        tournament_results: tourn_results,
        oriented_graph_results: oriented_results,
        paley_tournament_results: paley_results,
        total_graphs_checked: total_checked,
        total_counterexamples: total_cex,
        execution_time_ms: elapsed.as_millis(),
    };

    let json_path = "../data/seymour_results_n7.json";
    let mut file = File::create(json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&output).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("Exported machine-readable results to {}", json_path);
}
