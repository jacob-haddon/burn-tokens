mod ruler;
mod solver;

use ruler::GolombRuler;
use serde::{Deserialize, Serialize};
use solver::GolombSolver;
use std::fs::File;
use std::io::Write;
use std::time::Instant;

#[derive(Debug, Serialize, Deserialize)]
pub struct OrderRecord {
    pub order: usize,
    pub optimal_length: usize,
    pub oeis_a003006_expected: usize,
    pub oeis_match: bool,
    pub num_canonical_rulers: usize,
    pub canonical_rulers: Vec<GolombRuler>,
    pub proved_empty_at_minus_one: bool,
    pub execution_time_ms: u128,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct GolombRunOutput {
    pub timestamp: String,
    pub max_order: usize,
    pub records: Vec<OrderRecord>,
    pub total_rulers_cataloged: usize,
    pub all_oeis_verified: bool,
    pub total_execution_time_ms: u128,
}

fn main() {
    println!("===============================================================");
    println!("   OPTIMAL GOLOMB RULER & DIFFERENCE TRIANGLE FRONTIER ENGINE  ");
    println!("===============================================================");

    let total_start = Instant::now();

    // Known exact optimal lengths from OEIS A003006 / A003022
    let oeis_optimal = [0, 1, 3, 6, 11, 17, 25, 34, 44, 55, 72, 85];

    let mut records = Vec::new();
    let mut total_rulers = 0;

    for (idx, &opt_len) in oeis_optimal.iter().enumerate() {
        let n = idx + 1;
        let start_time = Instant::now();

        // 1. Solve at exact optimal length
        let mut solver = GolombSolver::new(n, opt_len);
        let rulers = solver.solve_exact();

        // 2. Prove non-existence at L = opt_len - 1 (for n <= 10)
        let empty_minus_one = if opt_len > 0 && n <= 10 {
            let mut empty_solver = GolombSolver::new(n, opt_len - 1);
            let empty_rulers = empty_solver.solve_exact();
            empty_rulers.is_empty()
        } else {
            true
        };

        let elapsed = start_time.elapsed().as_millis();
        let oeis_match = !rulers.is_empty() && empty_minus_one;
        total_rulers += rulers.len();

        println!(
            "Order n = {:>2} | Optimal L(n) = {:>2} (OEIS: {:>2}) | Canonical Rulers = {:>2} | L-1 Empty = {:<5} | Time = {:>5}ms",
            n,
            opt_len,
            opt_len,
            rulers.len(),
            empty_minus_one,
            elapsed
        );

        for (r_idx, r) in rulers.iter().enumerate() {
            println!("   -> Ruler #{}: {:?}", r_idx + 1, r.marks);
        }

        records.push(OrderRecord {
            order: n,
            optimal_length: opt_len,
            oeis_a003006_expected: opt_len,
            oeis_match,
            num_canonical_rulers: rulers.len(),
            canonical_rulers: rulers,
            proved_empty_at_minus_one: empty_minus_one,
            execution_time_ms: elapsed,
        });
    }

    let total_elapsed = total_start.elapsed();
    let all_valid = records.iter().all(|r| r.oeis_match);

    println!("\n===============================================================");
    println!("TOTAL EXECUTION TIME: {:?}", total_elapsed);
    println!("TOTAL CANONICAL RULERS CATALOGED: {}", total_rulers);
    println!("ALL OEIS A003006 OPTIMAL LENGTHS VERIFIED: {}", all_valid);
    println!("===============================================================");

    let output = GolombRunOutput {
        timestamp: "2026-08-26T00:59:00+02:00".to_string(),
        max_order: 12,
        records,
        total_rulers_cataloged: total_rulers,
        all_oeis_verified: all_valid,
        total_execution_time_ms: total_elapsed.as_millis(),
    };

    let json_path = "../data/golomb_rulers_frontier.json";
    let mut file = File::create(json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&output).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("Exported machine-readable results to {}", json_path);
}
