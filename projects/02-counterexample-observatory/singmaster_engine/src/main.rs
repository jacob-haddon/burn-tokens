use serde::Serialize;
use std::collections::HashMap;
use std::fs::{self, File};
use std::io::Write;
use std::path::Path;
use std::time::Instant;

/// Safely compute binomial coefficient C(n, k) using exact 128-bit integer arithmetic.
/// Returns None on overflow or if C(n, k) exceeds limit.
fn binom_u128(n: u128, mut k: u128, limit: u128) -> Option<u128> {
    if k > n {
        return None;
    }
    if k > n - k {
        k = n - k;
    }
    if k == 0 {
        return Some(1);
    }
    if k == 1 {
        return if n <= limit { Some(n) } else { None };
    }

    let mut res: u128 = 1;
    for i in 1..=k {
        let num = n - k + i;
        let den = i;
        // Divide res and num by gcd with den to prevent intermediate overflow
        let g = gcd(res, den);
        res /= g;
        let den_rem = den / g;

        let g2 = gcd(num, den_rem);
        let num_div = num / g2;
        let den_final = den_rem / g2;
        assert_eq!(den_final, 1, "Denominator must divide completely");

        match res.checked_mul(num_div) {
            Some(val) => {
                if val > limit {
                    return None;
                }
                res = val;
            }
            None => return None,
        }
    }
    Some(res)
}

fn gcd(mut a: u128, mut b: u128) -> u128 {
    while b != 0 {
        let t = b;
        b = a % b;
        a = t;
    }
    a
}

/// Compute exact integer square root using integer Newton's method.
fn isqrt_u128(n: u128) -> u128 {
    if n == 0 {
        return 0;
    }
    let mut x0 = 1 << ((128 - n.leading_zeros() + 1) / 2);
    loop {
        let x1 = (x0 + n / x0) / 2;
        if x1 >= x0 {
            return x0;
        }
        x0 = x1;
    }
}

#[derive(Debug, Serialize, Clone)]
struct Representation {
    n: u64,
    k: u64,
}

#[derive(Debug, Serialize, Clone)]
struct MultiplicityEntry {
    value: u128,
    total_multiplicity: usize,
    non_trivial_count: usize,
    representations: Vec<Representation>,
}

#[derive(Debug, Serialize)]
struct SingmasterReport {
    limit: u128,
    elapsed_ms: u128,
    total_k3_pairs_evaluated: usize,
    total_distinct_k3_values: usize,
    max_multiplicity_found: usize,
    champion_values: Vec<u128>,
    entries_with_multiplicity_ge_6: Vec<MultiplicityEntry>,
    entries_with_multiplicity_ge_8: Vec<MultiplicityEntry>,
}

