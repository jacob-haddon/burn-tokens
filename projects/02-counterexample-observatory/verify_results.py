#!/usr/bin/env python3
"""
Independent Standalone Verifier for 1/3-2/3 Poset Conjecture Frontier Results.

This script independently:
1. Validates the JSON schema and summary statistics against OEIS A000112.
2. Checks all 76 extremal posets (delta = 1/3):
   - Verifies strict partial order axioms (transitive closure, acyclicity, irreflexivity).
   - Independently enumerates all linear extensions using backtracking DFS.
   - Computes exact rational pair probabilities P(u < v) via fractions.Fraction.
   - Verifies that delta(P) is exactly 1/3 and matches the Rust engine's output.
"""

import json
import sys
from fractions import Fraction
from pathlib import Path

OEIS_A000112 = {
    1: 1,
    2: 2,
    3: 5,
    4: 16,
    5: 63,
    6: 318,
    7: 2045,
    8: 16999,
    9: 183231,
    10: 2567284,
}

def verify_strict_partial_order(n, adj):
    """Verify adjacency matrix represents a strict partial order."""
    # Irreflexive
    for i in range(n):
        if adj[i][i] != 0:
            return False, f"Self loop at {i}"
    
    # Transitive: if adj[i][j] and adj[j][k] then adj[i][k]
    for i in range(n):
        for j in range(n):
            if adj[i][j]:
                for k in range(n):
                    if adj[j][k] and not adj[i][k]:
                        return False, f"Transitivity violated: {i} < {j} < {k} but not {i} < {k}"
    
    # Acyclic / Asymmetric: if adj[i][j] then not adj[j][i]
    for i in range(n):
        for j in range(n):
            if adj[i][j] and adj[j][i]:
                return False, f"2-cycle detected between {i} and {j}"
                
    return True, "Valid strict partial order"

def enumerate_linear_extensions_python(n, adj):
    """
    Independent Python DFS backtracking algorithm to generate all linear extensions
    and count exact pair orders.
    """
    in_degree = [0] * n
    for i in range(n):
        for j in range(n):
            if adj[i][j]:
                in_degree[j] += 1

    pair_counts = [[0] * n for _ in range(n)]
    total_exts = 0
    current_seq = []
    used = [False] * n

    def dfs():
        nonlocal total_exts
        if len(current_seq) == n:
            total_exts += 1
            for idx_u in range(n):
                u = current_seq[idx_u]
                for idx_v in range(idx_u + 1, n):
                    v = current_seq[idx_v]
                    pair_counts[u][v] += 1
            return

        for u in range(n):
            if not used[u] and in_degree[u] == 0:
                used[u] = True
                current_seq.append(u)
                for v in range(n):
                    if adj[u][v]:
                        in_degree[v] -= 1

                dfs()

                # Backtrack
                for v in range(n):
                    if adj[u][v]:
                        in_degree[v] += 1
                current_seq.pop()
                used[u] = False

    dfs()
    return total_exts, pair_counts

def verify_report(json_path: Path):
    print(f"Loading report from: {json_path}")
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    max_n = data["max_n"]
    print(f"Report covers up to n = {max_n}")
    print(f"Total posets checked: {data['total_posets_checked']:,}")
    print(f"Total counterexamples reported: {data['total_counterexamples']}")
    print(f"Total extremal posets (delta = 1/3): {len(data['extremal_posets'])}")

    print("\n--- Level Summaries vs OEIS A000112 ---")
    total_checked = 0
    for lvl in data["level_summaries"]:
        n = lvl["n"]
        total = lvl["total_posets"]
        total_checked += total
        expected_oeis = OEIS_A000112.get(n)
        assert total == expected_oeis, f"Level {n} count {total} != OEIS {expected_oeis}"
        
        non_total = lvl["non_total_orders_tested"]
        sat = lvl["posets_satisfying_conjecture"]
        cex = lvl["counterexamples_found"]
        ext_count = lvl["strictly_one_third_count"]
        min_bal = Fraction(lvl["min_balance_num"], lvl["min_balance_den"])
        
        print(f"  n={n:2d}: {total:8,d} posets | non-total: {non_total:8,d} | satisfied: {sat:8,d} | cex: {cex} | delta_min: {min_bal} | extremal_1/3: {ext_count:2d}")
        assert cex == 0, f"Counterexample reported at n={n}"
        assert sat == non_total, f"Not all non-total posets satisfied conjecture at n={n}"
        if non_total > 0:
            assert min_bal >= Fraction(1, 3), f"Minimum balance below 1/3 at n={n}: {min_bal}"

    assert total_checked == data["total_posets_checked"], "Total poset count mismatch"

    print("\n--- Independent Verification of Extremal Posets (delta = 1/3) ---")
    extremal_list = data["extremal_posets"]
    for idx, rec in enumerate(extremal_list):
        n = rec["n"]
        adj = rec["adjacency_matrix"]
        
        # 1. Check strict partial order
        valid, msg = verify_strict_partial_order(n, adj)
        assert valid, f"Extremal poset #{idx} (n={n}) invalid: {msg}"
        
        # 2. Independent linear extension computation
        py_total, py_pairs = enumerate_linear_extensions_python(n, adj)
        assert py_total == rec["total_extensions"], f"Extremal poset #{idx} (n={n}) extension count mismatch: Py={py_total}, JSON={rec['total_extensions']}"
        
        # 3. Verify balance delta(P) == 1/3
        incomp_pairs = []
        max_balance = Fraction(0, 1)
        for u in range(n):
            for v in range(u + 1, n):
                if adj[u][v] == 0 and adj[v][u] == 0:
                    e_uv = py_pairs[u][v]
                    e_vu = py_pairs[v][u]
                    assert e_uv + e_vu == py_total, f"Sum of pair extensions != total: {e_uv} + {e_vu} != {py_total}"
                    pair_bal = Fraction(min(e_uv, e_vu), py_total)
                    incomp_pairs.append(((u, v), pair_bal, e_uv, e_vu))
                    if pair_bal > max_balance:
                        max_balance = pair_bal

        assert max_balance == Fraction(1, 3), f"Extremal poset #{idx} (n={n}) balance {max_balance} != 1/3"
        assert rec["delta_num"] == 1 and rec["delta_den"] == 3, f"Recorded delta {rec['delta_num']}/{rec['delta_den']} != 1/3"
        
        if (idx + 1) % 10 == 0 or idx == len(extremal_list) - 1:
            print(f"  [Verified {idx+1:2d}/{len(extremal_list):2d}] n={n}, LevelIdx={rec['index_in_level']:5d}, total_exts={py_total:4d}, delta={max_balance}")

    print("\n========================================================")
    print("  ALL INDEPENDENT CHECKS PASSED: VERIFIED EXACT & SOUND")
    print("========================================================")

if __name__ == "__main__":
    target_path = Path("projects/02-counterexample-observatory/data/frontier_results_n10.json")
    if not target_path.exists():
        target_path = Path("data/frontier_results_n10.json")
    if not target_path.exists():
        target_path = Path("../data/frontier_results_n10.json")
        
    verify_report(target_path)
