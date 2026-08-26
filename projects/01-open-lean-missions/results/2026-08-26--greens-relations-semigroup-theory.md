# Result Note: Formalization of Green's Relations, D-Commutation, and Green's Lemma in Lean 4 (Ticket T-0045)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0110` (Ticket `T-0045`)
- **Candidate Title**: Formalization of Green's Relations, Commutation of D-Classes, and Green's Lemma in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Green's Relations (Wikipedia)](https://en.wikipedia.org/wiki/Green%27s_relations)
  - [Green's Relations (nLab)](https://ncatlab.org/nlab/show/Green%27s+relations)
  - J. A. Green (1951), "On the structure of semigroups", *Ann. of Math.*

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Green's Five Relations**: $\mathcal{L}, \mathcal{R}, \mathcal{H}, \mathcal{J}, \mathcal{D}$ on any monoid $M$.
2. **Equivalence Properties**: Prove reflexivity, symmetry, and transitivity for $\mathcal{L}, \mathcal{R}, \mathcal{H}, \mathcal{J}$ (0 axioms).
3. **Green's Commutation Theorem**: Prove relational commutation $\mathcal{L} \circ \mathcal{R} = \mathcal{R} \circ \mathcal{L}$, confirming $\mathcal{D}$ is an equivalence relation (0 axioms).
4. **Green's Lemma (Core Isomorphism Theorem of Semigroups)**:
   - For $a \mathcal{R} b$ witnessed by $a s = b$ and $b t = a$, the right-translation $\rho_s : x \mapsto x s$ maps the $\mathcal{L}$-class of $a$ bijectively onto the $\mathcal{L}$-class of $b$, with two-sided inverse $\rho_t : y \mapsto y t$ ($(x s) t = x$ and $(y t) s = y$) (0 axioms).
   - $\rho_s$ preserves $\mathcal{R}$-relations ($x \mathcal{R} x s$) (0 axioms).
   - $\rho_s$ restricts to a bijection between $\mathcal{H}$-classes ($H_a \cong H_b$) (0 axioms).

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/greens_relations/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `GreensRelations/Basic.lean`: Self-contained formal library (230 lines) containing:
    - `MyMonoid` typeclass and associative multiplication laws.
    - `relL`, `relR`, `relH`, `relJ`, `relD`.
    - `relL_refl`, `_symm`, `_trans`; `relR_refl`, `_symm`, `_trans`.
    - `relH_refl`, `_symm`, `_trans`; `relJ_refl`, `_symm`, `_trans`.
    - `relD_comm_fwd`, `relD_comm`, `relD_refl`, `_symm`, `_trans`.
    - `greens_lemma_fwd`, `greens_lemma_bwd`, `greens_lemma_r_preservation`, `greens_lemma_h_fwd`, `greens_lemma_h_bwd`.
  - `GreensRelations.lean`: Axiom reflection verification harness.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/greens_relations
lake build
lake env lean GreensRelations/Basic.lean
lake env lean GreensRelations.lean
```

### Outcome

- **Build**: Clean compilation in 140ms (4 jobs).
- **Axiom Check**:
  - **ALL 21 THEOREMS**: **0 axioms** (`does not depend on any axioms`).
  - Zero custom or unverified axioms.
- **`sorry` Count**: 0.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by Lean 4.33.1 kernel with 0 `sorry` and 0 axioms).

---

## 6. Best Next Step & Blockers

- **Best Next Step**: Formalize Schützenberger groups and idempotent $\mathcal{H}$-class maximal subgroups (Clifford-Preston theorem).
- **Blockers**: None.
