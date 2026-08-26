/// Lyndon word generation and de Bruijn sequence construction via the Fredricksen-Maiorana-Kessler (FKM) algorithm.

use std::collections::HashSet;

/// Generate the lexicographically earliest de Bruijn sequence B(k, n) by concatenating Lyndon words whose lengths divide n.
pub fn generate_debruijn_fkm(k: usize, n: usize) -> Vec<usize> {
    if n == 0 {
        return vec![];
    }
    if k == 1 {
        return vec![0];
    }
    if n == 1 {
        return (0..k).collect();
    }

    let mut sequence = Vec::with_capacity(k.pow(n as u32));
    let mut a = vec![0; n + 1];
    let mut t = 1;
    let mut p = 1;

    // FKM Lyndon word algorithm
    while {
        if n % p == 0 {
            for i in 1..=p {
                sequence.push(a[i]);
            }
        }
        for j in (p + 1)..=n {
            a[j] = a[j - p];
        }
        t = n;
        while t > 0 && a[t] == k - 1 {
            t -= 1;
        }
        if t > 0 {
            a[t] += 1;
            p = t;
        }
        t > 0
    } {}

    sequence
}

/// Verify that a given cyclic sequence of length k^n over alphabet {0..k-1} contains every n-gram exactly once.
pub fn verify_debruijn_coverage(seq: &[usize], k: usize, n: usize) -> (bool, usize, usize) {
    let expected_len = k.pow(n as u32);
    if seq.len() != expected_len {
        return (false, seq.len(), expected_len);
    }

    let mut seen_ngrams = HashSet::new();
    let l = seq.len();

    for i in 0..l {
        let mut ngram = Vec::with_capacity(n);
        for j in 0..n {
            let idx = (i + j) % l;
            ngram.push(seq[idx]);
        }
        seen_ngrams.insert(ngram);
    }

    let unique_count = seen_ngrams.len();
    (unique_count == expected_len, unique_count, expected_len)
}
