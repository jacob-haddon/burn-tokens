mod balance;
mod generator;
mod linear_extensions;
mod poset;
mod verifier;

use balance::{analyze_poset_balance, PosetBalanceAnalysis};
use generator::generate_all_posets_up_to;
use linear_extensions::compute_extension_stats_dp;
use poset::Poset;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;

#[derive(Serialize, Deserialize, Debug)]
pub struct ExtremalPosetRecord {
    pub n: usize,
    pub index_in_level: usize,
    pub covers: Vec<(usize, usize)>,
    pub adjacency_matrix: Vec<Vec<u8>>,
    pub is_connected: bool,
    pub height: usize,
    pub width: usize,
    pub total_extensions: u64,
    pub delta_num: u64,
    pub delta_den: u64,
    pub delta_float: f64,
    pub most_balanced_pair: Option<(usize, usize)>,
    pub incomparable_pairs: Vec<((usize, usize), u64, u64)>, // ((u, v), e(u<v), e(v<u))
}

#[derive(Serialize, Deserialize, Debug)]
pub struct LevelSummary {
    pub n: usize,
    pub total_posets: usize,
    pub total_orders: usize,
    pub non_total_orders_tested: usize,
    pub posets_satisfying_conjecture: usize,
    pub counterexamples_found: usize,
    pub strictly_one_third_count: usize,
    pub min_balance_num: u64,
    pub min_balance_den: u64,
    pub min_balance_float: f64,
    pub max_balance_float: f64,
    pub avg_balance_float: f64,
    pub elapsed_ms: u128,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct FullRunReport {
    pub timestamp: String,
    pub max_n: usize,
    pub level_summaries: Vec<LevelSummary>,
    pub total_posets_checked: usize,
    pub total_counterexamples: usize,
    pub extremal_posets: Vec<ExtremalPosetRecord>,
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    // Run self-tests
    if let Err(e) = verifier::run_self_tests() {
        eprintln!("Self-test failed: {}", e);
        std::process::exit(1);
    }

    let max_n: usize = if args.len() > 1 {
        args[1].parse().unwrap_or(8)
    } else {
        8
    };

    println!("\n========================================================");
    println!("  1/3–2/3 POSET CONJECTURE EXHAUSTIVE FRONTIER SEARCH");
    println!("  Testing all non-isomorphic posets up to n = {}", max_n);
    println!("========================================================\n");

    let total_start = Instant::now();
    let gen_start = Instant::now();
    let levels = generate_all_posets_up_to(max_n);
    let gen_elapsed = gen_start.elapsed();
    println!("Poset generation complete in {:.3?}\n", gen_elapsed);

    let mut level_summaries = Vec::new();
    let mut all_extremal_records = Vec::new();
    let mut total_posets_checked = 0;
    let mut total_counterexamples = 0;

    for n in 1..=max_n {
        let level_start = Instant::now();
        let posets = &levels[n];
        let num_posets = posets.len();
        total_posets_checked += num_posets;

        println!("--------------------------------------------------------");
        println!("Analyzing Level n = {} ({} non-isomorphic posets)...", n, num_posets);

        // Parallel analysis of all posets at level n
        let analyses: Vec<(usize, &Poset, PosetBalanceAnalysis)> = posets
            .par_iter()
            .enumerate()
            .map(|(idx, p)| {
                let stats = compute_extension_stats_dp(p);
                let analysis = analyze_poset_balance(stats);
                (idx, p, analysis)
            })
            .collect();

        let mut total_orders = 0;
        let mut satisfied_count = 0;
        let mut counterexample_count = 0;
        let mut strictly_one_third = 0;
        let mut min_balance = 1.0f64;
        let mut min_bal_num = 1u64;
        let mut min_bal_den = 1u64;
        let mut max_balance = 0.0f64;
        let mut balance_sum = 0.0f64;
        let mut non_total_count = 0;

        for &(idx, p, ref bal) in &analyses {
            if bal.is_total_order {
                total_orders += 1;
            } else {
                non_total_count += 1;
                balance_sum += bal.delta_float;
                if bal.delta_float < min_balance {
                    min_balance = bal.delta_float;
                    min_bal_num = bal.delta_num;
                    min_bal_den = bal.delta_den;
                }
                if bal.delta_float > max_balance {
                    max_balance = bal.delta_float;
                }

                if bal.satisfies_conjecture {
                    satisfied_count += 1;
                } else {
                    counterexample_count += 1;
                    println!(
                        "  [!!! COUNTEREXAMPLE FOUND !!!] n={}, index={}, delta={}/{} ({:.6})",
                        n, idx, bal.delta_num, bal.delta_den, bal.delta_float
                    );
                }

                if bal.is_strictly_one_third {
                    strictly_one_third += 1;

                    // Build extremal record
                    let mut incomp_details = Vec::new();
                    for pair in &bal.incomparable_pair_details {
                        incomp_details.push(((pair.u, pair.v), pair.e_u_less_v, pair.e_v_less_u));
                    }

                    let mut adj = vec![vec![0u8; n]; n];
                    for u in 0..n {
                        for v in 0..n {
                            if p.is_less(u, v) {
                                adj[u][v] = 1;
                            }
                        }
                    }

                    all_extremal_records.push(ExtremalPosetRecord {
                        n,
                        index_in_level: idx,
                        covers: p.hasse_covers(),
                        adjacency_matrix: adj,
                        is_connected: p.is_connected(),
                        height: p.height(),
                        width: p.width(),
                        total_extensions: bal.total_extensions,
                        delta_num: bal.delta_num,
                        delta_den: bal.delta_den,
                        delta_float: bal.delta_float,
                        most_balanced_pair: bal.most_balanced_pair,
                        incomparable_pairs: incomp_details,
                    });
                }
            }
        }

        let elapsed = level_start.elapsed();
        total_counterexamples += counterexample_count;

        let avg_balance = if non_total_count > 0 {
            balance_sum / non_total_count as f64
        } else {
            0.0
        };

        let summary = LevelSummary {
            n,
            total_posets: num_posets,
            total_orders,
            non_total_orders_tested: non_total_count,
            posets_satisfying_conjecture: satisfied_count,
            counterexamples_found: counterexample_count,
            strictly_one_third_count: strictly_one_third,
            min_balance_num: if non_total_count > 0 { min_bal_num } else { 0 },
            min_balance_den: if non_total_count > 0 { min_bal_den } else { 1 },
            min_balance_float: if non_total_count > 0 { min_balance } else { 0.0 },
            max_balance_float: max_balance,
            avg_balance_float: avg_balance,
            elapsed_ms: elapsed.as_millis(),
        };

        println!("  Total posets: {}", num_posets);
        println!("  Total orders (trivial): {}", total_orders);
        println!("  Tested posets with >=1 incomparable pair: {}", non_total_count);
        println!("  Satisfying 1/3-2/3 conjecture (delta >= 1/3): {}", satisfied_count);
        println!("  Counterexamples (delta < 1/3): {}", counterexample_count);
        println!("  Strictly extremal posets (delta == 1/3): {}", strictly_one_third);
        if non_total_count > 0 {
            println!(
                "  Min balance delta_min: {}/{} = {:.6}",
                min_bal_num, min_bal_den, min_balance
            );
            println!("  Max balance delta_max: {:.6}", max_balance);
            println!("  Average balance: {:.6}", avg_balance);
        }
        println!("  Time for level {}: {:.3?}", n, elapsed);

        level_summaries.push(summary);
    }

    let total_elapsed = total_start.elapsed();
    println!("\n========================================================");
    println!("  OVERALL RUN SUMMARY");
    println!("========================================================");
    println!("  Total posets checked: {}", total_posets_checked);
    println!("  Total counterexamples: {}", total_counterexamples);
    println!("  Total extremal posets (delta = 1/3): {}", all_extremal_records.len());
    println!("  Total time elapsed: {:.3?}", total_elapsed);

    // Save JSON data artifacts
    let data_dir = Path::new("../data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }

    let report = FullRunReport {
        timestamp: "2026-08-26T00:20:00+02:00".to_string(),
        max_n,
        level_summaries,
        total_posets_checked,
        total_counterexamples,
        extremal_posets: all_extremal_records,
    };

    let filename = format!("frontier_results_n{}.json", max_n);
    let json_path = data_dir.join(&filename);
    let mut file = File::create(&json_path).expect("Unable to create json file");
    let json_str = serde_json::to_string_pretty(&report).expect("JSON serialization failed");
    file.write_all(json_str.as_bytes()).expect("Write failed");
    println!("Detailed results exported to: {}", json_path.display());
}
