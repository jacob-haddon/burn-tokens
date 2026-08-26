use crate::metrics::SetMetrics;
use rayon::prelude::*;

fn gcd(mut a: u64, mut b: u64) -> u64 {
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }
    a
}

fn set_gcd(arr: &[u64]) -> u64 {
    arr.iter().copied().fold(0, gcd)
}

/// Generate candidate structured sets (AP, GP, 2D grid, smooth numbers).
pub fn generate_structured_candidates(k: usize) -> Vec<Vec<u64>> {
    let mut candidates = Vec::new();

    // 1. Arithmetic progression
    candidates.push((1..=k as u64).collect());

    // 2. Geometric progressions (r = 2, 3, 4, 5)
    for r in [2, 3, 4, 5] {
        let mut gp = Vec::with_capacity(k);
        let mut val = 1u64;
        for _ in 0..k {
            gp.push(val);
            val = val.saturating_mul(r);
        }
        if gp.len() == k && gp.last().copied().unwrap_or(0) > 0 {
            candidates.push(gp);
        }
    }

    // 3. 2D grids / GAPs: X * Y >= k
    for x in 2..=k {
        for y in 2..=k {
            if x * y >= k {
                // Multiplicative grid {2^a * 3^b}
                let mut grid = Vec::new();
                for a in 0..x {
                    for b in 0..y {
                        let val = 2u64.pow(a as u32) * 3u64.pow(b as u32);
                        grid.push(val);
                    }
                }
                grid.sort_unstable();
                grid.dedup();
                if grid.len() >= k {
                    candidates.push(grid[0..k].to_vec());
                }

                // Additive-multiplicative mixed
                let mut mixed = Vec::new();
                for a in 1..=x as u64 {
                    for b in 1..=y as u64 {
                        mixed.push(a * 6u64.pow(b as u32 - 1));
                    }
                }
                mixed.sort_unstable();
                mixed.dedup();
                if mixed.len() >= k {
                    candidates.push(mixed[0..k].to_vec());
                }
            }
        }
    }

    // 4. Smooth numbers {2^a 3^b <= 100}
    let mut smooth = Vec::new();
    for a in 0..=7 {
        for b in 0..=5 {
            let val = 2u64.pow(a) * 3u64.pow(b);
            if val <= 150 {
                smooth.push(val);
            }
        }
    }
    smooth.sort_unstable();
    smooth.dedup();

    // Take various k-element prefixes and windows of smooth numbers
    for i in 0..smooth.len().saturating_sub(k) {
        let window = smooth[i..i + k].to_vec();
        candidates.push(window);
    }

    candidates
}

/// Exhaustively search all integer subsets of size k in {1, ..., N}.
pub fn find_exact_extremal_sum_product(k: usize, n: usize) -> (usize, Vec<SetMetrics>) {
    // Generate all combinations of size k from 1..=N with gcd == 1
    let mut all_subsets = Vec::new();
    let universe: Vec<u64> = (1..=n as u64).collect();

    fn combine(
        start: usize,
        k: usize,
        current: &mut Vec<u64>,
        universe: &[u64],
        out: &mut Vec<Vec<u64>>,
    ) {
        if current.len() == k {
            if set_gcd(current) == 1 {
                out.push(current.clone());
            }
            return;
        }
        for i in start..universe.len() {
            current.push(universe[i]);
            combine(i + 1, k, current, universe, out);
            current.pop();
        }
    }

    let mut cur = Vec::with_capacity(k);
    combine(0, k, &mut cur, &universe, &mut all_subsets);

    // Also append structured candidates
    for cand in generate_structured_candidates(k) {
        if set_gcd(&cand) == 1 {
            all_subsets.push(cand);
        }
    }

    // Compute metrics in parallel
    let all_metrics: Vec<SetMetrics> = all_subsets
        .par_iter()
        .map(|s| SetMetrics::compute(s))
        .collect();

    let min_max = all_metrics
        .iter()
        .map(|m| m.max_sum_product)
        .min()
        .unwrap_or(0);

    let mut minimizers: Vec<SetMetrics> = all_metrics
        .into_iter()
        .filter(|m| m.max_sum_product == min_max)
        .collect();

    // Sort by sumset_size, productset_size
    minimizers.sort_by_key(|m| (m.sumset_size, m.productset_size, m.set.clone()));
    minimizers.dedup_by(|a, b| a.set == b.set);

    (min_max, minimizers)
}
