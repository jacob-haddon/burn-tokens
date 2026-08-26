use crate::ruzsa::{analyze_triple, TripleAnalysis};

pub fn generate_candidate_subsets() -> Vec<Vec<i64>> {
    let mut subsets: Vec<Vec<i64>> = Vec::new();

    // 1. Singletons
    for x in -5..=5 {
        subsets.push(vec![x]);
    }

    // 2. Arithmetic Progressions
    for start in -4..=4 {
        for diff in 1..=4 {
            for len in 2..=6 {
                let s: Vec<i64> = (0..len).map(|i| start + i * diff).collect();
                subsets.push(s);
            }
        }
    }

    // 3. Geometric Progressions
    for r in 2..=3 {
        for len in 2..=5 {
            let s: Vec<i64> = (0..len).map(|i| (r as i64).pow(i as u32)).collect();
            subsets.push(s);
        }
    }

    // 4. Sidon subsets (B2 sets)
    subsets.push(vec![0, 1, 3]);
    subsets.push(vec![0, 1, 4, 6]);
    subsets.push(vec![0, 1, 4, 9, 11]);
    subsets.push(vec![0, 1, 4, 10, 12, 17]);

    // 5. Primes and Squares
    subsets.push(vec![2, 3, 5]);
    subsets.push(vec![2, 3, 5, 7]);
    subsets.push(vec![2, 3, 5, 7, 11]);
    subsets.push(vec![1, 4, 9, 16]);
    subsets.push(vec![1, 4, 9, 16, 25]);

    // 6. Highly composite divisors
    subsets.push(vec![1, 2, 3, 6]);
    subsets.push(vec![1, 2, 3, 4, 6]);
    subsets.push(vec![1, 2, 3, 4, 6, 12]);

    // 7. Symmetric & Asymmetric arbitrary subsets
    subsets.push(vec![-3, -1, 0, 1, 3]);
    subsets.push(vec![-2, 0, 1, 4, 7]);
    subsets.push(vec![0, 2, 5, 6, 9, 10]);

    // Deduplicate
    for s in &mut subsets {
        s.sort_unstable();
        s.dedup();
    }
    subsets.sort();
    subsets.dedup();

    subsets
}

pub struct SearchSummary {
    pub total_triples_tested: u64,
    pub counterexamples_found: u64,
    pub metric_violations_found: u64,
    pub sharp_equality_count: u64,
    pub max_ratio: f64,
    pub min_triangle_slack: f64,
    pub equality_witnesses: Vec<TripleAnalysis>,
    pub max_distance_triples: Vec<TripleAnalysis>,
}

pub fn stress_test_ruzsa_inequality() -> SearchSummary {
    let subsets = generate_candidate_subsets();
    let n = subsets.len();

    let mut total_tested = 0u64;
    let mut counterexamples = 0u64;
    let mut metric_violations = 0u64;
    let mut equality_count = 0u64;
    let mut max_ratio = 0.0f64;
    let mut min_slack = f64::MAX;

    let mut equality_witnesses = Vec::new();
    let mut max_slack_witnesses = Vec::new();

    for i in 0..n {
        for j in 0..n {
            for k in 0..n {
                let analysis = analyze_triple(&subsets[i], &subsets[j], &subsets[k]);
                total_tested += 1;

                if !analysis.is_valid_inequality {
                    counterexamples += 1;
                }

                if analysis.triangle_slack < -1e-9 {
                    metric_violations += 1;
                }

                if analysis.ratio > max_ratio {
                    max_ratio = analysis.ratio;
                }

                if analysis.triangle_slack < min_slack {
                    min_slack = analysis.triangle_slack;
                }

                if analysis.lhs == analysis.rhs {
                    equality_count += 1;
                    if equality_witnesses.len() < 10 && analysis.card_a > 1 && analysis.card_b > 1 {
                        equality_witnesses.push(analysis.clone());
                    }
                }

                if analysis.triangle_slack > 2.0 && max_slack_witnesses.len() < 5 {
                    max_slack_witnesses.push(analysis);
                }
            }
        }
    }

    SearchSummary {
        total_triples_tested: total_tested,
        counterexamples_found: counterexamples,
        metric_violations_found: metric_violations,
        sharp_equality_count: equality_count,
        max_ratio,
        min_triangle_slack: min_slack,
        equality_witnesses,
        max_distance_triples: max_slack_witnesses,
    }
}
