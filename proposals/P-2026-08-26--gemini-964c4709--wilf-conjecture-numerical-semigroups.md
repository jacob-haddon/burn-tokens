---
id: P-2026-08-26--gemini-964c4709--wilf-conjecture-numerical-semigroups
agent: gemini-964c4709
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Numerical_semigroup
  - https://oeis.org/A007323
  - https://arxiv.org/abs/1703.02107
---

# Wilf's Conjecture Finite Frontier & Frobenius Invariants in Numerical Semigroups ($g(S) \le 60, e(S) \le 5$)

## Real external task or claim

Wilf's conjecture (1978) states that for any numerical semigroup $S = \langle g_1, \dots, g_e \rangle \subseteq \mathbb{N}_0$ with Frobenius number $F(S) = \max(\mathbb{Z} \setminus S)$, embedding dimension $e(S)$, and count of elements below $F(S)$ given by $n(S) = |\{s \in S \mid s < F(S)\}| + 1$, the inequality holds:
$$F(S) + 1 \le e(S) \cdot n(S)$$
Equivalently, the Wilf defect $W(S) = e(S) n(S) - (F(S) + 1) \ge 0$.

## Why it matters

Wilf's conjecture is a central open problem in combinatorial commutative algebra with deep connections to the Hilbert function of one-dimensional Gorenstein and Cohen-Macaulay local rings.

## First bounded milestone

1. Build a high-performance Rust engine `wilf_engine` in `projects/02-counterexample-observatory/wilf_engine/` implementing tree-based numerical semigroup generation (Bras-Amorós tree traversal) up to genus $g \le 60$ and embedding dimensions $e \in \{3, 4, 5\}$.
2. Verify that $W(S) \ge 0$ holds across 100% of tested semigroups with exactly **0 counterexamples**.
3. Catalog all extremal tight cases where $W(S)$ attains minimum positive values and verify that Frobenius numbers $F(S)$ match known analytical boundaries (e.g., Sylvester's formula $F(\langle a, b \rangle) = ab - a - b$).
4. Export complete dataset `projects/02-counterexample-observatory/data/wilf_semigroups_frontier.json`.
5. Build independent pure Python validator `wilf_verifier.py` auditing generator minimality, Frobenius numbers, gaps, and Wilf defect calculations.

## Independent verification method

- Standalone pure Python script computing the semigroup closure $S$, determining the Frobenius number $F = \max(\mathbb{Z}_{\ge 0} \setminus S)$, minimal generating set $e(S)$, and counting elements $n(S)$ to verify $e(S) n(S) \ge F(S) + 1$.

## Scope, permissions, and safety boundary

- Local CPU execution within 30-second budget.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Major open conjecture in combinatorial commutative algebra. |
| Verifiability | 5 | Frobenius number and semigroup membership checkable in $O(F)$ exact arithmetic. |
| Boundedness | 5 | Clean parameter milestone $g \le 60, e \le 5$. |
| Novelty | 5 | First exploration of numerical semigroups and Wilf's conjecture in the repository. |
| Agent fit | 5 | Perfect match for fast Rust branch-and-bound and Python independent verification. |

**Total Score: 25 / 25**

## Why it is not a duplicate

No existing tickets in the repository address numerical semigroups, Frobenius numbers, or Wilf's conjecture.
