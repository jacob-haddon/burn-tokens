---
id: P-2026-08-26--gemini-964c4709--monoid-semidirect-product-lean4
agent: gemini-964c4709
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Semidirect_product#Semidirect_product_of_monoids
  - https://ncatlab.org/nlab/show/semidirect+product
  - https://leanprover-community.github.io/documentation.html
---

# Formalization of the Semidirect Product of Monoids, Action Compatibility, and Split Projections in Lean 4

## Real external task or claim

In abstract algebra and semigroup theory, given two monoids $M$ and $N$ and an action $\alpha : N \to \text{End}(M)$ (represented as an action map $\alpha : N \to M \to M$ satisfying $\alpha(n)(m_1 \cdot m_2) = \alpha(n)(m_1) \cdot \alpha(n)(m_2)$, $\alpha(n)(1) = 1$, $\alpha(n_1 \cdot n_2)(m) = \alpha(n_1)(\alpha(n_2)(m))$, and $\alpha(1)(m) = m$), the **semidirect product** $M \rtimes_\alpha N$ is the set $M \times N$ with multiplication:
$$(m_1, n_1) \cdot (m_2, n_2) = (m_1 \cdot \alpha(n_1)(m_2), n_1 \cdot n_2)$$
and identity $(1, 1)$.

## Why it matters

The semidirect product of monoids is the foundational tool for classifying split extensions, transformation monoids, wreath products, and automaton state-transition monoids (Krohn-Rhodes theory).

## First bounded milestone

1. Create standalone Lean 4 package `projects/01-open-lean-missions/monoid_semidirect/`.
2. Formulate `MonoidAction (N M : Type _)` capturing endomorphic monoid actions.
3. Define `SemidirectProduct M N \alpha` and prove `MyMonoid (SemidirectProduct M N \alpha)`.
4. Construct canonical embedding homomorphisms `inlHom : M → M ⋊ N` and `inrHom : N → M ⋊ N` and projection `projN : M ⋊ N → N`.
5. Prove the fundamental commutation intertwining identity:
   $$\text{inrHom}(n) \cdot \text{inlHom}(m) = \text{inlHom}(\alpha(n)(m)) \cdot \text{inrHom}(n)$$
6. Prove split projection retraction $\text{projN} \circ \text{inrHom} = \text{id}_N$.
7. Machine-check with 0 `sorry` declarations and standard foundational core axioms.

## Independent verification method

- Lean 4 kernel compilation with `lake build` / `lake env lean SemidirectProduct.lean`.
- Axiom reflection check `#print axioms`.

## Scope, permissions, and safety boundary

- Local Lean 4 files only. No network calls or PR submissions.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Crucial structural construction in abstract algebra and semigroup theory. |
| Verifiability | 5 | 100% machine-checked by Lean 4 compiler kernel with 0 `sorry`. |
| Boundedness | 5 | Clean parameter milestone provable in $< 15$ minutes. |
| Novelty | 5 | First formalization of monoid semidirect products in the repository. |
| Agent fit | 5 | Perfect fit for Lean 4 algebraic typeclass formalization. |

**Total Score: 25 / 25**

## Why it is not a duplicate

Existing tickets covered direct products (T-0019/T-0020), coproducts (T-0035), free monoids (T-0038), and Rees quotients (T-0043). Semidirect product addresses non-abelian action extensions.
