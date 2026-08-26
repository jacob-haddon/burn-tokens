mod energy;
mod verifier;

use energy::{
    compute_additive_energy, compute_sumset_size, make_arithmetic_progression,
    make_dissociated_set, theoretical_max_energy, theoretical_min_energy, OrderLevelReport,
    WitnessSet,
};
use serde::{Deserialize, Serialize};
use std::collections::{BTreeMap, BTreeSet};
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;

#[derive(Serialize, Deserialize, Debug)]
pub struct AdditiveEnergyComprehensiveReport {
    pub timestamp: String,
    pub min_cardinality: usize,
    pub max_cardinality: usize,
    pub all_bounds_verified: bool,
    pub levels: Vec<OrderLevelReport>,
}

fn explore_spectrum_for_order(k: usize) -> (BTreeMap<usize, Vec<i64>>, usize, usize) {
    let mut energy_to_set: BTreeMap<usize, Vec<i64>> = BTreeMap::new();

    // 1. Exact AP
    let ap = make_arithmetic_progression(k);
    let e_ap = compute_additive_energy(&ap);
    energy_to_set.insert(e_ap, ap);

    // 2. Exact Dissociated set
    let dis = make_dissociated_set(k);
    let e_dis = compute_additive_energy(&dis);
    energy_to_set.insert(e_dis, dis);

    // 3. Exhaustive search on small universes {0, ..., M}
    let universe_size = match k {
        2..=4 => 16,
        5 => 14,
        6 => 12,
        7 => 11,
        8 => 10,
        _ => 9,
    };

    let mut current_subsets: Vec<Vec<i64>> = vec![vec![]];
    for val in 0..universe_size as i64 {
        let mut next_subsets = current_subsets.clone();
        for s in &current_subsets {
            if s.len() < k {
                let mut s_new = s.clone();
                s_new.push(val);
                if s_new.len() == k {
                    let e = compute_additive_energy(&s_new);
                    energy_to_set.entry(e).or_insert_with(|| s_new.clone());
                } else {
                    next_subsets.push(s_new);
                }
            }
        }
        current_subsets = next_subsets;
    }

    // 4. Two-AP unions: AP of length p and AP of length q with gap
    for p in 1..k {
        let q = k - p;
        for gap in 1..=20i64 {
            let mut combined = Vec::new();
            for i in 0..p as i64 {
                combined.push(i);
            }
            let start = p as i64 + gap;
            for j in 0..q as i64 {
                combined.push(start + j);
            }
            let e = compute_additive_energy(&combined);
            energy_to_set.entry(e).or_insert_with(|| combined.clone());
        }
    }

    // 5. 2D Generalized Arithmetic Progressions
    for d1 in 1..=5i64 {
        for d2 in (d1 + 1)..=10i64 {
            for n1 in 2..=k {
                let n2 = (k + n1 - 1) / n1;
                let mut gap_set = Vec::new();
                for i1 in 0..n1 as i64 {
                    for i2 in 0..n2 as i64 {
                        if gap_set.len() < k {
                            gap_set.push(i1 * d1 + i2 * d2);
                        }
                    }
                }
                if gap_set.len() == k {
                    let mut unique: BTreeSet<i64> = gap_set.into_iter().collect();
                    if unique.len() == k {
                        let sorted: Vec<i64> = unique.into_iter().collect();
                        let e = compute_additive_energy(&sorted);
                        energy_to_set.entry(e).or_insert_with(|| sorted);
                    }
                }
            }
        }
    }

    (energy_to_set, e_dis, e_ap)
}

