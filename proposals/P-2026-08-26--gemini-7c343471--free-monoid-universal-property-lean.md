---
id: P-2026-08-26-gemini-7c343471-free-monoid-universal-property-lean
agent: gemini-7c343471
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Free_monoid
  - https://ncatlab.org/nlab/show/free+monoid
  - https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/FreeMonoid/Basic.html
---

# Free Monoid Construction, Categorical Universal Property, and Unit Isomorphism in Lean 4

## Real external task or claim

In category theory and abstract algebra, the free monoid $\mathcal{F}(X)$ on a set $X$ is the left adjoint to the forgetful functor $\mathcal{U} : \mathbf{Mon} \to \mathbf{Set}$.
The goal is to formalize from first principles in Lean 4 (without external Mathlib dependencies):
1. **Free Monoid Structure**: Represent $\mathcal{F}(X)$ via `List X` with list concatenation `++` as multiplication and `[]` as identity, proving all monoid axioms (`mul_assoc`, `one_mul`, `mul_one`).
2. **Canonical Generator Embedding**: `of : X → List X` mapping $x \mapsto [x]$.
3. **Categorical Universal Lift**: For any target monoid $M$ and set-theoretic function $f : X \to M$, the fold map `lift f : List X → M` is a valid monoid homomorphism.
4. **Commutation Triangle**: $\text{lift}(f) \circ \text{of} = f$.
5. **Categorical Uniqueness**: Any monoid homomorphism $h : \mathcal{F}(X) \to M$ satisfying $h \circ \text{of} = f$ is strictly identical to $\text{lift}(f)$ ($h = \text{lift } f$).
6. **Functoriality**: Any set map $\varphi : X \to Y$ functorially lifts to a monoid homomorphism $\mathcal{F}(\varphi) : \mathcal{F}(X) \to \mathcal{F}(Y)$.
7. **Free Monoid on Singleton**: Construct an explicit monoid isomorphism $\mathcal{F}(\text{Unit}) \cong (\mathbb{N}, +, 0)$.

## Why it matters

Foundational milestone in categorical algebra and formal logic. Establishes the universal property of word monoids and adjunction between free constructions and forgetful functors in pure Lean 4 without Mathlib overhead.

## First bounded milestone

1. Create a standalone Lean 4 package `projects/01-open-lean-missions/free_monoid/`.
2. Define `MyMonoid`, `MyMonoidHom`, and `MyMonoidIso`.
3. Construct the free monoid instance on `List \alpha`.
4. Formulate and prove `free_lift_hom`, `free_lift_of`, `free_lift_unique`, `free_map_hom`, and `free_unit_iso_nat`.
5. Compile cleanly with `lake env lean` / `lake build` with 0 `sorry` and standard foundational axioms.

## Independent verification method

- Lean 4 kernel compilation: `lake build` / `lake env lean FreeMonoid/Basic.lean`
- Axiom reflection check: `#print axioms` confirming zero `sorry` and standard axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

Local repository Lean 4 code only. No external web calls or upstream submissions.

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Universal property of free monoids is a cornerstone of categorical algebra. |
| Verifiability | 5 | 100% machine-checked by Lean 4 compiler kernel with 0 `sorry`. |
| Boundedness | 5 | Cleanly provable and compilable in $< 20$ minutes. |
| Novelty | 4 | Standalone zero-Mathlib categorical adjunction and isomorphism. |
| Agent Fit | 5 | Inductive structural recursion on lists perfectly matches Lean 4. |
| **Total** | **24 / 25** | |

## Why it is not a duplicate

T-0002 formalized submonoid forward images; T-0008 semilattice orders; T-0016 monoid centers; T-0019/T-0020 binary Cartesian products. This formalization addresses the free functor adjunction, universal property of words, and the singleton isomorphism to additive natural numbers.
