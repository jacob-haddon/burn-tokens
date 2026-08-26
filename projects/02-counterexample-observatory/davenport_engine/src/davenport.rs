use crate::group::FiniteGroup;
use serde::{Deserialize, Serialize};
use std::time::Instant;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GroupDavenportRecord {
    pub name: String,
    pub order: usize,
    pub is_abelian: bool,
    pub ordered_davenport: usize,   // d(G) - product in sequence order
    pub unordered_davenport: usize, // D(G) - product under any permutation
    pub ordered_witness_sequence: Vec<usize>,
    pub unordered_witness_sequence: Vec<usize>,
    pub group_order_bound: usize,
    pub obeys_theoretical_bounds: bool,
    pub execution_time_ms: u128,
}

pub struct DavenportSolver<'a> {
    pub group: &'a FiniteGroup,
    pub max_ordered_len: usize,
    pub best_ordered_seq: Vec<usize>,
    pub max_unordered_len: usize,
    pub best_unordered_seq: Vec<usize>,
}

impl<'a> DavenportSolver<'a> {
    pub fn new(group: &'a FiniteGroup) -> Self {
        Self {
            group,
            max_ordered_len: 0,
            best_ordered_seq: Vec::new(),
            max_unordered_len: 0,
            best_unordered_seq: Vec::new(),
        }
    }

    /// Fast ordered Davenport check: is seq zero-sum free in sequence order?
    pub fn is_ordered_zs_free(&self, seq: &[usize]) -> bool {
        let order = self.group.order;
        let mut reachable = vec![false; order];

        for &x in seq {
            if x == 0 {
                return false;
            }
            let inv = self.group.inverses[x];
            if reachable[inv] {
                return false;
            }
            let mut next = reachable.clone();
            next[x] = true;
            for g in 0..order {
                if reachable[g] {
                    let prod = self.group.cayley_table[g][x];
                    if prod == 0 {
                        return false;
                    }
                    next[prod] = true;
                }
            }
            reachable = next;
        }

        true
    }

    /// Unordered Davenport check: is seq zero-sum free under arbitrary sub-multiset reordering?
    pub fn is_unordered_zs_free(&self, seq: &[usize]) -> bool {
        let k = seq.len();
        if k == 0 {
            return true;
        }
        if k > 20 {
            return false;
        }

        let order = self.group.order;
        let num_subsets = 1 << k;
        let mut dp: Vec<Vec<usize>> = vec![Vec::new(); num_subsets];
        dp[0].push(0);

        for mask in 1..num_subsets {
            let mut set_products = vec![false; order];
            for i in 0..k {
                if (mask & (1 << i)) != 0 {
                    let prev_mask = mask ^ (1 << i);
                    let elem = seq[i];
                    for &p in &dp[prev_mask] {
                        let prod1 = self.group.cayley_table[p][elem];
                        if prod1 == 0 {
                            return false; // Zero-sum found!
                        }
                        if !set_products[prod1] {
                            set_products[prod1] = true;
                        }
                        let prod2 = self.group.cayley_table[elem][p];
                        if prod2 == 0 {
                            return false;
                        }
                        if !set_products[prod2] {
                            set_products[prod2] = true;
                        }
                    }
                }
            }
            for g in 0..order {
                if set_products[g] {
                    dp[mask].push(g);
                }
            }
        }

        true
    }

    /// Backtracking search for ordered Davenport constant d(G)
    pub fn solve_ordered(&mut self) -> usize {
        // Seed with cyclic subgroup candidate of maximum element order
        let mut best_gen = 1;
        let mut max_ord = 1;
        for (elem, &ord) in self.group.element_orders.iter().enumerate().skip(1) {
            if ord > max_ord {
                max_ord = ord;
                best_gen = elem;
            }
        }

        let mut candidate = vec![best_gen; max_ord - 1];
        if self.is_ordered_zs_free(&candidate) {
            self.max_ordered_len = candidate.len();
            self.best_ordered_seq = candidate.clone();

            // Try extending with any other element
            for y in 1..self.group.order {
                candidate.push(y);
                if self.is_ordered_zs_free(&candidate) {
                    self.max_ordered_len = candidate.len();
                    self.best_ordered_seq = candidate.clone();
                }
                candidate.pop();
            }
        }

        let mut current_seq = Vec::new();
        let reachable = vec![false; self.group.order];
        self.search_ordered(1, &mut current_seq, &reachable);
        self.max_ordered_len + 1
    }

