mod generator;

use generator::compute_mian_chowla_sieve;
use std::fs::File;
use std::io::Write;
use std::time::Instant;

fn main() {
    println!("===============================================================");
    println!("    MIAN-CHOWLA GREEDY SIDON SEQUENCE FRONTIER ENGINE         ");
    println!("===============================================================");

    let target_n = 5000;
    println!("\n--- 1. COMPUTING MIAN-CHOWLA SEQUENCE (N = {}) ---", target_n);
    let start = Instant::now();

    let output = compute_mian_chowla_sieve(target_n);

    println!("\n--- 2. GROWTH & ASYMPTOTIC MILESTONES ---");
    println!("{:<6} | {:<14} | {:<14} | {:<14} | {:<16}", "n", "a_n", "a_n / n^3", "a_n / n^2", "Total Diffs");
    println!("{:-<6}-|-{:-<14}-|-{:-<14}-|-{:-<14}-|-{:-<16}", "", "", "", "", "");
    for m in &output.milestones {
        println!(
            "{:<6} | {:<14} | {:<14.6} | {:<14.4} | {:<16}",
            m.n, m.a_n, m.ratio_over_n3, m.ratio_over_n2, m.total_differences
        );
    }

    println!("\n--- 3. VERIFICATION SUMMARY ---");
    println!("OEIS A005282 Initial 50 Terms Match: {}", output.oeis_a005282_match);
    println!("Total Terms Computed: {}", output.total_terms_computed);
    println!("Final Term a_{}: {}", output.max_n, output.final_term);
    println!("Total Execution Time: {:?} ({}ms)", start.elapsed(), output.execution_time_ms);

    let json_path = "../data/mian_chowla_frontier_n5000.json";
    let mut file = File::create(json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&output).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("\nExported machine-readable results to {}", json_path);
}
