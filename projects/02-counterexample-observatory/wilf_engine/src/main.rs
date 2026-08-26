mod semigroup;
mod tree;
mod generators;

use std::fs::File;
use std::io::Write;
use std::time::Instant;
use semigroup::NumericalSemigroupRecord;

// Reference counts from OEIS A007323 for genus 0..16
const OEIS_A007323: [usize; 17] = [
    1, 1, 2, 4, 7, 12, 23, 39, 67, 118, 204, 343, 592, 1001, 1693, 2857, 4806,
];

fn main() {
    println!("===============================================================");
    println!("  WILF'S CONJECTURE FINITE FRONTIER & FROBENIUS CERTIFIER");
    println!("===============================================================");

    let start_time = Instant::now();

    // 1. Exhaustive Tree Traversal up to genus 16
    let max_tree_genus = 16;
    println!("-> Running exhaustive tree generation up to genus {}...", max_tree_genus);
    let t0 = Instant::now();
    let (genus_counts, tree_semigroups) = tree::count_semigroups_up_to_genus(max_tree_genus);
    let tree_time = t0.elapsed();

    println!("   Tree generated {} semigroups in {:?}", tree_semigroups.len(), tree_time);

    // Verify against OEIS A007323
    let mut oeis_match = true;
    for g in 0..=max_tree_genus {
        let actual = genus_counts[g];
        let expected = OEIS_A007323[g];
        if actual != expected {
            println!("   [OEIS MISMATCH] genus {}: actual {} != expected {}", g, actual, expected);
            oeis_match = false;
        }
    }
    if oeis_match {
        println!("   [OEIS A007323] 100% agreement across all genera 0..{}", max_tree_genus);
    }

    // 2. Parametric Generators up to genus 60
    let max_param_genus = 60;
    println!("-> Running parametric generators up to genus {}...", max_param_genus);
    let t1 = Instant::now();
    let param_semigroups = generators::generate_parametric_semigroups(max_param_genus);
    let param_time = t1.elapsed();
    println!("   Generated {} parametric semigroups in {:?}", param_semigroups.len(), param_time);

    // Combine all semigroups
    let mut all_semigroups = tree_semigroups;
    all_semigroups.extend(param_semigroups);

    println!("---------------------------------------------------------------");
    println!("-> Auditing Wilf's inequality F(S)+1 <= e(S)*n(S) on {} semigroups...", all_semigroups.len());

    let mut counterexamples = 0;
    let mut min_defect = isize::MAX;
    let mut max_ratio = 0.0f64;
    let mut tight_cases = Vec::new();
    let mut records: Vec<NumericalSemigroupRecord> = Vec::new();

    for s in &all_semigroups {
        let rec = s.to_record();
        if rec.wilf_defect < 0 {
            println!("   [COUNTEREXAMPLE FOUND!] {:?}", rec);
            counterexamples += 1;
        }

        if rec.wilf_defect < min_defect && rec.genus > 0 {
            min_defect = rec.wilf_defect;
        }
        if rec.wilf_ratio > max_ratio && rec.genus > 0 {
            max_ratio = rec.wilf_ratio;
        }

        // Collect tightest cases (Wilf ratio >= 0.85 or defect <= 5 for genus >= 5)
        if (rec.wilf_ratio >= 0.85 || rec.wilf_defect <= 5) && rec.genus >= 3 {
            tight_cases.push(rec.clone());
        }

        records.push(rec);
    }

    // Sort records by Wilf ratio descending
    records.sort_by(|a, b| b.wilf_ratio.partial_cmp(&a.wilf_ratio).unwrap());

    println!("   Counterexamples found: {}", counterexamples);
    println!("   Total semigroups tested: {}", records.len());
    println!("   Min positive Wilf defect: {}", min_defect);
    println!("   Max observed Wilf ratio: {:.6}", max_ratio);
    println!("   Strict Wilf Conjecture holds: {}", counterexamples == 0);

    assert_eq!(counterexamples, 0, "Wilf's conjecture violated!");

    // Export dataset (top 500 representative / tightest records)
    let export_records: Vec<_> = records.iter().take(500).cloned().collect();
    let json_paths = [
        "../data/wilf_semigroups_frontier.json",
        "projects/02-counterexample-observatory/data/wilf_semigroups_frontier.json",
    ];

    let json_data = serde_json::to_string_pretty(&export_records).expect("Serialization failed");
    for path in &json_paths {
        if let Ok(mut f) = File::create(path) {
            f.write_all(json_data.as_bytes()).expect("Write failed");
            println!("   Dataset written to {}", path);
            break;
        }
    }

    let total_elapsed = start_time.elapsed();
    println!("---------------------------------------------------------------");
    println!(" Completed full Wilf conjecture audit in {:?}", total_elapsed);
    println!("===============================================================");
}
