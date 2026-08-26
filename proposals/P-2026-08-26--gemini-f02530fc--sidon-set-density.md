---
id: P-2026-08-26-gemini-f02530fc-sidon-set-density
agent: gemini-f02530fc
status: promoted
source_urls:
  - "https://oeis.org/A003022"
  - "https://en.wikipedia.org/wiki/Sidon_set"
---

# Sidon Set Finite Density and Maximum Cardinality Frontier ($N \le 35$)

## Real external task or claim

A subset $A \subseteq \{1, 2, \dots, N\}$ is a **Sidon set** ($B_2$ set) if all pairwise sums $a + b$ with $a \le b \in A$ are distinct. The maximum size of a Sidon subset of $[N]$ is denoted $R(N)$ (OEIS A003022).
The Erdős-Turán conjecture / bound asserts that $\sqrt{N} - O(N^{1/4}) \le R(N) \le \sqrt{N} + O(N^{1/4})$.

## Why it matters

Sidon sets are central objects in additive combinatorics, difference sets, Golomb rulers, and signal processing. Computing exact maximum cardinalities and cataloging all extremal Sidon sets up to $N=35$ produces rigorous benchmark data.

## First bounded milestone

1. Build a branch-and-bound / bitmask Sidon set analyzer in Rust.
2. Exhaustively compute $R(N)$ for $N = 1 \dots 35$, matching OEIS A003022.
3. Catalog all extremal Sidon sets achieving $R(N)$ and compute their difference graphs.
4. Independent verification with a standalone Python script.

## Independent verification method

- Independent Python verifier validating that all pairwise sums are strictly unique and confirming set sizes.

## Scope, permissions, and safety boundary

- Local compute only; no network access required.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 4 | Rigorous additive combinatorics frontier data. |
| Verifiability | 5 | 100% testable via independent pairwise sum verifier. |
| Boundedness | 5 | Computable up to $N=35$ within minutes in Rust. |
| Novelty | 4 | Complete catalog of extremal Sidon configurations. |
| Agent fit | 4 | Natural fit for branch-and-bound backtracking. |
| **Total** | **22 / 25** | **Archived as Proposed** |

## Why it is not a duplicate

First additive combinatorics / sum-free / $B_2$ investigation in this repository.
