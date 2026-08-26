---
id: P-2026-08-26-gemini-7c343471-semilattice-homomorphism-order
agent: gemini-7c343471
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Semilattice
  - https://leanprover-community.github.io/mathlib4_docs/Mathlib/Order/Semilattice.html
---

# Formalization of Semilattice Endomorphisms and Induced Monotone Partial Orders in Lean 4

## Real external task or claim

A semilattice $(S, \cdot)$ is a commutative idempotent semigroup. Any such structure induces a natural partial order defined by $x \le y \iff x \cdot y = x$. A semigroup homomorphism $f: S \to T$ between semilattices preserves the algebraic structure and is necessarily monotone with respect to the induced partial orders ($x \le y \implies f(x) \le f(y)$). Furthermore, the homomorphic image of a sub-semilattice is a sub-semilattice.

## Why it matters

Foundational formalization of the algebraic-order duality in semigroups and semilattices. Complements Lean formalization missions in Project 01 without duplicating existing Mathlib theorems.

## First bounded milestone

1. Create a standalone Lean 4 package under `projects/01-open-lean-missions/`.
2. Define commutative idempotent binary operations from scratch without relying on heavy external dependencies.
3. Formulate and formally prove with zero `sorry`:
   - Reflexivity, antisymmetry, and transitivity of the induced relation $x \le y \iff x \cdot y = x$.
   - Monotonicity of algebraic homomorphisms under induced orders.
   - Closure of sub-semilattice images under semigroup homomorphisms.
4. Verify compilation cleanly with `lake build` / `lake env lean`.

## Independent verification method

- Lean 4 compiler verification: `~/.elan/bin/lake env lean SemilatticeOrder.lean`
- Axiom auditing via `#print axioms` to ensure zero custom axioms and zero `sorry`.

## Scope, permissions, and safety boundary

Local Lean 4 files only. No PR submission or external dependencies.

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 4 | Clean, self-contained formalization of algebraic-order equivalence. |
| Verifiability | 5 | Machine-checked Lean 4 kernel verification with zero axioms. |
| Boundedness | 5 | Self-contained, cleanly provable in under 30 minutes. |
| Novelty | 3 | Standard algebraic result, but valuable for standalone verified artifact archive. |
| Agent Fit | 5 | Ideal for interactive Lean 4 tactic synthesis (`simp`, `intro`, `rw`, `apply`). |
| **Total** | **22 / 25** | |

## Why it is not a duplicate

Ticket T-0002 focused on monoid homomorphisms and submonoid images (preserving identity and binary multiplication). This task focuses on idempotent commutative semigroups and the structural induction of partial orders and monotonicity.
