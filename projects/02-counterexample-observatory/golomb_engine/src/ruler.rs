use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct GolombRuler {
    pub order: usize,
    pub length: usize,
    pub marks: Vec<usize>,
    pub difference_triangle: Vec<Vec<usize>>,
    pub is_canonical: bool,
}

impl GolombRuler {
    pub fn new(marks: Vec<usize>) -> Self {
        let order = marks.len();
        let length = if order > 0 { marks[order - 1] } else { 0 };

        // Construct difference triangle:
        // row k (1 <= k <= order-1) contains marks[i+k] - marks[i] for i = 0..order-1-k
        let mut diff_triangle = Vec::new();
        for k in 1..order {
            let mut row = Vec::new();
            for i in 0..=(order - 1 - k) {
                row.push(marks[i + k] - marks[i]);
            }
            diff_triangle.push(row);
        }

        // Check canonical symmetry: a2 - a1 <= an - a_{n-1}
        let is_canonical = if order >= 3 {
            let left_diff = marks[1] - marks[0];
            let right_diff = marks[order - 1] - marks[order - 2];
            left_diff <= right_diff
        } else {
            true
        };

        Self {
            order,
            length,
            marks,
            difference_triangle: diff_triangle,
            is_canonical,
        }
    }

    /// Independently verify Golomb ruler properties:
    /// 1. Marks strictly increasing and starting at 0.
    /// 2. All pairwise differences strictly distinct.
    pub fn verify(&self) -> bool {
        let n = self.marks.len();
        if n == 0 {
            return true;
        }
        if self.marks[0] != 0 {
            return false;
        }
        for i in 1..n {
            if self.marks[i] <= self.marks[i - 1] {
                return false;
            }
        }

        let max_diff = self.length;
        let mut seen = vec![false; max_diff + 1];

        for i in 0..n {
            for j in (i + 1)..n {
                let diff = self.marks[j] - self.marks[i];
                if diff == 0 || diff > max_diff || seen[diff] {
                    return false;
                }
                seen[diff] = true;
            }
        }

        true
    }
}
