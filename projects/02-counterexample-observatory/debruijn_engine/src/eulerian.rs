/// State graph representation of G(k, n)
/// Vertices are (n-1)-tuples encoded as integers in 0..k^(n-1).
/// Out-edges from vertex u = (x_1, ..., x_{n-1}) lead to v = (x_2, ..., x_{n-1}, s) for s in 0..k.
pub struct DeBruijnGraph {
    pub k: usize,
    pub n: usize,
    pub num_edges: usize,
    pub adj: Vec<Vec<(usize, usize, usize)>>, // adj[u] = [(v, symbol, edge_id)]
}

impl DeBruijnGraph {
    pub fn new(k: usize, n: usize) -> Self {
        if n <= 1 {
            let num_edges = k;
            let mut adj = vec![vec![]; 1];
            for s in 0..k {
                adj[0].push((0, s, s));
            }
            return Self { k, n, num_edges, adj };
        }

        let num_nodes = k.pow((n - 1) as u32);
        let num_edges = k.pow(n as u32);
        let mut adj = vec![vec![]; num_nodes];
        let mut edge_id = 0;

        for u in 0..num_nodes {
            for s in 0..k {
                let v = (u % k.pow((n - 2) as u32)) * k + s;
                adj[u].push((v, s, edge_id));
                edge_id += 1;
            }
        }

        Self { k, n, num_edges, adj }
    }

    /// Count all distinct Eulerian cycles starting at vertex 0 and traversing first out-edge 0.
    /// By fixing the starting vertex and initial edge, the count of returned cycles equals N(k, n) / k^n.
    pub fn count_eulerian_cycles(&self) -> usize {
        if self.n <= 1 {
            // Permutations of k symbols
            let mut fact = 1;
            for i in 1..self.k {
                fact *= i;
            }
            return fact;
        }

        let mut used_edges = vec![false; self.num_edges];
        let mut count = 0;

        // Fix starting node 0 and choose first edge
        let start_node = 0;
        let (first_v, _s, first_edge_id) = self.adj[start_node][0];
        used_edges[first_edge_id] = true;

        self.backtrack_eulerian(first_v, 1, &mut used_edges, &mut count);

        count
    }

    fn backtrack_eulerian(&self, curr_node: usize, edges_traversed: usize, used_edges: &mut [bool], count: &mut usize) {
        if edges_traversed == self.num_edges {
            if curr_node == 0 {
                *count += 1;
            }
            return;
        }

        for &(next_node, _symbol, edge_id) in &self.adj[curr_node] {
            if !used_edges[edge_id] {
                used_edges[edge_id] = true;
                self.backtrack_eulerian(next_node, edges_traversed + 1, used_edges, count);
                used_edges[edge_id] = false;
            }
        }
    }
}
