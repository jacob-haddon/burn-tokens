use rayon::prelude::*;
use std::sync::atomic::{AtomicUsize, Ordering};

/// Computes the intersection-closure of a family represented as a u32 bitmask on universe 0..(1 << m).
/// Also ensures the top element (1 << m) - 1 is present.
#[inline(always)]
pub fn intersection_closure(mut mask: u32, m: usize) -> u32 {
    let top = (1 << m) - 1;
    mask |= 1 << top; // Must contain [m]

    loop {
        let prev = mask;
        let mut temp = mask;
        while temp != 0 {
            let i = temp.trailing_zeros();
            temp &= temp - 1;

            let mut temp2 = mask;
            while temp2 != 0 {
                let j = temp2.trailing_zeros();
                temp2 &= temp2 - 1;

                let inter = i & j;
                mask |= 1 << inter;
            }
        }
        if mask == prev {
            break;
        }
    }
    mask
}

/// Convert an intersection-closed family mask (Moore family) to its dual union-closed family mask.
/// Duality: S in C <=> (top ^ S) in F.
#[inline(always)]
pub fn dualize_moore_to_union_closed(moore_mask: u32, m: usize) -> u32 {
    let top = (1 << m) - 1;
    let mut union_mask = 0u32;
    let mut temp = moore_mask;
    while temp != 0 {
        let s = temp.trailing_zeros();
        temp &= temp - 1;
        let dual_s = top ^ s;
        union_mask |= 1 << dual_s;
    }
    union_mask
}

/// Fast evaluation of Frankl property on a union-closed family mask.
/// Returns (max_degree, family_size, satisfies_frankl, is_extremal).
#[inline(always)]
pub fn evaluate_frankl_union_mask(union_mask: u32, m: usize, elem_masks: &[u32]) -> (usize, usize, bool, bool) {
    let size = union_mask.count_ones() as usize;
    if size <= 1 {
        return (0, size, true, false);
    }
    let mut max_deg = 0;
    for &em in elem_masks.iter().take(m) {
        let deg = (union_mask & em).count_ones() as usize;
        if deg > max_deg {
            max_deg = deg;
        }
    }
    let satisfies = 2 * max_deg >= size;
    let is_extremal = 2 * max_deg == size;
    (max_deg, size, satisfies, is_extremal)
}

/// Precompute bitmasks of all subsets in 0..2^m containing element x.
pub fn precompute_element_masks(m: usize) -> Vec<u32> {
    let n_subsets = 1 << m;
    let mut masks = vec![0u32; m];
    for x in 0..m {
        let mut mask = 0u32;
        for s in 0..n_subsets {
            if (s & (1 << x)) != 0 {
                mask |= 1 << s;
            }
        }
        masks[x] = mask;
    }
    masks
}

/// Fast recursive tree search of all closure systems on m elements using Ganter's canonical test.
pub fn count_and_evaluate_closure_systems(m: usize) -> ClosureStats {
    let n_subsets = 1 << m;
    let elem_masks = precompute_element_masks(m);
    let initial_closure = intersection_closure(0, m);

    let total_count = AtomicUsize::new(0);
    let counterexamples = AtomicUsize::new(0);
    let extremal_count = AtomicUsize::new(0);
    let non_total_orders = AtomicUsize::new(0);

    // Parallelize at depth 1
    let mut first_level_children = Vec::new();
    for i in 0..n_subsets {
        if (initial_closure & (1 << i)) == 0 {
            let next_cand = initial_closure | (1 << i);
            let next_closed = intersection_closure(next_cand, m);
            let diff = next_closed & !initial_closure;
            let prefix_mask = (1 << i) - 1;
            if (diff & prefix_mask) == 0 {
                first_level_children.push((next_closed, i));
            }
        }
    }

    // Process root
    process_closure(
        initial_closure,
        m,
        &elem_masks,
        &total_count,
        &counterexamples,
        &extremal_count,
        &non_total_orders,
    );

    // Process children in parallel
    first_level_children.par_iter().for_each(|&(child_mask, last_i)| {
        dfs_closure_search(
            child_mask,
            last_i,
            m,
            n_subsets,
            &elem_masks,
            &total_count,
            &counterexamples,
            &extremal_count,
            &non_total_orders,
        );
    });

    ClosureStats {
        ground_set_size: m,
        total_closure_systems: total_count.load(Ordering::Relaxed),
        counterexamples: counterexamples.load(Ordering::Relaxed),
        extremal_count: extremal_count.load(Ordering::Relaxed),
        non_total_orders: non_total_orders.load(Ordering::Relaxed),
    }
}

fn dfs_closure_search(
    current_closed: u32,
    last_i: usize,
    m: usize,
    n_subsets: usize,
    elem_masks: &[u32],
    total_count: &AtomicUsize,
    counterexamples: &AtomicUsize,
    extremal_count: &AtomicUsize,
    non_total_orders: &AtomicUsize,
) {
    process_closure(
        current_closed,
        m,
        elem_masks,
        total_count,
        counterexamples,
        extremal_count,
        non_total_orders,
    );

    for i in (last_i + 1)..n_subsets {
        if (current_closed & (1 << i)) == 0 {
            let next_cand = current_closed | (1 << i);
            let next_closed = intersection_closure(next_cand, m);
            let diff = next_closed & !current_closed;
            let prefix_mask = (1 << i) - 1;
            if (diff & prefix_mask) == 0 {
                dfs_closure_search(
                    next_closed,
                    i,
                    m,
                    n_subsets,
                    elem_masks,
                    total_count,
                    counterexamples,
                    extremal_count,
                    non_total_orders,
                );
            }
        }
    }
}

#[inline(always)]
fn process_closure(
    moore_mask: u32,
    m: usize,
    elem_masks: &[u32],
    total_count: &AtomicUsize,
    counterexamples: &AtomicUsize,
    extremal_count: &AtomicUsize,
    non_total_orders: &AtomicUsize,
) {
    total_count.fetch_add(1, Ordering::Relaxed);
    let union_mask = dualize_moore_to_union_closed(moore_mask, m);
    let (_max_deg, size, satisfies, is_extremal) =
        evaluate_frankl_union_mask(union_mask, m, elem_masks);

    if size >= 2 {
        non_total_orders.fetch_add(1, Ordering::Relaxed);
        if !satisfies {
            counterexamples.fetch_add(1, Ordering::Relaxed);
        }
        if is_extremal {
            extremal_count.fetch_add(1, Ordering::Relaxed);
        }
    }
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct ClosureStats {
    pub ground_set_size: usize,
    pub total_closure_systems: usize,
    pub counterexamples: usize,
    pub extremal_count: usize,
    pub non_total_orders: usize,
}
