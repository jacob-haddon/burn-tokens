mod family;
mod generator;
mod verifier;

use family::FamilyStats;
use generator::{generate_all_exhaustive, generate_canonical_basis_frontier};
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;

#[derive(Serialize, Deserialize, Debug)]
pub struct ExtremalFamilyRecord {
    pub universe_size: usize,
    pub active_elements: usize,
    pub size: usize,
    pub contains_empty: bool,
    pub is_separating: bool,
    pub sets_hex: Vec<String>,
    pub element_frequencies: Vec<usize>,
    pub max_frequency: usize,
    pub max_freq_num: usize,
    pub max_freq_den: usize,
    pub max_freq_float: f64,
    pub best_elements: Vec<usize>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ExperimentSummary {
    pub experiment_name: String,
    pub universe_size: usize,
    pub search_type: String,
    pub total_candidates_tested: usize,
    pub union_closed_families: usize,
    pub nontrivial_families: usize,
    pub counterexamples_found: usize,
    pub strictly_half_count: usize,
    pub min_max_freq_num: usize,
    pub min_max_freq_den: usize,
    pub min_max_freq_float: f64,
    pub avg_max_freq_float: f64,
    pub elapsed_ms: u128,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct FranklRunReport {
    pub timestamp: String,
    pub total_families_analyzed: usize,
    pub total_counterexamples: usize,
    pub total_strictly_half: usize,
    pub experiments: Vec<ExperimentSummary>,
    pub extremal_families: Vec<ExtremalFamilyRecord>,
}

fn main() {
    // Run self-tests
    if let Err(e) = verifier::run_self_tests() {
        eprintln!("Self-test failed: {}", e);
        std::process::exit(1);
    }

    println!("========================================================");
    println!("  FRANKL'S UNION-CLOSED SETS CONJECTURE STRESS TEST");
    println!("  Exact Bitmask Search & Extremal Ratio Characterization");
    println!("========================================================\n");

    let total_start = Instant::now();
    let mut experiment_summaries = Vec::new();
    let mut all_extremal_records = Vec::new();
    let mut total_families_analyzed = 0;
    let mut total_counterexamples = 0;

    // Part 1: Exhaustive Power-Set Subsets for m = 1, 2, 3, 4
    for m in 1..=4 {
        let exp_start = Instant::now();
        let num_sets = 1usize << m;
        let total_cands = 1usize << num_sets;

        println!("--------------------------------------------------------");
        println!(
            "Running Exhaustive Experiment: Universe m = {} (Total 2^(2^{}) = {} candidate families)...",
            m, m, total_cands
        );

        let uc_families = generate_all_exhaustive(m);
        let num_uc = uc_families.len();
        total_families_analyzed += num_uc;

        let analyses: Vec<FamilyStats> = uc_families.par_iter().map(|f| f.analyze()).collect();

        let mut nontrivial = 0;
        let mut cex_count = 0;
        let mut strictly_half = 0;
        let mut min_max_ratio = 1.0f64;
        let mut min_num = 1;
        let mut min_den = 1;
        let mut sum_max_ratio = 0.0f64;

        for (f, stats) in uc_families.iter().zip(analyses.iter()) {
            if stats.active_elements == 0 {
                continue; // Trivial empty family
            }
            nontrivial += 1;
            sum_max_ratio += stats.max_freq_float;

            if stats.max_freq_float < min_max_ratio {
                min_max_ratio = stats.max_freq_float;
                min_num = stats.max_freq_num;
                min_den = stats.max_freq_den;
            }

            if !stats.satisfies_frankl {
                cex_count += 1;
                println!(
                    "  [!!! COUNTEREXAMPLE FOUND !!!] m={}, size={}, max_freq={}/{} ({:.6})",
                    m, stats.size, stats.max_freq_num, stats.max_freq_den, stats.max_freq_float
                );
            }

            if stats.is_strictly_half {
                strictly_half += 1;
                let sets_hex = f.sets.iter().map(|s| format!("0x{:x}", s)).collect();
                all_extremal_records.push(ExtremalFamilyRecord {
                    universe_size: m,
                    active_elements: stats.active_elements,
                    size: stats.size,
                    contains_empty: stats.contains_empty,
                    is_separating: stats.is_separating,
                    sets_hex,
                    element_frequencies: stats.element_frequencies.clone(),
                    max_frequency: stats.max_frequency,
                    max_freq_num: stats.max_freq_num,
                    max_freq_den: stats.max_freq_den,
                    max_freq_float: stats.max_freq_float,
                    best_elements: stats.best_elements.clone(),
                });
            }
        }

        let elapsed = exp_start.elapsed();
        total_counterexamples += cex_count;
        let avg_max_ratio = if nontrivial > 0 {
            sum_max_ratio / nontrivial as f64
        } else {
            0.0
        };

        let summary = ExperimentSummary {
            experiment_name: format!("Exhaustive m={}", m),
            universe_size: m,
            search_type: "exhaustive_power_set_subsets".to_string(),
            total_candidates_tested: total_cands,
            union_closed_families: num_uc,
            nontrivial_families: nontrivial,
            counterexamples_found: cex_count,
            strictly_half_count: strictly_half,
            min_max_freq_num: min_num,
            min_max_freq_den: min_den,
            min_max_freq_float: min_max_ratio,
            avg_max_freq_float: avg_max_ratio,
            elapsed_ms: elapsed.as_millis(),
        };

        println!("  Union-closed families found: {}", num_uc);
        println!("  Nontrivial families tested: {}", nontrivial);
        println!("  Counterexamples (max freq < 1/2): {}", cex_count);
        println!("  Strictly extremal families (max freq == 1/2): {}", strictly_half);
        println!("  Minimum max-frequency ratio: {}/{} = {:.6}", min_num, min_den, min_max_ratio);
        println!("  Average max-frequency ratio: {:.6}", avg_max_ratio);
        println!("  Time elapsed: {:.3?}", elapsed);

        experiment_summaries.push(summary);
    }

    // Part 2: Structured Basis Frontier Search for m = 5, 6, 7
    let structured_targets = vec![
        (5, 6, "Canonical Basis Frontier m=5 (k<=6 generators)"),
        (6, 5, "Canonical Basis Frontier m=6 (k<=5 generators)"),
        (7, 4, "Canonical Basis Frontier m=7 (k<=4 generators)"),
    ];

    for (m, max_k, desc) in structured_targets {
        let exp_start = Instant::now();
        println!("--------------------------------------------------------");
        println!("Running Frontier Experiment: {}...", desc);

        // Include both families with and without empty set
        let mut families = generate_canonical_basis_frontier(m, max_k, true);
        let families_no_empty = generate_canonical_basis_frontier(m, max_k, false);
        families.extend(families_no_empty);

        // Deduplicate
        families.sort_by(|a, b| a.sets.cmp(&b.sets));
        families.dedup_by(|a, b| a.sets == b.sets);

        let num_families = families.len();
        total_families_analyzed += num_families;

        let analyses: Vec<FamilyStats> = families.par_iter().map(|f| f.analyze()).collect();

        let mut nontrivial = 0;
        let mut cex_count = 0;
        let mut strictly_half = 0;
        let mut min_max_ratio = 1.0f64;
        let mut min_num = 1;
        let mut min_den = 1;
        let mut sum_max_ratio = 0.0f64;

        for (f, stats) in families.iter().zip(analyses.iter()) {
            if stats.active_elements == 0 {
                continue;
            }
            nontrivial += 1;
            sum_max_ratio += stats.max_freq_float;

            if stats.max_freq_float < min_max_ratio {
                min_max_ratio = stats.max_freq_float;
                min_num = stats.max_freq_num;
                min_den = stats.max_freq_den;
            }

            if !stats.satisfies_frankl {
                cex_count += 1;
                println!(
                    "  [!!! COUNTEREXAMPLE FOUND !!!] m={}, size={}, max_freq={}/{} ({:.6})",
                    m, stats.size, stats.max_freq_num, stats.max_freq_den, stats.max_freq_float
                );
            }

            if stats.is_strictly_half {
                strictly_half += 1;
                let sets_hex = f.sets.iter().map(|s| format!("0x{:x}", s)).collect();
                all_extremal_records.push(ExtremalFamilyRecord {
                    universe_size: m,
                    active_elements: stats.active_elements,
                    size: stats.size,
                    contains_empty: stats.contains_empty,
                    is_separating: stats.is_separating,
                    sets_hex,
                    element_frequencies: stats.element_frequencies.clone(),
                    max_frequency: stats.max_frequency,
                    max_freq_num: stats.max_freq_num,
                    max_freq_den: stats.max_freq_den,
                    max_freq_float: stats.max_freq_float,
                    best_elements: stats.best_elements.clone(),
                });
            }
        }

        let elapsed = exp_start.elapsed();
        total_counterexamples += cex_count;
        let avg_max_ratio = if nontrivial > 0 {
            sum_max_ratio / nontrivial as f64
        } else {
            0.0
        };

        let summary = ExperimentSummary {
            experiment_name: desc.to_string(),
            universe_size: m,
            search_type: format!("canonical_basis_closure_k<={}", max_k),
            total_candidates_tested: num_families,
            union_closed_families: num_families,
            nontrivial_families: nontrivial,
            counterexamples_found: cex_count,
            strictly_half_count: strictly_half,
            min_max_freq_num: min_num,
            min_max_freq_den: min_den,
            min_max_freq_float: min_max_ratio,
            avg_max_freq_float: avg_max_ratio,
            elapsed_ms: elapsed.as_millis(),
        };

        println!("  Canonical union-closed families: {}", num_families);
        println!("  Nontrivial families tested: {}", nontrivial);
        println!("  Counterexamples (max freq < 1/2): {}", cex_count);
        println!("  Strictly extremal families (max freq == 1/2): {}", strictly_half);
        println!("  Minimum max-frequency ratio: {}/{} = {:.6}", min_num, min_den, min_max_ratio);
        println!("  Average max-frequency ratio: {:.6}", avg_max_ratio);
        println!("  Time elapsed: {:.3?}", elapsed);

        experiment_summaries.push(summary);
    }

    let total_elapsed = total_start.elapsed();
    println!("\n========================================================");
    println!("  OVERALL RUN SUMMARY");
    println!("========================================================");
    println!("  Total union-closed families analyzed: {}", total_families_analyzed);
    println!("  Total counterexamples found: {}", total_counterexamples);
    println!("  Total extremal families recorded: {}", all_extremal_records.len());
    println!("  Total time elapsed: {:.3?}", total_elapsed);

    // Save JSON data artifacts
    let data_dir = Path::new("../data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }

    let report = FranklRunReport {
        timestamp: "2026-08-26T00:26:00+02:00".to_string(),
        total_families_analyzed,
        total_counterexamples,
        total_strictly_half: all_extremal_records.len(),
        experiments: experiment_summaries,
        extremal_families: all_extremal_records,
    };

    let json_path = data_dir.join("frankl_frontier_results.json");
    let mut file = File::create(&json_path).expect("Unable to create json file");
    let json_str = serde_json::to_string_pretty(&report).expect("JSON serialization failed");
    file.write_all(json_str.as_bytes()).expect("Write failed");
    println!("Detailed results exported to: {}", json_path.display());
}
