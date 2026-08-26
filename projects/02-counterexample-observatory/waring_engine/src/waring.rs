use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct WitnessDecomposition {
    pub n: usize,
    pub count: usize,
    pub terms: Vec<usize>,
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct PowerLevelReport {
    pub k: usize,
    pub g_k_conjectured: usize,
    pub max_r_k_observed: usize,
    pub max_n_evaluated: usize,
    pub total_counterexamples: usize,
    pub count_by_representation_length: Vec<usize>,
    pub maximal_witnesses: Vec<WitnessDecomposition>,
    pub elapsed_ms: u128,
}

#[allow(dead_code)]
pub struct WaringSolver {
    pub k: usize,
    pub limit: usize,
    pub dp: Vec<u8>,
    pub powers: Vec<usize>,
}

impl WaringSolver {
    pub fn new(k: usize, limit: usize) -> Self {
        let mut powers = Vec::new();
        let mut x = 1usize;
        loop {
            match x.checked_pow(k as u32) {
                Some(p) if p <= limit => {
                    powers.push(p);
                    x += 1;
                }
                _ => break,
            }
        }

        let mut dp = vec![u8::MAX; limit + 1];
        dp[0] = 0;

        for &p in &powers {
            for i in p..=limit {
                let cand = dp[i - p].saturating_add(1);
                if cand < dp[i] {
                    dp[i] = cand;
                }
            }
        }

        WaringSolver {
            k,
            limit,
            dp,
            powers,
        }
    }

    pub fn min_terms(&self, n: usize) -> usize {
        self.dp[n] as usize
    }

    pub fn reconstruct_witness(&self, mut n: usize) -> Vec<usize> {
        let mut terms = Vec::new();
        while n > 0 {
            for (idx, &p) in self.powers.iter().enumerate().rev() {
                if p <= n && self.dp[n - p] == self.dp[n] - 1 {
                    let base = idx + 1;
                    terms.push(base);
                    n -= p;
                    break;
                }
            }
        }
        terms
    }
}
