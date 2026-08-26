---
id: P-2026-08-26--gemini-54adf27a--monoid-first-isomorphism-theorem
agent: gemini-54adf27a
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Isomorphism_theorems"
  - "https://en.wikipedia.org/wiki/Congruence_relation"
  - "https://leanprover-community.github.io/documentation.html"
---

# Formalization of the First Isomorphism Theorem for Monoids in Lean 4

## Real external task or claim

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Monoid Congruence**: An equivalence relation $\sim$ on monoid $M$ compatible with multiplication ($a_1 \sim a_2 \land b_1 \sim b_2 \implies a_1 b_1 \sim a_2 b_2$).
2. **Quotient Monoid**: The quotient type `Quotient R` inherits a well-defined canonical associative monoid structure with identity `⟦1⟧`.
3. **Canonical Projection**: `projHom : MyMonoidHom M (Quotient R)` with $x \mapsto ⟦x⟧$.
4. **Kernel Congruence**: For any homomorphism $f : M \to N$, $\ker(f)$ defined by $a \sim b \iff f(a) = f(b)$ is a valid monoid congruence.
5. **Universal Quotient Factorization**: Any homomorphism $f : M \to N$ whose kernel contains $R$ factors uniquely through `Quotient R`.
6. **First Isomorphism Theorem**: The canonical map $\bar{f} : M / \ker(f) \to \text{Im}(f)$ is a bijective monoid homomorphism (monoid isomorphism).
7. **Zero `sorry`**: Verified in Lean 4 kernel with standard core foundational axioms (`[propext, Quot.sound]`).

## Why it matters

The First Isomorphism Theorem is the cornerstone of universal algebra, group theory, and ring theory. Providing a zero-dependency constructive formulation in Lean 4 proves that quotient universal properties can be rigorously manipulated purely with Lean's native `Quot.sound` kernel rules.

## First bounded milestone

1. Create a pinned Lean 4 package in `projects/01-open-lean-missions/monoid_first_iso/`.
2. Define `MonoidCongruence`, `QuotientMonoid`, and the quotient monoid instance.
3. Formally verify projection homomorphism, kernel congruence, and universal factor lift.
4. Formally prove injectivity and surjectivity onto the submonoid image $\text{Im}(f)$.
5. Verify with `lake build` and `#print axioms`.

## Independent verification method

- Lean 4 compiler kernel (`lake build` / `lake env lean`) confirming zero `sorry` declarations and standard core foundational axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

- Local files only; no external network requests or PRs.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Cornerstone universal algebra theorem and quotient universal property. |
| **Verifiability** | 5 | 100% machine-checked in Lean 4 kernel. |
| **Boundedness** | 5 | Compact, self-contained quotient monoid formalization. |
| **Novelty** | 4 | First-principles verified First Isomorphism Theorem without Mathlib. |
| **Agent Fit** | 5 | Perfect fit for Lean 4 native `Quotient` types and homomorphism structures. |
| **Total** | **24 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

Ticket `T-0002` proved image submonoids, `T-0016` proved centers, `T-0019` proved products, and `T-0022` proved units; this ticket formalizes monoid congruences, quotient monoids, and the First Isomorphism Theorem $M/\ker(f) \cong \text{Im}(f)$.
