use crate::linear_extensions::{PairStats, PosetExtensionStats};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct PosetBalanceAnalysis {
    pub n: usize,
    pub is_total_order: bool,
    pub total_extensions: u64,
    pub num_incomparable_pairs: usize,
    /// Balance delta(P) = max_{u || v} min(e(u<v), e(v<u)) / e(P)
    /// Represented as exact rational (num, den) in reduced form
    pub delta_num: u64,
    pub delta_den: u64,
    pub delta_float: f64,
    pub satisfies_conjecture: bool,
    pub is_strictly_one_third: bool,
    pub most_balanced_pair: Option<(usize, usize)>,
    pub min_pair_balance_num: u64,
    pub min_pair_balance_den: u64,
    pub min_pair_balance_float: f64,
    pub least_balanced_pair: Option<(usize, usize)>,
    pub incomparable_pair_details: Vec<PairStats>,
}

fn gcd(mut a: u64, mut b: u64) -> u64 {
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }
    a
}

pub fn analyze_poset_balance(stats: PosetExtensionStats) -> PosetBalanceAnalysis {
    let n = stats.n;
    let total = stats.total_extensions;
    let is_total_order = stats.num_incomparable_pairs == 0;

    if is_total_order {
        return PosetBalanceAnalysis {
            n,
            is_total_order: true,
            total_extensions: total,
            num_incomparable_pairs: 0,
            delta_num: 0,
            delta_den: 1,
            delta_float: 0.0,
            satisfies_conjecture: true, // Trivially vacuous or total
            is_strictly_one_third: false,
            most_balanced_pair: None,
            min_pair_balance_num: 0,
            min_pair_balance_den: 1,
            min_pair_balance_float: 0.0,
            least_balanced_pair: None,
            incomparable_pair_details: Vec::new(),
        };
    }

    let incomp_pairs: Vec<PairStats> = stats
        .pair_stats
        .into_iter()
        .filter(|p| p.is_incomparable)
        .collect();

    // Find maximum balance over all incomparable pairs: delta(P) = max_{u || v} min(e(u<v), e(v<u)) / total
    let mut max_min_num = 0u64;
    let mut best_pair = None;

    let mut min_min_num = u64::MAX;
    let mut worst_pair = None;

    for p in &incomp_pairs {
        let min_val = p.e_u_less_v.min(p.e_v_less_u);
        if min_val >= max_min_num {
            max_min_num = min_val;
            best_pair = Some((p.u, p.v));
        }
        if min_val < min_min_num {
            min_min_num = min_val;
            worst_pair = Some((p.u, p.v));
        }
    }

    let satisfies = 3 * max_min_num >= total;
    let is_strictly_1_3 = 3 * max_min_num == total;

    let g_max = gcd(max_min_num, total);
    let delta_num = if total == 0 { 0 } else { max_min_num / g_max };
    let delta_den = if total == 0 { 1 } else { total / g_max };
    let delta_float = if total == 0 {
        0.0
    } else {
        max_min_num as f64 / total as f64
    };

    let g_min = gcd(min_min_num, total);
    let min_num = if total == 0 { 0 } else { min_min_num / g_min };
    let min_den = if total == 0 { 1 } else { total / g_min };
    let min_float = if total == 0 {
        0.0
    } else {
        min_min_num as f64 / total as f64
    };

    PosetBalanceAnalysis {
        n,
        is_total_order: false,
        total_extensions: total,
        num_incomparable_pairs: incomp_pairs.len(),
        delta_num,
        delta_den,
        delta_float,
        satisfies_conjecture: satisfies,
        is_strictly_one_third: is_strictly_1_3,
        most_balanced_pair: best_pair,
        min_pair_balance_num: min_num,
        min_pair_balance_den: min_den,
        min_pair_balance_float: min_float,
        least_balanced_pair: worst_pair,
        incomparable_pair_details: incomp_pairs,
    }
}
