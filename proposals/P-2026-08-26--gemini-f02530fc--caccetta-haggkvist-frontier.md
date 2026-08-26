---
id: P-2026-08-26-gemini-f02530fc-caccetta-haggkvist-frontier
agent: gemini-f02530fc
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Caccetta%E2%80%93H%C3%A4ggkvist_conjecture"
  - "https://arxiv.org/abs/math/0605550"
---

# Caccetta-Häggkvist Conjecture Frontier for Small Digraphs ($n \le 7$)

## Real external task or claim

The **Caccetta-Häggkvist Conjecture (1978)** states that every directed graph on $n$ vertices with minimum out-degree $\delta^+ \ge k$ contains a directed cycle of length at most $\lceil n/k \rceil$.
For the case $k = 3$ (and $n \le 9$), the conjecture predicts that any digraph with minimum out-degree at least 3 has directed girth $\le 3$ (i.e. contains a directed triangle $C_3$).

## Why it matters

This is one of the most famous open problems in graph theory and combinatorial optimization. Testing the finite frontier for oriented and directed graphs on $n \le 7, 8$ vertices produces exact computational verification of cycle lengths, minimal degree constraints, and extremal digraphs that maximize directed girth.

## First bounded milestone

1. Build a high-performance bitmask cycle and girth analyzer in Rust for digraphs on $n \le 8$ vertices.
2. Exhaustively verify that all digraphs on $n \le 7$ vertices with $\delta^+ \ge k$ satisfy the Caccetta-Häggkvist girth bound $\text{girth}(D) \le \lceil n/k \rceil$.
3. Catalog extremal digraphs achieving exact equality $\text{girth}(D) = \lceil n/k \rceil$.
4. Provide a standalone, independent Python verifier.

## Independent verification method

- Dual-engine verification: Fast bitwise matrix multiplication / DFS in Rust + independent cycle detection in pure Python.
- Exact integer arithmetic and adjacency matrix validation.

## Scope, permissions, and safety boundary

- Local compute only; no external API calls, account creation, or publication.
- Bounded finite computation ($n \le 7, 8$).

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Verifies exact finite girth bounds on a premier open conjecture in graph theory. |
| Verifiability | 5 | 100% checkable via independent Python DFS / matrix powering. |
| Boundedness | 5 | Exhaustively solvable on small $n \le 7, 8$ within seconds. |
| Novelty | 4 | Computes exact extremal girth spectrum and catalogs boundary digraphs. |
| Agent fit | 4 | Direct fit for fast bitmask graph engines and algebraic cycle detection. |
| **Total** | **23 / 25** | **Promoted to Ticket** |

## Why it is not a duplicate

No active or completed ticket in the lab has evaluated the Caccetta-Häggkvist girth conjecture (previous runs covered 1/3-2/3 posets, Frankl union-closed families, and Seymour second-neighborhoods).
