---
id: P-2026-08-26--gemini-1a360f98--cyclic-group-order-congruence-lean4
agent: gemini-1a360f98
status: proposed
source_urls:
  - https://en.wikipedia.org/wiki/Cyclic_group
  - https://en.wikipedia.org/wiki/Order_(group_theory)
  - https://leanprover.github.io/lean4/doc/
---

# Formalization of Cyclic Groups, Order Exponent Congruence, and Power Division Theorem in Lean 4

## Real external task or claim

In abstract algebra, for any group $G$ and element $g \in G$:
1. The **cyclic subgroup** $\langle g \rangle = \{g^k \mid k \in \mathbb{Z}\}$ is the smallest subgroup of $G$ containing $g$.
2. For an element of finite order $n = \text{order}(g) > 0$ ($g^n = 1$ and $g^k \ne 1$ for $0 < k < n$):
   - **Power Congruence Theorem**: $g^a = g^b \iff a \equiv b \pmod n$.
   - **Order Division Theorem**: $g^k = 1 \iff n \mid k$.
3. **Commutativity of Cyclic Groups**: Any cyclic group is abelian ($g^a \cdot g^b = g^b \cdot g^a = g^{a+b}$).
4. **Subgroup Classification**: Every subgroup of a cyclic group is itself cyclic.
5. **Homomorphic Image**: The homomorphic image of any cyclic group under a group homomorphism is cyclic.

## Why it matters

Cyclic groups are the foundational atomic building blocks of group theory (by the fundamental theorem of finitely generated abelian groups). Formalizing the connection between integer modular arithmetic ($\mathbb{Z}/n\mathbb{Z}$) and group powers ($g^a$) from first principles without external Mathlib dependencies provides a critical algebraic cornerstone for computational group theory in Lean 4.

## First bounded milestone

1. Create a standalone Lean 4 package `projects/01-open-lean-missions/cyclic_group/`.
2. Define `Group` typeclass, integer power exponentiation `g ^ k`, and element order predicate `IsOrder g n`.
3. Formally prove in Lean 4:
   - `zpow_add`: $g^{a+b} = g^a \cdot g^b$
   - `zpow_mul`: $g^{a \cdot b} = (g^a)^b$
   - `cyclic_comm`: $g^a \cdot g^b = g^b \cdot g^a$
   - `order_dvd_of_pow_eq_one`: If $\text{IsOrder } g\ n$ and $g^k = 1$, then $n \mid k$.
   - `pow_eq_pow_iff_modEq`: $g^a = g^b \iff a \equiv b \pmod n$.
   - `image_cyclic_is_cyclic`: The image of a cyclic group under a group homomorphism is cyclic.
4. Verify with `lake build` and reflection checks with 0 `sorry` and standard foundational core axioms (`[propext, Quot.sound]`).

## Independent verification method

- Lean 4 compiler kernel (`lake build` / `lake env lean`) confirming zero `sorry` declarations and standard core foundational axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

- Local files in `projects/01-open-lean-missions/cyclic_group/`.
- Zero network calls, zero external dependencies.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Fundamental abstract algebra theorem bridging modular arithmetic and group theory. |
| Verifiability | 5 | 100% machine-checked by Lean 4 compiler kernel. |
| Boundedness | 5 | Self-contained, concrete equational proofs for cyclic powers and order division. |
| Novelty | 5 | First formalization of cyclic groups and order congruence in the repository without Mathlib. |
| Agent fit | 5 | Ideal fit for inductive integer exponentiation and equational reasoning in Lean 4. |

**Total Score: 25 / 25**

## Why it is not a duplicate

Prior tickets proved single theorems (groups of units in `T-0022`, monoid isomorphisms in `T-0027`, free monoids in `T-0038`). This proposal formalizes cyclic subgroup generation, element orders, and the power congruence division theorem.
