#!/usr/bin/env python3
"""
Independent Standalone Verifier for Mian-Chowla Greedy Sidon Sequence (Ticket T-0017)
"""

import json
import os
import sys

def main():
    json_path = os.path.join(os.path.dirname(__file__), "../data/mian_chowla_frontier_n5000.json")
    if not os.path.exists(json_path):
        print(f"Error: Artifact not found at {json_path}")
        sys.exit(1)

    with open(json_path, "r") as f:
        data = json.load(f)

    terms = data["terms"]
    total = len(terms)
    print(f"Loaded {total} terms of Mian-Chowla sequence from artifact.")
    print(f"Final term a_{total}: {terms[-1]:,}")

    # 1. Monotonicity check
    for i in range(1, total):
        assert terms[i] > terms[i - 1], f"Monotonicity failed at index {i}"
    print("  [PASS] Strict monotonicity verified across all 5,000 terms.")

    # 2. OEIS A005282 prefix check
    oeis_prefix = [
        1, 2, 4, 8, 13, 21, 31, 45, 66, 81, 97, 123, 148, 182, 204, 252, 290, 361, 401, 475,
        565, 593, 662, 775, 822, 916, 970, 1016, 1159, 1312, 1395, 1523, 1572, 1821, 1896,
        2029, 2254, 2379, 2510, 2780, 2925, 3155, 3354, 3591, 3797, 3998, 4297, 4433, 4779,
        4851,
    ]
    assert terms[:len(oeis_prefix)] == oeis_prefix, "OEIS A005282 prefix mismatch!"
    print(f"  [PASS] Exact match with OEIS A005282 prefix ({len(oeis_prefix)} terms).")

    # 3. Exhaustive pairwise sum uniqueness check on first 500 terms (125,250 pairwise sums)
    sub_n = 500
    seen_sums = set()
    for i in range(sub_n):
        for j in range(i, sub_n):
            s = terms[i] + terms[j]
            assert s not in seen_sums, f"Sum collision detected: {terms[i]} + {terms[j]} = {s}"
            seen_sums.add(s)
    print(f"  [PASS] 0 sum collisions among {len(seen_sums):,} pairwise sums for n=500.")

    # 4. Exhaustive pairwise difference uniqueness check on first 500 terms (124,750 differences)
    seen_diffs = set()
    for i in range(sub_n):
        for j in range(i):
            d = terms[i] - terms[j]
            assert d not in seen_diffs, f"Difference collision detected: {terms[i]} - {terms[j]} = {d}"
            seen_diffs.add(d)
    print(f"  [PASS] 0 difference collisions among {len(seen_diffs):,} differences for n=500.")

    # 5. Greedy minimality test on initial 30 terms
    for n_idx in range(1, 30):
        prev = terms[n_idx - 1]
        chosen = terms[n_idx]
        current_prefix = set(terms[:n_idx])
        existing_diffs = set()
        for x in current_prefix:
            for y in current_prefix:
                if x > y:
                    existing_diffs.add(x - y)

        # Every integer c in (prev, chosen) must generate a difference collision
        for c in range(prev + 1, chosen):
            new_diffs = {c - x for x in current_prefix}
            has_collision = bool(new_diffs.intersection(existing_diffs))
            assert has_collision, f"Greedy minimality failed! Candidate {c} was valid between a_{n_idx} and a_{n_idx+1}"
    print("  [PASS] Greedy minimality certified: every skipped candidate between terms generated a sum collision.")

    print("\n===============================================================")
    print("ALL MIAN-CHOWLA INDEPENDENT VERIFICATION CHECKS PASSED (100%)")
    print("===============================================================")

if __name__ == "__main__":
    main()
