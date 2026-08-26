use serde::{Deserialize, Serialize};
use std::collections::{BTreeSet, HashMap};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SubsetAnalysis {
    pub size: usize,
    pub elements: Vec<i64>,
    pub sumset_size: usize,
    pub sumset: Vec<i64>,
    pub productset_size: usize,
    pub productset: Vec<i64>,
    pub max_cardinality: usize,
    pub sum_of_cardinalities: usize,
    pub additive_energy: u64,
    pub multiplicative_energy: u64,
}

pub fn analyze_subset(elements: &[i64]) -> SubsetAnalysis {
    let mut a_sorted = elements.to_vec();
    a_sorted.sort_unstable();
    a_sorted.dedup();
    let k = a_sorted.len();

    let mut sumset = BTreeSet::new();
    let mut sum_counts: HashMap<i64, u64> = HashMap::new();
    for &x in &a_sorted {
        for &y in &a_sorted {
            let s = x + y;
            sumset.insert(s);
            *sum_counts.entry(s).or_insert(0) += 1;
        }
    }

    let mut productset = BTreeSet::new();
    let mut prod_counts: HashMap<i64, u64> = HashMap::new();
    for &x in &a_sorted {
        for &y in &a_sorted {
            let p = x * y;
            productset.insert(p);
            *prod_counts.entry(p).or_insert(0) += 1;
        }
    }

    let mut e_plus = 0u64;
    for &cnt in sum_counts.values() {
        e_plus += cnt * cnt;
    }

    let mut e_times = 0u64;
    for &cnt in prod_counts.values() {
        e_times += cnt * cnt;
    }

    let sum_sz = sumset.len();
    let prod_sz = productset.len();

    SubsetAnalysis {
        size: k,
        elements: a_sorted,
        sumset_size: sum_sz,
        sumset: sumset.into_iter().collect(),
        productset_size: prod_sz,
        productset: productset.into_iter().collect(),
        max_cardinality: std::cmp::max(sum_sz, prod_sz),
        sum_of_cardinalities: sum_sz + prod_sz,
        additive_energy: e_plus,
        multiplicative_energy: e_times,
    }
}
