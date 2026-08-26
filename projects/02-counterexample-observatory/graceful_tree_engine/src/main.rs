mod generator;
mod solver;
mod tree;
mod verifier;

use generator::generate_all_unrooted_trees;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use solver::{find_graceful_labeling, is_graceful};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;
use tree::Tree;

#[derive(Serialize, Deserialize, Debug)]
pub struct TreeCertificate {
    pub n: usize,
    pub index_in_level: usize,
    pub canonical_code: String,
    pub edges: Vec<(usize, usize)>,
    pub degrees: Vec<usize>,
    pub labeling: Vec<usize>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct LevelSummary {
    pub n: usize,
    pub total_trees: usize,
    pub graceful_trees: usize,
    pub counterexamples_found: usize,
    pub elapsed_ms: u128,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct GracefulTreeReport {
    pub timestamp: String,
    pub max_n: usize,
    pub total_trees_verified: usize,
    pub total_counterexamples: usize,
    pub level_summaries: Vec<LevelSummary>,
    pub sample_certificates: Vec<TreeCertificate>,
}

fn main() {
    let args: Vec<String> = std::env::args().collect();

    // Run self-tests
    if let Err(e) = verifier::run_self_tests() {
        eprintln!("Self-test failed: {}", e);
        std::process::exit(1);
    }

    let max_n: usize = if args.len() > 1 {
        args[1].parse().unwrap_or(16)
    } else {
        16
    };

    println!("========================================================");
    println!("  GRACEFUL TREE CONJECTURE FINITE CERTIFICATE GENERATOR");
    println!("  Testing all non-isomorphic trees up to n = {}", max_n);
    println!("========================================================\n");

    let total_start = Instant::now();
    let mut level_summaries = Vec::new();
    let mut all_sample_certificates = Vec::new();
    let mut total_trees_verified = 0;
    let mut total_counterexamples = 0;

    for n in 1..=max_n {
        let level_start = Instant::now();
        let trees = generate_all_unrooted_trees(n);
        let count = trees.len();
        total_trees_verified += count;

        println!("--------------------------------------------------------");
        println!("Analyzing Level n = {} ({} non-isomorphic trees)...", n, count);

        // Solve graceful labeling in parallel
        let results: Vec<(usize, &Tree, Option<Vec<usize>>)> = trees
            .par_iter()
            .enumerate()
            .map(|(idx, t)| {
                let labeling = find_graceful_labeling(t);
                (idx, t, labeling)
            })
            .collect();

        let mut graceful_count = 0;
        let mut cex_count = 0;

        for (idx, t, labeling_opt) in &results {
            match labeling_opt {
                Some(label) => {
                    assert!(is_graceful(t, label), "Generated labeling is not graceful!");
                    graceful_count += 1;

                    // Keep a few sample certificates per level (or all if small)
                    if *idx < 5 || n <= 10 {
                        all_sample_certificates.push(TreeCertificate {
                            n,
                            index_in_level: *idx,
                            canonical_code: t.canonical_code(),
                            edges: t.edges.clone(),
                            degrees: t.degrees(),
                            labeling: label.clone(),
                        });
                    }
                }
                None => {
                    cex_count += 1;
                    println!("  [!!! COUNTEREXAMPLE FOUND !!!] n={}, tree #{:?}", n, t);
                }
            }
        }

        let elapsed = level_start.elapsed();
        total_counterexamples += cex_count;

        let summary = LevelSummary {
            n,
            total_trees: count,
            graceful_trees: graceful_count,
            counterexamples_found: cex_count,
            elapsed_ms: elapsed.as_millis(),
        };

        println!("  Total trees generated: {}", count);
        println!("  Gracefully labeled trees: {}", graceful_count);
        println!("  Counterexamples (no graceful labeling): {}", cex_count);
        println!("  Time elapsed: {:.3?}", elapsed);

        level_summaries.push(summary);
    }

    let total_elapsed = total_start.elapsed();
    println!("\n========================================================");
    println!("  OVERALL RUN SUMMARY");
    println!("========================================================");
    println!("  Total trees checked: {}", total_trees_verified);
    println!("  Total counterexamples: {}", total_counterexamples);
    println!("  Total time elapsed: {:.3?}", total_elapsed);

    // Save JSON data artifacts
    let data_dir = Path::new("../data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }

    let report = GracefulTreeReport {
        timestamp: "2026-08-26T00:46:00+02:00".to_string(),
        max_n,
        total_trees_verified,
        total_counterexamples,
        level_summaries,
        sample_certificates: all_sample_certificates,
    };

    let filename = format!("graceful_tree_certificates_n{}.json", max_n);
    let json_path = data_dir.join(&filename);
    let mut file = File::create(&json_path).expect("Unable to create json file");
    let json_str = serde_json::to_string_pretty(&report).expect("JSON serialization failed");
    file.write_all(json_str.as_bytes()).expect("Write failed");
    println!("Detailed results exported to: {}", json_path.display());
}
