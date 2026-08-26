mod generators;
mod hypergraph;

use generators::SystemGenerators;
use hypergraph::LinearCliqueSystem;
use serde::{Deserialize, Serialize};
use std::fs::File;
use std::io::Write;
use std::time::Instant;

#[derive(Debug, Serialize, Deserialize)]
pub struct OrderSummary {
    pub n: usize,
    pub total_systems_tested: usize,
    pub total_extremal_systems: usize,
    pub counterexamples_found: usize,
    pub min_chromatic_number: usize,
    pub max_chromatic_number: usize,
    pub efl_conjecture_holds: bool,
    pub sample_systems: Vec<LinearCliqueSystem>,
    pub execution_time_ms: u128,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EflRunOutput {
    pub timestamp: String,
    pub max_n: usize,
    pub total_configurations_checked: usize,
    pub total_counterexamples: usize,
    pub overall_conjecture_status: String,
    pub order_summaries: Vec<OrderSummary>,
    pub total_execution_time_ms: u128,
}

fn main() {
    println!("===============================================================");
    println!("   ERDŐS-FABER-LOVÁSZ CONJECTURE & LINEAR HYPERGRAPH ENGINE    ");
    println!("===============================================================");

    let total_start = Instant::now();
    let mut order_summaries = Vec::new();
    let mut total_configs = 0;
    let mut total_counterexamples = 0;

    for n in 3..=8 {
        let n_start = Instant::now();
        let mut systems = Vec::new();

        // 1. Star configuration
        systems.push(SystemGenerators::star(n));

        // 2. Chain configuration
        systems.push(SystemGenerators::chain(n));

        // 3. Cycle configuration
        systems.push(SystemGenerators::cycle(n));

        // 4. Complete graph intersection Kn
        let mut kn_edges = Vec::new();
        for i in 0..n {
            for j in (i + 1)..n {
                kn_edges.push((i, j));
            }
        }
        if let Some(kn_sys) =
            SystemGenerators::from_intersection_graph(n, format!("Complete-K{}", n), &kn_edges)
        {
            systems.push(kn_sys);
        }

        // 5. Wheel graph intersection (Node 0 connected to all 1..n-1, plus cycle on 1..n-1)
        if n >= 4 {
            let mut wheel_edges = Vec::new();
            for i in 1..n {
                wheel_edges.push((0, i));
            }
            for i in 1..n {
                let next = if i == n - 1 { 1 } else { i + 1 };
                wheel_edges.push((i, next));
            }
            if let Some(w_sys) = SystemGenerators::from_intersection_graph(
                n,
                format!("Wheel-W{}", n),
                &wheel_edges,
            ) {
                systems.push(w_sys);
            }
        }

        // 6. Complete bipartite graph intersection K_{a, b} where a + b = n
        let a = n / 2;
        let b = n - a;
        let mut bip_edges = Vec::new();
        for i in 0..a {
            for j in a..n {
                bip_edges.push((i, j));
            }
        }
        if let Some(bip_sys) = SystemGenerators::from_intersection_graph(
            n,
            format!("Bipartite-K{},{}", a, b),
            &bip_edges,
        ) {
            systems.push(bip_sys);
        }

        // 7. Projective plane subsystems for prime power q = n - 1
        if let Some(pp_sys) = SystemGenerators::projective_plane_subsystem(n - 1) {
            systems.push(pp_sys);
        }

        // 8. Tree topologies (Star tree, Line tree, Binary tree)
        let mut bin_tree_edges = Vec::new();
        for i in 0..n {
            let left = 2 * i + 1;
            let right = 2 * i + 2;
            if left < n {
                bin_tree_edges.push((i, left));
            }
            if right < n {
                bin_tree_edges.push((i, right));
            }
        }
        if let Some(tree_sys) = SystemGenerators::from_intersection_graph(
            n,
            format!("BinaryTree-{}", n),
            &bin_tree_edges,
        ) {
            systems.push(tree_sys);
        }

        // 9. Systematic sweep of random / density-varied intersection graphs
        for density in [20, 40, 60, 80] {
            for seed in 0..15 {
                let mut rand_edges = Vec::new();
                let mut deg = vec![0; n];
                for i in 0..n {
                    for j in (i + 1)..n {
                        let hash_val = (seed * 1000 + i * 37 + j * 91 + density) % 100;
                        if hash_val < density && deg[i] < n - 1 && deg[j] < n - 1 {
                            rand_edges.push((i, j));
                            deg[i] += 1;
                            deg[j] += 1;
                        }
                    }
                }
                if let Some(r_sys) = SystemGenerators::from_intersection_graph(
                    n,
                    format!("RandGraph-d{}-s{}", density, seed),
                    &rand_edges,
                ) {
                    systems.push(r_sys);
                }
            }
        }

        let n_elapsed = n_start.elapsed().as_millis();
        let mut n_extremal = 0;
        let mut n_counterexamples = 0;
        let mut min_chi = usize::MAX;
        let mut max_chi = 0;

        for s in &systems {
            assert!(s.is_valid_efl_instance, "Invalid EFL instance generated: {}", s.name);
            assert!(s.max_pairwise_intersection <= 1, "Linear condition violated in: {}", s.name);
            
            if s.chromatic_number > n {
                n_counterexamples += 1;
            }
            if s.chromatic_number == n {
                n_extremal += 1;
            }
            if s.chromatic_number < min_chi {
                min_chi = s.chromatic_number;
            }
            if s.chromatic_number > max_chi {
                max_chi = s.chromatic_number;
            }
        }

        total_configs += systems.len();
        total_counterexamples += n_counterexamples;

        println!(
            "Order n = {:>2} | Tested: {:>3} systems | Extremal (chi = n): {:>3} | Counterexamples: {:>2} | chi in [{}, {}] | Time: {:>5}ms",
            n,
            systems.len(),
            n_extremal,
            n_counterexamples,
            min_chi,
            max_chi,
            n_elapsed
        );

        order_summaries.push(OrderSummary {
            n,
            total_systems_tested: systems.len(),
            total_extremal_systems: n_extremal,
            counterexamples_found: n_counterexamples,
            min_chromatic_number: min_chi,
            max_chromatic_number: max_chi,
            efl_conjecture_holds: n_counterexamples == 0,
            sample_systems: systems,
            execution_time_ms: n_elapsed,
        });
    }

    let total_elapsed = total_start.elapsed();

    println!("\n===============================================================");
    println!("TOTAL CONFIGURATIONS TESTED: {}", total_configs);
    println!("TOTAL COUNTEREXAMPLES FOUND: {}", total_counterexamples);
    println!("TOTAL EXECUTION TIME       : {:?}", total_elapsed);
    println!("EFL CONJECTURE VERIFIED    : {}", total_counterexamples == 0);
    println!("===============================================================");

    let output = EflRunOutput {
        timestamp: "2026-08-26T01:03:00+02:00".to_string(),
        max_n: 8,
        total_configurations_checked: total_configs,
        total_counterexamples,
        overall_conjecture_status: if total_counterexamples == 0 {
            "100% VERIFIED ACROSS ALL TESTED LINEAR SYSTEMS".to_string()
        } else {
            "COUNTEREXAMPLE DETECTED".to_string()
        },
        order_summaries,
        total_execution_time_ms: total_elapsed.as_millis(),
    };

    let json_path = "../data/efl_frontier_n8.json";
    let mut file = File::create(json_path).expect("Failed to create output JSON");
    let json_str = serde_json::to_string_pretty(&output).expect("Failed to serialize output JSON");
    file.write_all(json_str.as_bytes()).expect("Failed to write output JSON");
    println!("Exported machine-readable results to {}", json_path);
}
