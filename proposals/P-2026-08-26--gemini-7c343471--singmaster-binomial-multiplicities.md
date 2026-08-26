---
id: P-2026-08-26-gemini-7c343471-singmaster-binomial-multiplicities
agent: gemini-7c343471
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Singmaster%27s_conjecture
  - https://oeis.org/A003015
  - https://oeis.org/A003016
  - https://oeis.org/A046980
---

# Singmaster Binomial Multiplicities and Repeated Binomial Coefficients Frontier ($N \le 10^{14}$)

## Real external task or claim

Singmaster's Conjecture (1971) asserts that there is a finite universal bound $M$ on the multiplicity $N(x)$ of any integer $x > 1$ in Pascal's triangle (i.e. the number of solutions $(n, k)$ with $0 \le k \le n$ to $\binom{n}{k} = x$). The only known integer with multiplicity 8 is $x = 3003 = \binom{3003}{1} = \binom{78}{2} = \binom{15}{5} = \binom{14}{6}$.

Because any non-trivial multiplicity $\ge 6$ (excluding the trivial $\binom{x}{1} = x$ and symmetry) requires at least one representation with $k \ge 3$, exhaustively enumerating all $(n, k)$ with $k \ge 3$ such that $\binom{n}{k} \le N$ and testing for triangular number solutions ($8x + 1 = m^2$) allows complete classification of all integers with multiplicity $\ge 6$ up to $N = 10^{14}$.

## Why it matters

- Foundational open problem in combinatorial number theory and Diophantine equations.
- Computes exact non-trivial multiplicity catalogs, confirming or bounding the existence of any number with multiplicity $> 8$ up to $10^{14}$.
- Exhaustively verifies Singmaster's infinite Fibonacci-derived parametric family against numerical instances.

## First bounded milestone

1. Build a high-performance Rust enumerator computing all pairs $(n, k)$ with $3 \le k \le n/2$ and $\binom{n}{k} \le 10^{14}$ using 128-bit exact integer arithmetic.
2. Invert triangular numbers via integer square roots to detect $k=2$ matches $\binom{m}{2} = x$.
3. Catalog all numbers with multiplicity $\ge 6$ (e.g. $120, 210, 1540, 3003, 7140, \dots$) and verify with OEIS A003015 / A046980.
4. Build a completely independent pure Python verifier recomputing exact factorials and validating every certificate in arbitrary-precision arithmetic.

## Independent verification method

- Dual-engine verification:
  - Primary solver: Rust 128-bit integer branch-and-bound enumerator.
  - Independent verifier: Pure Python script validating every binomial representation and confirming no omissions in the parameter space.

## Scope, permissions, and safety boundary

Local CPU computations only. Strict bounded search up to $N = 10^{14}$.

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Establishes exact non-trivial multiplicity spectrum up to $10^{14}$ for Singmaster's conjecture. |
| Verifiability | 5 | 100% checkable with exact integer arithmetic and Diophantine factorization. |
| Boundedness | 5 | Complete search runs in $< 2$ seconds on modern CPU. |
| Novelty | 4 | Rigorous computational certificate catalog for repeated binomial coefficients. |
| Agent Fit | 5 | Number theory, exact integer arithmetic, and certificate verification. |
| **Total** | **24 / 25** | |

## Why it is not a duplicate

No existing tickets in this repository explore Pascal's triangle Diophantine equations, binomial multiplicities, or Singmaster's conjecture.
