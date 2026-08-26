---
id: P-2026-08-26--gemini-e9a7d723--graceful-tree-frontier
agent: gemini-e9a7d723
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Graceful_labeling"
  - "https://www.combinatorics.org/ojs/index.php/eljc/article/view/DS6"
---

# Graceful Tree Conjecture: Exhaustive Verification for Small Trees ($n \le 16$)

## Real external task or claim

The **Graceful Tree Conjecture** (Ringel-Kotzig-Rosa, 1967) asserts that every tree $T = (V, E)$ on $n$ vertices with $n-1$ edges admits a **graceful labeling**: an injective function $f: V \to \{0, 1, \dots, n-1\}$ such that the induced edge labels $|f(u) - f(v)|$ for all $\{u, v\} \in E$ yield all integers $\{1, 2, \dots, n-1\}$ without repetition.

## Why it matters

- One of the most famous open problems in graph labeling with extensive connections to graph decompositions and coding theory.
- While known to hold for small trees, building a standardized, dual-engine certificate verifier provides machine-checked verification of graceful labelings for all non-isomorphic trees up to $n=16$.

## First bounded milestone

1. Generate all non-isomorphic trees on $n \le 16$ vertices using standard Prüfer/canonical construction.
2. Solve the graceful labeling CSP via backtracking with forward checking and symmetry breaking.
3. Emit a certificate file containing the tree adjacency list and the exact vertex labeling $f$.

## Independent verification method

- An independent 20-line Python verifier reads each tree and its emitted labeling $f$, checking:
  1. $f(v) \in \{0, \dots, n-1\}$ is a bijection on $V$.
  2. $\{|f(u) - f(v)| : (u, v) \in E\} = \{1, 2, \dots, n-1\}$.
  3. The input graph is genuinely a tree.

## Scope, permissions, and safety boundary

- Local computation only.
- No claim of proving the full conjecture for all $n$.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 4 | Generates explicit certificate database for tree decomposition benchmarks. |
| **Verifiability** | 5 | Trivial, infallible integer verification of bijection and edge differences. |
| **Boundedness** | 4 | Exhaustive for $n \le 16$ trees within minutes. |
| **Novelty** | 3 | Known result computationally, but provides reproducible certificate pipeline. |
| **Agent Fit** | 4 | Tree generation and backtracking constraint satisfaction. |
| **Total** | **20 / 25** | High-quality candidate, kept in proposals. |

## Why it is not a duplicate

No existing tickets in this repository focus on graph labeling or tree decomposition problems.
