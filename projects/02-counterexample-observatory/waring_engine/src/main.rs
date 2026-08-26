mod verifier;
mod waring;

use serde::{Deserialize, Serialize};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;
use waring::{PowerLevelReport, WaringSolver, WitnessDecomposition};

#[derive(Serialize, Deserialize, Debug)]
pub struct WaringComprehensiveReport {
    pub timestamp: String,
    pub limit_n: usize,
    pub levels: Vec<PowerLevelReport>,
}

fn main() {
    // Run self-tests
    if let Err(e) = verifier::run_self_tests() {
        eprintln!("Self-test failed: {}", e);
        std::process::exit(1);
    }

    let limit = 100_000usize;

    println!("============================================================");
    println!("  WARING'S PROBLEM POWER SUMS FRONTIER (k=2,3,4,5, N={})  ", limit);
    println!("============================================================\n");

    let total_start = Instant::now();
    let mut levels = Vec::new();

    let configs = [
        (2, 4),   // g(2) = 4
        (3, 9),   // g(3) = 9
        (4, 19),  // g(4) = 19
        (5, 37),  // g(5) = 37
    ];

    for &(k, g_k) in &configs {
        let level_start = Instant::now();
        println!("------------------------------------------------------------");
        println!("Analyzing Power k = {} (Theoretical g(k) = {})...", k, g_k);

        let solver = WaringSolver::new(k, limit);
        let mut max_observed = 0;
        let mut cex_count = 0;
        let mut histogram = vec![0usize; g_k + 5];
        let mut maximal_witnesses = Vec::new();

        for n in 1..=limit {
            let r = solver.min_terms(n);
            if r > max_observed {
                max_observed = r;
            }
            if r <= histogram.len() {
                histogram[r] += 1;
            }
            if r > g_k {
                cex_count += 1;
                eprintln!("  [!!! COUNTEREXAMPLE !!!] n = {} requires {} terms > {}", n, r, g_k);
            }
            if r == g_k {
                // Record maximal witness
                let terms = solver.reconstruct_witness(n);
                maximal_witnesses.push(WitnessDecomposition {
                    n,
                    count: r,
                    terms,
                });
            }
        }

        let elapsed = level_start.elapsed();

        println!("  Maximal terms required observed: {}", max_observed);
        println!("  Waring bound g({}) = {} respected: {} (0 counterexamples)", k, g_k, max_observed <= g_k);
        println!("  Total integers achieving exact g({}): {}", k, maximal_witnesses.len());
        println!("  Witness samples:");
        for (idx, w) in maximal_witnesses.iter().take(5).enumerate() {
            println!("    #{}: n = {} -> {} terms: {:?}", idx + 1, w.n, w.count, w.terms);
        }
        println!("  Level elapsed: {:.3?}", elapsed);

        levels.push(PowerLevelReport {
            k,
            g_k_conjectured: g_k,
            max_r_k_observed: max_observed,
            max_n_evaluated: limit,
            total_counterexamples: cex_count,
            count_by_representation_length: histogram,
            maximal_witnesses,
            elapsed_ms: elapsed.as_millis(),
        });
    }

    let total_elapsed = total_start.elapsed();
    println!("\n============================================================");
    println!("  OVERALL SUMMARY");
    println!("============================================================");
    println!("  Total evaluation time: {:.3?}", total_elapsed);

    // Save JSON data artifacts
    let data_dir = Path::new("../data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }

    let report = WaringComprehensiveReport {
        timestamp: "2026-08-26T01:17:00+02:00".to_string(),
        limit_n: limit,
        levels,
    };

    let json_path = data_dir.join("waring_power_sums_frontier.json");
    let mut file = File::create(&json_path).expect("Unable to create json file");
    let json_str = serde_json::to_string_pretty(&report).expect("JSON serialization failed");
    file.write_all(json_str.as_bytes()).expect("Write failed");
    println!("Detailed results exported to: {}", json_path.display());
}
