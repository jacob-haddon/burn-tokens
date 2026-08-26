---
id: P-2026-08-26-gemini-7c343471-caccetta-haggkvist-finite-audit
agent: gemini-7c343471
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Caccetta%E2%80%93H%C3%A4ggkvist_conjecture
  - https://arxiv.org/abs/math/0605556
---

# Scoped Finite Audit of Caccetta-Häggkvist Directed Girth Bounds

## Real external task or claim

The Caccetta-Häggkvist Conjecture (1978) states that every simple directed graph $G = (V, E)$ on $n$ vertices with minimum out-degree $\delta^+(G) \ge r$ contains a directed cycle of length at most $\lceil n/r \rceil$. The special case $r = \lceil n/3 \rceil$ asserts that every digraph with minimum out-degree at least $n/3$ contains a directed triangle ($\vec{C}_3$).

## Why it matters

This is one of the most celebrated open problems in extremal graph theory. While partial asymptotic bounds (e.g. out-degree $0.3465n$ via flag algebras) and small fixed $r \in \{2, 3, 4, 5\}$ are proven, verifying the exact finite frontier across all non-isomorphic digraphs up to $n = 7$ and oriented graphs up to $n = 8$ provides computational evidence and extremal witness catalogs for girth minimality.

## First bounded milestone

1. Implement an exhaustive digraph generator for small $n \le 7$ filtering for $\delta^+(G) \ge \lceil n/3 \rceil$.
2. Compute the exact directed girth (length of shortest directed cycle) using integer matrix powers $A^k$ and BFS cycle enumeration.
3. Validate that every candidate graph satisfies directed girth $\le 3$.
4. Catalog extremal configurations where directed girth achieves the maximum possible value.

## Independent verification method

Dual-engine verification:
- Primary search in Rust utilizing fast bitset adjacency matrices and matrix multiplication trace checks ($\text{Tr}(A^3) > 0$).
- Independent standalone pure Python script utilizing NetworkX-free DFS elementary cycle detection on exported JSON adjacency matrices.

## Scope, permissions, and safety boundary

Local computational search only. No external calls, account creation, or publication. Claim is strictly bounded to the exhaustively tested vertex domain ($n \le 7$ for general digraphs, $n \le 8$ for oriented graphs).

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 4 | Generates concrete extremal girth data for a major open combinatorial question. |
| Verifiability | 5 | Directed cycle existence is 100% checkable by independent integer matrix trace / DFS verifier. |
| Boundedness | 5 | $n \le 7$ exhaustive search completes in under 1 minute. |
| Novelty | 4 | Builds dedicated dual-engine auditor distinct from previous poset and tournament tasks. |
| Agent Fit | 5 | Fast bitwise adjacency representation and discrete search are ideal for agent code synthesis. |
| **Total** | **23 / 25** | |

## Why it is not a duplicate

Tickets T-0001 (posets), T-0003 (Frankl union-closed), and T-0004 (Seymour second neighborhood) audited different invariants. Seymour's conjecture checked second out-neighborhood size $|N^{++}(v)| \ge d^+(v)$, whereas this task explicitly audits the directed cycle length (girth) $\text{girth}(G) \le \lceil n / \delta^+(G) \rceil$.
