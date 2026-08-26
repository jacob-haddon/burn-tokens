use serde::{Deserialize, Serialize};

/// Representation of a finite partially ordered set (poset) on `n` elements (n <= 16).
/// Elements are indexed 0 .. n-1.
/// The relation is stored as bitmasks: `less_than[i] & (1 << j) != 0` iff i < j in the strict partial order.
#[derive(Clone, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct Poset {
    pub n: usize,
    /// `less_than[i]` bitmask: bit j is 1 iff i < j (strict).
    pub less_than: [u16; 16],
    /// `greater_than[i]` bitmask: bit j is 1 iff i > j (strict).
    pub greater_than: [u16; 16],
}

impl std::fmt::Debug for Poset {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Poset(n={}, covers={:?})", self.n, self.hasse_covers())
    }
}

impl Poset {
    /// Create an empty poset with `n` elements and no relations (an antichain).
    pub fn new(n: usize) -> Self {
        assert!(n <= 16, "Poset size must be <= 16");
        Poset {
            n,
            less_than: [0; 16],
            greater_than: [0; 16],
        }
    }

    /// Construct a poset from strict relations and compute transitive closure.
    pub fn from_relations(n: usize, relations: &[(usize, usize)]) -> Result<Self, &'static str> {
        let mut poset = Poset::new(n);
        for &(u, v) in relations {
            if u >= n || v >= n {
                return Err("Index out of bounds");
            }
            if u == v {
                return Err("Self-loop violates strict partial order");
            }
            poset.less_than[u] |= 1 << v;
            poset.greater_than[v] |= 1 << u;
        }

