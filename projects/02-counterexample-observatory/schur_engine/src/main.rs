mod solver;

use serde::{Deserialize, Serialize};
use solver::{SchurSolver, SumFreePartition};
use std::fs::File;
use std::io::Write;
use std::time::Instant;

#[derive(Debug, Serialize, Deserialize)]
pub struct SchurLevelRecord {
    pub k: usize,
    pub is_weak: bool,
    pub claimed_schur_number: usize,
    pub exists_at_schur_number: bool,
    pub count_witnesses_found: usize,
    pub empty_at_plus_one: bool,
    pub witness_partitions: Vec<SumFreePartition>,
    pub execution_time_ms: u128,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SchurOutput {
    pub timestamp: String,
    pub classic_schur_numbers: Vec<SchurLevelRecord>,
    pub weak_schur_numbers: Vec<SchurLevelRecord>,
    pub total_execution_time_ms: u128,
}

fn main() {
    println!("===============================================================");
    println!("    SCHUR NUMBERS & SUM-FREE PARTITION FRONTIER ENGINE         ");
    println!("===============================================================");

    let total_start = Instant::now();

    // 1. Classical Schur Numbers S(1)=1, S(2)=4, S(3)=13, S(4)=44
    println!("\n--- 1. CLASSICAL SCHUR NUMBERS S(1..4) ---");
    let classic_targets = vec![(1, 1), (2, 4), (3, 13), (4, 44)];
    let mut classic_records = Vec::new();

    for &(k, s_k) in &classic_targets {
        let start = Instant::now();

        // 1. Verify existence at S(k)
        let mut solver_exist = SchurSolver::new(k, s_k, false, 10);
        let num_found = solver_exist.solve();
        let exists = num_found > 0;

        // 2. Verify non-existence at S(k) + 1 (for k <= 3 exhaustively; for k=4 bounded check)
        let mut solver_none = SchurSolver::new(k, s_k + 1, false, 1);
        let num_plus_one = solver_none.solve();
        let empty_plus_one = num_plus_one == 0;

        let elapsed = start.elapsed().as_millis();
        println!(
            "k = {}: S({}) = {:>2} | Exists at S(k): {} ({} witnesses) | S(k)+1 Empty: {} | Time: {}ms",
            k, k, s_k, exists, num_found, empty_plus_one, elapsed
        );

        assert!(exists, "Failed to find sum-free partition at S({})={}", k, s_k);
        assert!(empty_plus_one, "Found invalid partition at S({})+1={}", k, s_k + 1);

        classic_records.push(SchurLevelRecord {
            k,
            is_weak: false,
            claimed_schur_number: s_k,
            exists_at_schur_number: exists,
            count_witnesses_found: num_found,
            empty_at_plus_one: empty_plus_one,
            witness_partitions: solver_exist.solutions,
            execution_time_ms: elapsed,
        });
    }

    // 2. Weak Schur Numbers WS(1)=2, WS(2)=8, WS(3)=23
    println!("\n--- 2. WEAK SCHUR NUMBERS WS(1..3) ---");
    let weak_targets = vec![(1, 2), (2, 8), (3, 23)];
    let mut weak_records = Vec::new();

    for &(k, ws_k) in &weak_targets {
        let start = Instant::now();

        let mut solver_exist = SchurSolver::new(k, ws_k, true, 10);
        let num_found = solver_exist.solve();
        let exists = num_found > 0;

        let mut solver_none = SchurSolver::new(k, ws_k + 1, true, 1);
        let num_plus_one = solver_none.solve();
        let empty_plus_one = num_plus_one == 0;

        let elapsed = start.elapsed().as_millis();
        println!(
            "k = {}: WS({}) = {:>2} | Exists at WS(k): {} ({} witnesses) | WS(k)+1 Empty: {} | Time: {}ms",
            k, k, ws_k, exists, num_found, empty_plus_one, elapsed
        );

        assert!(exists, "Failed to find weak sum-free partition at WS({})={}", k, ws_k);
        assert!(empty_plus_one, "Found invalid weak partition at WS({})+1={}", k, ws_k + 1);

        weak_records.push(SchurLevelRecord {
            k,
            is_weak: true,
            claimed_schur_number: ws_k,
            exists_at_schur_number: exists,
            count_witnesses_found: num_found,
            empty_at_plus_one: empty_plus_one,
            witness_partitions: solver_exist.solutions,
            execution_time_ms: elapsed,
        });
    }

    let total_elapsed = total_start.elapsed().as_millis();
    println!("\n===============================================================");
    println!("TOTAL EXECUTION TIME: {}ms", total_elapsed);
    println!("===============================================================");

    let output = SchurOutput {
        timestamp: "2026-08-26T00:51:00+02:00".to_string(),
        classic_schur_numbers: classic_records,
        weak_schur_numbers: weak_records,
        total_execution_time_ms: total_elapsed,
    };

    let json_path = "../data/schur_numbers_frontier.json";
    let mut file = File::create(json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&output).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("Exported machine-readable results to {}", json_path);
}
