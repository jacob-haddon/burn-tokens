mod analytics;
mod sidon;
mod solver;

use analytics::{FrontierRecord, GlobalReport};
use sidon::{is_sidon_diff_form, is_sidon_sum_form, SidonSet};
use solver::{solve_sidon_frontier, OEIS_A003022};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;

fn run_self_tests() -> Result<(), String> {
    // Test 1: {1, 2, 4} is valid Sidon
    let s1 = SidonSet::new(vec![1, 2, 4], 4);
    if !s1.is_valid_sidon_sums() || !s1.is_valid_sidon_diffs() {
        return Err("Self-test 1 failed: {1, 2, 4} must be valid Sidon".to_string());
    }

    // Test 2: {1, 2, 3} is invalid Sidon (1+3 = 2+2 = 4)
    let s2 = SidonSet::new(vec![1, 2, 3], 3);
    if s2.is_valid_sidon_sums() || s2.is_valid_sidon_diffs() {
        return Err("Self-test 2 failed: {1, 2, 3} must be invalid Sidon".to_string());
    }

    // Test 3: Canonical form for {2, 3, 5} -> translated {1, 2, 4}, reflected {1, 3, 4} -> canonical {1, 2, 4}
    let s3 = SidonSet::new(vec![2, 3, 5], 5);
    let can3 = s3.canonical();
    if can3 != vec![1, 2, 4] {
        return Err(format!("Self-test 3 failed: canonical was {:?}", can3));
    }

    Ok(())
}

fn main() {
    println!("===============================================================");
    println!("   SIDON SET FRONTIER & EXTREMAL DENSITY ENGINE (N <= 35)    ");
    println!("===============================================================");

    if let Err(e) = run_self_tests() {
        eprintln!("[FATAL] Self-test failed: {}", e);
        std::process::exit(1);
    }
    println!("[*] Self-tests passed successfully (pairwise sums == pairwise diffs).");

    let max_n = 35;
    let mut records = Vec::new();
    let mut total_configs = 0;
    let start_all = Instant::now();

    println!("\n|  N | R(N) | Total Extremal | Canonical | Density R/N | R / sqrt(N) | Dev: R - sqrt(N) | Time (ms) |");
    println!("|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|");

    let mut oeis_verified = true;

    for n in 1..=max_n {
        let t0 = Instant::now();
        let res = solve_sidon_frontier(n);
        let elapsed = t0.elapsed();

        if !res.oeis_a003022_match {
            eprintln!("[ERROR] At N={}, computed R(N)={} but OEIS expected {}", n, res.max_cardinality, OEIS_A003022[(n-1) as usize]);
            oeis_verified = false;
        }

        // Validate every extremal set produced using both algorithms
        for raw in &res.extremal_sets {
            if !is_sidon_sum_form(raw) || !is_sidon_diff_form(raw) {
                eprintln!("[FATAL] Set {:?} at N={} is NOT a valid Sidon set!", raw, n);
                std::process::exit(1);
            }
        }

        let density = res.max_cardinality as f64 / n as f64;
        let sqrt_n = (n as f64).sqrt();
        let asymptotic_ratio = res.max_cardinality as f64 / sqrt_n;
        let erdos_turan_dev = res.max_cardinality as f64 - sqrt_n;

        total_configs += res.count_max_sets;

        let sample = if res.extremal_sets.is_empty() {
            vec![]
        } else {
            res.extremal_sets[0].clone()
        };

        records.push(FrontierRecord {
            n,
            r_n: res.max_cardinality,
            density,
            asymptotic_ratio,
            erdos_turan_deviation: erdos_turan_dev,
            total_extremal_count: res.count_max_sets,
            canonical_count: res.count_canonical_sets,
            canonical_sets: res.canonical_sets.clone(),
            sample_extremal_set: sample,
            all_extremal_sets: res.extremal_sets.clone(),
        });

        println!(
            "| {:2} |  {:2}  | {:14} | {:9} |   {:.4}    |   {:.4}    |      {:+0.4}      | {:8.2}  |",
            n,
            res.max_cardinality,
            res.count_max_sets,
            res.count_canonical_sets,
            density,
            asymptotic_ratio,
            erdos_turan_dev,
            elapsed.as_secs_f64() * 1000.0
        );
    }

    let total_elapsed = start_all.elapsed();
    println!("\n[*] Complete frontier N=1..{} computed in {:.2}s", max_n, total_elapsed.as_secs_f64());
    println!("[*] Total extremal Sidon configurations cataloged: {}", total_configs);
    println!("[*] OEIS A003022 consistency check: {}", if oeis_verified { "PASSED (100% MATCH)" } else { "FAILED" });

    // Output JSON report
    let report = GlobalReport {
        timestamp: "2026-08-26T00:43:00Z".to_string(),
        max_n,
        total_extremal_configurations: total_configs,
        oeis_match_verified: oeis_verified,
        records,
    };

    let target_paths = [
        "../data/sidon_frontier_results_n35.json",
        "projects/02-counterexample-observatory/data/sidon_frontier_results_n35.json",
    ];

    let json_str = serde_json::to_string_pretty(&report).expect("Failed to serialize report JSON");

    for p_str in target_paths {
        let p = Path::new(p_str);
        if let Some(parent) = p.parent() {
            let _ = fs::create_dir_all(parent);
        }
        if let Ok(mut file) = File::create(p) {
            let _ = file.write_all(json_str.as_bytes());
            println!("[*] Saved JSON dataset to: {}", p.display());
            break;
        }
    }
}
