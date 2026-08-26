use crate::tree::Tree;

/// Find a graceful labeling f: V -> {0, ..., n-1} for tree T using tree-directed BFS CSP.
pub fn find_graceful_labeling(tree: &Tree) -> Option<Vec<usize>> {
    let n = tree.n;
    if n <= 1 {
        return Some(vec![0]);
    }
    if n == 2 {
        return Some(vec![0, 1]);
    }

    let adj = tree.adjacency_list();
    let deg = tree.degrees();

    // Pick root: maximum degree vertex
    let mut root = 0;
    let mut max_d = 0;
    for i in 0..n {
        if deg[i] > max_d {
            max_d = deg[i];
            root = i;
        }
    }

    // BFS order from root to get parent array
    let mut order = Vec::with_capacity(n);
    let mut parent = vec![usize::MAX; n];
    let mut visited = vec![false; n];
    let mut queue = vec![root];
    visited[root] = true;

    while let Some(u) = queue.pop() {
        order.push(u);
        // Sort neighbors by degree descending for tightest constraints first
        let mut neighbors: Vec<usize> = adj[u].iter().copied().filter(|&v| !visited[v]).collect();
        neighbors.sort_by_key(|&v| std::cmp::Reverse(deg[v]));
        for v in neighbors {
            visited[v] = true;
            parent[v] = u;
            queue.push(v);
        }
    }

    let mut labels = vec![usize::MAX; n];
    let mut used_label = vec![false; n];
    let mut used_diff = vec![false; n]; // 1..=n-1

    // Try starting with root label 0, 1, ..., n-1
    for start_val in 0..n {
        labels[root] = start_val;
        used_label[start_val] = true;

        if dfs_tree(1, n, &order, &parent, &mut labels, &mut used_label, &mut used_diff) {
            return Some(labels);
        }

        used_label[start_val] = false;
        labels[root] = usize::MAX;
    }

    None
}

fn dfs_tree(
    step: usize,
    n: usize,
    order: &[usize],
    parent: &[usize],
    labels: &mut [usize],
    used_label: &mut [bool],
    used_diff: &mut [bool],
) -> bool {
    if step == n {
        return true;
    }

    let v = order[step];
    let p = parent[v];
    let p_label = labels[p];

    // Branch over unused differences (from largest down to 1 for aggressive pruning)
    for d in (1..n).rev() {
        if used_diff[d] {
            continue;
        }

        // Try p_label + d
        let c_plus = p_label + d;
        if c_plus < n && !used_label[c_plus] {
            labels[v] = c_plus;
            used_label[c_plus] = true;
            used_diff[d] = true;

            if dfs_tree(step + 1, n, order, parent, labels, used_label, used_diff) {
                return true;
            }

            used_diff[d] = false;
            used_label[c_plus] = false;
            labels[v] = usize::MAX;
        }

        // Try p_label - d
        if p_label >= d {
            let c_minus = p_label - d;
            if !used_label[c_minus] {
                labels[v] = c_minus;
                used_label[c_minus] = true;
                used_diff[d] = true;

                if dfs_tree(step + 1, n, order, parent, labels, used_label, used_diff) {
                    return true;
                }

                used_diff[d] = false;
                used_label[c_minus] = false;
                labels[v] = usize::MAX;
            }
        }
    }

    false
}

/// Verify if a labeling is a valid graceful labeling for tree T.
pub fn is_graceful(tree: &Tree, labeling: &[usize]) -> bool {
    let n = tree.n;
    if labeling.len() != n {
        return false;
    }

    // Check bijection to {0, ..., n-1}
    let mut seen_label = vec![false; n];
    for &l in labeling {
        if l >= n || seen_label[l] {
            return false;
        }
        seen_label[l] = true;
    }

    // Check edge differences {1, ..., n-1}
    let mut seen_diff = vec![false; n];
    for &(u, v) in &tree.edges {
        let lu = labeling[u];
        let lv = labeling[v];
        let d = if lu > lv { lu - lv } else { lv - lu };
        if d == 0 || d >= n || seen_diff[d] {
            return false;
        }
        seen_diff[d] = true;
    }

    for d in 1..n {
        if !seen_diff[d] {
            return false;
        }
    }

    true
}
