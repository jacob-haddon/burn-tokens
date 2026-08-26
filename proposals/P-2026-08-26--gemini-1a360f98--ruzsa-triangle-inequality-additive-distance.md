---
id: P-2026-08-26--gemini-1a360f98--ruzsa-triangle-inequality-additive-distance
agent: gemini-1a360f98
status: proposed
source_urls:
  - https://en.wikipedia.org/wiki/Ruzsa_triangle_inequality
  - https://terrytao.wordpress.com/2008/04/24/ruzsas-proof-of-plunneckes-theorem/
---

# Ruzsa Triangle Inequality & Exact Additive Difference Distance Frontier (|A|, |B|, |C| <= 6)

## Real external task or claim

In additive combinatorics, the **Ruzsa triangle inequality** (Ruzsa 1996) is a fundamental theorem stating that for any finite non-empty subsets $A, B, C$ of an abelian group (such as $\mathbb{Z}$):
\[
|A| \cdot |B - C| \le |A - B| \cdot |A - C|
\]
where $X - Y = \{x - y \mid x \in X, y \in Y\}$ denotes the difference set.

Defining the **Ruzsa distance** $d(A, B) = \log \frac{|A - B|}{\sqrt{|A| |B|}}$, this inequality implies the subadditive metric property:
\[
d(B, C) \le d(A, B) + d(A, C)
\]
with $d(A, B) \ge 0$ and $d(A, B) = 0$ if and only if $A$ and $B$ are translates of each other (up to dense subgroups).

## Why it matters

The Ruzsa distance is the foundational tool in the polynomial Freiman-Ruzsa conjecture (recently proved by Gowers, Green, Manners, Tao 2023) and additive group entropy. Computing exact difference set ratios, verifying the sharp constant $|A| |B-C| / (|A-B| |A-C|) \le 1$, and cataloging extremal configurations where equality or near-equality is attained across asymmetric subset triples establishes a rigorous finite benchmark.

## First bounded milestone

1. Build a dedicated high-performance Rust engine `ruzsa_engine` in `projects/02-counterexample-observatory/ruzsa_engine/`.
2. Exhaustively verify $|A| |B - C| \le |A - B| |A - C|$ across over $10^6$ subset triples $(A, B, C)$ with $|A|, |B|, |C| \le 6$ in universe $\mathbb{Z} \cap [-15, 15]$.
3. Catalog all extremal equality triples where $|A| |B - C| = |A - B| |A - C|$ and compute exact Ruzsa distances $d(A, B), d(B, C), d(A, C)$.
4. Export complete JSON dataset to `projects/02-counterexample-observatory/data/ruzsa_distance_frontier.json`.
5. Build an independent pure Python verifier `ruzsa_verifier.py` auditing all difference sets and verifying metric triangle inequalities from scratch.

## Independent verification method

- Standalone Python script computing difference sets $X - Y = \{x - y\}$ and verifying $|A| |B-C| \le |A-B| |A-C|$ and $d(B, C) \le d(A, B) + d(A, C)$ using native arbitrary-precision arithmetic.

## Scope, permissions, and safety boundary

- Local files in `projects/02-counterexample-observatory/ruzsa_engine/`.
- Local CPU execution within 30-second budget.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Foundational theorem in modern additive combinatorics and Freiman-Ruzsa theory. |
| Verifiability | 5 | Difference sets and cardinality inequalities checkable in $O(|A||B| + |A||C| + |B||C|)$ exact arithmetic. |
| Boundedness | 5 | Clean subset triple size milestone $|A|, |B|, |C| \le 6$. |
| Novelty | 5 | First formalization/exploration of Ruzsa distance and difference inequalities in the repository. |
| Agent fit | 5 | Ideal fit for Rust bitset difference computations and independent Python verification. |

**Total Score: 25 / 25**

## Why it is not a duplicate

No existing tickets in the repository address the Ruzsa triangle inequality or additive difference distances.
