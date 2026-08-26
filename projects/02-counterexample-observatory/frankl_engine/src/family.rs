use serde::{Deserialize, Serialize};

/// A finite set family on universe {0, ..., m-1}, with m <= 64.
/// Each set is represented as a u64 bitmask (bit i is 1 iff element i is in the set).
#[derive(Clone, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub struct SetFamily {
    pub universe_size: usize,
    pub sets: Vec<u64>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct FamilyStats {
    pub universe_size: usize,
    pub active_elements: usize,
    pub active_mask: u64,
    pub size: usize,
    pub contains_empty: bool,
    pub contains_universe: bool,
    pub is_union_closed: bool,
    pub is_separating: bool,
    pub element_frequencies: Vec<usize>,
    pub max_frequency: usize,
    pub min_frequency: usize,
    pub max_freq_num: usize,
    pub max_freq_den: usize,
    pub max_freq_float: f64,
    pub satisfies_frankl: bool,
    pub is_strictly_half: bool,
    pub best_elements: Vec<usize>,
}

fn gcd(mut a: usize, mut b: usize) -> usize {
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }
    a
}

impl SetFamily {
    pub fn new(universe_size: usize, mut sets: Vec<u64>) -> Self {
        sets.sort_unstable();
        sets.dedup();
        SetFamily {
            universe_size,
            sets,
        }
    }

    /// Compute the union-closure of a generating family of sets.
    pub fn from_generators(universe_size: usize, generators: &[u64], include_empty: bool) -> Self {
        let mut family_sets = Vec::new();
        if include_empty {
            family_sets.push(0u64);
        }

        let num_gen = generators.len();
        let max_subsets = 1usize << num_gen;
        for mask in 1..max_subsets {
            let mut u = 0u64;
            for (i, &g) in generators.iter().enumerate().take(num_gen) {
                if (mask & (1 << i)) != 0 {
                    u |= g;
                }
            }
            family_sets.push(u);
        }

        Self::new(universe_size, family_sets)
    }

    /// Check if the family is union-closed.
    pub fn is_union_closed(&self) -> bool {
        let n = self.sets.len();
        for i in 0..n {
            let si = self.sets[i];
            for j in i..n {
                let union_set = si | self.sets[j];
                if self.sets.binary_search(&union_set).is_err() {
                    return false;
                }
            }
        }
        true
    }

    /// Compute the active ground set mask: U(F) = \bigcup_{S in F} S.
    pub fn active_universe_mask(&self) -> u64 {
        let mut mask = 0u64;
        for &s in &self.sets {
            mask |= s;
        }
        mask
    }

    /// Check if the family is separating (no two elements belong to the exact same sets).
    pub fn is_separating(&self) -> bool {
        let active_mask = self.active_universe_mask();
        let m = self.universe_size;
        for i in 0..m {
            if (active_mask & (1 << i)) == 0 {
                continue;
            }
            for j in (i + 1)..m {
                if (active_mask & (1 << j)) == 0 {
                    continue;
                }
                // Check if there is some set containing i but not j, or j but not i
                let mut separated = false;
                for &s in &self.sets {
                    let has_i = (s & (1 << i)) != 0;
                    let has_j = (s & (1 << j)) != 0;
                    if has_i != has_j {
                        separated = true;
                        break;
                    }
                }
                if !separated {
                    return false;
                }
            }
        }
        true
    }

    /// Compute full Frankl analysis of the family.
    pub fn analyze(&self) -> FamilyStats {
        let m = self.universe_size;
        let size = self.sets.len();
        let active_mask = self.active_universe_mask();
        let active_count = active_mask.count_ones() as usize;

        let contains_empty = self.sets.binary_search(&0u64).is_ok();
        let full_mask = if m == 64 { u64::MAX } else { (1u64 << m) - 1 };
        let contains_universe = self.sets.binary_search(&full_mask).is_ok();

        let union_closed = self.is_union_closed();
        let separating = self.is_separating();

        let mut freqs = vec![0usize; m];
        for &s in &self.sets {
            for i in 0..m {
                if (s & (1 << i)) != 0 {
                    freqs[i] += 1;
                }
            }
        }

        let mut max_freq = 0usize;
        let mut min_freq = usize::MAX;
        let mut best_elems = Vec::new();

        if active_count == 0 {
            // Trivial family {empty} or empty
            return FamilyStats {
                universe_size: m,
                active_elements: 0,
                active_mask: 0,
                size,
                contains_empty,
                contains_universe,
                is_union_closed: union_closed,
                is_separating: false,
                element_frequencies: freqs,
                max_frequency: 0,
                min_frequency: 0,
                max_freq_num: 0,
                max_freq_den: 1,
                max_freq_float: 0.0,
                satisfies_frankl: true, // Vacuous for trivial family
                is_strictly_half: false,
                best_elements: Vec::new(),
            };
        }

        for i in 0..m {
            if (active_mask & (1 << i)) != 0 {
                let f = freqs[i];
                if f > max_freq {
                    max_freq = f;
                    best_elems.clear();
                    best_elems.push(i);
                } else if f == max_freq {
                    best_elems.push(i);
                }

                if f < min_freq {
                    min_freq = f;
                }
            }
        }

        // Frankl predicate: exists x in U(F) with 2 * f(x) >= |F|
        let satisfies = 2 * max_freq >= size;
        let is_strictly_half = 2 * max_freq == size;

        let g = gcd(max_freq, size);
        let num = max_freq / g;
        let den = size / g;
        let float_val = max_freq as f64 / size as f64;

        FamilyStats {
            universe_size: m,
            active_elements: active_count,
            active_mask,
            size,
            contains_empty,
            contains_universe,
            is_union_closed: union_closed,
            is_separating: separating,
            element_frequencies: freqs,
            max_frequency: max_freq,
            min_frequency: if min_freq == usize::MAX { 0 } else { min_freq },
            max_freq_num: num,
            max_freq_den: den,
            max_freq_float: float_val,
            satisfies_frankl: satisfies,
            is_strictly_half,
            best_elements: best_elems,
        }
    }

    /// Permute the universe according to permutation `p`.
    pub fn permute(&self, p: &[usize]) -> Self {
        let mut new_sets = Vec::with_capacity(self.sets.len());
        for &s in &self.sets {
            let mut new_s = 0u64;
            for (i, &pi) in p.iter().enumerate().take(self.universe_size) {
                if (s & (1 << i)) != 0 {
                    new_s |= 1 << pi;
                }
            }
            new_sets.push(new_s);
        }
        SetFamily::new(self.universe_size, new_sets)
    }

    /// Canonical form under universe permutations S_m.
    pub fn canonical_form(&self) -> SetFamily {
        let m = self.universe_size;
        if m <= 1 {
            return self.clone();
        }

        let mut p: Vec<usize> = (0..m).collect();
        let mut best_family = self.clone();

        // Heap's algorithm for permutations of 0..m
        fn generate_perms(
            k: usize,
            p: &mut [usize],
            orig: &SetFamily,
            best: &mut SetFamily,
        ) {
            if k == 1 {
                let cand = orig.permute(p);
                if cand.sets < best.sets {
                    *best = cand;
                }
                return;
            }

            generate_perms(k - 1, p, orig, best);
            for i in 0..(k - 1) {
                if k % 2 == 0 {
                    p.swap(i, k - 1);
                } else {
                    p.swap(0, k - 1);
                }
                generate_perms(k - 1, p, orig, best);
            }
        }

        generate_perms(m, &mut p, self, &mut best_family);
        best_family
    }
}
