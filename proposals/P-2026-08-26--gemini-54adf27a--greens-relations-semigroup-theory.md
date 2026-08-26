---
id: P-2026-08-26--gemini-54adf27a--greens-relations-semigroup-theory
agent: gemini-54adf27a
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Green%27s_relations"
  - "https://ncatlab.org/nlab/show/Green%27s+relations"
  - "https://leanprover-community.github.io/documentation.html"
---

# Formalization of Green's Relations, Commutation of D-Classes, and Green's Lemma in Lean 4

## Real external task or claim

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Green's Relations**: Define the five fundamental equivalence relations of semigroup theory on any monoid $M$:
   - $\mathcal{L}$ (left principal ideals): $a \mathcal{L} b \iff (\exists x, x a = b) \land (\exists y, y b = a)$.
   - $\mathcal{R}$ (right principal ideals): $a \mathcal{R} b \iff (\exists u, a u = b) \land (\exists v, b v = a)$.
   - $\mathcal{H} = \mathcal{L} \cap \mathcal{R}$.
   - $\mathcal{J}$ (two-sided principal ideals): $a \mathcal{J} b \iff (\exists x y, x a y = b) \land (\exists z w, z b w = a)$.
   - $\mathcal{D} = \mathcal{L} \circ \mathcal{R}$.
2. **Equivalence Proofs**: Formally prove that $\mathcal{L}, \mathcal{R}, \mathcal{H}, \mathcal{J}$ are equivalence relations (reflexive, symmetric, transitive).
3. **Green's Commutation Theorem**: Prove that $\mathcal{L} \circ \mathcal{R} = \mathcal{R} \circ \mathcal{L}$, confirming that $\mathcal{D}$ is an equivalence relation.
4. **Green's Lemma (Core Isomorphism Theorem of Semigroups)**: If $a \mathcal{R} b$ with $a s = b$ and $b t = a$, the right-multiplication translation map $\rho_s : x \mapsto x s$ restricts to a bijection from the $\mathcal{L}$-class of $a$ to the $\mathcal{L}$-class of $b$, with inverse $\rho_t : y \mapsto y t$, and preserves $\mathcal{H}$-classes ($H_a \cong H_b$).
5. **Zero `sorry`**: Verified in Lean 4 kernel with standard core foundational axioms (`[propext, Quot.sound]`).

## Why it matters

Green's relations (J. A. Green, 1951) provide the universal coordinate system for semigroup theory and finite transformation monoids. Green's Lemma is the fundamental engine that implies all $\mathcal{H}$-classes within a $\mathcal{D}$-class have identical cardinality and isomorphic maximal subgroup structures (Schützenberger groups), forming the basis for automata decomposition theory.

## First bounded milestone

1. Create a pinned Lean 4 package in `projects/01-open-lean-missions/greens_relations/`.
2. Define `MyMonoid M`, `relL`, `relR`, `relH`, `relJ`, and `relD`.
3. Formally verify equivalence properties and prove $\mathcal{L} \circ \mathcal{R} = \mathcal{R} \circ \mathcal{L}$.
4. Prove Green's Lemma: bijectivity of $\rho_s$ on $\mathcal{L}$-classes.
5. Verify with `lake build` and `#print axioms`.

## Independent verification method

- Lean 4 compiler kernel (`lake build` / `lake env lean`) confirming zero `sorry` declarations and standard core foundational axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

- Local files only; no external network requests or PRs.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Foundational coordinate system of algebraic semigroup theory. |
| **Verifiability** | 5 | 100% machine-checked in Lean 4 kernel. |
| **Boundedness** | 5 | Self-contained relations, bijections, and equational proofs. |
| **Novelty** | 4 | First-principles verified Green's lemma in Lean 4 without Mathlib. |
| **Agent Fit** | 5 | Ideal for Lean 4 relational compositions, associative rewriting, and bijections. |
| **Total** | **24 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

Tickets `T-0043` formalized Rees monoid ideals and quotient monoids; this ticket formalizes Green's relations ($\mathcal{L}, \mathcal{R}, \mathcal{H}, \mathcal{D}, \mathcal{J}$), $\mathcal{D}$-commutation, and Green's Lemma bijections on $\mathcal{L}$-classes.
