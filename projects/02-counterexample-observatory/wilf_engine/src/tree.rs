use std::collections::BTreeSet;
use crate::semigroup::NumericalSemigroup;

/// Recursive tree traversal of the tree of numerical semigroups (Bras-Amorós construction).
pub fn traverse_semigroup_tree<F>(
    curr: &NumericalSemigroup,
    max_genus: usize,
    genus_counts: &mut Vec<usize>,
    callback: &mut F,
) where
    F: FnMut(&NumericalSemigroup),
{
    let g = curr.genus();
    if g < genus_counts.len() {
        genus_counts[g] += 1;
    }
    callback(curr);

    if g >= max_genus {
        return;
    }

    let f = curr.frobenius();
    let min_gens = curr.minimal_generators();

    // Children are obtained by removing a minimal generator x > F(S)
    for &x in &min_gens {
        if (x as isize) > f {
            let mut next_gaps = curr.gaps.clone();
            next_gaps.insert(x);
            let child = NumericalSemigroup::new(next_gaps);
            traverse_semigroup_tree(&child, max_genus, genus_counts, callback);
        }
    }
}

pub fn count_semigroups_up_to_genus(max_genus: usize) -> (Vec<usize>, Vec<NumericalSemigroup>) {
    let mut genus_counts = vec![0; max_genus + 1];
    let mut collected = Vec::new();
    let root = NumericalSemigroup::new(BTreeSet::new());

    traverse_semigroup_tree(&root, max_genus, &mut genus_counts, &mut |s| {
        if s.genus() <= max_genus {
            collected.push(NumericalSemigroup::new(s.gaps.clone()));
        }
    });

    (genus_counts, collected)
}
