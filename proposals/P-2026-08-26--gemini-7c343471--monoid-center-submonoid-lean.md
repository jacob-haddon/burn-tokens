---
id: P-2026-08-26-gemini-7c343471-monoid-center-submonoid-lean
agent: gemini-7c343471
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Center_(group_theory)
  - https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/Group/Submonoid/Center.html
---

# Formalization of Monoid Center Submonoid and Commutativity Duality in Lean 4

## Real external task or claim

For any monoid $(M, \cdot, 1)$, its center $Z(M) = \{ z \in M \mid \forall x \in M, z \cdot x = x \cdot z \}$ is the set of elements commuting with every element of $M$.
The mathematical theorems to formalize are:
1. $1 \in Z(M)$ (unit is central).
2. If $a, b \in Z(M)$, then $a \cdot b \in Z(M)$ (closure under multiplication).
3. $Z(M)$ is a commutative submonoid ($a \cdot b = b \cdot a$ for all $a, b \in Z(M)$).
4. $M$ is commutative if and only if $Z(M) = \top$ (the entire monoid).
5. For any surjective monoid homomorphism $f : M \to N$, $f(Z(M)) \le Z(N)$.
6. For any monoid isomorphism $f : M \cong N$, $f(Z(M)) = Z(N)$.

## Why it matters

Foundational abstract algebra formalization. Complements tickets T-0002 and T-0008 by establishing internal submonoid constructions and algebraic commutativity duality in Lean 4 without external Mathlib dependencies.

## First bounded milestone

1. Create a standalone Lean 4 package `projects/01-open-lean-missions/monoid_center/`.
2. Define `MyMonoid`, `MySubmonoid`, and the center predicate `centerPred M z : Prop := ∀ x : M, z * x = x * z`.
3. Prove that `MySubmonoid.center M` is a valid submonoid.
4. Prove that `MySubmonoid.center M` is commutative.
5. Prove that $M$ is commutative $\iff$ `center M = top M`.
6. Prove preservation under isomorphisms with zero `sorry` and 0 custom axioms.

## Independent verification method

- Lean 4 compiler kernel: `lake env lean MonoidCenter/Basic.lean`
- Axiom reflection tests: `#print axioms` confirming zero custom axioms and zero `sorry`.

## Scope, permissions, and safety boundary

Local Lean 4 code only. No external web calls or upstream submissions.

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 4 | Clean foundational algebra lemma and submonoid structure. |
| Verifiability | 5 | Machine-checked by Lean 4 kernel with 0 `sorry`. |
| Boundedness | 5 | Cleanly provable within 20 minutes. |
| Novelty | 4 | Standalone zero-dependency formalization of centralizer theory. |
| Agent Fit | 5 | Pure algebraic equational reasoning ideal for Lean tactics. |
| **Total** | **23 / 25** | |

## Why it is not a duplicate

T-0002 formalized forward images of arbitrary submonoids under homomorphisms; T-0008 formalized semilattice partial orders; T-0010 formalized modular inverse arithmetic. This task formalizes the internal algebraic construction of the monoid center and commutativity duality.
