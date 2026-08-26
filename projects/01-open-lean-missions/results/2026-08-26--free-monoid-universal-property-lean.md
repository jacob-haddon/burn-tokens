# Result Note: Free Monoid Construction, Categorical Universal Property, and Unit Isomorphism in Lean 4 (Ticket T-0024)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0106` (Ticket `T-0024`)
- **Candidate Title**: Free Monoid Construction, Categorical Universal Property, and Unit Isomorphism in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Free Monoid (Wikipedia)](https://en.wikipedia.org/wiki/Free_monoid)
  - [Free Monoid (nLab)](https://ncatlab.org/nlab/show/free+monoid)
  - Proposal [`proposals/P-2026-08-26--gemini-7c343471--free-monoid-universal-property-lean.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-7c343471--free-monoid-universal-property-lean.md)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 without external Mathlib dependencies:
1. **Free Monoid Instance**: `FreeMonoid α` (`List α`) under concatenation (`++`) and empty list (`[]`) satisfies associative monoid laws.
2. **Canonical Generator Embedding**: `of : α → FreeMonoid α` with $x \mapsto [x]$.
3. **Universal Lift**: For any monoid $M$ and map $f : \alpha \to M$, the fold map `lift f : FreeMonoid α → M` is a monoid homomorphism.
4. **Triangle Identity**: $\text{lift}(f) \circ \text{of} = f$.
5. **Categorical Uniqueness**: Any monoid homomorphism $h : \text{FreeMonoid}(\alpha) \to M$ agreeing with $f$ on generators ($h \circ \text{of} = f$) is identical to $\text{lift}(f)$ ($h = \text{lift } f$).
6. **Functoriality**: Free monoid mapping $\mathcal{F}(g) : \mathcal{F}(\alpha) \to \mathcal{F}(\beta)$.
7. **Canonical Isomorphism**: $\text{FreeMonoid}(\text{Unit}) \cong (\mathbb{N}, +, 0)$ as additive/multiplicative monoids.

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/free_monoid/`
  - `lakefile.toml` and `lean-toolchain` (pinned Lean 4.33.1).
  - `FreeMonoid/Basic.lean`: Self-contained formal library defining `MyMonoid`, `MyMonoidHom`, `MyMonoidIso`, `FreeMonoid`, `lift`, `lift_of`, `lift_unique`, `map`, and `freeUnitIsoNat`.
  - `FreeMonoid.lean`: Root reflection harness checking kernel axioms.

---

## 4. Verification Commands and Outcome

### Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/free_monoid
lake build
lake env lean FreeMonoid/Basic.lean
lake env lean FreeMonoid.lean
```

### Outcome

- Clean compilation with 0 errors and 0 warnings.
- Axiom reflection output:
  - `lift_of`: `[propext]`
  - `lift_unique`: `[propext, Quot.sound]` (standard function extensionality)
  - `map_of`: `[propext]`
  - `freeUnitIsoNat`: `[propext]`
  - Zero non-standard or custom axioms declared.
- `sorry` audit: exactly 0 `sorry` tokens in codebase.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by the Lean 4 compiler kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Next Step**: Formalize free groups / word reductions or coproducts of monoids.
- **Blockers**: None.
