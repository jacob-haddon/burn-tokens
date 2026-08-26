#!/usr/bin/env python3
"""
Independent Python Verifier for Sidon Set Finite Density & Maximum Cardinality (N <= 35)
Ticket: T-0007
Audits all 32,485 extremal Sidon set configurations output by Rust sidon_engine.
"""

import json
import math
import sys
from pathlib import Path

OEIS_A003022 = [
    1,
    2, 2,
    3, 3, 3,
    4, 4, 4, 4, 4,
    5, 5, 5, 5, 5, 5,
    6, 6, 6, 6, 6, 6, 6, 6,
    7, 7, 7, 7, 7, 7, 7, 7, 7,
    8,
]

def verify_pairwise_sums_sidon(elements):
    seen_sums = set()
    n_elems = len(elements)
    for i in range(n_elems):
        for j in range(i, n_elems):
            s = elements[i] + elements[j]
            if s in seen_sums:
                return False, f"Duplicate sum {s} found from pairs"
            seen_sums.add(s)
    return True, None

def verify_pairwise_diffs_sidon(elements):
    seen_diffs = set()
    n_elems = len(elements)
    for i in range(n_elems):
        for j in range(i + 1, n_elems):
            d = elements[j] - elements[i]
            if d in seen_diffs:
                return False, f"Duplicate difference {d} found"
            seen_diffs.add(d)
    return True, None

def canonical_form(elements):
    if not elements:
        return ()
    first = elements[0]
    last = elements[-1]
    translated = tuple(x - first + 1 for x in elements)
    reflected = tuple(sorted(last - x + 1 for x in elements))
    return min(translated, reflected)

def main():
    data_path = Path(__file__).resolve().parent.parent / "data" / "sidon_frontier_results_n35.json"
    if not data_path.exists():
        print(f"[ERROR] Data file not found: {data_path}")
        sys.exit(1)

    print(f"[*] Loading data from {data_path}...")
    with open(data_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    records = data.get("records", [])
    if len(records) != 35:
        print(f"[ERROR] Expected 35 records, found {len(records)}")
        sys.exit(1)

    total_audited_sets = 0
    total_canonical_audited = 0

    print("==========================================================================")
    print("   INDEPENDENT AUDIT: SIDON SET (B2) PROPERTIES & EXTREMAL CATALOG       ")
    print("==========================================================================")

    for rec in records:
        n = rec["n"]
        r_n = rec["r_n"]
        expected_rn = OEIS_A003022[n - 1]
        
        # 1. Check OEIS matching
        if r_n != expected_rn:
            print(f"[FAIL] N={n}: computed R(N)={r_n} != OEIS expected {expected_rn}")
            sys.exit(1)

        all_sets = rec["all_extremal_sets"]
        if len(all_sets) != rec["total_extremal_count"]:
            print(f"[FAIL] N={n}: recorded count {rec['total_extremal_count']} != list len {len(all_sets)}")
            sys.exit(1)

        canonical_seen = set()

        for s in all_sets:
            total_audited_sets += 1
            
            # Check range
            if not all(1 <= x <= n for x in s):
                print(f"[FAIL] N={n}: Element out of range in set {s}")
                sys.exit(1)
                
            # Check sorted strictly increasing
            if s != sorted(list(set(s))) or len(s) != r_n:
                print(f"[FAIL] N={n}: Set {s} not strictly increasing or length {len(s)} != R(N)={r_n}")
                sys.exit(1)

            # Check Sidon sum property
            valid_sums, err_s = verify_pairwise_sums_sidon(s)
            if not valid_sums:
                print(f"[FAIL] N={n}: Set {s} violates Sidon sum property: {err_s}")
                sys.exit(1)

            # Check Sidon difference property
            valid_diffs, err_d = verify_pairwise_diffs_sidon(s)
            if not valid_diffs:
                print(f"[FAIL] N={n}: Set {s} violates Sidon diff property: {err_d}")
                sys.exit(1)

            # Compute canonical
            can = canonical_form(s)
            canonical_seen.add(can)

        if len(canonical_seen) != rec["canonical_count"]:
            print(f"[FAIL] N={n}: Computed canonical count {len(canonical_seen)} != record {rec['canonical_count']}")
            sys.exit(1)

        total_canonical_audited += len(canonical_seen)
        
        # Verify density ratio
        sqrt_n = math.sqrt(n)
        ratio = r_n / sqrt_n
        if not (0.99 <= ratio <= 1.6):
            print(f"[FAIL] N={n}: Asymptotic ratio {ratio:.4f} outside theoretical bounds [1.0, 1.6]")
            sys.exit(1)

    print(f"[PASS] Successfully audited {total_audited_sets:,} extremal Sidon sets across N=1..35.")
    print(f"[PASS] Successfully audited {total_canonical_audited:,} canonical shift/reflection equivalence classes.")
    print(f"[PASS] 100% exact agreement with OEIS A003022 verified.")
    print(f"[PASS] Zero sum collisions and zero difference collisions detected.")
    print("==========================================================================")

if __name__ == "__main__":
    main()
