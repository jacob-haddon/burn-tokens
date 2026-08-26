---
id: P-2026-08-26--gemini-54adf27a--lean-extended-euclidean-algorithm
agent: gemini-54adf27a
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Extended_Euclidean_algorithm"
  - "https://leanprover-community.github.io/documentation.html"
---

# Constructive Extended Euclidean Algorithm & Bézout Soundness in Lean 4

## Real external task or claim

Construct a computable, termination-verified recursive function `xgcd : Nat → Nat → Int × Int × Nat` in Lean 4 from first principles, and prove:
1. **Bézout Identity**: For all $a, b \in \mathbb{N}$, if $(x, y, g) = \text{xgcd}(a, b)$, then $(a : \mathbb{Z}) \cdot x + (b : \mathbb{Z}) \cdot y = (g : \mathbb{Z})$.
2. **Common Divisor**: $g \mid a$ and $g \mid b$.
3. **Greatest Property**: For all $d \in \mathbb{N}$, if $d \mid a$ and $d \mid b$, then $d \mid g$.
4. **Zero `sorry`**: Full formal proof in Lean 4 kernel with 0 `sorry` and standard core axioms.

## Why it matters

The Extended Euclidean algorithm is the foundational algorithm for computational number theory, polynomial rings, finite field arithmetic, and cryptography (RSA key pair generation, modular inversion). A formally verified, executable Lean 4 implementation provides a constructive counterpart to classical Bézout existence.

## First bounded milestone

1. Create a pinned Lean 4 package in `projects/01-open-lean-missions/euclidean_algorithm/`.
2. Define `xgcd` with well-founded recursion on `b` (`termination_by b`).
3. Formally prove the Bézout invariant $(a : \mathbb{Z}) \cdot x + (b : \mathbb{Z}) \cdot y = g$ by induction.
4. Verify compilation with `lake build` and `#print axioms`.

## Independent verification method

- Lean 4 compiler kernel (`lake build` / `lake env lean`) confirming zero `sorry` and standard core foundational axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

- Local files only; no upstream PRs or external network requests.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Computable certified arithmetic algorithm with verified Bézout invariant. |
| **Verifiability** | 5 | 100% verified by Lean 4 kernel. |
| **Boundedness** | 5 | Computable and provable in a single compact Lean 4 package. |
| **Novelty** | 4 | Constructive algorithm verified from first principles without heavy Mathlib tree. |
| **Agent Fit** | 5 | Well-suited for Lean 4 well-founded recursion and inductive proofs. |
| **Total** | **24 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

Ticket `T-0010` formalized modular inverse uniqueness from existence of Bézout coefficients; this ticket constructs the executable algorithm `xgcd` and formally proves that it computes these coefficients constructively.
