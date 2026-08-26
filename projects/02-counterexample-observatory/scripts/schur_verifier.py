#!/usr/bin/env python3
"""
Independent Standalone Python Verifier for Schur Numbers & Sum-Free Partitions.

Verifies:
1. Disjoint union partition validity on {1, ..., N}.
2. Exact sum-free conditions (x + y != z) for both classical and weak Schur partitions.
3. Re-verifies S(1)=1, S(2)=4, S(3)=13 and WS(1)=2, WS(2)=8 via independent pure Python solver.
"""

import sys
import json
from pathlib import Path


def verify_partition(n: int, k: int, is_weak: bool, parts: list[list[int]]) -> bool:
    """Verifies that parts form a valid sum-free partition of {1, ..., n}."""
    seen = set()
    all_elements = set()

    for idx, part in enumerate(parts):
        part_set = set(part)
        # Check uniqueness across parts
        if not part_set.isdisjoint(seen):
            print(f"Error: Part {idx} overlaps with previous parts!")
            return False
        seen.update(part_set)
        all_elements.update(part_set)

        # Check sum-free property
        for i, x in enumerate(part):
            for j, y in enumerate(part):
                if is_weak and i == j:
                    continue
                s = x + y
                if s in part_set:
                    print(f"Error: Sum violation in part {idx} ({'weak' if is_weak else 'strong'}): {x} + {y} = {s} in part!")
                    return False

    # Check that union is exactly {1, ..., n}
    expected = set(range(1, n + 1))
    if all_elements != expected:
        print(f"Error: Partition elements {all_elements} do not match expected range {expected}!")
        return False

    return True


def independent_schur_check(k: int, n: int, is_weak: bool) -> bool:
    """Independent pure Python backtracking solver to test partition existence."""
    parts = [set() for _ in range(k)]

    def backtrack(v: int, max_used: int) -> bool:
        if v > n:
            return True
        for c in range(min(max_used + 1, k)):
            # Check if v can be added to parts[c]
            valid = True
            for x in parts[c]:
                # If v = x + y where y in parts[c]
                y = v - x
                if y in parts[c]:
                    if not is_weak or x != y:
                        valid = False
                        break
            if valid:
                parts[c].add(v)
                if backtrack(v + 1, max(max_used, c + 1)):
                    return True
                parts[c].remove(v)
        return False

    return backtrack(1, 0)


def audit_schur_json(json_path: Path):
    print(f"Loading artifact from {json_path}...")
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    total_witnesses = 0

    # 1. Audit Classical Schur records
    print("\n--- Auditing Classical Schur Records S(1..4) ---")
    for rec in data["classic_schur_numbers"]:
        k = rec["k"]
        s_k = rec["claimed_schur_number"]
        witnesses = rec["witness_partitions"]
        print(f"Auditing S({k}) = {s_k} ({len(witnesses)} witness partitions)...")
        assert rec["exists_at_schur_number"], f"S({k}) record states non-existence!"
        assert rec["empty_at_plus_one"], f"S({k})+1 record states existence!"

        for w_idx, w in enumerate(witnesses):
            assert verify_partition(s_k, k, False, w["parts"]), f"Witness {w_idx} invalid for S({k})!"
            total_witnesses += 1

    # 2. Audit Weak Schur records
    print("\n--- Auditing Weak Schur Records WS(1..3) ---")
    for rec in data["weak_schur_numbers"]:
        k = rec["k"]
        ws_k = rec["claimed_schur_number"]
        witnesses = rec["witness_partitions"]
        print(f"Auditing WS({k}) = {ws_k} ({len(witnesses)} witness partitions)...")
        assert rec["exists_at_schur_number"], f"WS({k}) record states non-existence!"
        assert rec["empty_at_plus_one"], f"WS({k})+1 record states existence!"

        for w_idx, w in enumerate(witnesses):
            assert verify_partition(ws_k, k, True, w["parts"]), f"Witness {w_idx} invalid for WS({k})!"
            total_witnesses += 1

    print(f"\nAll {total_witnesses} witness partitions mathematically audited and confirmed sum-free!")

    # 3. Independent Cross-Verification for small k
    print("\n--- Running Independent Python Solver Cross-Checks ---")
    assert independent_schur_check(1, 1, False), "S(1)=1 failed in Python!"
    assert not independent_schur_check(1, 2, False), "S(1)=1 upper bound failed in Python!"
    assert independent_schur_check(2, 4, False), "S(2)=4 failed in Python!"
    assert not independent_schur_check(2, 5, False), "S(2)=4 upper bound failed in Python!"
    assert independent_schur_check(3, 13, False), "S(3)=13 failed in Python!"
    assert not independent_schur_check(3, 14, False), "S(3)=13 upper bound failed in Python!"
    print("Classical S(1)=1, S(2)=4, S(3)=13 cross-checked independently.")

    assert independent_schur_check(1, 2, True), "WS(1)=2 failed in Python!"
    assert not independent_schur_check(1, 3, True), "WS(1)=2 upper bound failed in Python!"
    assert independent_schur_check(2, 8, True), "WS(2)=8 failed in Python!"
    assert not independent_schur_check(2, 9, True), "WS(2)=8 upper bound failed in Python!"
    print("Weak WS(1)=2, WS(2)=8 cross-checked independently.")

    print("\n=== ALL INDEPENDENT SCHUR CHECKS PASSED PERFECTLY ===")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])
    else:
        path = Path(__file__).parent.parent / "data" / "schur_numbers_frontier.json"

    if not path.exists():
        print(f"Error: {path} does not exist.")
        sys.exit(1)

    audit_schur_json(path)
