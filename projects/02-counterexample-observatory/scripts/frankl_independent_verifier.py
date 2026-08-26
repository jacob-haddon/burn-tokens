#!/usr/bin/env python3
import json
import os
import sys
from itertools import combinations
from typing import List, Set

def bitmask_to_set(mask: int) -> frozenset:
    s = set()
    x = 0
    while mask > 0:
        if mask & 1:
            s.add(x)
        mask >>= 1
        x += 1
    return frozenset(s)

def verify_union_closure(family_sets: List[frozenset]) -> bool:
    fam_set = set(family_sets)
    for a in family_sets:
        for b in family_sets:
            u = a | b
            if u not in fam_set:
                return False
    return True

def compute_element_degrees(m: int, family_sets: List[frozenset]) -> List[int]:
    degs = [0] * m
    for s in family_sets:
        for x in s:
            if x < m:
                degs[x] += 1
    return degs

def compute_union_closure_from_basis(m: int, basis_masks: List[int]) -> Set[frozenset]:
    basis = [bitmask_to_set(b) for b in basis_masks]
    closed = {frozenset()} # empty set
    k = len(basis)
    for r in range(1, k + 1):
        for combo in combinations(basis, r):
            u = frozenset().union(*combo)
            closed.add(u)
    return closed

def verify_extremal_record(idx: int, rec: dict) -> bool:
    m = rec["ground_set_size"]
    fam_size = rec["family_size"]
    member_masks = rec["member_sets"]
    basis_masks = rec["minimal_basis"]
    reported_degs = rec["element_degrees"]
    reported_ratio = rec["frankl_ratio"]

    # 1. Decode sets
    family_sets = [bitmask_to_set(mask) for mask in member_masks]
    if len(family_sets) != fam_size:
        print(f"[FAIL] Record {idx}: size mismatch ({len(family_sets)} vs {fam_size})")
        return False

    # 2. Check union closure
    if not verify_union_closure(family_sets):
        print(f"[FAIL] Record {idx}: family is NOT union-closed!")
        return False

    # 3. Check ground set coverage
    ground_union = set().union(*family_sets)
    if not ground_union.issubset(set(range(m))):
        print(f"[FAIL] Record {idx}: elements out of range [0, {m})")
        return False

    # 4. Check element degrees
    computed_degs = compute_element_degrees(m, family_sets)
    if computed_degs != reported_degs:
        print(f"[FAIL] Record {idx}: degree mismatch ({computed_degs} vs {reported_degs})")
        return False

    # 5. Check Frankl ratio
    max_d = max(computed_degs)
    if 2 * max_d != fam_size:
        print(f"[FAIL] Record {idx}: not extremal! max_d={max_d}, size={fam_size}, ratio={max_d/fam_size}")
        return False
    if abs(reported_ratio - 0.5) > 1e-9:
        print(f"[FAIL] Record {idx}: reported ratio != 0.5 ({reported_ratio})")
        return False

    # 6. Check minimal basis generation
    generated_closure = compute_union_closure_from_basis(m, basis_masks)
    if set(family_sets) != generated_closure:
        print(f"[FAIL] Record {idx}: basis does not generate the family!")
        return False

    return True

def verify_classical_designs():
    print("\n--- Verifying Classical Combinatorial Designs in Pure Python ---")
    
    # Fano Plane PG(2, 2)
    fano_lines = [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6},
        {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5}
    ]
    fano_closed = {frozenset()}
    for r in range(1, 8):
        for combo in combinations(fano_lines, r):
            fano_closed.add(frozenset().union(*combo))
    
    fano_degs = compute_element_degrees(7, list(fano_closed))
    fano_max_d = max(fano_degs)
    fano_ratio = fano_max_d / len(fano_closed)
    print(f"Fano Plane: size={len(fano_closed)}, max_deg={fano_max_d}, ratio={fano_ratio:.4f} (>= 0.5: {fano_ratio >= 0.5})")
    assert verify_union_closure(list(fano_closed))
    assert fano_ratio >= 0.5
    assert len(fano_closed) == 37

    # Complete bipartite K_{3, 3}
    k33_nbrs = [
        {3, 4, 5}, {3, 4, 5}, {3, 4, 5},
        {0, 1, 2}, {0, 1, 2}, {0, 1, 2}
    ]
    k33_closed = {frozenset()}
    for r in range(1, 7):
        for combo in combinations(k33_nbrs, r):
            k33_closed.add(frozenset().union(*combo))
    k33_degs = compute_element_degrees(6, list(k33_closed))
    k33_max_d = max(k33_degs)
    k33_ratio = k33_max_d / len(k33_closed)
    print(f"K_3,3 Neighborhoods: size={len(k33_closed)}, max_deg={k33_max_d}, ratio={k33_ratio:.4f} (== 0.5: {k33_ratio == 0.5})")
    assert verify_union_closure(list(k33_closed))
    assert k33_ratio == 0.5
    assert len(k33_closed) == 4

    print("Classical designs verified successfully.")

def main():
    json_path = os.path.join(os.path.dirname(__file__), "../data/frankl_frontier_m5.json")
    if not os.path.exists(json_path):
        print(f"Error: Artifact not found at {json_path}")
        sys.exit(1)

    with open(json_path, "r") as f:
        data = json.load(f)

    print(f"Loaded artifact timestamped {data['timestamp']}")
    print(f"Total closure systems checked: {data['total_closure_systems_checked']:,}")
    print(f"Total counterexamples: {data['total_counterexamples']}")

    extremals = data["non_isomorphic_extremal_families"]
    print(f"\n--- Independently Verifying {len(extremals)} Non-Isomorphic Extremal Families ---")

    passed = 0
    for idx, rec in enumerate(extremals):
        if verify_extremal_record(idx, rec):
            passed += 1
        else:
            print(f"Verification FAILED at record {idx}")
            sys.exit(1)

    print(f"[PASS] All {passed} / {len(extremals)} extremal records independently verified with exact closure, degree counts, and basis reconstruction!")

    verify_classical_designs()

    print("\n===============================================================")
    print("ALL INDEPENDENT PYTHON VERIFICATION CHECKS PASSED (100% SUCCESS)")
    print("===============================================================")

if __name__ == "__main__":
    main()
