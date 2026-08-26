#!/usr/bin/env python3
"""
Independent Python Verifier for De Bruijn Universal Sequences.
Audits cyclic n-gram coverage, symbol alphabet boundaries, and exact sequence counts.
"""

import json
import math
import sys
from pathlib import Path

def compute_theoretical_count(k: int, n: int) -> int:
    """N(k, n) = (k!)^(k^(n-1)) / k^n"""
    k_fact = math.factorial(k)
    exp = k ** (n - 1)
    numerator = k_fact ** exp
    denominator = k ** n
    return numerator // denominator

def verify_cyclic_ngrams(seq: list[int], k: int, n: int) -> tuple[bool, int, int]:
    expected_len = k ** n
    if len(seq) != expected_len:
        return False, len(seq), expected_len

    # Check alphabet bounds
    for x in seq:
        if not (0 <= x < k):
            return False, 0, expected_len

    l = len(seq)
    seen = set()
    for i in range(l):
        ngram = tuple(seq[(i + j) % l] for j in range(n))
        seen.add(ngram)

    return len(seen) == expected_len, len(seen), expected_len

def generate_lyndon_words_dividing_n(k: int, n: int) -> list[int]:
    """Independent implementation of FKM algorithm in Python."""
    if n == 0:
        return []
    if k == 1:
        return [0]
    if n == 1:
        return list(range(k))

    sequence = []
    a = [0] * (n + 1)
    t = 1
    p = 1

    while True:
        if n % p == 0:
            for i in range(1, p + 1):
                sequence.append(a[i])
        for j in range(p + 1, n + 1):
            a[j] = a[j - p]
        t = n
        while t > 0 and a[t] == k - 1:
            t -= 1
        if t > 0:
            a[t] += 1
            p = t
        else:
            break

    return sequence

def main():
    print("===============================================================")
    print("  INDEPENDENT PYTHON AUDITOR: DE BRUIJN UNIVERSAL SEQUENCES")
    print("===============================================================")

    data_path = Path("projects/02-counterexample-observatory/data/debruijn_sequences_frontier.json")
    if not data_path.exists():
        print(f"[ERROR] Data file not found: {data_path}")
        sys.exit(1)

    with open(data_path, "r") as f:
        records = json.load(f)

    total_audited = 0
    failures = 0

    for rec in records:
        k = rec["k"]
        n = rec["n"]
        seq = rec["lexicographically_first_sequence"]

        # 1. Verify cyclic n-gram coverage
        valid_cov, unique_cnt, exp_cnt = verify_cyclic_ngrams(seq, k, n)
        if not valid_cov:
            print(f"[FAIL] (k={k}, n={n}): Cyclic coverage mismatch: {unique_cnt}/{exp_cnt}")
            failures += 1
            continue

        # 2. Verify independent generation matches Rust output
        py_seq = generate_lyndon_words_dividing_n(k, n)
        if py_seq != seq:
            print(f"[FAIL] (k={k}, n={n}): Independent Python sequence mismatch!")
            failures += 1
            continue

        # 3. Verify theoretical sequence count
        theo = compute_theoretical_count(k, n)
        if str(theo) != rec["theoretical_total_sequences"]:
            print(f"[FAIL] (k={k}, n={n}): Theoretical count mismatch: expected {theo}, got {rec['theoretical_total_sequences']}")
            failures += 1
            continue

        # 4. Verify Eulerian cycle count consistency
        if rec.get("exact_eulerian_cycles_counted") is not None:
            eulerian = rec["exact_eulerian_cycles_counted"]
            if eulerian != theo:
                print(f"[FAIL] (k={k}, n={n}): Eulerian cycle count {eulerian} != theoretical {theo}")
                failures += 1
                continue

        print(f"[PASS] (k={k}, n={n}): Length={len(seq)} | 100% {unique_cnt}/{exp_cnt} n-grams | N(k,n)={theo}")
        total_audited += 1

    print("---------------------------------------------------------------")
    if failures == 0:
        print(f"SUCCESS: Audited {total_audited} configurations with ZERO errors.")
        print("All de Bruijn sequences certified perfectly.")
        sys.exit(0)
    else:
        print(f"FAILURE: {failures} configurations failed audit.")
        sys.exit(1)

if __name__ == "__main__":
    main()
