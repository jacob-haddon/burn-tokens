mod collatz;

use collatz::CollatzEngine;
use std::fs::File;
use std::io::Write;

fn main() {
    println!("===============================================================");
    println!("   COLLATZ TRAJECTORY FRONTIER & STOPPING TIME RECORDS ENGINE   ");
    println!("===============================================================");

    let limit = 100_000_000u64; // 10^8
    let cache_size = 20_000_000usize; // 20M cache elements

    println!("Exploring all starting integers n in 1 ..= {} ...", limit);
    let mut engine = CollatzEngine::new(limit, cache_size);
    let stats = engine.run();

    println!("\n===============================================================");
    println!("TOTAL NUMBERS TESTED: {}", stats.total_numbers_checked);
    println!("TOTAL EXECUTION TIME: {}ms", stats.execution_time_ms);
    println!("COUNTEREXAMPLES FOUND: {}", stats.counterexamples_found);
    println!(
        "MAX STOPPING TIME: {} (achieved by n = {})",
        stats.max_stopping_time_found, stats.max_stopping_time_champion
    );
    println!(
        "MAX PEAK HEIGHT: {} (achieved by n = {})",
        stats.max_peak_height_found, stats.max_peak_height_champion
    );
    println!(
        "TOTAL STOPPING TIME RECORDS: {}",
        stats.count_stopping_time_records
    );
    println!(
        "TOTAL PEAK HEIGHT RECORDS: {}",
        stats.count_peak_height_records
    );
    println!("===============================================================");

    println!("\nTop 10 Stopping Time Champions:");
    for (i, rec) in stats.stopping_time_records.iter().rev().take(10).rev().enumerate() {
        println!(
            "  #{:>2}: n = {:>10} | Stopping Time = {:>5} steps | Peak Height = {:>16}",
            stats.count_stopping_time_records - 10 + i + 1,
            rec.start_n,
            rec.stopping_time,
            rec.peak_height
        );
    }

    println!("\nTop 10 Peak Height Champions:");
    for (i, rec) in stats.peak_height_records.iter().rev().take(10).rev().enumerate() {
        println!(
            "  #{:>2}: n = {:>10} | Peak Height = {:>18} | Stopping Time = {:>5} steps",
            stats.count_peak_height_records - 10 + i + 1,
            rec.start_n,
            rec.peak_height,
            rec.stopping_time
        );
    }

    let json_path = if std::path::Path::new("projects/02-counterexample-observatory/data").exists() {
        std::path::PathBuf::from("projects/02-counterexample-observatory/data/collatz_records_frontier_100m.json")
    } else {
        std::path::PathBuf::from("../data/collatz_records_frontier_100m.json")
    };
    if let Some(parent) = json_path.parent() {
        let _ = std::fs::create_dir_all(parent);
    }
    let mut file = File::create(&json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&stats).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("\nExported machine-readable results to {:?}", json_path);
}
