mod metrics;
mod search;
mod verifier;

use metrics::SetMetrics;
use search::find_exact_extremal_sum_product;
use serde::{Deserialize, Serialize};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;

#[derive(Serialize, Deserialize, Debug)]
pub struct LevelResult {
    pub k: usize,
    pub min_max_sum_product: usize,
    pub max_possible_sumset: usize, // k(k+1)/2
    pub min_possible_sumset: usize, // 2k-1
    pub num_minimizing_sets_found: usize,
    pub sample_minimizers: Vec<SetMetrics>,
    pub elapsed_ms: u128,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct SumProductReport {
    pub timestamp: String,
    pub max_k: usize,
    pub results: Vec<LevelResult>,
}

fn main() {
    // Run self-tests
    if let Err(e) = verifier::run_self_tests() {
        eprintln!("Self-test failed: {}", e);
        std::process::exit(1);
    }

    println!("==========================================================");
    println!("  ERDŐS-SZEMERÉDI SUM-PRODUCT ENERGY FRONTIER (|A| <= 7)  ");
    println!("==========================================================\n");

    let total_start = Instant::now();
    let mut level_results = Vec::new();

    let search_params = [
        (2, 10),
        (3, 15),
        (4, 20),
        (5, 25),
        (6, 24),
        (7, 22),
    ];

    for &(k, n_max) in &search_params {
        let level_start = Instant::now();
        println!("----------------------------------------------------------");
        println!("Analyzing Set Size k = {} (Universe N = {})...", k, n_max);

        let (min_val, minimizers) = find_exact_extremal_sum_product(k, n_max);
        let elapsed = level_start.elapsed();

        let max_possible = k * (k + 1) / 2;
        let min_possible = 2 * k - 1;

        println!("  Exact min max(|A+A|, |A*A|): {}", min_val);
        println!("  Theoretical bounds: [min: {}, max: {}]", min_possible, max_possible);
        println!("  Found {} minimizing sets in universe", minimizers.len());

        for (idx, m) in minimizers.iter().take(3).enumerate() {
            println!(
                "    #{}: A = {:?} | |A+A| = {}, |A*A| = {}, E_+ = {}, E_x = {}",
                idx + 1,
                m.set,
                m.sumset_size,
                m.productset_size,
                m.additive_energy,
                m.multiplicative_energy
            );
        }

        println!("  Level elapsed: {:.3?}", elapsed);

        level_results.push(LevelResult {
            k,
            min_max_sum_product: min_val,
            max_possible_sumset: max_possible,
            min_possible_sumset: min_possible,
            num_minimizing_sets_found: minimizers.len(),
            sample_minimizers: minimizers.into_iter().take(10).collect(),
            elapsed_ms: elapsed.as_millis(),
        });
    }

    let total_elapsed = total_start.elapsed();
    println!("\n==========================================================");
    println!("  OVERALL SUMMARY");
    println!("==========================================================");
    println!("  Total search time: {:.3?}", total_elapsed);

    // Save JSON data artifacts
    let data_dir = Path::new("../data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }

    let report = SumProductReport {
        timestamp: "2026-08-26T01:14:00+02:00".to_string(),
        max_k: 7,
        results: level_results,
    };

    let json_path = data_dir.join("sum_product_frontier.json");
    let mut file = File::create(&json_path).expect("Unable to create json file");
    let json_str = serde_json::to_string_pretty(&report).expect("JSON serialization failed");
    file.write_all(json_str.as_bytes()).expect("Write failed");
    println!("Detailed results exported to: {}", json_path.display());
}
