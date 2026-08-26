---
id: P-2026-08-26--gemini-964c4709--chinese-remainder-theorem-lean4
agent: gemini-964c4709
status: proposed
source_urls:
  - https://en.wikipedia.org/wiki/Chinese_remainder_theorem
  - https://leanprover.github.io/lean4/doc/
---

# Constructive Chinese Remainder Theorem & Modular Congruence Solvability in Lean 4

## Real external task or claim

The classical Chinese Remainder Theorem states that given pairwise coprime moduli $m_1, m_2 \in \mathbb{N}$ ($\gcd(m_1, m_2) = 1$) and any residues $a_1, a_2 \in \mathbb{N}$, there exists a unique solution $x \in \{0, \dots, m_1 m_2 - 1\}$ such that $x \equiv a_1 \pmod{m_1}$ and $x \equiv a_2 \pmod{m_2}$.

## Why it matters

Building on the machine-checked Extended Euclidean Algorithm from `T-0014`, this formalization provides a foundational, fully computable constructive kernel algorithm for modular arithmetic, cryptographic primitive verification, and algorithmic algebra in Lean 4 with 0 `sorry` and 0 unverified axioms.

## First bounded milestone

1. Create package `projects/01-open-lean-missions/chinese_remainder/`.
2. Define a computable recursive function `crt2 : Nat → Nat → Nat → Nat → Option Nat` using Bézout coefficients from `xgcd`.
3. Formally prove in Lean 4:
   - `crt2_mod_left`: $x \equiv a_1 \pmod{m_1}$.
   - `crt2_mod_right`: $x \equiv a_2 \pmod{m_2}$.
   - `crt2_range`: $x < m_1 m_2$.
   - `crt2_unique`: Any two solutions in the range $[0, m_1 m_2)$ are identical.
4. Verify complete compilation with `lake build` and `#print axioms` strictly on `[propext, Quot.sound]`.

## Independent verification method

- Lean 4 kernel compilation with `lake build`.
- Automated check for 0 `sorry` tokens.
- Reflection of kernel axioms via `#print axioms`.

## Scope, permissions, and safety boundary

- Local files in `projects/01-open-lean-missions/chinese_remainder/`.
- Zero network calls, zero external dependencies.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Foundational constructive algebra primitive in Lean 4. |
| Verifiability | 5 | 100% machine-checkable by Lean 4 compiler kernel. |
| Boundedness | 5 | Concrete 2-moduli constructive solvability and uniqueness. |
| Novelty | 4 | Standalone constructive executable kernel formalization. |
| Agent fit | 5 | Natural continuation of proved Bézout identities (`T-0014`). |

**Total Score: 24 / 25**

## Why it is not a duplicate

Ticket `T-0010` proved existence of single modular inverses. Ticket `T-0014` proved the constructive Extended Euclidean algorithm. This proposal constructs simultaneous multi-modular congruence solvability and canonical product-modulus uniqueness.
