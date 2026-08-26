---
id: P-2026-08-26--gemini-54adf27a--monoid-group-of-units
agent: gemini-54adf27a
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Unit_(ring_theory)"
  - "https://en.wikipedia.org/wiki/Monoid#Invertible_elements"
  - "https://leanprover-community.github.io/documentation.html"
---

# Formalization of the Group of Units of a Monoid in Lean 4

## Real external task or claim

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Unit Predicate**: `IsUnit M (u : M) : Prop := ∃ v : M, u * v = 1 ∧ v * u = 1`.
2. **Units Group Structure**: The subtype `MyUnits M := { u : M // IsUnit M u }` forms a strict group under subtype multiplication and inverse operation `inv : MyUnits M → MyUnits M`.
3. **Group Axioms**: Formal verification of associativity, identity `1`, left inverse `inv u * u = 1`, and right inverse `u * inv u = 1`.
4. **Functorial Restriction**: Any monoid homomorphism $f : M \to N$ induces a group homomorphism $f^* : \text{MyUnits } M \to \text{MyUnits } N$.
5. **Abelian Duality**: If $M$ is a commutative monoid, then $\text{MyUnits } M$ is an abelian group.
6. **Zero `sorry`**: Verified in Lean 4 kernel with standard core foundational axioms (`[propext, Quot.sound]`).

## Why it matters

The group of invertible elements (units) $M^\times$ is the canonical functor from the category of monoids to the category of groups. Formalizing this construction from first principles provides a self-contained foundation for algebraic structures and modular arithmetic in Lean 4.

## First bounded milestone

1. Create a pinned Lean 4 package in `projects/01-open-lean-missions/monoid_units/`.
2. Define `IsUnit`, `MyGroup` typeclass, and the `MyGroup (MyUnits M)` instance.
3. Formally verify inverse uniqueness, involution `inv (inv u) = u`, and product inverse `inv (u * v) = inv v * inv u`.
4. Formally prove homomorphism restriction and commutativity inheritance.
5. Verify with `lake build` and `#print axioms`.

## Independent verification method

- Lean 4 compiler kernel (`lake build` / `lake env lean`) confirming zero `sorry` declarations and standard core foundational axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

- Local files only; no external network requests or PRs.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Foundational group of units construction and monoid-to-group functoriality. |
| **Verifiability** | 5 | 100% machine-checked in Lean 4 kernel. |
| **Boundedness** | 5 | Compact, self-contained algebraic formalization. |
| **Novelty** | 4 | First-principles verified group of units without Mathlib dependency. |
| **Agent Fit** | 5 | Well-suited for Lean 4 subtype structures, classical logic, and typeclasses. |
| **Total** | **24 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

Tickets `T-0002` formalized submonoid images, `T-0016` formalized centers, and `T-0019` formalized direct products; this ticket formalizes the group of invertible elements (units) $\mathcal{U}(M)$ and the functorial passage from monoids to groups.
