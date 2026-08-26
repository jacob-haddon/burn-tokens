#!/usr/bin/env python3
"""
Independent Standalone Verifier for Caccetta-Häggkvist Girth Frontier (Ticket T-0006)
"""

import json
import os
import sys
from collections import deque

def compute_girth_python(n, adj_mat):
    min_cycle = float("inf")
    for start in range(n):
        dist = [-1] * n
        queue = deque()
        for v in range(n):
            if adj_mat[start][v] == 1:
                dist[v] = 1
                queue.append(v)

        while queue:
            u = queue.popleft()
            d = dist[u]
            if d >= min_cycle:
                break
            if adj_mat[u][start] == 1:
                min_cycle = min(min_cycle, d + 1)
            for w in range(n):
                if adj_mat[u][w] == 1 and dist[w] == -1 and w != start:
                    dist[w] = d + 1
                    queue.append(w)
    return min_cycle if min_cycle != float("inf") else None

def main():
    json_path = os.path.join(os.path.dirname(__file__), "../data/caccetta_haggkvist_frontier.json")
    if not os.path.exists(json_path):
        print(f"Error: Artifact not found at {json_path}")
        sys.exit(1)

    with open(json_path, "r") as f:
        data = json.load(f)

    print(f"Loaded artifact timestamped {data['timestamp']}")
    print(f"Total digraphs checked by engine: {data['total_graphs_checked']:,}")
    print(f"Total counterexamples found: {data['total_counterexamples']}")

    extremals = data["extremal_digraphs"]
    print(f"\n--- 1. Independently Verifying {len(extremals)} Extremal Digraphs in Pure Python ---")

    for idx, rec in enumerate(extremals):
        n = rec["n"]
        mat = rec["adjacency_matrix"]
        reported_min_deg = rec["min_out_degree"]
        reported_girth = rec["girth"]

        # 1. Check out degrees
        out_degs = [sum(mat[u]) for u in range(n)]
        min_deg = min(out_degs)
        assert min_deg == reported_min_deg, f"Record {idx}: min degree mismatch ({min_deg} vs {reported_min_deg})"

        # 2. Check directed girth
        computed_girth = compute_girth_python(n, mat)
        assert computed_girth == reported_girth, f"Record {idx}: girth mismatch ({computed_girth} vs {reported_girth})"

        # 3. Check Caccetta-Häggkvist condition
        ch_bound = (n + min_deg - 1) // min_deg if min_deg > 0 else n
        assert computed_girth <= ch_bound, f"Record {idx}: CEx! girth={computed_girth} > bound={ch_bound}"

    print(f"  [PASS] All {len(extremals)} extremal digraphs independently verified with exact girth computation.")

    print("\n--- 2. Independent Random Digraph Sampling ---")
    import random
    random.seed(12345)
    for n in range(3, 8):
        for k in range(1, (n + 1) // 2 + 1):
            ch_bound = (n + k - 1) // k
            checked = 0
            for _ in range(2000):
                # Generate random digraph with delta+ >= k
                mat = [[0] * n for _ in range(n)]
                for u in range(n):
                    others = [v for v in range(n) if v != u]
                    deg = random.randint(k, n - 1)
                    chosen = random.sample(others, deg)
                    for v in chosen:
                        mat[u][v] = 1

                girth = compute_girth_python(n, mat)
                assert girth is not None and girth <= ch_bound, f"CEx found for n={n}, k={k}!"
                checked += 1
            print(f"  [PASS] n={n}, k={k}: {checked} random digraphs tested, max girth observed <= {ch_bound}.")

    print("\n===============================================================")
    print("ALL CACCETTA-HÄGGKVIST INDEPENDENT VERIFICATIONS PASSED (100%)")
    print("===============================================================")

if __name__ == "__main__":
    main()
