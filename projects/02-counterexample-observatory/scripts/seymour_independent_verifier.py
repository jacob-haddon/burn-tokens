#!/usr/bin/env python3
"""
Independent Standalone Verifier for Seymour Second Neighborhood Conjecture (Ticket T-0004 / Card C-0203)
"""

import json
import os
import sys

def compute_second_out_neighborhood(n, adj_list, v):
    n1 = set(adj_list[v])
    n2 = set()
    for u in n1:
        for w in adj_list[u]:
            if w != v and w not in n1:
                n2.add(w)
    return n1, n2

def verify_paley_tournament(p):
    qr = set((x * x) % p for x in range(1, p))
    adj = [[] for _ in range(p)]
    for i in range(p):
        for j in range(p):
            if i != j and ((j - i + p) % p) in qr:
                adj[i].append(j)
    
    # Check degree for vertex 0
    n1, n2 = compute_second_out_neighborhood(p, adj, 0)
    d1 = len(n1)
    d2 = len(n2)
    expected_d = (p - 1) // 2
    assert d1 == expected_d, f"p={p}: d1={d1} != expected {expected_d}"
    assert d2 == expected_d, f"p={p}: d2={d2} != expected {expected_d}"
    assert d2 >= d1, f"p={p}: d2={d2} < d1={d1}"
    return d1, d2

def main():
    json_path = os.path.join(os.path.dirname(__file__), "../data/seymour_results_n7.json")
    if not os.path.exists(json_path):
        print(f"Error: Artifact not found at {json_path}")
        sys.exit(1)

    with open(json_path, "r") as f:
        data = json.load(f)

    print(f"Loaded artifact timestamped {data['timestamp']}")
    print(f"Total graphs checked by engine: {data['total_graphs_checked']:,}")
    print(f"Total counterexamples found: {data['total_counterexamples']}")

    print("\n--- 1. Pure Python Independent Verification of Paley Tournaments ---")
    primes = [3, 7, 11, 19, 23, 31, 43, 47, 59, 67, 71, 79, 83, 103, 107, 127]
    for p in primes:
        d1, d2 = verify_paley_tournament(p)
        print(f"  [PASS] Paley T_{p:<3}: d+(v)={d1:>2}, d++(v)={d2:>2} => Seymour satisfied with strict equality (|N++| == d+)")

    print("\n--- 2. Independent Check on Small Random Tournaments & Oriented Graphs ---")
    import random
    random.seed(42)
    for n in range(3, 8):
        checked = 0
        for _ in range(5000):
            # Generate random oriented graph
            adj = [[] for _ in range(n)]
            for u in range(n):
                for v in range(u + 1, n):
                    r = random.random()
                    if r < 0.333:
                        adj[u].append(v)
                    elif r < 0.666:
                        adj[v].append(u)
            
            # Check Seymour property
            has_seymour = False
            for v in range(n):
                n1, n2 = compute_second_out_neighborhood(n, adj, v)
                if len(n2) >= len(n1):
                    has_seymour = True
                    break
            assert has_seymour, f"Counterexample found at n={n}!"
            checked += 1
        print(f"  [PASS] n={n}: 5,000 independent random oriented graphs checked, 0 counterexamples.")

    print("\n===============================================================")
    print("ALL SEYMOUR INDEPENDENT PYTHON VERIFICATIONS PASSED (100% SUCCESS)")
    print("===============================================================")

if __name__ == "__main__":
    main()
