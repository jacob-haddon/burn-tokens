use serde::{Deserialize, Serialize};
use std::collections::HashSet;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LinearCliqueSystem {
    pub n: usize,
    pub name: String,
    pub num_vertices: usize,
    pub cliques: Vec<Vec<usize>>,
    pub is_valid_efl_instance: bool,
    pub max_pairwise_intersection: usize,
    pub chromatic_number: usize,
    pub efl_bound_satisfied: bool,
    pub coloring: Vec<usize>,
}

impl LinearCliqueSystem {
    pub fn new(n: usize, name: String, cliques: Vec<Vec<usize>>) -> Self {
        // Collect all distinct vertices and remap to 0..V-1
        let mut all_v: Vec<usize> = cliques.iter().flatten().cloned().collect();
        all_v.sort();
        all_v.dedup();
        let num_vertices = all_v.len();

        let mapped_cliques: Vec<Vec<usize>> = cliques
            .iter()
            .map(|c| c.iter().map(|&v| all_v.binary_search(&v).unwrap()).collect())
            .collect();
        let cliques = mapped_cliques;

        let mut max_inter = 0;
        let mut is_valid = cliques.len() == n;

        for (i, c1) in cliques.iter().enumerate() {
            if c1.len() != n {
                is_valid = false;
            }
            let s1: HashSet<usize> = c1.iter().cloned().collect();
            if s1.len() != c1.len() {
                is_valid = false;
            }

            for (j, c2) in cliques.iter().enumerate().skip(i + 1) {
                let inter_count = c2.iter().filter(|v| s1.contains(v)).count();
                if inter_count > max_inter {
                    max_inter = inter_count;
                }
            }
        }

        if max_inter > 1 {
            is_valid = false;
        }

        let mut sys = Self {
            n,
            name,
            num_vertices,
            cliques,
            is_valid_efl_instance: is_valid,
            max_pairwise_intersection: max_inter,
            chromatic_number: 0,
            efl_bound_satisfied: false,
            coloring: Vec::new(),
        };

        let (chi, col) = sys.compute_chromatic_number();
        sys.chromatic_number = chi;
        sys.efl_bound_satisfied = chi <= n;
        sys.coloring = col;

        sys
    }

    /// Build adjacency matrix of the union graph G = \bigcup K_i
    pub fn build_adjacency_matrix(&self) -> Vec<Vec<bool>> {
        let v = self.num_vertices;
        let mut adj = vec![vec![false; v]; v];
        for c in &self.cliques {
            let len = c.len();
            for i in 0..len {
                for j in (i + 1)..len {
                    let u = c[i];
                    let w = c[j];
                    if u < v && w < v {
                        adj[u][w] = true;
                        adj[w][u] = true;
                    }
                }
            }
        }
        adj
    }

    /// Exact chromatic number calculation via DSATUR / backtracking
    pub fn compute_chromatic_number(&self) -> (usize, Vec<usize>) {
        let v = self.num_vertices;
        if v == 0 {
            return (0, Vec::new());
        }

        let adj = self.build_adjacency_matrix();

        // Lower bound is n since each clique has size n
        let min_k = self.n;

        for k in min_k..=(self.n + 2) {
            let mut coloring = vec![usize::MAX; v];
            if Self::backtrack_color(&adj, v, k, 0, &mut coloring) {
                return (k, coloring);
            }
        }

        // Fallback for upper bound
        let mut greedy_coloring = vec![usize::MAX; v];
        let mut max_c = 0;
        for i in 0..v {
            let mut used = vec![false; v + 1];
            for j in 0..v {
                if adj[i][j] && greedy_coloring[j] != usize::MAX {
                    used[greedy_coloring[j]] = true;
                }
            }
            let mut c = 0;
            while used[c] {
                c += 1;
            }
            greedy_coloring[i] = c;
            if c + 1 > max_c {
                max_c = c + 1;
            }
        }
        (max_c, greedy_coloring)
    }

    fn backtrack_color(
        adj: &[Vec<bool>],
        num_v: usize,
        max_colors: usize,
        node: usize,
        coloring: &mut [usize],
    ) -> bool {
        if node == num_v {
            return true;
        }

        // DSATUR vertex selection: pick uncolored vertex with highest degree of saturation
        let mut best_v = usize::MAX;
        let mut max_sat = 0;
        let mut max_deg = 0;

        for i in 0..num_v {
            if coloring[i] == usize::MAX {
                let mut sat_colors = vec![false; max_colors];
                let mut deg = 0;
                for j in 0..num_v {
                    if adj[i][j] {
                        deg += 1;
                        if coloring[j] != usize::MAX {
                            sat_colors[coloring[j]] = true;
                        }
                    }
                }
                let sat = sat_colors.iter().filter(|&&b| b).count();
                if sat > max_sat || (sat == max_sat && deg >= max_deg) {
                    max_sat = sat;
                    max_deg = deg;
                    best_v = i;
                }
            }
        }

        if best_v == usize::MAX {
            return true;
        }

        let mut available = vec![true; max_colors];
        for j in 0..num_v {
            if adj[best_v][j] && coloring[j] != usize::MAX {
                available[coloring[j]] = false;
            }
        }

        for c in 0..max_colors {
            if available[c] {
                coloring[best_v] = c;
                if Self::backtrack_color(adj, num_v, max_colors, node + 1, coloring) {
                    return true;
                }
                coloring[best_v] = usize::MAX;
            }
        }

        false
    }
}
