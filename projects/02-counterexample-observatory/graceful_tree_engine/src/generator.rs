use crate::tree::Tree;
use rayon::prelude::*;
use std::collections::HashSet;

/// Generate all non-isomorphic rooted trees on `n` vertices using the Beyer-Hedetniemi algorithm.
pub fn generate_all_rooted_trees(n: usize) -> Vec<Tree> {
    if n == 0 {
        return Vec::new();
    }
    if n == 1 {
        return vec![Tree::new(1, Vec::new())];
    }
    if n == 2 {
        return vec![Tree::new(2, vec![(0, 1)])];
    }

    let mut level_seqs: Vec<Vec<usize>> = Vec::new();
    // Start with the path graph: 0, 1, 2, ..., n-1
    let mut l: Vec<usize> = (0..n).collect();
    level_seqs.push(l.clone());

    loop {
        // Find largest p > 0 with l[p] > 1
        let mut p = 0;
        for i in (1..n).rev() {
            if l[i] > 1 {
                p = i;
                break;
            }
        }

        if p == 0 {
            break;
        }

        // Find largest q < p with l[q] = l[p] - 1
        let mut q = 0;
        for i in (0..p).rev() {
            if l[i] == l[p] - 1 {
                q = i;
                break;
            }
        }

        let period = p - q;
        for i in p..n {
            l[i] = l[i - period];
        }

        level_seqs.push(l.clone());
    }

    // Convert each level sequence to a Tree
    level_seqs
        .into_iter()
        .map(|seq| {
            let mut edges = Vec::with_capacity(n - 1);
            for i in 1..n {
                let target_level = seq[i] - 1;
                // Find nearest preceding vertex with target_level
                for j in (0..i).rev() {
                    if seq[j] == target_level {
                        edges.push((j, i));
                        break;
                    }
                }
            }
            Tree::new(n, edges)
        })
        .collect()
}

/// Generate all non-isomorphic unrooted trees on `n` vertices.
pub fn generate_all_unrooted_trees(n: usize) -> Vec<Tree> {
    if n <= 2 {
        return generate_all_rooted_trees(n);
    }

    let rooted = generate_all_rooted_trees(n);
    
    // Parallel canonical code computation
    let coded: Vec<(Tree, String)> = rooted
        .into_par_iter()
        .map(|t| {
            let code = t.canonical_code();
            (t, code)
        })
        .collect();

    let mut seen = HashSet::new();
    let mut unrooted = Vec::new();

    for (tree, code) in coded {
        if seen.insert(code) {
            unrooted.push(tree);
        }
    }

    unrooted
}
