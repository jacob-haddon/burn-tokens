mod circulant_search;
mod digraph;
mod exhaustive_search;
mod triangle_free_search;

use circulant_search::{audit_circulants, CirculantAuditResult};
use exhaustive_search::{run_exhaustive_search_level, ExhaustiveLevelStats};
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::Write;
use std::time::Instant;
use triangle_free_search::{
    analyze_triangle_free_frontier, ExtremalDigraphRecord, TriangleFreeFrontierStats,
};

#[derive(Debug, Serialize, Deserialize)]
pub struct CaccettaRunOutput {
    pub timestamp: String,
    pub exhaustive_runs: Vec<ExhaustiveLevelStats>,
    pub triangle_free_frontier: Vec<TriangleFreeFrontierStats>,
    pub extremal_digraphs: Vec<ExtremalDigraphRecord>,
    pub circulant_audits: Vec<CirculantAuditResult>,
    pub total_graphs_checked: usize,
    pub total_counterexamples: usize,
    pub execution_time_ms: u128,
}

fn main() {
    println!("===============================================================");
    println!("    CACCETTA-HÄGGKVIST CONJECTURE GIRTH FRONTIER ENGINE        ");
    println!("===============================================================");

    let start_time = Instant::now();
    let mut total_checked = 0usize;
    let mut total_cex = 0usize;

    // 1. Exhaustive level search (all digraphs on n = 3..6 with min out-degree >= k)
    println!("\n--- 1. EXHAUSTIVE LEVEL SEARCH (n = 3..6) ---");
    let mut exhaustive_results = Vec::new();
    let levels = vec![
        (3, 1),
        (3, 2),
        (4, 1),
        (4, 2),
        (4, 3),
        (5, 1),
        (5, 2),
        (5, 3),
        (6, 2),
        (6, 3),
    ];

    for &(n, k) in &levels {
        let stats = run_exhaustive_search_level(n, k);
        total_checked += stats.total_graphs_with_min_outdeg;
        total_cex += stats.counterexamples;
        println!(
            "n = {}, k = {}: Total Digraphs = {:>10} | Bound = {} | 2-Cycles = {:>8} | 3-Cycles = {:>8} | Satisfied = {:>10} | CEx = {} | Time = {}ms",
            stats.n,
            stats.k,
            stats.total_graphs_with_min_outdeg,
            stats.ch_bound,
            stats.total_graphs_with_2cycle,
            stats.total_graphs_with_3cycle,
            stats.satisfied_conjecture,
            stats.counterexamples,
            stats.execution_time_ms
        );
        exhaustive_results.push(stats);
    }

    // 2. Triangle-free frontier analysis (n = 3..9)
    println!("\n--- 2. TRIANGLE-FREE / GIRTH FRONTIER ANALYSIS (n = 3..9) ---");
    let mut tf_results = Vec::new();
    let mut all_extremal = Vec::new();

    for n in 3..=9 {
        let (stats, extremals) = analyze_triangle_free_frontier(n);
        println!(
            "n = {}: CH Threshold k = {} | Max delta+ without Triangles = {} | CEx = {} | Extremal Cataloged = {} | Time = {}ms",
            stats.n,
            stats.ch_threshold_k,
            stats.max_min_out_degree_found,
            if !stats.strictly_satisfies_ch { "YES!" } else { "0" },
            stats.count_maximal_graphs,
            stats.execution_time_ms
        );
        tf_results.push(stats);
        all_extremal.extend(extremals);
    }

    // 3. Circulant Digraphs Audit (n = 3..16)
    println!("\n--- 3. CIRCULANT DIGRAPH AUDIT (n = 3..16) ---");
    let circulant_results = audit_circulants(16);
    let circ_count = circulant_results.len();
    let circ_extremal = circulant_results.iter().filter(|c| c.is_extremal).count();
    let circ_cex = circulant_results.iter().filter(|c| !c.satisfies_ch).count();
    total_cex += circ_cex;
    println!(
        "Audited {} circulant digraphs | Extremal (girth == ceil(n/k)): {} | CEx: {}",
        circ_count, circ_extremal, circ_cex
    );

    let elapsed = start_time.elapsed();
    println!("\n===============================================================");
    println!("TOTAL COMPUTATION TIME: {:?}", elapsed);
    println!("TOTAL DIGRAPHS CHECKED: {}", total_checked);
    println!("TOTAL COUNTEREXAMPLES FOUND: {}", total_cex);
    println!("===============================================================");

    let output = CaccettaRunOutput {
        timestamp: "2026-08-26T00:43:00+02:00".to_string(),
        exhaustive_runs: exhaustive_results,
        triangle_free_frontier: tf_results,
        extremal_digraphs: all_extremal,
        circulant_audits: circulant_results,
        total_graphs_checked: total_checked,
        total_counterexamples: total_cex,
        execution_time_ms: elapsed.as_millis(),
    };

    let json_path = "../data/caccetta_haggkvist_frontier.json";
    let mut file = File::create(json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&output).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("Exported machine-readable results to {}", json_path);
}
