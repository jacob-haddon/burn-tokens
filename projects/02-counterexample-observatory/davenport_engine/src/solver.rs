use crate::group::FiniteGroup;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct DavenportResult {
    pub group_name: String,
    pub order: usize,
    pub is_abelian: bool,
    pub davenport_constant: usize,
    pub max_zero_sum_free_length: usize,
    pub sample_zero_sum_free_seq: Vec<usize>,
    pub reachable_products_count: usize,
}

pub struct DavenportSolver<'a> {
    group: &'a FiniteGroup,
    max_len: usize,
    best_seq: Vec<usize>,
    best_reach_count: usize,
}

impl<'a> DavenportSolver<'a> {
    pub fn new(group: &'a FiniteGroup) -> Self {
        Self {
            group,
            max_len: 0,
            best_seq: Vec::new(),
            best_reach_count: 0,
        }
    }

    pub fn solve(mut self) -> DavenportResult {
        let mut current_seq = Vec::with_capacity(32);
        // Start search with empty reach mask (0u64)
        self.search(&mut current_seq, 0u64, 1);

        DavenportResult {
            group_name: self.group.name.clone(),
            order: self.group.order,
            is_abelian: self.group.is_abelian,
            davenport_constant: self.max_len + 1,
            max_zero_sum_free_length: self.max_len,
            sample_zero_sum_free_seq: self.best_seq,
            reachable_products_count: self.best_reach_count,
        }
    }

    fn search(
        &mut self,
        current_seq: &mut Vec<usize>,
        reach_mask: u64,
        start_elem: usize,
    ) {
        let k = current_seq.len();
        if k > self.max_len {
            self.max_len = k;
            self.best_seq = current_seq.clone();
            self.best_reach_count = reach_mask.count_ones() as usize;
        }

        // Try appending all non-identity elements g in 1..order
        for g in 1..self.group.order {
            // Compute candidate new reachable products:
            // g itself, and p * g for all p in reach_mask
            let mut new_reach = reach_mask | (1u64 << g);
            let mut zero_sum_found = false;

            for p in 1..self.group.order {
                if (reach_mask & (1u64 << p)) != 0 {
                    let prod = self.group.mul_table[p][g];
                    if prod == 0 {
                        zero_sum_found = true;
                        break;
                    }
                    new_reach |= 1u64 << prod;
                }
            }

            if !zero_sum_found {
                current_seq.push(g);
                self.search(current_seq, new_reach, g);
                current_seq.pop();
            }
        }
    }
}
