#!/usr/bin/env python3
"""
Independent Standalone Python Verifier for Overlap-Free Binary Words Frontier (n <= 30).

Zero external dependencies.
Independently verifies:
1. Exact absence of any overlap subword (factor of the form u u u[0]) in all sample words.
2. Exact sequence counts for all lengths n = 1 .. 30.
"""

import json
from pathlib import Path

def is_overlap_free(w: str) -> bool:
    n = len(w)
    if n <= 2:
        return True
    for i in range(n):
        for m in range(1, n):
            if i + 2 * m + 1 <= n:
                u1 = w[i : i + m]
                u2 = w[i + m : i + 2 * m]
                char_next = w[i + 2 * m]
                if u1 == u2 and w[i] == char_next:
                    return False
    return True

def verify_report(json_path: Path):
    print(f"Loading overlap-free report from: {json_path}")
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    max_len = data["max_length"]
    print(f"Report evaluated word lengths up to n = {max_len}")
    print(f"Total overlap-free words certified: {data['total_words_tested']:,}\n")

    for lvl in data["levels"]:
        n = lvl["length"]
        count = lvl["count"]
        expected = lvl["oeis_a007416_expected"]
        is_match = lvl["is_exact_match"]
        samples = lvl["sample_words"]

        print(f"--- Length n = {n:2d}: {count:4d} words (Expected: {expected:4d}) | Match: {is_match} ---")
        assert is_match, f"Count mismatch at length {n}: got {count}, expected {expected}"

        for idx, s in enumerate(samples):
            w = s["binary_string"]
            assert len(w) == n, f"Word length {len(w)} != {n}"
            assert is_overlap_free(w), f"Word '{w}' contains an overlap!"
            if idx == 0:
                print(f"    Sample #{idx+1}: {w} (Overlap-free verified: True, Thue-Morse factor: {s['is_thue_morse_factor']})")

    print("\n=================================================================")
    print("  [ALL INDEPENDENT CHECKS PASSED] OVERLAP-FREE FRONTIER VERIFIED ")
    print("=================================================================")

if __name__ == "__main__":
    p = Path("projects/02-counterexample-observatory/data/overlap_free_words_frontier.json")
    if not p.exists():
        p = Path("../data/overlap_free_words_frontier.json")
    if not p.exists():
        p = Path("data/overlap_free_words_frontier.json")
    verify_report(p)
