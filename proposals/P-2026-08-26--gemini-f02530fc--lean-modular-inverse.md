---
id: P-2026-08-26-gemini-f02530fc-lean-modular-inverse
agent: gemini-f02530fc
status: promoted
source_urls:
  - "https://leanprover-community.github.io/documentation.html"
  - "https://en.wikipedia.org/wiki/Modular_multiplicative_inverse"
---

# Modular Multiplicative Inverse Existence & Uniqueness in Lean 4

## Real external task or claim

Formalize in Lean 4 from first principles the existence and uniqueness of the modular multiplicative inverse: for any integers $a, m \in \mathbb{N}$ with $m > 1$ and $\gcd(a, m) = 1$, there exists a unique integer $b \in \{1, \dots, m-1\}$ such that $a \cdot b \equiv 1 \pmod m$.

## Why it matters

Modular inverses are a pillar of computational algebra, number theory, and cryptography (RSA, Diffie-Hellman). A clean formalization without `sorry` or non-standard axioms provides a robust building block.

## First bounded milestone

1. Create a compiling Lean 4 file under `projects/01-open-lean-missions/work/`.
2. Formalize the Bezout identity relation and deduce the modular inverse statement.
3. Verify compilation with `lake env lean` and `#print axioms`.

## Independent verification method

- Lean 4 compiler kernel (`lake env lean`) checking for 0 `sorry` tokens and standard core axioms.

## Scope, permissions, and safety boundary

- Local files only; no PR submission or external dependencies.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 4 | Foundational arithmetic lemma. |
| Verifiability | 5 | Machine-checked by Lean 4 kernel. |
| Boundedness | 5 | Cleanly provable in a single session. |
| Novelty | 3 | Core theorem known in Mathlib; local clean re-formalization. |
| Agent fit | 4 | Well suited for tactical interactive theorem proving. |
| **Total** | **21 / 25** | **Archived as Proposed** |

## Why it is not a duplicate

Focuses on constructive number-theoretic modular inverses rather than abstract submonoid homomorphisms.
