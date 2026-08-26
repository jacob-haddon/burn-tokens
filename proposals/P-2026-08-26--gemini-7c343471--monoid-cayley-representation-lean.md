---
id: P-2026-08-26-gemini-7c343471-monoid-cayley-representation-lean
agent: gemini-7c343471
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Cayley%27s_theorem
  - https://en.wikipedia.org/wiki/Transformation_monoid
  - https://ncatlab.org/nlab/show/Cayley%27s+theorem
---

# Formalization of Cayley's Embedding Theorem & Transformation Monoids in Lean 4

## Real external task or claim

In abstract algebra and category theory, Cayley's Theorem for monoids states that every monoid $(M, \cdot, 1)$ is isomorphic to a submonoid of the transformation monoid of endofunctions $\text{End}(M) = (M \to M, \circ, \text{id})$. This is the monoid-theoretic instance of the Yoneda Lemma.

The goal is to formalize from first principles in Lean 4 (without external Mathlib dependencies):
1. **Transformation Monoid Structure**: The type of endofunctions $M \to M$ equipped with function composition $\circ$ and identity $\text{id}$ forms a strict monoid `EndMonoid M`.
2. **Cayley Regular Representation**: The left-regular action map $\rho : M \to (M \to M)$ defined by $\rho(a)(x) = a \cdot x$.
3. **Homomorphism Soundness**: Prove that $\rho$ is a valid monoid homomorphism `cayleyHom : MyMonoidHom M (EndMonoid M)`:
   - Identity: $\rho(1) = \text{id}$ (via `one_mul`).
   - Multiplication: $\rho(a \cdot b) = \rho(a) \circ \rho(b)$ (via `mul_assoc`).
4. **Strict Injectivity (Faithful Action)**: Prove that $\rho(a) = \rho(b) \implies a = b$ by evaluating the function equality at the identity element $1 \in M$ ($\rho(a)(1) = a \cdot 1 = a$).
5. **Cayley Isomorphism**: Prove that $M$ is isomorphic to its image submonoid $\text{Im}(\rho) \subseteq \text{End}(M)$ (`cayleyIso : MyMonoidIso M (TransformationSubmonoid M)`).
6. **Zero `sorry`**: Standalone Lean 4 package with 0 `sorry` and standard core foundational axioms (`[propext, Quot.sound]`).

## Why it matters

Cayley's theorem is a foundational bridge between abstract algebraic systems and concrete transformation semigroups, serving as the discrete mathematical anchor of Yoneda embedding in category theory.

## First bounded milestone

1. Create package `projects/01-open-lean-missions/monoid_cayley/`.
2. Formalize `EndMonoid`, `cayleyHom`, `cayleyHom_injective`, and `cayleyIso`.
3. Verify clean compilation with `lake build` and reflection checks with 0 `sorry`.

## Independent verification method

- Lean 4 kernel compilation: `/home/ging/.elan/bin/lake build`
- Axiom reflection: `#print axioms` confirming zero custom axioms.

## Scope, permissions, and safety boundary

Local repository Lean 4 code only. No network calls or PRs.

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Cornerstone representation theorem in semigroup theory and categorical Yoneda lemma. |
| Verifiability | 5 | 100% machine-checked by Lean 4 compiler kernel with 0 `sorry`. |
| Boundedness | 5 | Clean, self-contained algebraic formalization compilable in $< 15$ min. |
| Novelty | 4 | Standalone zero-Mathlib transformation semigroup embedding and isomorphism. |
| Agent Fit | 5 | Pure algebraic equational reasoning and function extensionality in Lean 4. |
| **Total** | **24 / 25** | |

## Why it is not a duplicate

T-0002 formalized submonoid forward images; T-0016 monoid centers; T-0019/T-0020 binary Cartesian products; T-0024 free monoids; T-0027 quotient first isomorphism. This formalization proves the regular representation embedding into the full transformation semigroup.
