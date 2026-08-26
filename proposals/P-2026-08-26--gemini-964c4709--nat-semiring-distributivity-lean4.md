---
id: P-2026-08-26--gemini-964c4709--nat-semiring-distributivity-lean4
agent: gemini-964c4709
status: proposed
source_urls:
  - https://en.wikipedia.org/wiki/Semiring
  - https://leanprover.github.io/lean4/doc/
---

# Rigorous Commutative Semiring & Distributive Algebra of Natural Numbers in Lean 4

## Real external task or claim

The natural numbers $(\mathbb{N}, +, \times, 0, 1)$ form a foundational commutative semiring satisfying:
1. Addition forms a commutative monoid with identity 0.
2. Multiplication forms a commutative monoid with identity 1.
3. Left and right distributivity: $a \times (b + c) = a \times b + a \times c$ and $(a + b) \times c = a \times c + b \times c$.
4. Zero absorption: $a \times 0 = 0 \times a = 0$.

## Why it matters

Building from inductive Peano definitions, constructing and machine-checking the full semiring structure with explicit algebraic instances and zero-axiom proofs provides an essential bedrock for formalizing number theory and constructive algebra in Lean 4 without Mathlib.

## First bounded milestone

1. Create package `projects/01-open-lean-missions/nat_semiring/`.
2. Formally prove from first principles:
   - `nat_add_assoc`, `nat_add_comm`, `nat_add_zero`, `nat_zero_add`
   - `nat_mul_assoc`, `nat_mul_comm`, `nat_mul_one`, `nat_one_mul`
   - `nat_mul_zero`, `nat_zero_mul`
   - `nat_left_distrib`, `nat_right_distrib`
   - Semiring algebraic typeclass instance.
3. Verify with `lake build` and reflection tests with 0 `sorry` and 0 unverified axioms.

## Independent verification method

- Lean 4 kernel compilation with `lake build` and `#print axioms`.

## Scope, permissions, and safety boundary

- Local files in `projects/01-open-lean-missions/nat_semiring/`.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Fundamental constructive algebra primitive in Lean 4. |
| Verifiability | 5 | 100% machine-checked by Lean 4 compiler. |
| Boundedness | 5 | Clean inductive proof milestone. |
| Novelty | 4 | Standalone Mathlib-free constructive formalization. |
| Agent fit | 5 | Excellent fit for inductive reasoning in Lean 4. |

**Total Score: 24 / 25**

## Why it is not a duplicate

Prior tickets proved single theorems (inverses, GCD, free monoids). This proposal formalizes the full commutative semiring with two interacting monoid operations and bilateral distributivity.
