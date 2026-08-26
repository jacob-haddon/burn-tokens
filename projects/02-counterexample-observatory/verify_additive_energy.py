#!/usr/bin/env python3
"""
Independent Standalone Python Verifier for Additive Energy Spectrum Frontier (|A| <= 8).

Zero external dependencies.
Independently verifies:
1. Exact additive quadruples E(A) = |{(a,b,c,d) in A^4 : a+b = c+d}|.
2. Cauchy-Schwarz lower bounds: E(A) >= |A|^4 / |A+A|.
3. Extremal bounds conformance: E_min = 2k^2 - k, E_max = (2k^3 + k)/3.
"""

import json
from pathlib import Path

def compute_energy_exact(set_elements: list[int]) -> int:
    count = 0
    for a in set_elements:
        for b in set_elements:
            for c in set_elements:
                for d in set_elements:
                    if a + b == c + d:
                        count += 1
    return count

def compute_sumset_exact(set_elements: list[int]) -> int:
    sums = {a + b for a in set_elements for b in set_elements}
    return len(sums)

def verify_report(json_path: Path):
    print(f"Loading Additive Energy report from: {json_path}")
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    min_k = data["min_cardinality"]
    max_k = data["max_cardinality"]
    print(f"Report evaluated set cardinalities from |A| = {min_k} to {max_k}\n")

    for lvl in data["levels"]:
        k = lvl["k"]
        e_min_theor = lvl["theoretical_min_energy"]
        e_max_theor = lvl["theoretical_max_energy"]
        e_min_obs = lvl["min_energy_observed"]
        e_max_obs = lvl["max_energy_observed"]
        witnesses = lvl["sample_witnesses"]

        print(f"--- Cardinality |A| = {k} (E in [{e_min_theor}, {e_max_theor}]) ---")
        assert e_min_obs == e_min_theor, f"Min energy mismatch: {e_min_obs} != {e_min_theor}"
        assert e_max_obs == e_max_theor, f"Max energy mismatch: {e_max_obs} != {e_max_theor}"

        # Expected algebraic formulas
        assert e_min_theor == 2 * k * k - k
        assert e_max_theor == (2 * k * k * k + k) // 3

        print(f"  Verifying {len(witnesses)} witness sets across the energy spectrum...")
        for idx, w in enumerate(witnesses):
            s = w["set"]
            reported_e = w["energy"]
            assert len(s) == k, f"Set length {len(s)} != {k}"
            assert len(set(s)) == k, f"Set contains duplicate elements: {s}"

            # Compute exact energy from 4-loops
            exact_e = compute_energy_exact(s)
            assert exact_e == reported_e, f"Energy mismatch: exact={exact_e}, reported={reported_e} for {s}"

            # Compute exact sumset size
            exact_sumset = compute_sumset_exact(s)
            assert exact_sumset == w["sumset_size"], f"Sumset size mismatch for {s}"

            # Cauchy-Schwarz check: E(A) >= k^4 / |A+A|
            cs_bound = (k**4) / exact_sumset
            assert exact_e >= cs_bound, f"Cauchy-Schwarz violated: E={exact_e} < k^4/|A+A|={cs_bound}"

            if idx == 0 or idx == len(witnesses) - 1:
                print(f"    Witness (E={reported_e:3d}, |A+A|={exact_sumset:2d}, Type={w['set_type']}): {s}")

        print(f"  Cardinality |A| = {k} successfully verified.\n")

    print("=================================================================")
    print("  [ALL INDEPENDENT CHECKS PASSED] ADDITIVE ENERGY SPECTRUM OK    ")
    print("=================================================================")

if __name__ == "__main__":
    p = Path("projects/02-counterexample-observatory/data/additive_energy_frontier.json")
    if not p.exists():
        p = Path("../data/additive_energy_frontier.json")
    if not p.exists():
        p = Path("data/additive_energy_frontier.json")
    verify_report(p)
