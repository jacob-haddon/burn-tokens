#!/usr/bin/env python3
"""
Independent Python Auditor for Wilf's Conjecture in Numerical Semigroups.
Audits Frobenius numbers, minimal generating sets, gap sets, and Wilf defect invariants.
"""

import json
import math
import sys
from pathlib import Path

def gcd_list(lst: list[int]) -> int:
    return math.gcd(*lst)

def verify_semigroup_record(rec: dict) -> tuple[bool, str]:
    min_gens = rec["minimal_generators"]
    reported_f = rec["frobenius"]
    reported_e = rec["embedding_dimension"]
    reported_n = rec["num_elements_below_f"]
    reported_defect = rec["wilf_defect"]

    if reported_e != len(min_gens):
        return False, f"Embedding dimension mismatch: {reported_e} != {len(min_gens)}"

    if reported_f < 0:
        # N_0 trivial case
        if reported_defect != 0 or reported_n != 1:
            return False, "N_0 trivial case mismatch"
        return True, "OK"

    # Compute Frobenius and elements using DP
    cond = reported_f + 1
    mult = min(min_gens)
    bound = cond + mult + 50

    reachable = [False] * (bound + 1)
    reachable[0] = True
    for g in min_gens:
        for i in range(g, bound + 1):
            if reachable[i - g]:
                reachable[i] = True

    # 1. Check Frobenius: reported_f is not reachable, and all items in [reported_f + 1, bound] are reachable
    if reachable[reported_f]:
        return False, f"Frobenius number {reported_f} is in semigroup!"

    for x in range(reported_f + 1, bound + 1):
        if not reachable[x]:
            return False, f"Element {x} > F({reported_f}) is not in semigroup!"

    # 2. Check minimal generators are actually minimal (none is sum of others)
    for i, g in enumerate(min_gens):
        other_gens = [x for j, x in enumerate(min_gens) if j != i]
        if other_gens:
            sub_reach = [False] * (g + 1)
            sub_reach[0] = True
            for og in other_gens:
                for idx in range(og, g + 1):
                    if sub_reach[idx - og]:
                        sub_reach[idx] = True
            if sub_reach[g]:
                return False, f"Generator {g} is redundant (spanned by other generators {other_gens})!"

    # 3. Count elements below F
    actual_n = sum(1 for x in range(reported_f + 1) if reachable[x])
    if actual_n != reported_n:
        return False, f"Elements below F mismatch: actual {actual_n} != reported {reported_n}"

    # 4. Check Wilf defect and inequality
    actual_defect = reported_e * actual_n - (reported_f + 1)
    if actual_defect != reported_defect:
        return False, f"Wilf defect mismatch: actual {actual_defect} != reported {reported_defect}"

    if actual_defect < 0:
        return False, f"WILF CONJECTURE COUNTEREXAMPLE! Defect={actual_defect}"

    return True, "OK"

def main():
    print("===============================================================")
    print("  INDEPENDENT PYTHON AUDITOR: WILF'S CONJECTURE & FROBENIUS")
    print("===============================================================")

    data_path = Path("projects/02-counterexample-observatory/data/wilf_semigroups_frontier.json")
    if not data_path.exists():
        print(f"[ERROR] Data file not found: {data_path}")
        sys.exit(1)

    with open(data_path, "r") as f:
        records = json.load(f)

    total_audited = 0
    failures = 0
    min_observed_defect = 999999
    max_observed_ratio = 0.0

    for rec in records:
        valid, msg = verify_semigroup_record(rec)
        if not valid:
            print(f"[FAIL] Gens={rec['minimal_generators']}: {msg}")
            failures += 1
            continue

        d = rec["wilf_defect"]
        r = rec["wilf_ratio"]
        if d < min_observed_defect and rec["genus"] > 0:
            min_observed_defect = d
        if r > max_observed_ratio and rec["genus"] > 0:
            max_observed_ratio = r

        total_audited += 1

    print(f"-> Verified {total_audited} representative / tightest semigroups.")
    print(f"   Min observed Wilf defect: {min_observed_defect}")
    print(f"   Max observed Wilf ratio:  {max_observed_ratio:.6f}")

    print("---------------------------------------------------------------")
    if failures == 0:
        print(f"SUCCESS: Audited {total_audited} semigroups with ZERO errors.")
        print("Wilf's inequality F(S)+1 <= e(S)*n(S) independently verified 100%.")
        sys.exit(0)
    else:
        print(f"FAILURE: {failures} semigroups failed audit.")
        sys.exit(1)

if __name__ == "__main__":
    main()
