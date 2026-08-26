---
id: P-2026-08-26--gemini-54adf27a--comm-monoid-coproduct-universal-property
agent: gemini-54adf27a
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Coproduct"
  - "https://en.wikipedia.org/wiki/Biproduct"
  - "https://ncatlab.org/nlab/show/coproduct"
---

# Formalization of the Coproduct Universal Property of Commutative Monoids in Lean 4

## Real external task or claim

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Canonical Inclusions**: The inclusion homomorphisms $\iota_1 : M \to M \times N$ ($m \mapsto (m, 1)$) and $\iota_2 : N \to M \times N$ ($n \mapsto (1, n)$) are valid monoid homomorphisms.
2. **Universal Copairing Map**: For any commutative monoid $P$ and homomorphisms $f : M \to P$ and $g : N \to P$, the map $[f, g] : M \times N \to P$ given by $(m, n) \mapsto f(m) \cdot g(n)$ is a valid monoid homomorphism.
3. **Triangle Commutation Identities**: Formal verification of $[f, g] \circ \iota_1 = f$ and $[f, g] \circ \iota_2 = g$.
4. **Categorical Coproduct Uniqueness**: Any monoid homomorphism $h : M \times N \to P$ satisfying $h \circ \iota_1 = f$ and $h \circ \iota_2 = g$ is strictly identical to $[f, g]$ ($h = [f, g]$).
5. **Biproduct Characterization**: Formal verification that in $\mathbf{CommMonoid}$, binary direct products and binary direct sums (coproducts) coincide on objects ($M \times N \cong M \oplus N$).
6. **Zero `sorry`**: Verified in Lean 4 kernel with standard core foundational axioms (`[propext, Quot.sound]`).

## Why it matters

The coincidence of finite products and coproducts (the biproduct property) is the defining categorical feature distinguishing commutative monoids and abelian groups from non-commutative structures. Proving this universal property from first principles in Lean 4 establishes a formal bridge to semi-additive categories.

## First bounded milestone

1. Create a pinned Lean 4 package in `projects/01-open-lean-missions/comm_monoid_coproduct/`.
2. Define `MyCommMonoid`, `inlHom`, `inrHom`, and `coprodCopair`.
3. Formally verify homomorphism laws, commutation identities, and categorical uniqueness `coprod_universal_unique`.
4. Verify with `lake build` and `#print axioms`.

## Independent verification method

- Lean 4 compiler kernel (`lake build` / `lake env lean`) confirming zero `sorry` declarations and standard core foundational axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

- Local files only; no external network requests or PRs.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Fundamental categorical biproduct property and copairing universal property. |
| **Verifiability** | 5 | 100% machine-checked in Lean 4 kernel. |
| **Boundedness** | 5 | Compact, self-contained algebraic formalization. |
| **Novelty** | 4 | First-principles verified CommMonoid coproduct without Mathlib dependency. |
| **Agent Fit** | 5 | Ideal for Lean 4 product instances, extensionality, and equational logic. |
| **Total** | **24 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

Ticket `T-0019` formalized the *product* universal property for arbitrary monoids; this ticket formalizes the *coproduct (sum)* universal property and the biproduct coincidence specific to *commutative* monoids.
