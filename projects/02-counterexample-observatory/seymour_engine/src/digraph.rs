#![allow(dead_code)]
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct OrientedGraph {
    pub n: usize,
    pub adj: Vec<u32>, // adj[u] has bit v set iff directed edge u -> v
}

impl OrientedGraph {
    pub fn new(n: usize) -> Self {
        Self {
            n,
            adj: vec![0; n],
        }
    }

    pub fn from_adj(n: usize, adj: Vec<u32>) -> Self {
        Self { n, adj }
    }

    pub fn add_edge(&mut self, u: usize, v: usize) {
        self.adj[u] |= 1 << v;
    }

    #[inline(always)]
    pub fn has_edge(&self, u: usize, v: usize) -> bool {
        (self.adj[u] & (1 << v)) != 0
    }

    #[inline(always)]
    pub fn out_degree(&self, v: usize) -> usize {
        self.adj[v].count_ones() as usize
    }

    #[inline(always)]
    pub fn in_degree(&self, v: usize) -> usize {
        let mut deg = 0;
        for u in 0..self.n {
            if (self.adj[u] & (1 << v)) != 0 {
                deg += 1;
            }
        }
        deg
    }

    /// Compute second out-neighborhood bitmask N^{++}(v)
    #[inline(always)]
    pub fn second_out_neighborhood(&self, v: usize) -> u32 {
        let mut n2 = 0u32;
        let mut temp = self.adj[v];
        while temp != 0 {
            let u = temp.trailing_zeros() as usize;
            temp &= temp - 1;
            n2 |= self.adj[u];
        }
        // Exclude first out-neighborhood and v itself
        n2 & !self.adj[v] & !(1 << v)
    }

    #[inline(always)]
    pub fn second_out_degree(&self, v: usize) -> usize {
        self.second_out_neighborhood(v).count_ones() as usize
    }

    #[inline(always)]
    pub fn is_seymour_vertex(&self, v: usize) -> bool {
        let d1 = self.out_degree(v);
        let d2 = self.second_out_degree(v);
        d2 >= d1
    }

    pub fn seymour_vertices(&self) -> Vec<usize> {
        (0..self.n)
            .filter(|&v| self.is_seymour_vertex(v))
            .collect()
    }

    pub fn seymour_count(&self) -> usize {
        (0..self.n)
            .filter(|&v| self.is_seymour_vertex(v))
            .count()
    }

    pub fn has_seymour_vertex(&self) -> bool {
        (0..self.n).any(|v| self.is_seymour_vertex(v))
    }

    /// Minimum out-degree vertex and whether it is Seymour
    pub fn min_out_degree_analysis(&self) -> (usize, usize, bool) {
        let mut min_d = usize::MAX;
        let mut min_v = 0;
        for v in 0..self.n {
            let d = self.out_degree(v);
            if d < min_d {
                min_d = d;
                min_v = v;
            }
        }
        let is_sey = self.is_seymour_vertex(min_v);
        (min_v, min_d, is_sey)
    }

    /// Check if graph is a tournament (for all u != v, exactly one edge u->v or v->u)
    pub fn is_tournament(&self) -> bool {
        for u in 0..self.n {
            for v in (u + 1)..self.n {
                let uv = self.has_edge(u, v);
                let vu = self.has_edge(v, u);
                if (uv && vu) || (!uv && !vu) {
                    return false;
                }
            }
        }
        true
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_directed_triangle() {
        // Directed 3-cycle: 0->1->2->0
        let mut g = OrientedGraph::new(3);
        g.add_edge(0, 1);
        g.add_edge(1, 2);
        g.add_edge(2, 0);

        assert!(g.is_tournament());
        // For vertex 0: N+(0) = {1}, d+(0) = 1. N++(0) = N+(1) \ {0, 1} = {2}. d++(0) = 1 >= 1.
        assert!(g.is_seymour_vertex(0));
        assert!(g.is_seymour_vertex(1));
        assert!(g.is_seymour_vertex(2));
        assert_eq!(g.seymour_count(), 3);
    }

    #[test]
    fn test_transitive_tournament() {
        // Transitive tournament on 4 vertices: i -> j for all i < j
        let mut g = OrientedGraph::new(4);
        for i in 0..4 {
            for j in (i + 1)..4 {
                g.add_edge(i, j);
            }
        }
        assert!(g.is_tournament());
        // Vertex 3 has d+(3) = 0, d++(3) = 0 >= 0 (Seymour)
        // Vertex 2 has d+(2) = 1 (to 3), d++(2) = 0 < 1 (Not Seymour)
        // Vertex 1 has d+(1) = 2 (to 2, 3), d++(1) = 0 < 2 (Not Seymour)
        // Vertex 0 has d+(0) = 3, d++(0) = 0 < 3 (Not Seymour)
        assert_eq!(g.seymour_vertices(), vec![3]);
    }
}
