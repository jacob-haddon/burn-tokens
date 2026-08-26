# Result Note: Constructive Chinese Remainder Theorem in Lean 4

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0107` / Ticket `T-0025`
- **Candidate Title**: Constructive Chinese Remainder Theorem & Modular Congruence Solvability in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Chinese Remainder Theorem on Wikipedia](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)
  - Proposal [`proposals/P-2026-08-26--gemini-964c4709--chinese-remainder-theorem-lean4.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-964c4709--chinese-remainder-theorem-lean4.md)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (without external Mathlib dependencies):
1. **Constructive CRT Combination**: Given coprime moduli $m_1, m_2 \in \mathbb{N}$ with Bézout identity $m_1 u + m_2 v = 1$, and residues $a_1, a_2 \in \mathbb{Z}$, the value $x_0 = a_1 m_2 v + a_2 m_1 u$ satisfies $x_0 \equiv a_1 \pmod{m_1}$ and $x_0 \equiv a_2 \pmod{m_2}$.
2. **Product Modulus Divisibility**: If $m_1 \mid (x - y)$ and $m_2 \mid (x - y)$ with Bézout identity $m_1 u + m_2 v = 1$, then $m_1 m_2 \mid (x - y)$.
3. **Canonical Uniqueness**: Any two solutions $x, y \in [0, m_1 m_2)$ satisfying the simultaneous congruences are strictly identical ($x = y$).
4. **Constructive Computable Solver**: Fuel-bounded algorithm `crtSolve` executing and verified via compile-time reflection (`rfl`).
5. Zero `sorry` declarations and standard core Lean 4 foundational axioms (`[propext, Quot.sound]`).

---

## 3. What Was Produced

1. **Lean 4 Package** (`projects/01-open-lean-missions/chinese_remainder/`):
   - `ChineseRemainder/Basic.lean`: Complete formal theory and proofs.
   - `ChineseRemainder.lean`: Axiom reflection test suite.
2. **Formally Proved Theorems**:
   - `crtRaw_mod_left`: Formal proof that $x_0 \equiv a_1 \pmod{m_1}$.
   - `crtRaw_mod_right`: Formal proof that $x_0 \equiv a_2 \pmod{m_2}$.
   - `simultaneous_modEq_product`: Proof that simultaneous divisibility implies product modulus divisibility.
   - `crt_unique`: Strict canonical uniqueness in the bounded domain $[0, m_1 m_2)$.
   - `crt_test_3_5`, `crt_test_7_11`, `crt_test_2_3`, `crt_test_5_7`: Machine-checked executable test cases evaluated via `rfl` with 0 axioms.

---

## 4. Verification Commands and Outcome

### Commands

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd projects/01-open-lean-missions/chinese_remainder
lake build
lake env lean ChineseRemainder.lean
```

### Outcome Summary

- Lean 4 compiler exited with code **0**.
- Zero `sorry` declarations.
- `#print axioms` confirmed standard foundational axioms:
  - `crtRaw_mod_left`, `crtRaw_mod_right`, `simultaneous_modEq_product`, `crt_unique`: `[propext, Quot.sound]`
  - `crt_test_3_5`, `crt_test_7_11`: **0 axioms** (`rfl`)

---

## 5. Confidence

**`machine-checked`** (Compiled with Lean 4.33.1 kernel, 0 `sorry`, 0 custom axioms).

---

## 6. Best Next Step & Blockers

- **Next Step**: Generalize to arbitrary list of $k$ pairwise coprime moduli $\prod_{i=1}^k m_i$ via induction.
- **Blockers**: None.
