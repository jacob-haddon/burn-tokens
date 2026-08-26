use crate::family::Family;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DesignBenchmarkResult {
    pub name: String,
    pub ground_set_size: usize,
    pub num_generators: usize,
    pub union_family_size: usize,
    pub max_degree: usize,
    pub frankl_ratio: f64,
    pub satisfies_frankl: bool,
    pub is_extremal: bool,
}

pub fn benchmark_classical_designs() -> Vec<DesignBenchmarkResult> {
    let mut results = Vec::new();

    // 1. Fano plane PG(2, 2)
    // Points: 0..7. 7 lines:
    // L0: {0, 1, 2}
    // L1: {0, 3, 4}
    // L2: {0, 5, 6}
    // L3: {1, 3, 5}
    // L4: {1, 4, 6}
    // L5: {2, 3, 6}
    // L6: {2, 4, 5}
    let fano_lines = vec![
        (1 << 0) | (1 << 1) | (1 << 2),
        (1 << 0) | (1 << 3) | (1 << 4),
        (1 << 0) | (1 << 5) | (1 << 6),
        (1 << 1) | (1 << 3) | (1 << 5),
        (1 << 1) | (1 << 4) | (1 << 6),
        (1 << 2) | (1 << 3) | (1 << 6),
        (1 << 2) | (1 << 4) | (1 << 5),
    ];
    let fano_fam = Family::from_generators(7, &fano_lines);
    let (fano_max_deg, _) = fano_fam.max_degree();
    results.push(DesignBenchmarkResult {
        name: "Fano Plane PG(2, 2) Lines".to_string(),
        ground_set_size: 7,
        num_generators: 7,
        union_family_size: fano_fam.sets.len(),
        max_degree: fano_max_deg,
        frankl_ratio: fano_fam.frankl_ratio(),
        satisfies_frankl: fano_fam.satisfies_frankl(),
        is_extremal: fano_fam.is_extremal(),
    });

    // 2. Affine Plane AG(2, 3) (9 points, 12 lines of size 3)
    // Points (x, y) for x, y in {0, 1, 2}, index = 3*x + y
    let mut ag23_lines = Vec::new();
    // Horizontal lines: x = c
    for x in 0..3 {
        let mask = (1 << (3 * x + 0)) | (1 << (3 * x + 1)) | (1 << (3 * x + 2));
        ag23_lines.push(mask);
    }
    // Vertical lines: y = c
    for y in 0..3 {
        let mask = (1 << (3 * 0 + y)) | (1 << (3 * 1 + y)) | (1 << (3 * 2 + y));
        ag23_lines.push(mask);
    }
    // Diagonal lines: y = x + c (mod 3)
    for c in 0..3 {
        let mut mask = 0u32;
        for x in 0..3 {
            let y = (x + c) % 3;
            mask |= 1 << (3 * x + y);
        }
        ag23_lines.push(mask);
    }
    // Anti-diagonal lines: y = 2x + c (mod 3)
    for c in 0..3 {
        let mut mask = 0u32;
        for x in 0..3 {
            let y = (2 * x + c) % 3;
            mask |= 1 << (3 * x + y);
        }
        ag23_lines.push(mask);
    }
    let ag23_fam = Family::from_generators(9, &ag23_lines);
    let (ag23_max_deg, _) = ag23_fam.max_degree();
    results.push(DesignBenchmarkResult {
        name: "Affine Plane AG(2, 3) Lines".to_string(),
        ground_set_size: 9,
        num_generators: 12,
        union_family_size: ag23_fam.sets.len(),
        max_degree: ag23_max_deg,
        frankl_ratio: ag23_fam.frankl_ratio(),
        satisfies_frankl: ag23_fam.satisfies_frankl(),
        is_extremal: ag23_fam.is_extremal(),
    });

    // 3. Petersen Graph Open Neighborhoods
    // 10 vertices: outer 0..4 (cycle), inner 5..9 (star)
    let mut petersen_adj = vec![0u32; 10];
    let edges = vec![
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 0), // outer cycle
        (5, 7), (7, 9), (9, 6), (6, 8), (8, 5), // inner star
        (0, 5), (1, 6), (2, 7), (3, 8), (4, 9), // spokes
    ];
    for (u, v) in edges {
        petersen_adj[u] |= 1 << v;
        petersen_adj[v] |= 1 << u;
    }
    let pet_open_fam = Family::from_generators(10, &petersen_adj);
    let (pet_open_max_deg, _) = pet_open_fam.max_degree();
    results.push(DesignBenchmarkResult {
        name: "Petersen Graph Open Neighborhoods".to_string(),
        ground_set_size: 10,
        num_generators: 10,
        union_family_size: pet_open_fam.sets.len(),
        max_degree: pet_open_max_deg,
        frankl_ratio: pet_open_fam.frankl_ratio(),
        satisfies_frankl: pet_open_fam.satisfies_frankl(),
        is_extremal: pet_open_fam.is_extremal(),
    });

    // 4. Complete bipartite graph K_{3, 3}
    let mut k33_adj = vec![0u32; 6];
    for u in 0..3 {
        for v in 3..6 {
            k33_adj[u] |= 1 << v;
            k33_adj[v] |= 1 << u;
        }
    }
    let k33_fam = Family::from_generators(6, &k33_adj);
    let (k33_max_deg, _) = k33_fam.max_degree();
    results.push(DesignBenchmarkResult {
        name: "Complete Bipartite K_{3, 3} Neighborhoods".to_string(),
        ground_set_size: 6,
        num_generators: 6,
        union_family_size: k33_fam.sets.len(),
        max_degree: k33_max_deg,
        frankl_ratio: k33_fam.frankl_ratio(),
        satisfies_frankl: k33_fam.satisfies_frankl(),
        is_extremal: k33_fam.is_extremal(),
    });

    results
}
