#![allow(dead_code)]
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct Digraph {
    pub n: usize,
    pub adj: Vec<u32>, // adj[u] has bit v set iff u -> v
}

impl Digraph {
    pub fn new(n: usize) -> Self {
        assert!(n <= 32, "Max vertices supported is 32");
        Self {
            n,
            adj: vec![0; n],
        }
    }

    #[inline(always)]
    pub fn add_edge(&mut self, u: usize, v: usize) {
        debug_assert!(u < self.n && v < self.n && u != v);
        self.adj[u] |= 1 << v;
    }

    #[inline(always)]
    pub fn remove_edge(&mut self, u: usize, v: usize) {
        debug_assert!(u < self.n && v < self.n);
        self.adj[u] &= !(1 << v);
    }

    #[inline(always)]
    pub fn has_edge(&self, u: usize, v: usize) -> bool {
        (self.adj[u] & (1 << v)) != 0
    }

    #[inline(always)]
    pub fn out_degree(&self, u: usize) -> usize {
        self.adj[u].count_ones() as usize
    }

    pub fn in_degree(&self, v: usize) -> usize {
        let mut count = 0;
        let mask = 1 << v;
        for u in 0..self.n {
            if (self.adj[u] & mask) != 0 {
                count += 1;
            }
        }
        count
    }

    pub fn min_out_degree(&self) -> usize {
        (0..self.n)
            .map(|u| self.out_degree(u))
            .min()
            .unwrap_or(0)
    }

    pub fn max_out_degree(&self) -> usize {
        (0..self.n)
            .map(|u| self.out_degree(u))
            .max()
            .unwrap_or(0)
    }

    pub fn out_degrees(&self) -> Vec<usize> {
        (0..self.n).map(|u| self.out_degree(u)).collect()
    }

    pub fn count_edges(&self) -> usize {
        self.adj.iter().map(|&mask| mask.count_ones() as usize).sum()
    }

    /// Checks if there exists any 2-cycle u -> v -> u
    pub fn has_2cycle(&self) -> bool {
        for u in 0..self.n {
            let mut mask = self.adj[u];
            while mask != 0 {
                let v = mask.trailing_zeros() as usize;
                mask &= mask - 1;
                if v > u && (self.adj[v] & (1 << u)) != 0 {
                    return true;
                }
            }
        }
        false
    }

    /// Fast check for existence of directed 3-cycle u -> v -> w -> u (pairwise distinct)
    pub fn has_directed_triangle(&self) -> bool {
        for u in 0..self.n {
            let mut out_u = self.adj[u];
            while out_u != 0 {
                let v = out_u.trailing_zeros() as usize;
                out_u &= out_u - 1;
                if v == u {
                    continue;
                }
                let mut out_v = self.adj[v];
                while out_v != 0 {
                    let w = out_v.trailing_zeros() as usize;
                    out_v &= out_v - 1;
                    if w != u && w != v && (self.adj[w] & (1 << u)) != 0 {
                        return true;
                    }
                }
            }
        }
        false
    }

    /// Count exact number of directed triangles (u, v, w) up to cyclic shift (1/3 of ordered triangles)
    pub fn count_directed_triangles(&self) -> usize {
        let mut count = 0;
        for u in 0..self.n {
            for v in 0..self.n {
                if v == u || !self.has_edge(u, v) {
                    continue;
                }
                for w in 0..self.n {
                    if w == u || w == v || !self.has_edge(v, w) {
                        continue;
                    }
                    if self.has_edge(w, u) {
                        count += 1;
                    }
                }
            }
        }
        count / 3
    }

    /// Computes the directed girth (length of shortest directed cycle).
    /// Returns None if the graph is a DAG (acyclic).
    pub fn compute_girth(&self) -> Option<usize> {
        let mut min_cycle = usize::MAX;
        let mut dist = vec![0usize; self.n];
        let mut visited = vec![false; self.n];
        let mut queue = std::collections::VecDeque::with_capacity(self.n);

        for start in 0..self.n {
            dist.fill(0);
            visited.fill(false);
            queue.clear();

            // Push all out-neighbors of start
            let mut mask = self.adj[start];
            while mask != 0 {
                let v = mask.trailing_zeros() as usize;
                mask &= mask - 1;
                if v == start {
                    return Some(1); // Self loop
                }
                dist[v] = 1;
                visited[v] = true;
                queue.push_back(v);
            }

            while let Some(u) = queue.pop_front() {
                let d = dist[u];
                if d >= min_cycle {
                    break;
                }

                if (self.adj[u] & (1 << start)) != 0 {
                    let cycle_len = d + 1;
                    if cycle_len < min_cycle {
                        min_cycle = cycle_len;
                    }
                }

                let mut out_u = self.adj[u];
                while out_u != 0 {
                    let next = out_u.trailing_zeros() as usize;
                    out_u &= out_u - 1;
                    if !visited[next] && next != start {
                        visited[next] = true;
                        dist[next] = d + 1;
                        queue.push_back(next);
                    }
                }
            }
        }

        if min_cycle == usize::MAX {
            None
        } else {
            Some(min_cycle)
        }
    }

    /// Canonical adjacency matrix representation as 0/1 integers
    pub fn to_matrix(&self) -> Vec<Vec<u8>> {
        let mut mat = vec![vec![0u8; self.n]; self.n];
        for u in 0..self.n {
            for v in 0..self.n {
                if (self.adj[u] & (1 << v)) != 0 {
                    mat[u][v] = 1;
                }
            }
        }
        mat
    }
}
