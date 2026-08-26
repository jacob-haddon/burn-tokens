use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SumFreePartition {
    pub k: usize,
    pub n: usize,
    pub is_weak: bool,
    pub parts: Vec<Vec<usize>>,
}

impl SumFreePartition {
    pub fn is_valid(&self) -> bool {
        let mut seen = vec![false; self.n + 1];
        let mut total_count = 0;

        for part in &self.parts {
            total_count += part.len();
            for &x in part {
                if x == 0 || x > self.n || seen[x] {
                    return false;
                }
                seen[x] = true;
            }

            // Check sum-free property
            for (i, &x) in part.iter().enumerate() {
                for (j, &y) in part.iter().enumerate() {
                    if self.is_weak && i == j {
                        continue;
                    }
                    let sum = x + y;
                    if part.contains(&sum) {
                        return false;
                    }
                }
            }
        }

        total_count == self.n && seen[1..=self.n].iter().all(|&b| b)
    }
}

pub struct SchurSolver {
    pub k: usize,
    pub n: usize,
    pub is_weak: bool,
    pub set_mask: [u64; 8],
    pub sum_mask: [u64; 8],
    pub solutions: Vec<SumFreePartition>,
    pub max_solutions: usize,
}

impl SchurSolver {
    pub fn new(k: usize, n: usize, is_weak: bool, max_solutions: usize) -> Self {
        assert!(k <= 8 && n <= 60, "Max k=8, max n=60 supported by u64 masks");
        Self {
            k,
            n,
            is_weak,
            set_mask: [0; 8],
            sum_mask: [0; 8],
            solutions: Vec::new(),
            max_solutions,
        }
    }

    pub fn solve(&mut self) -> usize {
        self.solutions.clear();
        self.backtrack(1, 0);
        self.solutions.len()
    }

    fn backtrack(&mut self, v: usize, num_used_colors: usize) -> bool {
        if v > self.n {
            let mut parts = Vec::with_capacity(self.k);
            for c in 0..self.k {
                let mut part = Vec::new();
                let mask = self.set_mask[c];
                for x in 1..=self.n {
                    if (mask & (1u64 << x)) != 0 {
                        part.push(x);
                    }
                }
                parts.push(part);
            }

            let partition = SumFreePartition {
                k: self.k,
                n: self.n,
                is_weak: self.is_weak,
                parts,
            };
            assert!(partition.is_valid(), "Generated invalid partition!");
            self.solutions.push(partition);

            return self.solutions.len() >= self.max_solutions;
        }

        let max_c = (num_used_colors + 1).min(self.k);
        let bit_v = 1u64 << v;

        for c in 0..max_c {
            // Check if v is forbidden in color c
            if (self.sum_mask[c] & bit_v) == 0 {
                // Place v in color c
                let old_set = self.set_mask[c];
                let old_sum = self.sum_mask[c];

                let mut new_sum = old_sum | (old_set << v);
                if !self.is_weak && 2 * v <= 63 {
                    new_sum |= 1u64 << (2 * v);
                }

                self.set_mask[c] = old_set | bit_v;
                self.sum_mask[c] = new_sum;

                let next_used = if c == num_used_colors { num_used_colors + 1 } else { num_used_colors };
                if self.backtrack(v + 1, next_used) {
                    self.set_mask[c] = old_set;
                    self.sum_mask[c] = old_sum;
                    return true;
                }

                self.set_mask[c] = old_set;
                self.sum_mask[c] = old_sum;
            }
        }

        false
    }
}
