use crate::ruler::GolombRuler;

pub struct GolombSolver {
    pub order: usize,
    pub target_len: usize,
    pub seen_diffs: Vec<bool>,
    pub marks: Vec<usize>,
    pub found_rulers: Vec<GolombRuler>,
}

impl GolombSolver {
    pub fn new(order: usize, target_len: usize) -> Self {
        Self {
            order,
            target_len,
            seen_diffs: vec![false; target_len + 1],
            marks: vec![0; order],
            found_rulers: Vec::new(),
        }
    }

    /// Search for all canonical Golomb rulers of given order and exact target_len.
    pub fn solve_exact(&mut self) -> Vec<GolombRuler> {
        let n = self.order;
        if n == 1 {
            if self.target_len == 0 {
                return vec![GolombRuler::new(vec![0])];
            } else {
                return Vec::new();
            }
        }
        if n == 2 {
            if self.target_len == 1 {
                return vec![GolombRuler::new(vec![0, 1])];
            } else {
                return Vec::new();
            }
        }

        self.marks[0] = 0;
        self.marks[n - 1] = self.target_len;
        self.seen_diffs[self.target_len] = true;

        // Symmetry breaking: marks[1] <= target_len / 2
        let max_first = self.target_len / 2;
        for m1 in 1..=max_first {
            self.marks[1] = m1;
            self.seen_diffs[m1] = true;

            // Difference from m1 to end: L - m1
            let d_end = self.target_len - m1;
            if !self.seen_diffs[d_end] {
                self.seen_diffs[d_end] = true;
                self.search_recursive(2);
                self.seen_diffs[d_end] = false;
            }

            self.seen_diffs[m1] = false;
        }

        self.seen_diffs[self.target_len] = false;

        let mut results = self.found_rulers.clone();
        results.retain(|r| r.verify() && r.is_canonical);
        results
    }

    fn search_recursive(&mut self, depth: usize) {
        let n = self.order;
        if depth == n - 1 {
            // Check canonical symmetry condition: a2 - a1 <= an - a_{n-1}
            let left_diff = self.marks[1] - self.marks[0];
            let right_diff = self.marks[n - 1] - self.marks[n - 2];
            if left_diff <= right_diff {
                let ruler = GolombRuler::new(self.marks.clone());
                self.found_rulers.push(ruler);
            }
            return;
        }

        let rem = n - 1 - depth;
        let min_m = self.marks[depth - 1] + 1;
        let max_m = self.marks[n - 1] - rem;

        // Lower bound check: the remaining `rem` gaps must be at least 1, 2, ..., rem
        let min_rem_span = rem * (rem + 1) / 2;
        if self.marks[depth - 1] + min_rem_span > self.marks[n - 1] {
            return;
        }

        'cand_loop: for m in min_m..=max_m {
            // Check all differences from previous marks
            let mut added_diffs = Vec::with_capacity(depth + 1);

            for i in 0..depth {
                let d = m - self.marks[i];
                if self.seen_diffs[d] {
                    // Revert seen_diffs
                    for &ad in &added_diffs {
                        self.seen_diffs[ad] = false;
                    }
                    continue 'cand_loop;
                }
                added_diffs.push(d);
                self.seen_diffs[d] = true;
            }

            // Difference to end mark: marks[n-1] - m
            let d_end = self.marks[n - 1] - m;
            if self.seen_diffs[d_end] {
                for &ad in &added_diffs {
                    self.seen_diffs[ad] = false;
                }
                continue 'cand_loop;
            }
            self.seen_diffs[d_end] = true;
            added_diffs.push(d_end);

            self.marks[depth] = m;
            self.search_recursive(depth + 1);

            // Backtrack
            for &ad in &added_diffs {
                self.seen_diffs[ad] = false;
            }
        }
    }
}
