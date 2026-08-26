use serde::{Deserialize, Serialize};

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct Tree {
    pub n: usize,
    pub edges: Vec<(usize, usize)>,
}

impl std::fmt::Debug for Tree {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Tree(n={}, edges={:?})", self.n, self.edges)
    }
}

impl Tree {
    pub fn new(n: usize, mut edges: Vec<(usize, usize)>) -> Self {
        // Normalize edges: u < v
        for e in &mut edges {
            if e.0 > e.1 {
                std::mem::swap(&mut e.0, &mut e.1);
            }
        }
        edges.sort_unstable();
        edges.dedup();
        Tree { n, edges }
    }

    pub fn adjacency_list(&self) -> Vec<Vec<usize>> {
        let mut adj = vec![Vec::new(); self.n];
        for &(u, v) in &self.edges {
            adj[u].push(v);
            adj[v].push(u);
        }
        adj
    }

    pub fn degrees(&self) -> Vec<usize> {
        let mut deg = vec![0; self.n];
        for &(u, v) in &self.edges {
            deg[u] += 1;
            deg[v] += 1;
        }
        deg
    }

    #[allow(dead_code)]
    pub fn is_tree(&self) -> bool {
        if self.edges.len() != self.n - 1 {
            return false;
        }
        if self.n <= 1 {
            return true;
        }
        // Check connectivity
        let adj = self.adjacency_list();
        let mut visited = vec![false; self.n];
        let mut queue = vec![0];
        visited[0] = true;
        let mut count = 0;
        while let Some(u) = queue.pop() {
            count += 1;
            for &v in &adj[u] {
                if !visited[v] {
                    visited[v] = true;
                    queue.push(v);
                }
            }
        }
        count == self.n
    }

    /// Find tree centers (1 or 2 vertices) by peeling leaves.
    pub fn centers(&self) -> Vec<usize> {
        if self.n <= 2 {
            return (0..self.n).collect();
        }

        let adj = self.adjacency_list();
        let mut degree = self.degrees();
        let mut leaves = Vec::new();

        for i in 0..self.n {
            if degree[i] == 1 {
                leaves.push(i);
            }
        }

        let mut remaining = self.n;
        while remaining > 2 {
            remaining -= leaves.len();
            let mut next_leaves = Vec::new();
            for &leaf in &leaves {
                for &neighbor in &adj[leaf] {
                    if degree[neighbor] > 1 {
                        degree[neighbor] -= 1;
                        if degree[neighbor] == 1 {
                            next_leaves.push(neighbor);
                        }
                    }
                }
            }
            leaves = next_leaves;
        }

        leaves.sort_unstable();
        leaves
    }

    /// Compute AHU canonical representation string for rooted tree.
    fn rooted_ahu(u: usize, parent: usize, adj: &[Vec<usize>]) -> String {
        let mut children_codes = Vec::new();
        for &v in &adj[u] {
            if v != parent {
                children_codes.push(Self::rooted_ahu(v, u, adj));
            }
        }
        children_codes.sort_unstable();
        let mut result = String::with_capacity(children_codes.iter().map(|s| s.len()).sum::<usize>() + 2);
        result.push('0');
        for code in children_codes {
            result.push_str(&code);
        }
        result.push('1');
        result
    }

    /// Canonical AHU string for unrooted tree.
    pub fn canonical_code(&self) -> String {
        if self.n <= 1 {
            return "01".to_string();
        }
        let adj = self.adjacency_list();
        let centers = self.centers();
        if centers.len() == 1 {
            Self::rooted_ahu(centers[0], usize::MAX, &adj)
        } else {
            let c1 = centers[0];
            let c2 = centers[1];
            let code1 = Self::rooted_ahu(c1, c2, &adj);
            let code2 = Self::rooted_ahu(c2, c1, &adj);
            let mut parts = vec![code1, code2];
            parts.sort_unstable();
            format!("0{}{}{}1", parts[0], parts[1], "")
        }
    }
}
