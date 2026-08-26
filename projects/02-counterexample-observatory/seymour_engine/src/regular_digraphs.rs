use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PaleyTournamentResult {
    pub prime_p: usize,
    pub out_degree: usize,
    pub second_out_degree: usize,
    pub is_seymour: bool,
    pub is_strictly_extremal: bool,
}

pub fn audit_paley_tournaments() -> Vec<PaleyTournamentResult> {
    let primes = vec![3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83, 103, 107, 127];
    let mut results = Vec::new();

    for &p in &primes {
        // Find quadratic residues mod p
        let mut is_qr = vec![false; p];
        for x in 1..p {
            is_qr[(x * x) % p] = true;
        }

        // Adjacency matrix using u128 (supports p <= 128)
        let mut adj = vec![0u128; p];
        for i in 0..p {
            for j in 0..p {
                if i != j {
                    let diff = (j + p - i) % p;
                    if is_qr[diff] {
                        adj[i] |= 1u128 << j;
                    }
                }
            }
        }

        let d1 = adj[0].count_ones() as usize;

        // Compute N++(0)
        let mut n2 = 0u128;
        let mut temp = adj[0];
        while temp != 0 {
            let u = temp.trailing_zeros() as usize;
            temp &= temp - 1;
            n2 |= adj[u];
        }
        n2 &= !adj[0] & !1u128;

        let d2 = n2.count_ones() as usize;
        let is_sey = d2 >= d1;
        let is_ext = d2 == d1;

        results.push(PaleyTournamentResult {
            prime_p: p,
            out_degree: d1,
            second_out_degree: d2,
            is_seymour: is_sey,
            is_strictly_extremal: is_ext,
        });
    }

    results
}
