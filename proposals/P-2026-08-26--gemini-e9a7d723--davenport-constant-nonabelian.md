---
id: P-2026-08-26--gemini-e9a7d723--davenport-constant-nonabelian
agent: gemini-e9a7d723
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Davenport_constant"
  - "https://arxiv.org/abs/1409.8054"
---

# Davenport Constant & Minimal Zero-Sum Sequences in Small Non-Abelian Groups ($|G| \le 32$)

## Real external task or claim

For a finite group $G$ (written multiplicatively), the **Davenport constant** $D(G)$ (or large Davenport constant $\mathsf{D}(G)$) is the smallest integer $d$ such that every sequence of $d$ elements in $G$ contains a non-empty subsequence whose elements multiply to the identity $1_G$ (in some order or sequence order).

While $D(G)$ is completely understood for finite abelian groups, its exact value for general non-abelian groups (such as dicyclic groups $Dic_n$, dihedral groups $D_{2n}$, alternating groups $A_4$, and Frobenius groups) is actively researched.

## Why it matters

- Key invariant in combinatorial number theory, factorization theory in non-commutative Dedekind domains, and zero-sum theory.
- Exact bounds and explicit minimal zero-sum free sequences provide benchmark structural data.

## First bounded milestone

1. Implement Cayley table generation for all small non-abelian groups of order $|G| \le 32$ (e.g. $D_6, D_8, Q_8, A_4, D_{12}, Dic_3, D_{16}, Q_{16}, SD_{16}$).
2. Compute the exact Davenport constant $D(G)$ via branch-and-bound sequence search.
3. Output maximal zero-sum free sequences and catalog whether $D(G) = 1 + \sum (d_i - 1)$ holds or exhibits non-abelian anomalies.

## Independent verification method

- Independent Python script verifies:
  1. Group axioms and Cayley table associativity.
  2. All $2^k-1$ non-empty sub-multisets of the maximal zero-sum free sequence produce no product equal to $1_G$.
  3. Every extension by any element $g \in G$ contains a zero-sum subsequence.

## Scope, permissions, and safety boundary

- Local CPU compute only.
- Strict bounded orders $|G| \le 32$.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 4 | Yields precise non-abelian Davenport constants and zero-sum certificates. |
| **Verifiability** | 5 | Direct combinatorial check of all $2^k-1$ products against identity. |
| **Boundedness** | 4 | Search space for $|G| \le 32$ is bounded and terminates in minutes. |
| **Novelty** | 3 | Systematic cross-group audit with dual-engine verification. |
| **Agent Fit** | 4 | Cayley table algebra, submultiset permutations, bitmask branch-and-bound. |
| **Total** | **20 / 25** | High-quality candidate, kept in proposals. |

## Why it is not a duplicate

No existing tickets in this repository focus on zero-sum theory, group Davenport constants, or non-abelian factorization invariants.
