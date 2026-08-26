use crate::hypergraph::LinearCliqueSystem;

pub struct SystemGenerators;

impl SystemGenerators {
    /// Star intersection: all n cliques share a single central vertex 0
    pub fn star(n: usize) -> LinearCliqueSystem {
        let mut cliques = Vec::with_capacity(n);
        let mut next_v = 1;
        for _ in 0..n {
            let mut c = vec![0];
            for _ in 1..n {
                c.push(next_v);
                next_v += 1;
            }
            cliques.push(c);
        }
        LinearCliqueSystem::new(n, format!("Star-{}", n), cliques)
    }

    /// Path / Chain intersection: K_i intersects K_{i+1} at a single vertex
    pub fn chain(n: usize) -> LinearCliqueSystem {
        let mut cliques = Vec::with_capacity(n);
        let mut next_v = 0;
        let mut shared_nodes = Vec::new();

        for i in 0..(n - 1) {
            shared_nodes.push(next_v);
            next_v += 1;
        }

        for i in 0..n {
            let mut c = Vec::with_capacity(n);
            if i > 0 {
                c.push(shared_nodes[i - 1]);
            }
            if i < n - 1 {
                c.push(shared_nodes[i]);
            }
            while c.len() < n {
                c.push(next_v);
                next_v += 1;
            }
            cliques.push(c);
        }
        LinearCliqueSystem::new(n, format!("Chain-{}", n), cliques)
    }

    /// Cycle intersection: K_i intersects K_{i+1} and K_n intersects K_1
    pub fn cycle(n: usize) -> LinearCliqueSystem {
        let mut cliques = Vec::with_capacity(n);
        let mut next_v = 0;
        let mut cycle_nodes = Vec::new();
        for _ in 0..n {
            cycle_nodes.push(next_v);
            next_v += 1;
        }

        for i in 0..n {
            let mut c = Vec::with_capacity(n);
            c.push(cycle_nodes[i]);
            c.push(cycle_nodes[(i + 1) % n]);
            while c.len() < n {
                c.push(next_v);
                next_v += 1;
            }
            cliques.push(c);
        }
        LinearCliqueSystem::new(n, format!("Cycle-{}", n), cliques)
    }

    /// General graph intersection topology: Given an intersection graph H on n nodes,
    /// an edge {i, j} means K_i and K_j share a single vertex.
    pub fn from_intersection_graph(
        n: usize,
        name: String,
        edges: &[(usize, usize)],
    ) -> Option<LinearCliqueSystem> {
        // Verify no vertex has degree > n-1
        let mut degrees = vec![0; n];
        for &(u, v) in edges {
            if u >= n || v >= n || u == v {
                return None;
            }
            degrees[u] += 1;
            degrees[v] += 1;
        }
        for d in degrees {
            if d >= n {
                return None;
            }
        }

        let mut cliques = vec![Vec::with_capacity(n); n];
        let mut next_v = 0;

        for &(u, v) in edges {
            let shared = next_v;
            next_v += 1;
            cliques[u].push(shared);
            cliques[v].push(shared);
        }

        for i in 0..n {
            while cliques[i].len() < n {
                cliques[i].push(next_v);
                next_v += 1;
            }
        }

        Some(LinearCliqueSystem::new(n, name, cliques))
    }

    /// Complete / Projective Plane Subsystem PG(2, q) for q = n - 1
    pub fn projective_plane_subsystem(q: usize) -> Option<LinearCliqueSystem> {
        let n = q + 1;
        // Generate projective plane points as 1D subspaces of F_q^3
        // For prime q in {2, 3, 5, 7}:
        let lines = match q {
            2 => Self::fano_plane_lines(),
            3 => Self::pg2_3_lines(),
            5 => Self::pg2_prime_lines(5),
            7 => Self::pg2_prime_lines(7),
            _ => return None,
        };

        if lines.len() < n {
            return None;
        }

        // Take any n lines
        let selected_lines = lines[0..n].to_vec();
        Some(LinearCliqueSystem::new(
            n,
            format!("PG(2,{})-Subsystem-{}", q, n),
            selected_lines,
        ))
    }

    fn fano_plane_lines() -> Vec<Vec<usize>> {
        // PG(2, 2) has 7 points and 7 lines of size 3
        vec![
            vec![0, 1, 2],
            vec![0, 3, 4],
            vec![0, 5, 6],
            vec![1, 3, 5],
            vec![1, 4, 6],
            vec![2, 3, 6],
            vec![2, 4, 5],
        ]
    }

    fn pg2_3_lines() -> Vec<Vec<usize>> {
        // PG(2, 3) has 13 points and 13 lines of size 4
        Self::pg2_prime_lines(3)
    }

    fn pg2_prime_lines(p: usize) -> Vec<Vec<usize>> {
        let mut points = Vec::new();
        // Homogeneous coordinates (x, y, z) in F_p^3:
        // Canonical representatives:
        // (1, y, z) for y, z in 0..p -> p^2 points
        for y in 0..p {
            for z in 0..p {
                points.push((1, y, z));
            }
        }
        // (0, 1, z) for z in 0..p -> p points
        for z in 0..p {
            points.push((0, 1, z));
        }
        // (0, 0, 1) -> 1 point
        points.push((0, 0, 1));

        let num_pts = points.len(); // p^2 + p + 1

        // Each line is defined by a homogeneous equation ax + by + cz = 0 (mod p)
        let mut lines = Vec::new();
        for &l_normal in &points {
            let (a, b, c) = l_normal;
            let mut line_pts = Vec::new();
            for (idx, &(x, y, z)) in points.iter().enumerate() {
                if (a * x + b * y + c * z) % p == 0 {
                    line_pts.push(idx);
                }
            }
            if line_pts.len() == p + 1 {
                lines.push(line_pts);
            }
        }

        lines
    }
}
