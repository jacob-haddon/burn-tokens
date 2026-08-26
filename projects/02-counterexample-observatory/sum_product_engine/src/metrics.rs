use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct SetMetrics {
    pub k: usize,
    pub set: Vec<u64>,
    pub sumset_size: usize,
    pub productset_size: usize,
    pub max_sum_product: usize,
    pub additive_energy: u64,
    pub multiplicative_energy: u64,
}

impl SetMetrics {
    pub fn compute(set: &[u64]) -> Self {
        let k = set.len();
        let mut sorted_set = set.to_vec();
        sorted_set.sort_unstable();
        sorted_set.dedup();

        // 1. Sumset and additive representation counts
        let mut sum_counts: HashMap<u64, u64> = HashMap::new();
        for i in 0..k {
            for j in 0..k {
                let s = sorted_set[i] + sorted_set[j];
                *sum_counts.entry(s).or_insert(0) += 1;
            }
        }
        let sumset_size = sum_counts.len();
        let additive_energy: u64 = sum_counts.values().map(|&c| c * c).sum();

        // 2. Productset and multiplicative representation counts
        let mut prod_counts: HashMap<u64, u64> = HashMap::new();
        for i in 0..k {
            for j in 0..k {
                let p = sorted_set[i] * sorted_set[j];
                *prod_counts.entry(p).or_insert(0) += 1;
            }
        }
        let productset_size = prod_counts.len();
        let multiplicative_energy: u64 = prod_counts.values().map(|&c| c * c).sum();

        let max_sum_product = std::cmp::max(sumset_size, productset_size);

        SetMetrics {
            k,
            set: sorted_set,
            sumset_size,
            productset_size,
            max_sum_product,
            additive_energy,
            multiplicative_energy,
        }
    }
}