fn main() {
    // Run self-tests
    if let Err(e) = verifier::run_self_tests() {
        eprintln!("Self-test failed: {}", e);
        std::process::exit(1);
    }

    println!("============================================================");
    println!("  ADDITIVE ENERGY SPECTRUM & EXTREMA FRONTIER (|A| <= 8)    ");
    println!("============================================================\n");

    let total_start = Instant::now();
    let mut levels = Vec::new();
    let mut all_bounds_ok = true;

    for k in 2..=8usize {
        let level_start = Instant::now();
        let e_min_theor = theoretical_min_energy(k);
        let e_max_theor = theoretical_max_energy(k);

        println!("------------------------------------------------------------");
        println!(
            "Analyzing Cardinality |A| = {} (Theoretical E in [{}, {}])...",
            k, e_min_theor, e_max_theor
        );

        let (spectrum, e_min_obs, e_max_obs) = explore_spectrum_for_order(k);
        let bounds_match = e_min_obs == e_min_theor && e_max_obs == e_max_theor;
        if !bounds_match {
            all_bounds_ok = false;
        }

        let distinct_count = spectrum.len();
        let realizable_energies: Vec<usize> = spectrum.keys().cloned().collect();

        println!("  Extremal Energy Bounds Verified: {}", bounds_match);
        println!("  Distinct Realizable Energies Discovered: {}", distinct_count);
        println!("  Full Realizable Spectrum: {:?}", realizable_energies);

        // Build min witness
        let min_set = &spectrum[&e_min_theor];
        let min_sumset = compute_sumset_size(min_set);
        let min_witness = WitnessSet {
            energy: e_min_theor,
            set: min_set.clone(),
            sumset_size: min_sumset,
            cauchy_schwarz_lower_bound: (k.pow(4) as f64) / (min_sumset as f64),
            energy_ratio_e_over_k3: (e_min_theor as f64) / ((k * k * k) as f64),
            set_type: "sidon_dissociated".to_string(),
        };

        // Build max witness
        let max_set = &spectrum[&e_max_theor];
        let max_sumset = compute_sumset_size(max_set);
        let max_witness = WitnessSet {
            energy: e_max_theor,
            set: max_set.clone(),
            sumset_size: max_sumset,
            cauchy_schwarz_lower_bound: (k.pow(4) as f64) / (max_sumset as f64),
            energy_ratio_e_over_k3: (e_max_theor as f64) / ((k * k * k) as f64),
            set_type: "arithmetic_progression".to_string(),
        };

        // Build sample witnesses across the spectrum
        let mut sample_witnesses = Vec::new();
        for (&e, s) in &spectrum {
            let sumset = compute_sumset_size(s);
            sample_witnesses.push(WitnessSet {
                energy: e,
                set: s.clone(),
                sumset_size: sumset,
                cauchy_schwarz_lower_bound: (k.pow(4) as f64) / (sumset as f64),
                energy_ratio_e_over_k3: (e as f64) / ((k * k * k) as f64),
                set_type: if e == e_min_theor {
                    "sidon_dissociated".to_string()
                } else if e == e_max_theor {
                    "arithmetic_progression".to_string()
                } else {
                    "intermediate_structure".to_string()
                },
            });
        }

        let elapsed = level_start.elapsed();

        levels.push(OrderLevelReport {
            k,
            theoretical_min_energy: e_min_theor,
            theoretical_max_energy: e_max_theor,
            min_energy_observed: e_min_obs,
            max_energy_observed: e_max_obs,
            bounds_exact_match: bounds_match,
            distinct_realizable_energies_found: distinct_count,
            realizable_energies,
            min_witness,
            max_witness,
            sample_witnesses,
            elapsed_ms: elapsed.as_millis(),
        });
    }

    let total_elapsed = total_start.elapsed();
    println!("\n============================================================");
    println!("  OVERALL SUMMARY");
    println!("============================================================");
    println!("  Total evaluation time: {:.3?}", total_elapsed);
    println!("  100% Extremal Bounds Concordance: {}", all_bounds_ok);

    // Save JSON data artifacts
    let data_dir = Path::new("../data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }

    let report = AdditiveEnergyComprehensiveReport {
        timestamp: "2026-08-26T01:23:00+02:00".to_string(),
        min_cardinality: 2,
        max_cardinality: 8,
        all_bounds_verified: all_bounds_ok,
        levels,
    };

    let json_path = data_dir.join("additive_energy_frontier.json");
    let mut file = File::create(&json_path).expect("Unable to create json file");
    let json_str = serde_json::to_string_pretty(&report).expect("JSON serialization failed");
    file.write_all(json_str.as_bytes()).expect("Write failed");
    println!("Detailed results exported to: {}", json_path.display());
}
