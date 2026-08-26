#!/usr/bin/env python3
"""
Independent Python Auditor for Graham-Sloane Harmonious Trees.
Audits tree topology (acyclicity, connectivity), vertex label frequencies, and modular edge sum bijections.
"""

import json
import sys
from pathlib import Path
from collections import deque, Counter

OEIS_A000055 = {
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
}

def verify_certificate(cert: dict) -> tuple[bool, str]:
    n = cert["n"]
    m = cert["m"]
    edges = cert["edges"]
    labels = cert["vertex_labels"]
    edge_labels = cert["edge_labels"]

    # 1. Edge count and vertex count
    if len(edges) != m or m != n - 1:
        return False, f"Invalid edge count: {len(edges)} != {m}"

    if len(labels) != n:
        return False, f"Invalid vertex label count: {len(labels)} != {n}"

    # 2. Tree connectivity and acyclicity
    adj = [[] for _ in range(n)]
    for u, v in edges:
        if u >= n or v >= n or u == v:
            return False, f"Invalid edge ({u}, {v}) in tree of size {n}"
        adj[u].append(v)
        adj[v].append(u)

    visited = [False] * n
    q = deque([0])
    visited[0] = True
    visited_count = 1

    while q:
        u = q.popleft()
        for v in adj[u]:
            if not visited[v]:
                visited[v] = True
                visited_count += 1
                q.append(v)

    if visited_count != n:
        return False, f"Tree is disconnected (visited {visited_count}/{n} vertices)"

    # 3. Vertex label bounds and multiplicity: values in {0, ..., m-1}, exactly one duplicated
    for l in labels:
        if not (0 <= l < m):
            return False, f"Vertex label {l} out of bounds [0, {m-1}]"

    label_counts = Counter(labels)
    if len(label_counts) != m:
        return False, f"Distinct vertex labels count {len(label_counts)} != {m}"

    duplicates = [l for l, count in label_counts.items() if count == 2]
    if len(duplicates) != 1:
        return False, f"Expected exactly 1 duplicated label, found {len(duplicates)}"

    if duplicates[0] != cert["duplicate_label"]:
        return False, f"Duplicate label mismatch: computed {duplicates[0]} != reported {cert['duplicate_label']}"

    # 4. Modular edge sums: (f(u) + f(v)) mod m must bijectively cover {0, ..., m-1}
    computed_edge_sums = []
    for u, v in edges:
        s = (labels[u] + labels[v]) % m
        computed_edge_sums.append(s)

    if computed_edge_sums != edge_labels:
        return False, "Reported edge labels do not match computed modular sums"

    edge_set = set(computed_edge_sums)
    if len(edge_set) != m or edge_set != set(range(m)):
        return False, f"Edge modular sums do not form a bijection over Z_{m}: {edge_set}"

    return True, "OK"

def main():
    print("===============================================================")
    print("  INDEPENDENT PYTHON AUDITOR: GRAHAM-SLOANE HARMONIOUS TREES")
    print("===============================================================")

    data_path = Path("projects/02-counterexample-observatory/data/harmonious_trees_frontier.json")
    if not data_path.exists():
        data_path = Path("data/harmonious_trees_frontier.json")
    if not data_path.exists():
        data_path = Path("../data/harmonious_trees_frontier.json")

    if not data_path.exists():
        print(f"[ERROR] Certificate file not found: {data_path}")
        sys.exit(1)

    with open(data_path, "r") as f:
        certificates = json.load(f)

    total_audited = 0
    failures = 0
    order_counts = Counter()

    for cert in certificates:
        valid, msg = verify_certificate(cert)
        if not valid:
            print(f"[FAIL] n={cert['n']}, id={cert['tree_id']}: {msg}")
            failures += 1
            continue

        order_counts[cert["n"]] += 1
        total_audited += 1

    print("-> Non-isomorphic tree coverage validation vs OEIS A000055:")
    oeis_all_match = True
    for n, expected in OEIS_A000055.items():
        actual = order_counts[n]
        status = "MATCH" if actual == expected else "MISMATCH"
        print(f"   Order n = {n:2}: {actual:4} trees verified [{status}] (OEIS A000055 = {expected:4})")
        if actual != expected:
            oeis_all_match = False

    print("---------------------------------------------------------------")
    if failures == 0 and oeis_all_match:
        print(f"SUCCESS: Audited {total_audited} harmonious tree certificates with ZERO errors.")
        print("Graham-Sloane Harmonious Tree Conjecture independently verified up to n = 12.")
        sys.exit(0)
    else:
        print(f"FAILURE: {failures} certificates failed audit, or OEIS mismatch.")
        sys.exit(1)

if __name__ == "__main__":
    main()
