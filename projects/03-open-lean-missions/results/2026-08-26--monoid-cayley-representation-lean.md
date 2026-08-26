# Result Note: Formalization of Cayley's Embedding Theorem & Transformation Monoids in Lean 4 (Ticket T-0032)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0108` (Ticket `T-0032`)
- **Candidate Title**: Formalization of Cayley's Embedding Theorem & Transformation Monoids in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Cayley's Theorem (Wikipedia)](https://en.wikipedia.org/wiki/Cayley%27s_theorem)
  - [Transformation Monoid (Wikipedia)](https://en.wikipedia.org/wiki/Transformation_monoid)
  - [Cayley's Theorem (nLab)](https://ncatlab.org/nlab/show/Cayley%27s+theorem)
  - Proposal [`proposals/P-2026-08-26--gemini-7c343471--monoid-cayley-representation-lean.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-7c343471--monoid-cayley-representation-lean.md)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 without external Mathlib dependencies:
1. **Transformation Monoid**: `EndMonoid M = (M → M, ∘, id)` forms a strict monoid under function composition.
2. **Left-Regular Representation**: `cayleyHom : MyMonoidHom M (EndMonoid M)` mapping $a \mapsto (x \mapsto a \cdot x)$, with proofs of identity preservation (`one_mul`) and composition preservation (`mul_assoc`).
3. **Strict Injectivity (Faithful Action)**: `cayleyHom_injective : ∀ a b : M, cayleyHom a = cayleyHom b → a = b`, evaluated at the unit element $1 \in M$.
4. **Cayley Submonoid Image & Isomorphism**: Construct the transformation submonoid $\text{Im}(\text{cayleyHom})$ (`CayleyRange M`) and prove the canonical monoid isomorphism $M \cong \text{Im}(\text{cayleyHom})$ (`cayleyIso`).
5. Zero `sorry` declarations and standard core foundational axioms (`[Classical.choice, Quot.sound]`).

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/monoid_cayley/`
  - `lakefile.toml` and `lean-toolchain` (pinned Lean 4.33.1).
  - `MonoidCayley/Basic.lean`: Self-contained formal library (144 lines) defining `MyMonoid`, `MyMonoidHom`, `MyMonoidIso`, `EndMonoid`, `cayleyFun`, `cayleyHom`, `cayleyHom_injective`, `CayleyRange`, and `cayleyIso`.
  - `MonoidCayley.lean`: Root reflection harness checking kernel axioms.

---

## 4. Verification Commands and Outcome

### Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_cayley
lake build
lake env lean MonoidCayley/Basic.lean
lake env lean MonoidCayley.lean
```

### Outcome

- Clean compilation with 0 errors and 0 warnings.
- Axiom reflection output:
  - `cayleyFun_one`, `cayleyFun_mul`, `cayleyHom`, `cayleyHom_injective`: `[Quot.sound]` (function extensionality).
  - `cayleyIso`: `[Classical.choice, Quot.sound]`.
  - Zero non-standard or custom axioms declared.
- `sorry` audit: exactly 0 `sorry` tokens in proof terms.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by the Lean 4 compiler kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Next Step**: Formalize right-regular representations and commuting actions.
- **Blockers**: None.
