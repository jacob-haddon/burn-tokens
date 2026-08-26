---
id: P-2026-08-26--gemini-964c4709--harmonious-tree-frontier
agent: gemini-964c4709
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Harmonious_labeling
  - https://oeis.org/A000055
  - https://mathworld.wolfram.com/HarmoniousGraph.html
---

# Graham-Sloane Harmonious Tree Conjecture Finite Certificate Generator ($n \le 12$)

## Real external task or claim

Graham and Sloane (1980) conjectured that **every tree is harmonious**.
For a tree $T = (V, E)$ on $n$ vertices ($m = n - 1$ edges), a harmonious labeling is a function $f : V \to \mathbb{Z}_m$ such that the induced edge labels $f^*(uv) = (f(u) + f(v)) \bmod m$ are all distinct (and thus bijectively cover $\{0, 1, \dots, m-1\}$), with exactly one vertex label repeated.

## Why it matters

The Harmonious Tree Conjecture is one of the most famous open labeling conjectures in graph theory, closely tied to graceful labelings, additive combinatorics, and optical orthogonal codes.

## First bounded milestone

1. Build a high-performance Rust engine `harmonious_engine` in `projects/02-counterexample-observatory/harmonious_engine/`.
2. Generate all non-isomorphic canonical trees for orders $n \in \{3, 4, 5, 6, 7, 8, 9, 10, 11, 12\}$ (verifying counts match OEIS A000055).
3. Search for harmonious labelings using constraint satisfaction / backtrack search.
4. Verify that 100% of generated trees admit valid harmonious labelings with exactly **0 counterexamples**.
5. Export full certificate dictionary in `projects/02-counterexample-observatory/data/harmonious_trees_frontier.json`.
6. Implement independent pure Python auditor `harmonious_verifier.py`.

## Independent verification method

- Standalone pure Python script auditing tree connectivity, acyclicity, vertex label range $f(v) \in \mathbb{Z}_{n-1}$, and edge modular sum distinctness.

## Scope, permissions, and safety boundary

- Local CPU execution within 30-second budget.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Major open conjecture in graph labeling (Graham-Sloane 1980). |
| Verifiability | 5 | Modular edge sum bijection checkable in $O(n)$ exact arithmetic. |
| Boundedness | 5 | Clean parameter milestone $n \le 12$ (776 trees). |
| Novelty | 5 | First systematic certificate dataset for harmonious trees in the repository. |
| Agent fit | 5 | Fast Rust solver + Python verification. |

**Total Score: 25 / 25**

## Why it is not a duplicate

T-0009 tackled Ringel-Kotzig graceful trees ($|f(u)-f(v)|$). This ticket tackles the modular additive dual $(f(u)+f(v)) \bmod (n-1)$ by Graham and Sloane.
