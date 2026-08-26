# Result Note: Formalization of the First Isomorphism Theorem for Monoids in Lean 4 (Ticket T-0027)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0107` (Ticket `T-0027`)
- **Candidate Title**: Formalization of the First Isomorphism Theorem for Monoids in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Isomorphism Theorems (Universal Algebra / Monoids)](https://en.wikipedia.org/wiki/Isomorphism_theorems)
  - [Congruence Relation](https://en.wikipedia.org/wiki/Congruence_relation)
  - [Lean 4 Documentation](https://leanprover-community.github.io/documentation.html)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Monoid Congruence**: `MonoidCongruence M` defining equivalence relations compatible with multiplication.
2. **Quotient Monoid**: The quotient type `Quotient R.toSetoid` forms a strict monoid under `quotMul R` and `⟦1⟧`.
3. **Projection Homomorphism**: Canonical projection homomorphism `projHom R : MyMonoidHom M (Quotient R.toSetoid)`.
4. **Quotient Universal Property**: Unique factorization `quotLift f R hR` for any homomorphism whose kernel contains $R$.
5. **Kernel Congruence**: `kerCongruence f` defined by $a \sim b \iff f(a) = f(b)$ is a valid monoid congruence (0 axioms).
6. **Range Submonoid**: The image $\text{Im}(f)$ forms a valid monoid under restricted multiplication (0 axioms).
7. **First Isomorphism Theorem**: The factored homomorphism $\bar{f} : M/\ker(f) \to \text{Im}(f)$ is both injective and surjective, establishing the canonical monoid isomorphism $M / \ker(f) \cong \text{Im}(f)$.

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/monoid_first_iso/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `MonoidFirstIso/Basic.lean`: Self-contained formal library (198 lines) containing:
    - `MyMonoid` and `MyMonoidHom` typeclasses and structures.
    - `MonoidCongruence` structure and `instMyMonoidQuotient`.
    - `projHom`, `quotLift`, `quotLift_comp`, `quotLift_unique`.
    - `kerCongruence` and `instMyMonoidRange`.
    - `firstIsoHom`, `firstIsoHom_injective`, `firstIsoHom_surjective`.
    - `firstMonoidIso : MyMonoidIso (Quotient (kerCongruence f).toSetoid) (MonoidRange f)`.
  - `MonoidFirstIso.lean`: Axiom reflection verification harness.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_first_iso
lake build
lake env lean MonoidFirstIso/Basic.lean
lake env lean MonoidFirstIso.lean
```

### Outcome

- **Build**: Clean compilation in 170ms (4 jobs).
- **Axiom Check**:
  - `kerCongruence`, `instMyMonoidRange`: **0 axioms**.
  - `instMyMonoidQuotient`, `projHom`, `quotLift`, `quotLift_comp`, `quotLift_unique`, `firstIsoHom`, `firstIsoHom_injective`, `firstIsoHom_surjective`: strictly `[Quot.sound]`.
  - `firstMonoidIso`: strictly `[Classical.choice, Quot.sound]`.
  - Zero custom or unverified axioms.
- **`sorry` Count**: 0.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by Lean 4.33.1 kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Best Next Step**: Formalize the Second and Third Isomorphism Theorems for submonoids and congruence lattices.
- **Blockers**: None.