        // Compute transitive closure via Floyd-Warshall bitwise
        poset.compute_transitive_closure()?;
        Ok(poset)
    }

    /// Compute transitive closure and verify strict partial order axioms (irreflexive, acyclic).
    pub fn compute_transitive_closure(&mut self) -> Result<(), &'static str> {
        for k in 0..self.n {
            for i in 0..self.n {
                if (self.less_than[i] & (1 << k)) != 0 {
                    self.less_than[i] |= self.less_than[k];
                }
            }
        }

        // Recompute greater_than
        for i in 0..self.n {
            self.greater_than[i] = 0;
        }
        for i in 0..self.n {
            for j in 0..self.n {
                if (self.less_than[i] & (1 << j)) != 0 {
                    self.greater_than[j] |= 1 << i;
                }
            }
        }

        // Check irreflexivity (no cycles)
        for i in 0..self.n {
            if (self.less_than[i] & (1 << i)) != 0 {
                return Err("Cycle detected: relation is not a strict partial order");
            }
        }

        Ok(())
    }

    #[inline(always)]
    pub fn is_less(&self, u: usize, v: usize) -> bool {
        (self.less_than[u] & (1 << v)) != 0
    }

    #[inline(always)]
    pub fn is_greater(&self, u: usize, v: usize) -> bool {
        (self.greater_than[u] & (1 << v)) != 0
    }

    #[inline(always)]
    pub fn is_incomparable(&self, u: usize, v: usize) -> bool {
        u != v && !self.is_less(u, v) && !self.is_greater(u, v)
    }

    /// Check if the poset is a total order (a chain).
    #[allow(dead_code)]
    pub fn is_total_order(&self) -> bool {
        for i in 0..self.n {
            for j in (i + 1)..self.n {
                if self.is_incomparable(i, j) {
                    return false;
                }
            }
        }
        true
    }

    /// Number of incomparable pairs (u, v) with u < v.
    #[allow(dead_code)]
    pub fn count_incomparable_pairs(&self) -> usize {
        let mut count = 0;
        for i in 0..self.n {
            for j in (i + 1)..self.n {
                if self.is_incomparable(i, j) {
                    count += 1;
                }
            }
        }
        count
    }

    /// List all incomparable pairs (u, v) with u < v.
    #[allow(dead_code)]
    pub fn incomparable_pairs(&self) -> Vec<(usize, usize)> {
        let mut pairs = Vec::new();
        for i in 0..self.n {
            for j in (i + 1)..self.n {
                if self.is_incomparable(i, j) {
                    pairs.push((i, j));
                }
            }
        }
        pairs
    }

    /// Cover relation (Hasse diagram edges): u < v such that there is no w with u < w < v.
    pub fn hasse_covers(&self) -> Vec<(usize, usize)> {
        let mut covers = Vec::new();
        for u in 0..self.n {
            for v in 0..self.n {
                if self.is_less(u, v) {
                    // Check if there is any intermediate w
                    let intermediate = self.less_than[u] & self.greater_than[v];
                    if intermediate == 0 {
                        covers.push((u, v));
                    }
                }
            }
        }
        covers
    }

    /// Compute all order ideals (down-sets).
    /// A set I (bitmask) is a down-set if for all y in I and x < y, x is in I.
    pub fn order_ideals(&self) -> Vec<u16> {
        let max_mask = 1 << self.n;
        let mut ideals = Vec::new();
        for mask in 0..max_mask {
            let mut is_ideal = true;
            for v in 0..self.n {
                if (mask & (1 << v)) != 0 {
                    // All elements strictly less than v must be in mask
                    if (self.greater_than[v] & !mask) != 0 {
                        is_ideal = false;
                        break;
                    }
                }
            }
            if is_ideal {
                ideals.push(mask as u16);
            }
        }
        ideals
    }

    /// Maximal elements in a down-set `mask`: elements x in mask having no y in mask with x < y.
    #[inline(always)]
    pub fn maximal_in_ideal(&self, mask: u16) -> u16 {
        let mut max_elements = 0u16;
        for v in 0..self.n {
            if (mask & (1 << v)) != 0 {
                // If no other element in mask is > v
                if (self.less_than[v] & mask) == 0 {
                    max_elements |= 1 << v;
                }
            }
        }
        max_elements
    }

    /// Minimal elements in remaining set (V \ mask): elements y not in mask having no x not in mask with x < y.
    #[inline(always)]
    pub fn minimal_in_complement(&self, mask: u16) -> u16 {
        let full_mask = (1 << self.n) - 1;
        let complement = full_mask & !mask;
        let mut min_elements = 0u16;
        for v in 0..self.n {
            if (complement & (1 << v)) != 0 {
                // If no other element in complement is < v
                if (self.greater_than[v] & complement) == 0 {
                    min_elements |= 1 << v;
                }
            }
        }
        min_elements
    }

    /// Check if the comparability graph of the poset is connected.
    pub fn is_connected(&self) -> bool {
        if self.n <= 1 {
            return true;
        }
        let mut visited = 1u16; // start at vertex 0
        let mut queue = vec![0usize];
        while let Some(u) = queue.pop() {
            for v in 0..self.n {
                if (visited & (1 << v)) == 0 && (self.is_less(u, v) || self.is_greater(u, v)) {
                    visited |= 1 << v;
                    queue.push(v);
                }
            }
        }
        visited == ((1 << self.n) - 1)
    }

    /// Height of the poset (size of longest chain).
    pub fn height(&self) -> usize {
        if self.n == 0 {
            return 0;
        }
        let mut chain_len = vec![1usize; self.n];
        // Dynamic programming on DAG
        for _ in 0..self.n {
            let mut updated = false;
            for u in 0..self.n {
                for v in 0..self.n {
                    if self.is_less(u, v) && chain_len[v] < chain_len[u] + 1 {
                        chain_len[v] = chain_len[u] + 1;
                        updated = true;
                    }
                }
            }
            if !updated {
                break;
            }
        }
        *chain_len.iter().max().unwrap_or(&0)
    }

    /// Width of the poset (size of largest antichain).
    pub fn width(&self) -> usize {
        if self.n == 0 {
            return 0;
        }
        let max_mask = 1 << self.n;
        let mut max_width = 1;
        for mask in 1..max_mask {
            let count = (mask as u16).count_ones() as usize;
            if count <= max_width {
                continue;
            }
            // Check if mask is an antichain
            let mut is_antichain = true;
            for i in 0..self.n {
                if (mask & (1 << i)) != 0 {
                    if (self.less_than[i] & mask) != 0 || (self.greater_than[i] & mask) != 0 {
                        is_antichain = false;
                        break;
                    }
                }
            }
            if is_antichain && count > max_width {
                max_width = count;
            }
        }
        max_width
    }

    /// Relabel vertices according to a permutation `p` where `p[i]` is the new index of vertex `i`.
    pub fn permute(&self, p: &[usize]) -> Self {
        let mut new_poset = Poset::new(self.n);
        for i in 0..self.n {
            for j in 0..self.n {
                if self.is_less(i, j) {
                    let ni = p[i];
                    let nj = p[j];
                    new_poset.less_than[ni] |= 1 << nj;
                    new_poset.greater_than[nj] |= 1 << ni;
                }
            }
        }
        new_poset
    }

    /// Compute an integer signature for the adjacency matrix (for canonical comparison).
    pub fn adjacency_code(&self) -> (u64, u64, u64, u64) {
        let mut c0 = 0u64;
        let mut c1 = 0u64;
        let mut c2 = 0u64;
        let mut c3 = 0u64;
        for i in 0..self.n.min(4) {
            c0 |= (self.less_than[i] as u64) << (i * 16);
        }
        for i in 4..self.n.min(8) {
            c1 |= (self.less_than[i] as u64) << ((i - 4) * 16);
        }
        for i in 8..self.n.min(12) {
            c2 |= (self.less_than[i] as u64) << ((i - 8) * 16);
        }
        for i in 12..self.n.min(16) {
            c3 |= (self.less_than[i] as u64) << ((i - 12) * 16);
        }
        (c0, c1, c2, c3)
    }

    /// Compute vertex invariants to partition vertices for fast canonical form search:
    /// Invariants per vertex v: (in-degree, out-degree, down-set size, up-set size).
    pub fn vertex_invariants(&self) -> Vec<(u32, u32, u32, u32)> {
        let mut invs = Vec::with_capacity(self.n);
        for v in 0..self.n {
            let in_deg = self.greater_than[v].count_ones();
            let out_deg = self.less_than[v].count_ones();
            let down_size = in_deg + 1;
            let up_size = out_deg + 1;
            invs.push((in_deg, out_deg, down_size, up_size));
        }
        invs
    }

    /// Compute canonical representative poset and its canonical code.
    pub fn canonical_form(&self) -> (Poset, (u64, u64, u64, u64)) {
        if self.n <= 1 {
            return (self.clone(), self.adjacency_code());
        }

        let invs = self.vertex_invariants();
        let mut distinct_invs = invs.clone();
        distinct_invs.sort_unstable();
        distinct_invs.dedup();

        let mut groups: Vec<Vec<usize>> = Vec::new();
        for &target in &distinct_invs {
            let group: Vec<usize> = (0..self.n).filter(|&v| invs[v] == target).collect();
            groups.push(group);
        }

        let mut current_perm = vec![0usize; self.n];
        let mut best_poset = self.clone();
        let mut best_code = (0u64, 0u64, 0u64, 0u64);
        let mut first = true;

        fn backtrack(
            group_idx: usize,
            slot_idx: usize,
            groups: &[Vec<usize>],
            used: &mut [bool],
            current_perm: &mut [usize],
            original_poset: &Poset,
            best_poset: &mut Poset,
            best_code: &mut (u64, u64, u64, u64),
            first: &mut bool,
        ) {
            if group_idx == groups.len() {
                let cand = original_poset.permute(current_perm);
                let code = cand.adjacency_code();
                if *first || code > *best_code {
                    *best_code = code;
                    *best_poset = cand;
                    *first = false;
                }
                return;
            }

            let group = &groups[group_idx];
            if slot_idx == group.len() {
                backtrack(
                    group_idx + 1,
                    0,
                    groups,
                    used,
                    current_perm,
                    original_poset,
                    best_poset,
                    best_code,
                    first,
                );
                return;
            }

            let target_base: usize = groups[..group_idx].iter().map(|g| g.len()).sum();
            for choice in 0..group.len() {
                let target_pos = target_base + choice;
                if !used[target_pos] {
                    used[target_pos] = true;
                    current_perm[group[slot_idx]] = target_pos;
                    backtrack(
                        group_idx,
                        slot_idx + 1,
                        groups,
                        used,
                        current_perm,
                        original_poset,
                        best_poset,
                        best_code,
                        first,
                    );
                    used[target_pos] = false;
                }
            }
        }

        let mut used = vec![false; self.n];
        backtrack(
            0,
            0,
            &groups,
            &mut used,
            &mut current_perm,
            self,
            &mut best_poset,
            &mut best_code,
            &mut first,
        );

        (best_poset, best_code)
    }
}
