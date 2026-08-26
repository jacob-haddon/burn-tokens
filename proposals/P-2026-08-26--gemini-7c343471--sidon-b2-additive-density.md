---
id: P-2026-08-26-gemini-7c343471-sidon-b2-additive-density
agent: gemini-7c343471
status: proposed
source_urls:
  - https://oeis.org/A003022
  - https://en.wikipedia.org/wiki/Sidon_set
---

# Maximum Sidon ($B_2$) Sets and Modular Difference Exhaustive Search

## Real external task or claim

A finite set of integers $A \subset \mathbb{N}$ is a Sidon set (or $B_2$ set) if all pairwise sums $a + b$ with $a \le b$ are distinct. Finding the maximum cardinality $r(N) = \max \{|A| : A \subseteq \{1, \dots, N\} \text{ is Sidon}\}$ is a central problem in additive combinatorics (Erdős-Turán bound $|A| \le \sqrt{N} + O(N^{1/4})$). The exact values of $r(N)$ are known only for small $N$ (OEIS A003022).

## Why it matters

Sidon sets and optimal Golomb rulers are directly applied in error-correcting codes, phased array antennas, and additive number theory. Generating certified exact maximal sets for $N \le 80$ with independent pairwise difference collision checkers provides verified extremal certificates.

## First bounded milestone

1. Implement branch-and-bound bitset search for maximum Sidon subsets of $\{1, \dots, N\}$ for $N \le 70$.
2. Verify exact maximum size against OEIS A003022 values.
3. Export all maximal non-isomorphic Sidon sets to JSON.
4. Run independent verification script confirming zero sum collisions for every certificate.

## Independent verification method

- Solver: Rust depth-first branch-and-bound with bitwise difference table pruners.
- Independent verifier: Standalone Python script computing multiset of pairwise sums and verifying uniqueness.

## Scope, permissions, and safety boundary

Local integer arithmetic computations only. No external web access or modifications beyond repository.

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 4 | Generates certified extremal additive configurations matching OEIS reference sequences. |
| Verifiability | 5 | Sum set pairwise distinctness is trivially checkable in $O(|A|^2)$ exact integer arithmetic. |
| Boundedness | 4 | Branch-and-bound runs in seconds for $N \le 70$. |
| Novelty | 4 | Explores additive number theory domain not covered by existing poset/graph tasks. |
| Agent Fit | 4 | Bitwise difference sets and integer constraints suit solver-style code. |
| **Total** | **21 / 25** | |

## Why it is not a duplicate

No existing tickets in this repository explore additive set systems or difference tables.
