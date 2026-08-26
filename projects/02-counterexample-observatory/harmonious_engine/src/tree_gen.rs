use std::collections::VecDeque;

#[derive(Clone, Debug, PartialEq, Eq)]
pub struct Tree {
    pub n: usize,
    pub edges: Vec<(usize, usize)>,
    pub adj: Vec<Vec<usize>>,
}

impl Tree {
    pub fn from_edges(n: usize, edges: Vec<(usize, usize)>) -> Self {
        let mut adj = vec![Vec::new(); n];
        for &(u, v) in &edges {
            adj[u].push(v);
            adj[v].push(u);
        }
        for list in &mut adj {
            list.sort_unstable();
        }
        Self { n, edges, adj }
    }

    /// Compute the centers of the tree (1 or 2 centers).
    pub fn centers(&self) -> Vec<usize> {
        let mut deg: Vec<usize> = self.adj.iter().map(|l| l.len()).collect();
        let mut leaves: VecDeque<usize> = VecDeque::new();
        for (i, &d) in deg.iter().enumerate() {
            if d <= 1 {
                leaves.push_back(i);
            }
        }

        let mut remaining = self.n;
        while remaining > 2 {
            let count = leaves.len();
            remaining -= count;
            for _ in 0..count {
                let u = leaves.pop_front().unwrap();
                for &v in &self.adj[u] {
                    if deg[v] > 0 {
                        deg[v] -= 1;
                        if deg[v] == 1 {
                            leaves.push_back(v);
                        }
                    }
                }
                deg[u] = 0;
            }
        }

        leaves.into_iter().collect()
    }

    /// Canonical AHU string for rooted tree at `root` with `parent`.
    pub fn ahu_encoding(&self, u: usize, p: usize) -> String {
        let mut sub_codes = Vec::new();
        for &v in &self.adj[u] {
            if v != p {
                sub_codes.push(self.ahu_encoding(v, u));
            }
        }
        sub_codes.sort();
        let mut res = String::from("0");
        for code in sub_codes {
            res.push_str(&code);
        }
        res.push('1');
        res
    }

    /// Canonical string representing the unrooted free tree.
    pub fn canonical_encoding(&self) -> String {
        let centers = self.centers();
        if centers.len() == 1 {
            self.ahu_encoding(centers[0], self.n)
        } else {
            let code1 = self.ahu_encoding(centers[0], centers[1]);
            let code2 = self.ahu_encoding(centers[1], centers[0]);
            let mut parts = vec![code1, code2];
            parts.sort();
            format!("0{}{}", parts[0], parts[1])
        }
    }
}

/// Generates all non-isomorphic rooted trees of size n using Beyer-Hedetniemi algorithm.
pub fn generate_free_trees(n: usize) -> Vec<Tree> {
    if n == 1 {
        return vec![Tree::from_edges(1, Vec::new())];
    }
    if n == 2 {
        return vec![Tree::from_edges(2, vec![(0, 1)])];
    }

    // Generate rooted trees via level sequence L
    // L[0] = 0, L[i] <= L[i-1] + 1
    let mut trees = Vec::new();
    let mut seen_canonical = std::collections::HashSet::new();

    let mut l = vec![0; n];
    for i in 0..n {
        l[i] = i;
    }

    loop {
        // Construct tree from level sequence: parent of node i is the latest j < i with L[j] = L[i] - 1
        let mut edges = Vec::with_capacity(n - 1);
        let mut last_at_level = vec![0; n];
        for i in 1..n {
            let parent = last_at_level[l[i] - 1];
            edges.push((parent, i));
            last_at_level[l[i]] = i;
        }

        let tree = Tree::from_edges(n, edges);
        let canon = tree.canonical_encoding();
        if !seen_canonical.contains(&canon) {
            seen_canonical.insert(canon);
            trees.push(tree);
        }

        // Find next level sequence in lexicographical order (Beyer-Hedetniemi)
        let mut p = 0;
        for i in 1..n {
            if l[i] > 1 {
                p = i;
            }
        }
        if p == 0 {
            break;
        }

        let mut q = 0;
        for i in 0..p {
            if l[i] == l[p] - 1 {
                q = i;
            }
        }

        for i in p..n {
            l[i] = l[i - (p - q)];
        }
    }

    trees
}
