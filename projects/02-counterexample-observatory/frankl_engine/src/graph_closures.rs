use crate::family::{BitSet, Family};
use rayon::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GraphClosureStats {
    pub num_vertices: usize,
    pub graphs_tested: usize,
    pub open_closure_counterexamples: usize,
    pub closed_closure_counterexamples: usize,
    pub clique_closure_counterexamples: usize,
    pub min_open_ratio: f64,
    pub min_closed_ratio: f64,
    pub min_clique_ratio: f64,
}

/// Represents a simple undirected graph on n <= 32 vertices.
#[derive(Debug, Clone)]
pub struct SimpleGraph {
    pub n: usize,
    pub adj: Vec<u32>, // adj[v] is bitmask of neighbors of v
}

impl SimpleGraph {
    pub fn new(n: usize) -> Self {
        Self {
            n,
            adj: vec![0; n],
        }
    }

    pub fn add_edge(&mut self, u: usize, v: usize) {
        self.adj[u] |= 1 << v;
        self.adj[v] |= 1 << u;
    }

    pub fn is_connected(&self) -> bool {
        if self.n <= 1 {
            return true;
        }
        let mut visited = 1u32; // start at vertex 0
        let mut queue = vec![0usize];
        while let Some(u) = queue.pop() {
            let mut neighbors = self.adj[u] & !visited;
            while neighbors != 0 {
                let v = neighbors.trailing_zeros() as usize;
                neighbors &= neighbors - 1;
                visited |= 1 << v;
                queue.push(v);
            }
        }
        visited.count_ones() as usize == self.n
    }

    /// Open neighborhood basis: { N(v) : v in V }
    pub fn open_neighborhood_family(&self) -> Family {
        let gens: Vec<BitSet> = self.adj.clone();
        Family::from_generators(self.n, &gens)
    }

    /// Closed neighborhood basis: { N[v] = N(v) U {v} : v in V }
    pub fn closed_neighborhood_family(&self) -> Family {
        let gens: Vec<BitSet> = (0..self.n)
            .map(|v| self.adj[v] | (1 << v))
            .collect();
        Family::from_generators(self.n, &gens)
    }

    /// Maximal cliques basis (using Bron-Kerbosch)
    pub fn maximal_cliques_family(&self) -> Family {
        let mut cliques = Vec::new();
        let r = 0u32;
        let p = (1u32 << self.n) - 1;
        let x = 0u32;
        self.bron_kerbosch(r, p, x, &mut cliques);
        Family::from_generators(self.n, &cliques)
    }

    fn bron_kerbosch(&self, r: u32, mut p: u32, mut x: u32, cliques: &mut Vec<BitSet>) {
        if p == 0 && x == 0 {
            cliques.push(r);
            return;
        }
        // Pivot selection
        let u = if (p | x) != 0 {
            (p | x).trailing_zeros() as usize
        } else {
            0
        };
        let mut candidates = p & !self.adj[u];
        while candidates != 0 {
            let v = candidates.trailing_zeros() as usize;
            candidates &= candidates - 1;
            let v_mask = 1 << v;
            self.bron_kerbosch(
                r | v_mask,
                p & self.adj[v],
                x & self.adj[v],
                cliques,
            );
            p &= !v_mask;
            x |= v_mask;
        }
    }
}

/// Enumerate and test all graphs on n vertices (for n <= 7 or sample for n=8).
pub fn analyze_graph_closures(n: usize) -> GraphClosureStats {
    let num_pairs = n * (n - 1) / 2;
    let total_graphs = 1usize << num_pairs;

    let mut pairs = Vec::new();
    for u in 0..n {
        for v in (u + 1)..n {
            pairs.push((u, v));
        }
    }

    // Limit to reasonable number of graphs if n >= 7
    let max_graphs_to_test = total_graphs.min(200_000);
    let step = if total_graphs > max_graphs_to_test {
        total_graphs / max_graphs_to_test
    } else {
        1
    };

    use std::sync::atomic::{AtomicUsize, Ordering};
    use std::sync::Mutex;

    let graphs_tested = AtomicUsize::new(0);
    let open_cex = AtomicUsize::new(0);
    let closed_cex = AtomicUsize::new(0);
    let clique_cex = AtomicUsize::new(0);

    let min_ratios = Mutex::new((1.0f64, 1.0f64, 1.0f64));

    let indices: Vec<usize> = (0..total_graphs).step_by(step).collect();

    indices.par_iter().for_each(|&mask| {
        let mut g = SimpleGraph::new(n);
        for (i, &(u, v)) in pairs.iter().enumerate() {
            if (mask & (1 << i)) != 0 {
                g.add_edge(u, v);
            }
        }

        if !g.is_connected() {
            return;
        }

        graphs_tested.fetch_add(1, Ordering::Relaxed);

        let f_open = g.open_neighborhood_family();
        let r_open = f_open.frankl_ratio();
        if !f_open.satisfies_frankl() {
            open_cex.fetch_add(1, Ordering::Relaxed);
        }

        let f_closed = g.closed_neighborhood_family();
        let r_closed = f_closed.frankl_ratio();
        if !f_closed.satisfies_frankl() {
            closed_cex.fetch_add(1, Ordering::Relaxed);
        }

        let f_clique = g.maximal_cliques_family();
        let r_clique = f_clique.frankl_ratio();
        if !f_clique.satisfies_frankl() {
            clique_cex.fetch_add(1, Ordering::Relaxed);
        }

        let mut lock = min_ratios.lock().unwrap();
        if r_open < lock.0 { lock.0 = r_open; }
        if r_closed < lock.1 { lock.1 = r_closed; }
        if r_clique < lock.2 { lock.2 = r_clique; }
    });

    let (m_open, m_closed, m_clique) = *min_ratios.lock().unwrap();

    GraphClosureStats {
        num_vertices: n,
        graphs_tested: graphs_tested.load(Ordering::Relaxed),
        open_closure_counterexamples: open_cex.load(Ordering::Relaxed),
        closed_closure_counterexamples: closed_cex.load(Ordering::Relaxed),
        clique_closure_counterexamples: clique_cex.load(Ordering::Relaxed),
        min_open_ratio: m_open,
        min_closed_ratio: m_closed,
        min_clique_ratio: m_clique,
    }
}
