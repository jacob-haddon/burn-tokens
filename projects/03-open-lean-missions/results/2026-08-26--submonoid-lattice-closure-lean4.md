# Result Note: Submonoid Lattice Structure and Closure Systems in Lean 4

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0109` / Ticket `T-0036`
- **Candidate Title**: Submonoid Lattice Structure and Closure Systems in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - Proposal [`proposals/P-2026-08-26--gemini-e9a7d723--submonoid-lattice-closure-lean4.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-e9a7d723--submonoid-lattice-closure-lean4.md)
  - Grätzer, *Universal Algebra*.
  - Howie, *Fundamentals of Semigroup Theory*.
  - Wikipedia: [Submonoid](https://en.wikipedia.org/wiki/Submonoid), [Closure operator](https://en.wikipedia.org/wiki/Closure_operator).

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (without Mathlib dependencies):
1. **Submonoid Structure**: `Submonoid M` with closure under $1$ and $\cdot$.
2. **Infimum and Meet Universal Properties**: `inf_le_left`, `inf_le_right`, and `le_inf`.
3. **Generated Submonoid & Moore Closure**: `InClosure X` and proofs that `closure X` is extensive (`subset_closure`), monotone (`closure_mono`), and idempotent (`closure_idem`).
4. **Supremum of Submonoids**: Binary `sup` and proofs `le_sup_left`, `le_sup_right`, `sup_le`.
5. **Complete Lattice Structure**: Arbitrary infima `sInf` (`sInf_le`, `le_sInf`) and arbitrary suprema `sSup` (`le_sSup`, `sSup_le`).
6. **Constructive Verification**: 0 `sorry` declarations and **0 axioms**.

---

## 3. What Was Produced

- **Lean 4 Package**: [`projects/01-open-lean-missions/submonoid_lattice/`](file:///home/ging/Work/burn-tokens/projects/01-open-lean-missions/submonoid_lattice/)
  - `SubmonoidLattice/Basic.lean`: `MyMonoid`, `Submonoid`, inclusion order `≤`, binary `inf`, `top`, inductive `InClosure`, and `closure`.
  - `SubmonoidLattice/Closure.lean`: `subset_closure`, `closure_le_submonoid`, `closure_mono`, `closure_idem`, `sup`, `le_sup_left`, `le_sup_right`, `sup_le`.
  - `SubmonoidLattice/Lattice.lean`: `sInf`, `sInf_le`, `le_sInf`, `sSup`, `le_sSup`, `sSup_le`, `bot`, `bot_le`.
  - `SubmonoidLattice/Test.lean`: Axiom reflection test harness.

---

## 4. Verification Commands and Outcome

### Commands:
```bash
export PATH="$HOME/.elan/bin:$PATH"
cd projects/01-open-lean-missions/submonoid_lattice
lake clean && lake build
lake env lean SubmonoidLattice/Test.lean
```

### Outcome Summary:
- **Build**: `Build completed successfully (6 jobs)`.
- **Axiom Audit**:
  - `inf_le_left`, `inf_le_right`, `le_inf`: **0 axioms**
  - `closure_mono`, `closure_idem`: **0 axioms**
  - `le_sup_left`, `le_sup_right`, `sup_le`: **0 axioms**
  - `sInf_le`, `le_sInf`, `le_sSup`, `sSup_le`, `bot_le`: **0 axioms**
- **Total `sorry` Declarations**: **0**.
- **Axiom Count**: **0** (Purely constructive order-theoretic proofs).

---

## 5. Confidence

`machine-checked` (Compiled and verified by Lean 4 compiler `v4.33.1` with 0 `sorry` and 0 axioms).

---

## 6. Best Next Step and Blockers

- **Next Step**: Formalize normal submonoids / congruence relations and quotient monoid universal properties.
- **Blockers**: None.
