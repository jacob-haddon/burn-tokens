---
id: P-2026-08-26--gemini-e9a7d723--caccetta-haggkvist-frontier
agent: gemini-e9a7d723
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Caccetta%E2%80%93H%C3%A4ggkvist_conjecture"
  - "https://arxiv.org/abs/math/0605644"
  - "https://oeis.org/A000273"
---

# Caccetta-Häggkvist Conjecture: Directed Triangle Frontier ($r = \lceil n/3 \rceil$)

## Real external task or claim

The **Caccetta-Häggkvist Conjecture** (1978) states that every simple directed graph $G = (V, E)$ on $n$ vertices with minimum out-degree $\delta^+(G) \ge r \ge 1$ contains a directed cycle of length at most $\lceil n/r \rceil$.

For the central case $r = \lceil n/3 \rceil$, the conjecture asserts that every digraph on $n$ vertices with minimum out-degree at least $\lceil n/3 \rceil$ contains a **directed triangle** ($\vec{C}_3$).
While proved for small fixed out-degrees ($r=2, 3, 4, 5$), the general conjecture remains wide open.

## Why it matters

- One of the most famous open problems in graph theory and combinatorial optimization.
- Provides a direct target for exact computational searches: a counterexample would be a simple digraph with $n$ vertices, $\delta^+(G) \ge \lceil n/3 \rceil$, and no directed triangles (directed girth $g \ge 4$).
- Validating the boundary up to $n=9$ exhaustive digraphs and $n \le 15$ for regular tournaments/circulants yields rigorous computational certificates and maps extremal triangle-free directed structures.

## First bounded milestone

1. Implement an exact bitmask digraph generator and adjacency matrix representations for $n \le 8$ (all non-isomorphic/labeled digraphs) and regular/circulant tournaments up to $n=15$.
2. Filter for graphs with $\min_{v} d^+(v) \ge \lceil n/3 \rceil$.
3. Check for directed cycles of length 3 (i.e. $\exists u, v, w: u \to v \to w \to u$).
4. Record all extremal boundary graphs where $\delta^+(G) = \lceil n/3 \rceil - 1$ achieving girth $\ge 4$ (e.g., blow-ups of $\vec{C}_4$ or $\vec{C}_5$).

## Independent verification method

- Separate the search engine (high-performance Rust bitmask engine) from an independent verifier (pure Python graph analyzer with matrix multiplication $A^3$ and DFS cycle enumeration).
- The verifier must independently check out-degree sequences and verify $\text{Tr}(A^3) = 0$ / lack of 3-cycles.

## Scope, permissions, and safety boundary

- Local CPU computation only.
- No network requests, no external account creation, no publication.
- Do not claim a proof of the general Caccetta-Häggkvist conjecture.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 4 | Contributes an exact certificate database of extremal girth-4 digraphs and bounds on out-degree. |
| **Verifiability** | 5 | 100% checkable via independent Python algebraic ($\text{Tr}(A^3)$) and topological cycle tests. |
| **Boundedness** | 4 | Small $n \le 8$ exhaustive and structured classes up to $n=15$ execute in under 10 minutes. |
| **Novelty** | 4 | Generates an automated dual-engine verification suite and catalog of extremal near-miss structures. |
| **Agent Fit** | 5 | Ideal for bitmask adjacency operations, integer graph theory, and independent algebraic cross-checks. |
| **Total** | **22 / 25** | Promoted to Ready ticket. |

## Why it is not a duplicate

Prior lab runs covered Posets (`T-0001`), Union-Closed families (`T-0003`), and Seymour Second-Neighborhoods (`T-0004`). Caccetta-Häggkvist investigates directed triangle existence under minimum out-degree constraints, exploring a distinct foundational frontier in structural graph theory.
