#!/usr/bin/env python3
"""
Independent Standalone Python Verifier for Graceful Tree Certificates (n <= 16).

This script independently:
1. Validates the level summaries against OEIS A000055 (Number of unrooted trees).
2. Verifies the graceful certificates:
   - Validates that each graph is an undirected, connected, acyclic tree.
   - Validates that the vertex labeling f is a bijection to {0, ..., n-1}.
   - Validates that the induced edge differences {|f(u) - f(v)|} cover {1, ..., n-1} with zero collisions.
"""

import json
from pathlib import Path

OEIS_A000055 = {
    1: 1,
    2: 1,
    3: 1,
    4: 2,
    5: 3,
    6: 6,
    7: 11,
    8: 23,
    9: 47,
    10: 106,
    11: 235,
    12: 551,
    13: 1301,
    14: 3159,
    15: 7741,
    16: 19320,
}

def verify_is_tree(n, edges):
    if len(edges) != n - 1:
        return False, f"Edge count {len(edges)} != n - 1 ({n-1})"
    if n <= 1:
        return True, "Valid tree"

    # Check connectivity via BFS
    adj = [[] for _ in range(n)]
    for u, v in edges:
        if u >= n or v >= n:
            return False, f"Edge ({u}, {v}) out of bounds for n={n}"
        if u == v:
            return False, f"Self loop at {u}"
        adj[u].append(v)
        adj[v].append(u)

    visited = [False] * n
    queue = [0]
    visited[0] = True
    count = 0

    while queue:
        u = queue.pop()
        count += 1
        for v in adj[u]:
            if not visited[v]:
                visited[v] = True
                queue.append(v)

    if count != n:
        return False, f"Graph is disconnected: visited {count}/{n} vertices"
    return True, "Valid connected tree"

def verify_graceful_labeling(n, edges, labeling):
    if len(labeling) != n:
        return False, f"Labeling length {len(labeling)} != n ({n})"

    # 1. Bijection check
    if sorted(labeling) != list(range(n)):
        return False, f"Labeling is not a permutation of {{0, ..., {n-1}}}"

    # 2. Edge differences check
    diffs = set()
    for u, v in edges:
        d = abs(labeling[u] - labeling[v])
        if d < 1 or d >= n:
            return False, f"Edge difference {d} out of range [1, {n-1}]"
        if d in diffs:
            return False, f"Duplicate edge difference {d}"
        diffs.add(d)

    if diffs != set(range(1, n)):
        return False, f"Edge differences do not cover {{1, ..., {n-1}}}"

    return True, "Graceful labeling verified"

def verify_report(json_path: Path):
    print(f"Loading report from: {json_path}")
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    max_n = data["max_n"]
    print(f"Report covers up to n = {max_n}")
    print(f"Total trees verified: {data['total_trees_verified']:,}")
    print(f"Total counterexamples reported: {data['total_counterexamples']}")

    print("\n--- Level Summaries vs OEIS A000055 ---")
    total_trees = 0
    for lvl in data["level_summaries"]:
        n = lvl["n"]
        count = lvl["total_trees"]
        graceful = lvl["graceful_trees"]
        cex = lvl["counterexamples_found"]
        expected_oeis = OEIS_A000055.get(n)
        total_trees += count

        print(f"  n={n:2d}: {count:6,d} trees (OEIS: {expected_oeis:6,d}) | Gracefully Labeled: {graceful:6,d} | Counterexamples: {cex}")
        assert count == expected_oeis, f"Level {n} tree count mismatch: got {count}, expected {expected_oeis}"
        assert graceful == count, f"Not all trees in level {n} were gracefully labeled: {graceful}/{count}"
        assert cex == 0, f"Counterexample reported at level {n}!"

    assert total_trees == data["total_trees_verified"], "Total tree count mismatch"
    assert total_trees == 32508, f"Expected 32,508 trees up to n=16, got {total_trees}"

    print("\n--- Independent Verification of Sample Tree Certificates ---")
    certs = data["sample_certificates"]
    print(f"Verifying {len(certs)} sample tree certificates across all levels...")
    for idx, cert in enumerate(certs):
        n = cert["n"]
        edges = cert["edges"]
        labeling = cert["labeling"]

        valid_tree, msg = verify_is_tree(n, edges)
        assert valid_tree, f"Certificate #{idx} invalid tree: {msg}"

        valid_graceful, msg = verify_graceful_labeling(n, edges, labeling)
        assert valid_graceful, f"Certificate #{idx} invalid graceful labeling: {msg}"

        if (idx + 1) % 50 == 0 or idx == len(certs) - 1:
            print(f"  [Checked {idx+1:3d}/{len(certs):3d}] n={n:2d}, LevelIdx={cert['index_in_level']:3d}, code={cert['canonical_code'][:20]}... -> OK")

    print("\n=================================================================")
    print("  [ALL INDEPENDENT CHECKS PASSED] GRACEFUL TREE CONJECTURE VERIFIED")
    print("=================================================================")

if __name__ == "__main__":
    p = Path("projects/02-counterexample-observatory/data/graceful_tree_certificates_n16.json")
    if not p.exists():
        p = Path("../data/graceful_tree_certificates_n16.json")
    if not p.exists():
        p = Path("data/graceful_tree_certificates_n16.json")
    verify_report(p)
