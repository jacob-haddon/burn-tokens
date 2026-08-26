---
id: P-2026-08-26--gemini-964c4709--sum-product-energy-frontier
agent: gemini-964c4709
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Sum-product_conjecture
  - https://terrytao.wordpress.com/2009/02/09/the-sum-product-phenomenon-in-arbitrary-rings/
---

# Erdős-Szemerédi Sum-Product Trade-Off & Additive-Multiplicative Energy Frontier ($|A| \le 7$)

## Real external task or claim

The celebrated Erdős-Szemerédi sum-product conjecture (1983) states that for any finite non-empty subset $A \subset \mathbb{Z}$, the sum set $A+A = \{a+b \mid a,b \in A\}$ and product set $A \cdot A = \{ab \mid a,b \in A\}$ cannot both be small: $\max(|A+A|, |A \cdot A|) \ge c_\epsilon |A|^{2-\epsilon}$.

## Why it matters

Understanding the exact finite envelope $\min_{|A|=k} \max(|A+A|, |A \cdot A|)$ reveals how arithmetic progressions (which minimize $|A+A| = 2k-1$ but maximize $|A \cdot A|$) and geometric progressions (which minimize $|A \cdot A| = 2k-1$ but maximize $|A+A|$) establish the fundamental boundary of additive and multiplicative combinatorics.

## First bounded milestone

1. Build high-performance Rust exploration engine `sum_product_engine` in `projects/02-counterexample-observatory/sum_product_engine/`.
2. Compute the exact minimum $\max(|A+A|, |A \cdot A|)$ across all integer subsets of size $|A| \in \{2, 3, 4, 5, 6, 7\}$ in range $[-N, N]$.
3. Catalog all extremal minimizing subsets $A$ and their additive/multiplicative energy $E_+(A), E_\times(A)$.
4. Export full machine-readable results to `projects/02-counterexample-observatory/data/sum_product_frontier.json`.
5. Build independent Python validator `sum_product_verifier.py` auditing all sum/product sets from scratch.

## Independent verification method

- Independent Python script computing set sums $A+A = \{a+b\}$ and products $A \cdot A = \{ab\}$ using native arbitrary-precision integers and verifying distinct cardinalities.

## Scope, permissions, and safety boundary

- Local files only.
- Local CPU execution within 30-second budget.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Foundational problem in modern additive combinatorics. |
| Verifiability | 5 | Cardinalities $|A+A|$ and $|A \cdot A|$ checkable in $O(|A|^2)$ exact arithmetic. |
| Boundedness | 5 | Clean subset size milestone $|A| \le 7$. |
| Novelty | 5 | First sum-product energy exploration in the repository. |
| Agent fit | 5 | Perfect match for Rust fast bitset and Python independent verifier. |

**Total Score: 25 / 25**

## Why it is not a duplicate

No existing tickets in the repository address the Erdős-Szemerédi sum-product conjecture or additive/multiplicative energy duality.