fn main() {
    let start_time = Instant::now();
    let limit: u128 = 100_000_000_000_000; // 10^14

    println!("=================================================================");
    println!("  SINGMASTER BINOMIAL MULTIPLICITY ENGINE (Limit N = 10^14)      ");
    println!("=================================================================");

    // Map: value -> list of (n, k) pairs with 3 <= k <= n/2
    let mut k3_map: HashMap<u128, Vec<(u64, u64)>> = HashMap::new();
    let mut total_pairs = 0;

    // Search k from 3 upwards
    for k in 3u64..=100 {
        let mut n = 2 * k;
        let mut found_any = false;
        loop {
            match binom_u128(n as u128, k as u128, limit) {
                Some(val) => {
                    found_any = true;
                    total_pairs += 1;
                    k3_map.entry(val).or_default().push((n, k));
                    n += 1;
                }
                None => break,
            }
        }
        if !found_any && n == 2 * k {
            // Even C(2k, k) exceeds limit
            break;
        }
    }

    println!("[*] Generated {} (n, k) pairs with k >= 3.", total_pairs);
    println!("[*] Found {} distinct values with k >= 3.", k3_map.len());

    let mut multi_ge_6: Vec<MultiplicityEntry> = Vec::new();
    let mut multi_ge_8: Vec<MultiplicityEntry> = Vec::new();
    let mut max_mult = 0;
    let mut champions = Vec::new();

    for (&val, pairs) in &k3_map {
        let mut all_reps = Vec::new();
        // 1. Trivial representation C(val, 1) = val
        if val > 1 && val <= limit {
            all_reps.push(Representation { n: val as u64, k: 1 });
        }

        // 2. Check if val = C(m, 2) = m*(m-1)/2
        // 8*val + 1 = (2m-1)^2
        let disc = 8 * val + 1;
        let s = isqrt_u128(disc);
        if s * s == disc && s % 2 == 1 {
            let m = (s + 1) / 2;
            if m >= 4 { // k=2 <= m/2 implies m >= 4
                all_reps.push(Representation { n: m as u64, k: 2 });
            }
        }

        // 3. Add all k >= 3 representations
        for &(n, k) in pairs {
            all_reps.push(Representation { n, k });
        }

        // Compute total occurrences in Pascal's triangle
        // Each representation with k < n/2 gives 2 occurrences (n, k) and (n, n-k)
        // A central coefficient with 2k == n gives 1 occurrence (n, n/2)
        let mut total_mult = 0;
        let mut non_trivial = 0;
        for rep in &all_reps {
            if rep.k == 1 {
                total_mult += 2; // C(val, 1) and C(val, val-1)
            } else if 2 * rep.k == rep.n {
                total_mult += 1;
                non_trivial += 1;
            } else {
                total_mult += 2;
                non_trivial += 1;
            }
        }

        if total_mult > max_mult {
            max_mult = total_mult;
            champions = vec![val];
        } else if total_mult == max_mult {
            champions.push(val);
        }

        let entry = MultiplicityEntry {
            value: val,
            total_multiplicity: total_mult,
            non_trivial_count: non_trivial,
            representations: all_reps,
        };

        if total_mult >= 6 {
            multi_ge_6.push(entry.clone());
        }
        if total_mult >= 8 {
            multi_ge_8.push(entry);
        }
    }

    multi_ge_6.sort_by_key(|e| e.value);
    multi_ge_8.sort_by_key(|e| e.value);

    let elapsed = start_time.elapsed().as_millis();

    println!("\n[*] RESULTS (Search up to N = 10^14):");
    println!("    Maximum multiplicity found: {}", max_mult);
    println!("    Champion integer(s) with max multiplicity: {:?}", champions);
    println!("    Total integers with multiplicity >= 6: {}", multi_ge_6.len());
    println!("    Total integers with multiplicity >= 8: {}", multi_ge_8.len());

    println!("\n[*] Spectrum of integers with multiplicity >= 6:");
    for entry in &multi_ge_6 {
        println!("    - Value: {:15} | Multiplicity: {} | Reps: {:?}",
                 entry.value, entry.total_multiplicity,
                 entry.representations.iter().map(|r| format!("C({},{})", r.n, r.k)).collect::<Vec<_>>());
    }

    let report = SingmasterReport {
        limit,
        elapsed_ms: elapsed,
        total_k3_pairs_evaluated: total_pairs,
        total_distinct_k3_values: k3_map.len(),
        max_multiplicity_found: max_mult,
        champion_values: champions,
        entries_with_multiplicity_ge_6: multi_ge_6,
        entries_with_multiplicity_ge_8: multi_ge_8,
    };

    let data_dir = Path::new("projects/02-counterexample-observatory/data");
    if !data_dir.exists() {
        fs::create_dir_all(data_dir).unwrap();
    }
    let json_path = data_dir.join("singmaster_frontier_n1e14.json");
    let mut file = File::create(&json_path).unwrap();
    let json_str = serde_json::to_string_pretty(&report).unwrap();
    file.write_all(json_str.as_bytes()).unwrap();

    println!("\n[+] Machine-readable report saved to {:?}", json_path);
    println!("=================================================================");
}
