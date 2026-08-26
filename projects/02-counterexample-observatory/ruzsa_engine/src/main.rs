mod ruzsa;
mod search;

use search::stress_test_ruzsa_inequality;
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::Path;
use std::time::Instant;
use ruzsa::TripleAnalysis;

#[derive(Debug, Serialize, Deserialize)]
pub struct RuzsaDataset {
    pub title: String,
    pub timestamp: String,
    pub total_triples_tested: u64,
    pub counterexamples_found: u64,
    pub metric_violations_found: u64,
    pub sharp_equality_count: u64,
    pub max_ratio_observed: f64,
    pub min_triangle_slack: f64,
    pub sample_equality_witnesses: Vec<TripleAnalysis>,
    pub sample_asymmetric_triples: Vec<TripleAnalysis>,
}

fn main() {
    let start_time = Instant::now();
    println!("===========================================================================");
    println!("   RUZSA TRIANGLE INEQUALITY & ADDITIVE DISTANCE FRONTIER ENGINE          ");
    println!("===========================================================================");

    let summary = stress_test_ruzsa_inequality();
    let elapsed = start_time.elapsed();

    println!("[*] Total Subset Triples Evaluated: {}", summary.total_triples_tested);
    println!("[*] Counterexamples to |A||B-C| <= |A-B||A-C|: {}", summary.counterexamples_found);
    println!("[*] Ruzsa Metric Distance Violations: {}", summary.metric_violations_found);
    println!("[*] Sharp Equality Count (|A||B-C| = |A-B||A-C|): {}", summary.sharp_equality_count);
    println!("[*] Maximum Ratio Observed: {:.6}", summary.max_ratio);
    println!("[*] Minimum Triangle Slack: {:.9}", summary.min_triangle_slack);
    println!("---------------------------------------------------------------------------");
    println!("Sample Sharp Equality Witnesses (|A||B-C| = |A-B||A-C|):");
    for (idx, w) in summary.equality_witnesses.iter().take(5).enumerate() {
        println!(
            "  #{}: A={:?}, B={:?}, C={:?} | LHS={} = RHS={}",
            idx + 1, w.set_a, w.set_b, w.set_c, w.lhs, w.rhs
        );
    }

    println!("===========================================================================");
    println!("TOTAL EXECUTION TIME: {:?}", elapsed);
    println!("===========================================================================");

    assert_eq!(summary.counterexamples_found, 0, "Counterexamples detected!");
    assert_eq!(summary.metric_violations_found, 0, "Metric violations detected!");

    let dataset = RuzsaDataset {
        title: "Ruzsa Triangle Inequality & Exact Additive Difference Distance Frontier (|A|, |B|, |C| <= 6)".to_string(),
        timestamp: "2026-08-26T01:11:00+02:00".to_string(),
        total_triples_tested: summary.total_triples_tested,
        counterexamples_found: summary.counterexamples_found,
        metric_violations_found: summary.metric_violations_found,
        sharp_equality_count: summary.sharp_equality_count,
        max_ratio_observed: summary.max_ratio,
        min_triangle_slack: summary.min_triangle_slack,
        sample_equality_witnesses: summary.equality_witnesses,
        sample_asymmetric_triples: summary.max_distance_triples,
    };

    let json_str = serde_json::to_string_pretty(&dataset).expect("Failed to serialize JSON");
    let out_path = Path::new("../data/ruzsa_distance_frontier.json");
    if let Some(parent) = out_path.parent() {
        fs::create_dir_all(parent).expect("Failed to create parent dir");
    }
    fs::write(out_path, json_str).expect("Failed to write JSON dataset");
    println!("Exported machine-readable results to {}", out_path.display());
}
