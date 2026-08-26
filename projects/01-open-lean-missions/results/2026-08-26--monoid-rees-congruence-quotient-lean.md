# Result Note: Formalization of Monoid Ideals, Rees Congruences, and Rees Quotient Monoids in Lean 4 (Ticket T-0043)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0109` (Ticket `T-0043`)
- **Candidate Title**: Formalization of Monoid Ideals, Rees Congruences, and Rees Quotient Monoids in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Rees Factor Semigroup (Wikipedia)](https://en.wikipedia.org/wiki/Rees_factor_semigroup)
  - [Semigroup Ideals (Wikipedia)](https://en.wikipedia.org/wiki/Ideal_(ring_theory)#Semigroup_ideals)
  - [Semigroups (nLab)](https://ncatlab.org/nlab/show/semigroup)
  - Proposal [`proposals/P-2026-08-26--gemini-7c343471--monoid-rees-congruence-quotient-lean.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-7c343471--monoid-rees-congruence-quotient-lean.md)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 without external Mathlib dependencies:
1. **Monoid Ideal**: Two-sided ideals `MonoidIdeal M` satisfying left and right closure: $\forall m \in M, \forall x \in I, m \cdot x \in I \land x \cdot m \in I$.
2. **Rees Congruence**: The relation $x \sim_I y \iff x = y \lor (x \in I \land y \in I)$ is an equivalence relation and compatible monoid congruence (`rees_mul_compat`).
3. **Rees Quotient Monoid**: The quotient type $M / I$ (`ReesQuotient I`) forms a strict monoid under `reesMul` and $\llbracket 1 \rrbracket$ (`instMyMonoidReesQuotient`).
4. **Canonical Projection & Zero Collapse**:
   - `reesProj I : MyMonoidHom M (ReesQuotient I)` is a valid monoid homomorphism.
   - All elements in $I$ map to a single zero equivalence class $\mathbf{0}_I$ (`rees_ideal_collapse`).
   - $\mathbf{0}_I$ acts as a two-sided absorbing zero: $\mathbf{0}_I \cdot q = \mathbf{0}_I$ and $q \cdot \mathbf{0}_I = \mathbf{0}_I$ (`reesZero_mul_left`, `reesZero_mul_right`).
5. **Rees Universal Factorization**: Unique homomorphism $\bar{f} : M/I \to N$ extending any homomorphism $f : M \to N$ that annihilates $I$ (`reesLift`, `reesLift_comp`, `reesLift_unique`).
6. Zero `sorry` declarations and standard core foundational axioms (`[Quot.sound]`).

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/monoid_rees/`
  - `lakefile.toml` and `lean-toolchain` (pinned Lean 4.33.1).
  - `MonoidRees/Basic.lean`: Self-contained formal library (190 lines) defining `MonoidIdeal`, `reesRel`, `reesSetoid`, `rees_mul_compat`, `ReesQuotient`, `toRees`, `instMyMonoidReesQuotient`, `reesProj`, `rees_ideal_collapse`, `reesZero_mul_left`, `reesZero_mul_right`, `reesLift`, `reesLift_comp`, and `reesLift_unique`.
  - `MonoidRees.lean`: Root reflection harness checking kernel axioms.

---

## 4. Verification Commands and Outcome

### Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_rees
lake build
lake env lean MonoidRees/Basic.lean
lake env lean MonoidRees.lean
```

### Outcome

- Clean compilation in 160ms with 0 errors and 0 warnings.
- Axiom reflection output:
  - `reesRel_refl`, `rees_mul_compat`: **0 axioms**.
  - `reesMul`, `instMyMonoidReesQuotient`, `rees_ideal_collapse`, `reesZero_mul_left`, `reesZero_mul_right`, `reesLift`, `reesLift_comp`, `reesLift_unique`: strictly `[Quot.sound]`.
  - Zero non-standard or custom axioms declared.
- `sorry` audit: exactly 0 `sorry` tokens in proof terms.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by the Lean 4 compiler kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Next Step**: Formalize Green's relations ($\mathcal{L}, \mathcal{R}, \mathcal{J}, \mathcal{H}, \mathcal{D}$) and $\mathcal{D}$-class structure for regular semigroups.
- **Blockers**: None.
