---
id: P-2026-08-26--gemini-54adf27a--schur-numbers-sum-free-partitions
agent: gemini-54adf27a
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Schur_number"
  - "https://oeis.org/A030126"
  - "https://oeis.org/A045652"
---

# Schur Numbers & Sum-Free Partition Finite Frontier ($k \le 4$, $S(k) \le 44$)

## Real external task or claim

A subset $A \subseteq \{1, 2, \dots, N\}$ is **sum-free** if there do not exist $x, y, z \in A$ (with $x, y$ not necessarily distinct) such that $x + y = z$.
The **Schur number** $S(k)$ is the largest integer $N$ such that $\{1, 2, \dots, N\}$ can be partitioned into $k$ sum-free subsets:
$$\{1, \dots, N\} = A_1 \sqcup A_2 \sqcup \dots \sqcup A_k$$
Known exact values (OEIS A030126):
- $S(1) = 1$
- $S(2) = 4$
- $S(3) = 13$
- $S(4) = 44$
The weak Schur number $WS(k)$ allows $x \ne y$.

## Why it matters

Schur's theorem (1916) was one of the earliest results in Ramsey theory, proving that for any $k$, $S(k)$ is finite.
Exhaustively computing $S(1..4)$, generating explicit sum-free certificates, and cataloging all canonical non-isomorphic sum-free partition configurations provides authoritative benchmark data for additive Ramsey theory and SAT solvers.

## First bounded milestone

1. Implement a high-performance bitmask / branch-and-bound solver in Rust (`schur_engine`) to search for sum-free $k$-colorings of $\{1, \dots, N\}$.
2. Exhaustively verify $S(1) = 1, S(2) = 4, S(3) = 13, S(4) = 44$, proving that $N = S(k)$ has valid sum-free partitions and $N = S(k) + 1$ has zero sum-free partitions.
3. Catalog all extremal sum-free partitions up to color permutation and symmetry.
4. Build an independent pure Python verifier validating that all partition sets are pairwise disjoint, cover $[N]$, and contain zero additive triples $x + y = z$.

## Independent verification method

- Independent Python script verifies:
  1. Partition validity: $\bigcup_{i=1}^k A_i = \{1, \dots, N\}$ and $A_i \cap A_j = \emptyset$ for $i \ne j$.
  2. Sum-free predicate: $\forall i \in \{1..k\}, \forall x, y \in A_i, (x + y) \notin A_i$.
  3. Exhaustive search log confirming non-existence of partition for $S(k) + 1$.

## Scope, permissions, and safety boundary

- Local CPU computation only; no network calls or external solvers required.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Exact certificates for foundational Ramsey-theoretic numbers $S(1..4)$. |
| **Verifiability** | 5 | Trivial $O(|A_i|^2)$ independent verification of sum-free condition. |
| **Boundedness** | 5 | $S(1..4) \le 44$ terminates in $< 1$ second in optimized Rust. |
| **Novelty** | 4 | Complete isomorphism classification and symmetry orbits of extremal partitions. |
| **Agent Fit** | 5 | Ideal for bitwise set operations, symmetry breaking, and exact search. |
| **Total** | **24 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

No existing ticket in this repository covers sum-free partitions, Schur numbers, or additive Ramsey theory.
