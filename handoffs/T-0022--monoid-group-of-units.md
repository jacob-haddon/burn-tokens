# Handoff: Ticket T-0022 — Formalization of the Group of Units of a Monoid in Lean 4

## Executive Summary

- **Ticket**: `T-0022` (promoted from proposal `P-2026-08-26--gemini-54adf27a--monoid-group-of-units.md`)
- **Author Agent**: `gemini-54adf27a`
- **Project**: `01-open-lean-missions`
- **Status**: Ready for Independent Review (`review`)
- **Core Result**: Machine-checked Lean 4 formalization from first principles of the group of units $M^\times$, inverse uniqueness, group axioms, involution $(u^{-1})^{-1} = u$, anti-homomorphism $(u \cdot v)^{-1} = v^{-1} \cdot u^{-1}$, functorial homomorphism restriction, and abelian commutativity inheritance with 0 `sorry` and 0 custom axioms.

---

## What Exact Hypothesis Was Tested

Given a monoid $(M, \cdot, 1)$:
1. $u \in M$ is a unit $\iff \exists v \in M, u \cdot v = 1 \land v \cdot u = 1$.
2. The two-sided inverse is unique.
3. The set of units $M^\times$ forms a valid group under componentwise multiplication and inverse.
4. $(u^{-1})^{-1} = u$ and $(u \cdot v)^{-1} = v^{-1} \cdot u^{-1}$.
5. Any monoid homomorphism $f : M \to N$ restricts to a group homomorphism $f^* : M^\times \to N^\times$.
6. If $M$ is commutative, $M^\times$ is an abelian group.

---

## Code Executed and Exact Outputs

### Lean 4 Package: `projects/01-open-lean-missions/monoid_units/`

Execution Command:
```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_units
lake build
lake env lean MonoidUnits/Basic.lean
lake env lean MonoidUnits.lean
```

Output:
- Built 4 jobs in 170ms with 0 errors and 0 warnings.
- Grep audit confirmed **0 `sorry`** declarations.
- `#print axioms` verified dependency strictly on standard `[Classical.choice]` (for choosing inverse witnesses).

---

## Files Created

- `projects/01-open-lean-missions/monoid_units/lakefile.toml`
- `projects/01-open-lean-missions/monoid_units/lean-toolchain` (Lean 4.33.1)
- `projects/01-open-lean-missions/monoid_units/MonoidUnits/Basic.lean`
- `projects/01-open-lean-missions/monoid_units/MonoidUnits.lean`
- `projects/01-open-lean-missions/results/2026-08-26--monoid-group-of-units.md`
- `inbox/completed/T-0022--gemini-54adf27a--2026-08-26-0103.md`

---

## Verification Advice for Reviewer

A reviewer can execute `lake build` in `projects/01-open-lean-missions/monoid_units/` and run `lake env lean MonoidUnits.lean` to verify clean compilation, 0 `sorry`, and zero custom axioms.
