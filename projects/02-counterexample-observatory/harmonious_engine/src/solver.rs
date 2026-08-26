use crate::tree_gen::Tree;
use std::collections::VecDeque;

pub struct HarmoniousSolver<'a> {
    tree: &'a Tree,
    m: usize,
    parent: Vec<usize>,
    order: Vec<usize>,
    vertex_labels: Vec<usize>,
    label_counts: Vec<u8>,
    duplicate_count: usize,
    used_edges_mask: u32,
}

impl<'a> HarmoniousSolver<'a> {
    pub fn new(tree: &'a Tree) -> Self {
        let n = tree.n;
        let m = n - 1;

        // BFS order from highest-degree node
        let root = (0..n).max_by_key(|&u| tree.adj[u].len()).unwrap();
        let mut parent = vec![n; n];
        let mut order = Vec::with_capacity(n);
        let mut visited = vec![false; n];
        let mut q = VecDeque::new();

        visited[root] = true;
        q.push_back(root);

        while let Some(u) = q.pop_front() {
            order.push(u);
            for &v in &tree.adj[u] {
                if !visited[v] {
                    visited[v] = true;
                    parent[v] = u;
                    q.push_back(v);
                }
            }
        }

        Self {
            tree,
            m,
            parent,
            order,
            vertex_labels: vec![0; n],
            label_counts: vec![0; m],
            duplicate_count: 0,
            used_edges_mask: 0,
        }
    }

    fn solve_step(&mut self, idx: usize) -> bool {
        if idx == self.tree.n {
            return self.used_edges_mask == ((1u32 << self.m) - 1);
        }

        let u = self.order[idx];
        let p = self.parent[u];

        for val in 0..self.m {
            // Check vertex label frequency constraints
            if self.label_counts[val] >= 2 {
                continue;
            }
            if self.label_counts[val] == 1 && self.duplicate_count >= 1 {
                continue;
            }

            // If u has a parent, check the edge sum constraint
            let mut edge_bit = 0;
            if p < self.tree.n {
                let p_val = self.vertex_labels[p];
                let edge_sum = (p_val + val) % self.m;
                edge_bit = 1u32 << edge_sum;
                if (self.used_edges_mask & edge_bit) != 0 {
                    continue;
                }
            }

            // Apply assignment
            self.vertex_labels[u] = val;
            let was_zero = self.label_counts[val] == 0;
            self.label_counts[val] += 1;
            if !was_zero {
                self.duplicate_count += 1;
            }
            let old_mask = self.used_edges_mask;
            self.used_edges_mask |= edge_bit;

            if self.solve_step(idx + 1) {
                return true;
            }

            // Backtrack
            self.used_edges_mask = old_mask;
            if !was_zero {
                self.duplicate_count -= 1;
            }
            self.label_counts[val] -= 1;
        }

        false
    }

    pub fn solve(mut self) -> Option<Vec<usize>> {
        // Symmetry breaking: fix root label to 0
        let root = self.order[0];
        self.vertex_labels[root] = 0;
        self.label_counts[0] = 1;

        if self.solve_step(1) {
            Some(self.vertex_labels)
        } else {
            None
        }
    }
}

pub fn find_harmonious_labeling(tree: &Tree) -> Option<Vec<usize>> {
    if tree.n <= 2 {
        return Some(vec![0; tree.n]);
    }
    let solver = HarmoniousSolver::new(tree);
    solver.solve()
}
