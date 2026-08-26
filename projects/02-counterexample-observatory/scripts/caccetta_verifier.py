#!/usr/bin/env python3
"""
Independent Standalone Python Verifier for Caccetta-Häggkvist Girth Frontier.

Verifies:
1. Digraph validity (simple, no self-loops, correct dimensions).
2. Out-degree calculations from raw adjacency matrix.
3. Pure Python BFS shortest directed cycle (girth) computation without third-party graph libraries.
4. Caccetta-Häggkvist inequality girth(D) <= ceil(n / delta+(D)) on all cataloged extremal digraphs.
5. Independent circulant digraph generation and verification.
"""

import sys
import json
import math
from pathlib import Path
from collections import deque


def verify_simple_digraph(n: int, matrix: list[list[int]]) -> bool:
    """Verify matrix is n x n 0/1 with zero diagonal."""
    if len(matrix) != n:
        return False
    for i in range(n):
        if len(matrix[i]) != n:
            return False
        if matrix[i][i] != 0:
            return False
        for j in range(n):
            if matrix[i][j] not in (0, 1):
                return False
    return True


def compute_out_degrees(n: int, matrix: list[list[int]]) -> list[int]:
    """Compute out-degree of each vertex."""
    return [sum(matrix[i]) for i in range(n)]


def compute_directed_girth_bfs(n: int, matrix: list[list[int]]) -> int | None:
    """
    Compute length of shortest directed cycle via independent BFS from each vertex.
    Returns None if graph is a DAG (acyclic).
    """
    min_cycle = float("inf")

    for start in range(n):
        queue = deque()
        dist = {}

        # Out-neighbors of start
        for v in range(n):
            if matrix[start][v] == 1:
                if v == start:
                    return 1  # Self loop
                dist[v] = 1
                queue.append(v)

        while queue:
            u = queue.popleft()
            d = dist[u]
            if d >= min_cycle:
                break

            # Check if there is an edge u -> start (closing a cycle of length d + 1)
            if matrix[u][start] == 1:
                min_cycle = min(min_cycle, d + 1)

            for next_v in range(n):
                if matrix[u][next_v] == 1:
                    if next_v not in dist and next_v != start:
                        dist[next_v] = d + 1
                        queue.append(next_v)

    return int(min_cycle) if min_cycle != float("inf") else None


def audit_caccetta_json(json_path: Path):
    print(f"Loading artifact from {json_path}...")
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    extremal_digraphs = data.get("extremal_digraphs", [])
    print(f"Auditing {len(extremal_digraphs)} cataloged extremal digraphs...")

    for i, rec in enumerate(extremal_digraphs):
        n = rec["n"]
        matrix = rec["adjacency_matrix"]
        expected_girth = rec["girth"]
        expected_min_deg = rec["min_out_degree"]

        # 1. Verify structure
        assert verify_simple_digraph(n, matrix), f"Digraph #{i} (n={n}) invalid simple matrix!"

        # 2. Verify degrees
        out_degs = compute_out_degrees(n, matrix)
        delta_plus = min(out_degs)
        assert delta_plus == expected_min_deg, f"Degree mismatch for #{i}: py={delta_plus}, rust={expected_min_deg}"

        # 3. Compute girth via BFS
        py_girth = compute_directed_girth_bfs(n, matrix)
        assert py_girth == expected_girth, f"Girth mismatch for #{i}: py={py_girth}, rust={expected_girth}"

        # 4. Verify Caccetta-Häggkvist condition
        if delta_plus > 0:
            ch_bound = math.ceil(n / delta_plus)
            assert py_girth <= ch_bound, f"CACCETTA-HÄGGKVIST VIOLATION: n={n}, delta+={delta_plus}, girth={py_girth} > bound={ch_bound}!"

    print(f"ALL {len(extremal_digraphs)} EXTREMAL DIGRAPHS INDEPENDENTLY AUDITED AND CONFIRMED!")

    # 5. Independent Circulant Digraph Benchmark
    print("Running independent circulant digraph verification (n=3..12)...")
    circulant_checked = 0
    for n in range(3, 13):
        # All non-empty subsets of jump lengths {1, ..., n-1}
        num_subsets = 1 << (n - 1)
        for mask in range(1, num_subsets):
            jumps = [j + 1 for j in range(n - 1) if (mask & (1 << j)) != 0]
            k = len(jumps)
            matrix = [[0] * n for _ in range(n)]
            for u in range(n):
                for jump in jumps:
                    v = (u + jump) % n
                    matrix[u][v] = 1

            girth = compute_directed_girth_bfs(n, matrix)
            assert girth is not None, f"Circulant C_{n}({jumps}) is acyclic!"
            ch_bound = math.ceil(n / k)
            assert girth <= ch_bound, f"Circulant counterexample at n={n}, jumps={jumps}, girth={girth} > {ch_bound}!"
            circulant_checked += 1

    print(f"Checked {circulant_checked} circulant digraphs across n=3..12 with 0 violations.")
    print("=== ALL INDEPENDENT CHECKS PASSED PERFECTLY ===")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])
    else:
        path = Path(__file__).parent.parent / "data" / "caccetta_haggkvist_frontier.json"

    if not path.exists():
        print(f"Error: {path} does not exist.")
        sys.exit(1)

    audit_caccetta_json(path)
