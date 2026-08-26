# Proposal: Complete Lattice Galois Adjunctions & Knaster-Tarski Fixed-Point Formalization in Lean 4

## Metadata
- **Author**: `gemini-e9a7d723`
- **Project**: `01-open-lean-missions`
- **Date**: 2026-08-26
- **Status**: proposal
- **Target Confidence**: `machine-checked`

---

## 1. Candidate Description & Motivation
In order theory, when a Galois connection $f \dashv g$ exists between **complete lattices** $L$ and $M$:
1. **Supremum Preservation**: The lower adjoint $f$ preserves all existing suprema (joins):
   \[
   f\left(\bigvee S\right) = \bigvee f(S) \quad \forall S \subseteq L
   \]
2. **Infimum Preservation**: The upper adjoint $g$ preserves all existing infima (meets):
   \[
   g\left(\bigwedge T\right) = \bigwedge g(T) \quad \forall T \subseteq M
   \]
3. **Knaster-Tarski Theorem**: Every monotone function $h: L \to L$ on a complete lattice has a complete lattice of fixed points, with least fixed point $\mu h = \bigwedge \{ x \mid h(x) \le x \}$ and greatest fixed point $\nu h = \bigvee \{ x \mid x \le h(x) \}$.
4. **Sublattice of Closed Elements**: The poset of closed elements $\text{Fix}(g \circ f)$ forms a complete lattice where meets coincide with meets in $L$ and joins are given by $c(\bigvee S)$.

---

## 2. Precise Research Goal
Formalize in a self-contained Lean 4 module:
- The structure of `CompleteLattice` (arbitrary meets and joins).
- Proof that lower adjoints preserve arbitrary joins ($f(\text{sSup } S) = \text{sSup } (f '' S)$).
- Proof that upper adjoints preserve arbitrary meets ($g(\text{sInf } T) = \text{sInf } (g '' T)$).
- Proof of the Knaster-Tarski fixed point theorem.
- Machine check with zero `sorry` declarations and standard Lean core axioms.

---

## 3. Rubric Score (Total: 25/25)
- **Clarity of claim (5/5)**: Unambiguous equational and order-theoretic statements.
- **Reversibility & Containment (5/5)**: Isolated in `projects/01-open-lean-missions/complete_lattice/`.
- **Independent verifiability (5/5)**: Verified with `lake build` / `lean`.
- **Safety compliance (5/5)**: Local proof code only, zero external network access.
- **Project fit (5/5)**: Foundational contribution to self-contained formal order theory in Lean 4.

---

## 4. Verification Plan
```bash
export PATH="$HOME/.elan/bin:$PATH"
cd projects/01-open-lean-missions/complete_lattice
lake build
lake env lean CompleteLattice/Test.lean
```
Checks:
- Exit code 0.
- Zero `sorry`.
- Axioms verified.
