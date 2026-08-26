mod lyndon;
mod eulerian;

use std::fs::File;
use std::io::Write;
use std::time::Instant;
use serde::{Serialize, Deserialize};
use num_bigint::BigUint;
use num_traits::One;

#[derive(Serialize, Deserialize, Debug, Clone)]
struct DeBruijnRecord {
    k: usize,
    n: usize,
    sequence_length: usize,
    expected_ngrams: usize,
    observed_unique_ngrams: usize,
    is_valid_debruijn: bool,
    theoretical_total_sequences: String,
    exact_eulerian_cycles_counted: Option<usize>,
    lexicographically_first_sequence: Vec<usize>,
}

fn compute_theoretical_count(k: usize, n: usize) -> BigUint {
    // N(k, n) = (k!)^(k^(n-1)) / k^n
    let mut k_fact = BigUint::one();
    for i in 1..=k {
        k_fact *= BigUint::from(i);
    }

    let exp = k.pow((n - 1) as u32);
    let numerator = k_fact.pow(exp as u32);
    let denominator = BigUint::from(k).pow(n as u32);

    numerator / denominator
}

fn main() {
    println!("===============================================================");
    println!("  DE BRUIJN UNIVERSAL SEQUENCE FRONTIER & EXACT CERTIFIER");
    println!("===============================================================");

    let start_time = Instant::now();
    let mut records = Vec::new();

    let target_instances = vec![
        // (k, n)
        (2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6),
        (3, 1), (3, 2), (3, 3), (3, 4),
        (4, 1), (4, 2), (4, 3),
    ];

    for &(k, n) in &target_instances {
        let t0 = Instant::now();
        let seq = lyndon::generate_debruijn_fkm(k, n);
        let (is_valid, unique_count, expected_count) = lyndon::verify_debruijn_coverage(&seq, k, n);
        let elapsed_gen = t0.elapsed();

        let theo_count = compute_theoretical_count(k, n);

        // For small instances, count exact Eulerian cycles to certify theoretical formula
        let eulerian_count = if (k == 2 && n <= 4) || (k == 3 && n <= 2) || (k == 4 && n <= 1) {
            let graph = eulerian::DeBruijnGraph::new(k, n);
            let c = graph.count_eulerian_cycles();
            println!("   [Graph Check] (k={}, n={}): exact {} distinct de Bruijn sequences (matches theoretical: {})",
                k, n, c, BigUint::from(c) == theo_count);
            Some(c)
        } else {
            None
        };

        println!("-> (k={}, n={}): len={} | unique n-grams={}/{} | valid={} | total N(k,n)={} | time={:?}",
            k, n, seq.len(), unique_count, expected_count, is_valid, theo_count, elapsed_gen);

        assert!(is_valid, "De Bruijn sequence generation failed for k={}, n={}", k, n);

        records.push(DeBruijnRecord {
            k,
            n,
            sequence_length: seq.len(),
            expected_ngrams: expected_count,
            observed_unique_ngrams: unique_count,
            is_valid_debruijn: is_valid,
            theoretical_total_sequences: theo_count.to_string(),
            exact_eulerian_cycles_counted: eulerian_count,
            lexicographically_first_sequence: seq,
        });
    }

    let total_elapsed = start_time.elapsed();
    println!("---------------------------------------------------------------");
    println!(" Certified {} parameter configurations in {:?}", records.len(), total_elapsed);
    println!(" All sequences satisfy 100% cyclic n-gram window coverage.");

    // Write to JSON dataset (handle both local execution and repo root execution)
    let json_paths = [
        "../data/debruijn_sequences_frontier.json",
        "projects/02-counterexample-observatory/data/debruijn_sequences_frontier.json",
    ];

    let json_data = serde_json::to_string_pretty(&records).expect("Failed to serialize records");
    for path in &json_paths {
        if let Ok(mut file) = File::create(path) {
            file.write_all(json_data.as_bytes()).expect("Failed to write dataset");
            println!(" Dataset written to {}", path);
            break;
        }
    }
    println!("===============================================================");
}
