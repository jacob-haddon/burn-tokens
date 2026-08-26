use std::collections::BTreeSet;
use crate::semigroup::NumericalSemigroup;

fn gcd(mut a: usize, mut b: usize) -> usize {
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }
    a
}

pub fn gcd_slice(slice: &[usize]) -> usize {
    if slice.is_empty() {
        return 0;
    }
    let mut res = slice[0];
    for &x in &slice[1..] {
        res = gcd(res, x);
    }
    res
}

/// Construct a numerical semigroup from a given generating set.
pub fn from_generators(gens: &[usize]) -> Option<NumericalSemigroup> {
    if gens.is_empty() || gcd_slice(gens) != 1 {
        return None;
    }

    let min_gen = *gens.iter().min().unwrap();
    if min_gen == 1 {
        return Some(NumericalSemigroup::new(BTreeSet::new()));
    }

    // Upper bound on Frobenius number: for 2 gens: a*b - a - b.
    // For general gens, Brauer / Johnson bound or simple bounded DP.
    let max_gen = *gens.iter().max().unwrap();
    let max_search = (max_gen * max_gen).max(500);

    let mut reachable = vec![false; max_search + 1];
    reachable[0] = true;

    for &g in gens {
        for i in g..=max_search {
            if reachable[i - g] {
                reachable[i] = true;
            }
        }
    }

    // Find conductor: start of min_gen consecutive trues
    let mut consecutive = 0;
    let mut conductor = 0;
    for i in 0..=max_search {
        if reachable[i] {
            consecutive += 1;
            if consecutive == min_gen {
                conductor = i + 1 - min_gen;
                break;
            }
        } else {
            consecutive = 0;
        }
    }

    if conductor == 0 && !reachable[max_search] {
        // Search bound was too small, double and retry if needed
        return None;
    }

    let mut gaps = BTreeSet::new();
    for i in 1..conductor {
        if !reachable[i] {
            gaps.insert(i);
        }
    }

    Some(NumericalSemigroup::new(gaps))
}

/// Generate a wide variety of parametric numerical semigroups up to high genus (g <= 60).
pub fn generate_parametric_semigroups(max_genus: usize) -> Vec<NumericalSemigroup> {
    let mut semigroups = Vec::new();

    // 1. Two-generator semigroups <a, b> with gcd(a, b) = 1
    for a in 2..=30 {
        for b in (a + 1)..=50 {
            if gcd(a, b) == 1 {
                if let Some(s) = from_generators(&[a, b]) {
                    if s.genus() <= max_genus {
                        semigroups.push(s);
                    }
                }
            }
        }
    }

    // 2. Three-generator semigroups <a, b, c>
    for a in 3..=20 {
        for b in (a + 1)..=25 {
            for c in (b + 1)..=30 {
                if gcd_slice(&[a, b, c]) == 1 {
                    if let Some(s) = from_generators(&[a, b, c]) {
                        if s.genus() <= max_genus && s.embedding_dimension() == 3 {
                            semigroups.push(s);
                        }
                    }
                }
            }
        }
    }

    // 3. Four-generator semigroups <a, b, c, d>
    for a in 4..=15 {
        for b in (a + 1)..=18 {
            for c in (b + 1)..=22 {
                for d in (c + 1)..=26 {
                    if gcd_slice(&[a, b, c, d]) == 1 {
                        if let Some(s) = from_generators(&[a, b, c, d]) {
                            if s.genus() <= max_genus && s.embedding_dimension() == 4 {
                                semigroups.push(s);
                            }
                        }
                    }
                }
            }
        }
    }

    // 4. Five-generator semigroups <a, b, c, d, e>
    for a in 5..=12 {
        for b in (a + 1)..=14 {
            for c in (b + 1)..=16 {
                for d in (c + 1)..=18 {
                    for e in (d + 1)..=20 {
                        if gcd_slice(&[a, b, c, d, e]) == 1 {
                            if let Some(s) = from_generators(&[a, b, c, d, e]) {
                                if s.genus() <= max_genus && s.embedding_dimension() == 5 {
                                    semigroups.push(s);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    semigroups
}
