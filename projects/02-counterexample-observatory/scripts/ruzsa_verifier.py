#!/usr/bin/env python3
"""
Independent Standalone Python Verifier for Ruzsa Triangle Inequality & Additive Distance Frontier.

This script independently audits:
1. Exact calculation of difference sets A-B, A-C, B-C using native Python sets.
2. Verification of |A|*|B-C| <= |A-B|*|A-C| with zero counterexamples.
3. Verification of Ruzsa metric distance subadditivity d(B,C) <= d(A,B) + d(A,C).
4. Independent combinatorial verification across diverse test families from scratch.
"""

import json
import math
from pathlib import Path

def diff_set(x, y):
    return set(a - b for a in x for b in y)

def ruzsa_dist(x, y):
    d = len(diff_set(x, y))
    denom = math.sqrt(len(x) * len(y))
    return math.log(d / denom)

def verify_triple(a, b, c):
    sa = sorted(list(set(a)))
    sb = sorted(list(set(b)))
    sc = sorted(list(set(c)))

    dab = diff_set(sa, sb)
    dac = diff_set(sa, sc)
    dbc = diff_set(sb, sc)

    na = len(sa)
    nb = len(sb)
    nc = len(sc)

    nab = len(dab)
    nac = len(dac)
    nbc = len(dbc)

    lhs = na * nbc
    rhs = nab * nac

    assert lhs <= rhs, f"Ruzsa triangle inequality violated! {lhs} > {rhs} for A={sa}, B={sb}, C={sc}"

    d_ab = ruzsa_dist(sa, sb)
    d_ac = ruzsa_dist(sa, sc)
    d_bc = ruzsa_dist(sb, sc)
    slack = d_ab + d_ac - d_bc

    assert slack >= -1e-9, f"Ruzsa metric distance triangle inequality violated! slack={slack} for A={sa}, B={sb}, C={sc}"

    return {
        "na": na,
        "nb": nb,
        "nc": nc,
        "lhs": lhs,
        "rhs": rhs,
        "ratio": lhs / rhs if rhs > 0 else 0.0,
        "is_equality": (lhs == rhs),
        "dist_ab": d_ab,
        "dist_ac": d_ac,
        "dist_bc": d_bc,
        "slack": slack,
    }

def main():
    print("=" * 80)
    print("  INDEPENDENT AUDIT: RUZSA TRIANGLE INEQUALITY & ADDITIVE DISTANCE")
    print("=" * 80)

    data_path = Path("projects/02-counterexample-observatory/data/ruzsa_distance_frontier.json")
    if not data_path.exists():
        data_path = Path("data/ruzsa_distance_frontier.json")
    if not data_path.exists():
        data_path = Path("../data/ruzsa_distance_frontier.json")

    assert data_path.exists(), f"Dataset not found at {data_path}"

    with open(data_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    total_tested = data["total_triples_tested"]
    c_found = data["counterexamples_found"]
    m_found = data["metric_violations_found"]
    eq_count = data["sharp_equality_count"]

    print(f"[*] Dataset: {data['title']}")
    print(f"[*] Total Triples Evaluated: {total_tested:,}")
    print(f"[*] Reported Counterexamples: {c_found}")
    print(f"[*] Reported Metric Violations: {m_found}")
    print(f"[*] Reported Sharp Equalities: {eq_count:,}")

    assert c_found == 0, "Non-zero counterexamples reported in dataset!"
    assert m_found == 0, "Non-zero metric violations reported in dataset!"

    # 1. Audit sample equality witnesses
    print("\n[*] Auditing Sample Sharp Equality Witnesses (|A||B-C| = |A-B||A-C|)...")
    for idx, w in enumerate(data.get("sample_equality_witnesses", [])):
        res = verify_triple(w["set_a"], w["set_b"], w["set_c"])
        assert res["is_equality"], f"Failed equality audit for witness #{idx+1}"
        print(f"    Witness #{idx+1}: A={w['set_a']}, B={w['set_b']}, C={w['set_c']} | LHS={res['lhs']} = RHS={res['rhs']} | ✅ PASS")

    # 2. Audit sample asymmetric triples
    print("\n[*] Auditing Sample Asymmetric Triples...")
    for idx, w in enumerate(data.get("sample_asymmetric_triples", [])):
        res = verify_triple(w["set_a"], w["set_b"], w["set_c"])
        print(f"    Asymmetric #{idx+1}: A={w['set_a']}, B={w['set_b']}, C={w['set_c']} | Ratio={res['ratio']:.4f}, Slack={res['slack']:.4f} | ✅ PASS")

    # 3. Independent scratch exploration over synthetic test families
    print("\n[*] Running independent exhaustive Python test on APs, GPs, and Sidon triples...")
    test_sets = [
        [1],
        [1, 2],
        [1, 2, 3],
        [1, 2, 3, 4],
        [1, 3, 5],
        [1, 2, 4],
        [1, 2, 4, 8],
        [0, 1, 3],
        [0, 1, 4, 6],
        [2, 3, 5, 7],
        [1, 2, 3, 6],
        [-3, 0, 3],
    ]
    py_tested = 0
    py_equalities = 0
    for a in test_sets:
        for b in test_sets:
            for c in test_sets:
                res = verify_triple(a, b, c)
                py_tested += 1
                if res["is_equality"]:
                    py_equalities += 1

    print(f"    -> Independently verified {py_tested:,} triples from scratch (0 violations, {py_equalities} equalities).")

    print("\n" + "=" * 80)
    print("  ALL RUZSA TRIANGLE INEQUALITY AUDITS PASSED CLEANLY (100% SOUND)")
    print("=" * 80)

if __name__ == "__main__":
    main()
