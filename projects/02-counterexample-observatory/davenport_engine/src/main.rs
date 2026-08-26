mod davenport;
mod group;

use davenport::{analyze_group, GroupDavenportRecord};
use group::FiniteGroup;
use rayon::prelude::*;
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::Write;
use std::time::Instant;

#[derive(Debug, Serialize, Deserialize)]
pub struct DavenportRunOutput {
    pub timestamp: String,
    pub group_records: Vec<GroupDavenportRecord>,
    pub total_groups_analyzed: usize,
    pub non_abelian_groups_analyzed: usize,
    pub all_theorems_verified: bool,
    pub execution_time_ms: u128,
}

fn main() {
    println!("===============================================================");
    println!("   NON-ABELIAN GROUP DAVENPORT CONSTANT RESEARCH SUITE        ");
    println!("===============================================================");

    let total_start = Instant::now();

    // 1. Instantiate Group Catalog
    let mut groups = Vec::new();

    // Dihedral Groups
    groups.push(FiniteGroup::dihedral(3)); // D_6
    groups.push(FiniteGroup::dihedral(4)); // D_8
    groups.push(FiniteGroup::dihedral(5)); // D_10
    groups.push(FiniteGroup::dihedral(6)); // D_12
    groups.push(FiniteGroup::dihedral(7)); // D_14
    groups.push(FiniteGroup::dihedral(8)); // D_16
    groups.push(FiniteGroup::dihedral(9)); // D_18
    groups.push(FiniteGroup::dihedral(10)); // D_20
    groups.push(FiniteGroup::dihedral(12)); // D_24
    groups.push(FiniteGroup::dihedral(16)); // D_32

    // Dicyclic / Quaternion Groups
    groups.push(FiniteGroup::dicyclic(2)); // Q_8
    groups.push(FiniteGroup::dicyclic(3)); // Dic_3
    groups.push(FiniteGroup::dicyclic(4)); // Q_16
    groups.push(FiniteGroup::dicyclic(5)); // Dic_5
    groups.push(FiniteGroup::dicyclic(6)); // Dic_6
    groups.push(FiniteGroup::dicyclic(8)); // Q_32

    // Alternating and Semidihedral Groups
    groups.push(FiniteGroup::alternating_4()); // A_4
    groups.push(FiniteGroup::semidihedral_16()); // SD_16

    // Frobenius Groups
    groups.push(FiniteGroup::frobenius_20()); // F_20
    groups.push(FiniteGroup::frobenius_21()); // F_21

    // Direct Products
    let z2 = FiniteGroup::cyclic(2);
    let z4 = FiniteGroup::cyclic(4);
    let d8 = FiniteGroup::dihedral(4);
    let q8 = FiniteGroup::dicyclic(2);
    let d6 = FiniteGroup::dihedral(3);

    groups.push(d6.direct_product(&z2)); // D_6 x Z_2
    groups.push(d8.direct_product(&z2)); // D_8 x Z_2
    groups.push(q8.direct_product(&z2)); // Q_8 x Z_2
    groups.push(d8.direct_product(&z4)); // D_8 x Z_4
    groups.push(q8.direct_product(&z4)); // Q_8 x Z_4

    // Abelian Controls for Baseline Calibration
    groups.push(FiniteGroup::cyclic(6));
    groups.push(FiniteGroup::cyclic(8));
    groups.push(z2.direct_product(&z2)); // Z_2 x Z_2
    groups.push(z2.direct_product(&z4)); // Z_2 x Z_4
    groups.push(z2.direct_product(&z2).direct_product(&z2)); // Z_2^3
    groups.push(FiniteGroup::cyclic(12));
    groups.push(FiniteGroup::cyclic(16));

    println!("Constructed {} test groups (all Cayley tables validated).", groups.len());

    // 2. Parallel Davenport Constant Analysis
    let records: Vec<GroupDavenportRecord> = groups
        .par_iter()
        .map(|g| {
            let rec = analyze_group(g);
            println!(
                "  [{:<18}] |G| = {:>2} | Abelian = {:<5} | d_seq(G) = {:>2} | D_perm(G) = {:>2} | Valid = {} | Time = {:>4}ms",
                rec.name,
                rec.order,
                rec.is_abelian,
                rec.ordered_davenport,
                rec.unordered_davenport,
                rec.obeys_theoretical_bounds,
                rec.execution_time_ms
            );
            rec
        })
        .collect();

    let elapsed = total_start.elapsed();
    let non_abelian_count = records.iter().filter(|r| !r.is_abelian).count();
    let all_valid = records.iter().all(|r| r.obeys_theoretical_bounds);

    println!("\n===============================================================");
    println!("TOTAL COMPUTATION TIME: {:?}", elapsed);
    println!("TOTAL GROUPS ANALYZED: {}", records.len());
    println!("NON-ABELIAN GROUPS ANALYZED: {}", non_abelian_count);
    println!("ALL THEORETICAL BOUNDS (D_perm(G) <= d_seq(G) <= |G|) VERIFIED: {}", all_valid);
    println!("===============================================================");

    let output = DavenportRunOutput {
        timestamp: "2026-08-26T00:52:00+02:00".to_string(),
        group_records: records,
        total_groups_analyzed: groups.len(),
        non_abelian_groups_analyzed: non_abelian_count,
        all_theorems_verified: all_valid,
        execution_time_ms: elapsed.as_millis(),
    };

    let json_path = "../data/davenport_results_g32.json";
    let mut file = File::create(json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&output).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("Exported machine-readable results to {}", json_path);
}