    fn search_ordered(
        &mut self,
        min_elem: usize,
        current_seq: &mut Vec<usize>,
        reachable: &[bool],
    ) {
        if current_seq.len() > self.max_ordered_len {
            self.max_ordered_len = current_seq.len();
            self.best_ordered_seq = current_seq.clone();
        }

        let reachable_count = reachable.iter().filter(|&&b| b).count();
        if current_seq.len() + (self.group.order - reachable_count) <= self.max_ordered_len {
            return;
        }

        let order = self.group.order;
        for x in min_elem..order {
            let inv = self.group.inverses[x];
            if reachable[inv] {
                continue;
            }

            let mut next_reachable = reachable.to_vec();
            next_reachable[x] = true;
            let mut valid = true;
            for g in 0..order {
                if reachable[g] {
                    let prod = self.group.cayley_table[g][x];
                    if prod == 0 {
                        valid = false;
                        break;
                    }
                    next_reachable[prod] = true;
                }
            }

            if valid {
                current_seq.push(x);
                self.search_ordered(x, current_seq, &next_reachable);
                current_seq.pop();
            }
        }
    }

    /// Backtracking search for unordered Davenport constant D(G)
    pub fn solve_unordered(&mut self, ordered_d: usize) -> usize {
        if self.group.is_abelian {
            self.max_unordered_len = self.max_ordered_len;
            self.best_unordered_seq = self.best_ordered_seq.clone();
            return ordered_d;
        }

        if self.is_unordered_zs_free(&self.best_ordered_seq) {
            self.max_unordered_len = self.best_ordered_seq.len();
            self.best_unordered_seq = self.best_ordered_seq.clone();
            if self.max_unordered_len >= ordered_d - 1 {
                return ordered_d;
            }
        }

        let mut current_seq = Vec::new();
        let reachable = vec![false; self.group.order];
        self.search_unordered(1, &mut current_seq, &reachable);
        self.max_unordered_len + 1
    }

    fn search_unordered(
        &mut self,
        min_elem: usize,
        current_seq: &mut Vec<usize>,
        reachable: &[bool],
    ) {
        if current_seq.len() > self.max_unordered_len {
            self.max_unordered_len = current_seq.len();
            self.best_unordered_seq = current_seq.clone();
        }

        let reachable_count = reachable.iter().filter(|&&b| b).count();
        if current_seq.len() + (self.group.order - reachable_count) <= self.max_unordered_len {
            return;
        }

        let order = self.group.order;
        for x in min_elem..order {
            let inv = self.group.inverses[x];
            if reachable[inv] {
                continue;
            }

            let mut next_reachable = reachable.to_vec();
            next_reachable[x] = true;
            let mut valid = true;
            for g in 0..order {
                if reachable[g] {
                    let prod = self.group.cayley_table[g][x];
                    if prod == 0 {
                        valid = false;
                        break;
                    }
                    next_reachable[prod] = true;
                }
            }

            if valid {
                current_seq.push(x);
                if self.is_unordered_zs_free(current_seq) {
                    self.search_unordered(x, current_seq, &next_reachable);
                }
                current_seq.pop();
            }
        }
    }
}

pub fn analyze_group(group: &FiniteGroup) -> GroupDavenportRecord {
    let start = Instant::now();
    let mut solver = DavenportSolver::new(group);

    let ord_d = solver.solve_ordered();
    let ord_witness = solver.best_ordered_seq.clone();

    let unord_d = solver.solve_unordered(ord_d);
    let unord_witness = solver.best_unordered_seq.clone();

    // Universal theorem: unordered_d <= ordered_d <= order
    let obeys = unord_d <= ord_d && ord_d <= group.order;

    GroupDavenportRecord {
        name: group.name.clone(),
        order: group.order,
        is_abelian: group.is_abelian,
        ordered_davenport: ord_d,
        unordered_davenport: unord_d,
        ordered_witness_sequence: ord_witness,
        unordered_witness_sequence: unord_witness,
        group_order_bound: group.order,
        obeys_theoretical_bounds: obeys,
        execution_time_ms: start.elapsed().as_millis(),
    }
}
