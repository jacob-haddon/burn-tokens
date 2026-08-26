mod tree_gen;
mod solver;

use std::fs::File;
use std::io::Write;
use std::time::Instant;
use serde::{Serialize, Deserialize};
use tree_gen::generate_free_trees;
use solver::find_harmonious_labeling;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct HarmoniousCertificate {
    pub n: usize,
    pub m: usize,
    pub tree_id: usize,
    pub canonical_ahu: String,
    pub edges: Vec<(usize, usize)>,
    pub vertex_labels: Vec<usize>,
    pub edge_labels: Vec<usize>,
    pub duplicate_label: usize,
}

// Reference non-isomorphic tree counts from OEIS A000055 for n = 1..12
const OEIS_A000055: [usize; 13] = [
    0, 1, 1, 1, 2, 3, 6, 11, 23, 47, 106, 235, 551,
];

fn main() {
    println!("===============================================================");
    println!("  GRAHAM-SLOANE HARMONIOUS TREE CONJECTURE FINITE CERTIFIER");
    println!("===============================================================");

    let start_time = Instant::now();
    let min_n = 3;
    let max_n = 12;

    let mut total_trees = 0;
    let mut total_solved = 0;
    let mut counterexamples = 0;
    let mut certificates = Vec::new();

    for n in min_n..=max_n {
        let t_start = Instant::now();
        let trees = generate_free_trees(n);
        let count = trees.len();
        total_trees += count;

        let expected = OEIS_A000055[n];
        let match_status = if count == expected { "MATCH" } else { "MISMATCH" };
        println!(
            "-> Order n = {:2} (edges m = {:2}): {:4} trees [{}] (OEIS A000055 = {:4})",
            n, n - 1, count, match_status, expected
        );
        assert_eq!(count, expected, "OEIS tree count mismatch at n = {}", n);

        for (tree_id, tree) in trees.iter().enumerate() {
            let m = n - 1;
            let canon = tree.canonical_encoding();

            if let Some(labels) = find_harmonious_labeling(tree) {
                // Compute edge labels: (f(u) + f(v)) % m
                let mut edge_labels = Vec::with_capacity(m);
                let mut edge_seen = vec![false; m];
                for &(u, v) in &tree.edges {
                    let e_val = (labels[u] + labels[v]) % m;
                    edge_labels.push(e_val);
                    edge_seen[e_val] = true;
                }

                // Verify all m edges are covered
                assert!(
                    edge_seen.iter().all(|&b| b),
                    "Edge sum bijection violated for tree {} at n = {}",
                    tree_id, n
                );

                // Find duplicate vertex label
                let mut counts = vec![0; m];
                let mut dup_label = 0;
                for &l in &labels {
                    counts[l] += 1;
                    if counts[l] == 2 {
                        dup_label = l;
                    }
                }

                certificates.push(HarmoniousCertificate {
                    n,
                    m,
                    tree_id,
                    canonical_ahu: canon,
                    edges: tree.edges.clone(),
                    vertex_labels: labels,
                    edge_labels,
                    duplicate_label: dup_label,
                });

                total_solved += 1;
            } else {
                println!("   [COUNTEREXAMPLE FOUND!] Tree n = {}, id = {}", n, tree_id);
                counterexamples += 1;
            }
        }

        let elapsed = t_start.elapsed();
        println!("   Processed {} trees in {:?}", count, elapsed);
    }

    let total_elapsed = start_time.elapsed();
    println!("---------------------------------------------------------------");
    println!("  Total Trees Evaluated: {}", total_trees);
    println!("  Harmonious Labelings Certified: {}", total_solved);
    println!("  Counterexamples Found: {}", counterexamples);
    println!("  Graham-Sloane Conjecture Holds: {}", counterexamples == 0);
    println!("  Total Execution Time: {:?}", total_elapsed);
    println!("===============================================================");

    assert_eq!(counterexamples, 0, "Counterexample found to Graham-Sloane conjecture!");

    // Export dataset to JSON
    let json_paths = [
        "../data/harmonious_trees_frontier.json",
        "projects/02-counterexample-observatory/data/harmonious_trees_frontier.json",
    ];

    let json_data = serde_json::to_string_pretty(&certificates).expect("Serialization failed");
    for path in &json_paths {
        if let Ok(mut f) = File::create(path) {
            f.write_all(json_data.as_bytes()).expect("Write failed");
            println!("   Certificates exported to {}", path);
            break;
        }
    }
}
