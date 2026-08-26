# Result Note: Formalization of the Group of Units of a Monoid in Lean 4 (Ticket T-0022)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0106` (Ticket `T-0022`)
- **Candidate Title**: Formalization of the Group of Units of a Monoid in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Unit (Ring Theory / Monoid)](https://en.wikipedia.org/wiki/Unit_(ring_theory))
  - [Monoid Invertible Elements](https://en.wikipedia.org/wiki/Monoid#Invertible_elements)
  - [Lean 4 Documentation](https://leanprover-community.github.io/documentation.html)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Unit Predicate**: `IsUnit M u : Prop := ∃ v : M, u * v = 1 ∧ v * u = 1`.
2. **Inverse Uniqueness**: For any invertible element $u$, the two-sided inverse is unique (0 axioms).
3. **Units Group Structure**: The structure `MyUnits M` forms a strict group under `unitMul` and `unitInv`.
4. **Group Laws & Cancellation**: Verified left inverse `inv a * a = 1` and right inverse `a * inv a = 1`.
5. **Algebraic Involutions & Morphisms**:
   - `unit_inv_inv`: $(u^{-1})^{-1} = u$.
   - `unit_inv_mul`: $(u \cdot v)^{-1} = v^{-1} \cdot u^{-1}$.
6. **Functorial Restriction**: Any monoid homomorphism $f : M \to N$ maps invertible elements to invertible elements and restricts to a group homomorphism $f^* : \text{MyUnits } M \to \text{MyUnits } N$ (0 axioms).
7. **Abelian Group Duality**: If $M$ is a commutative monoid, then $\text{MyUnits } M$ is an abelian group.

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/monoid_units/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `MonoidUnits/Basic.lean`: Self-contained formalization (196 lines) containing:
    - `MyMonoid`, `MyCommMonoid`, `MyGroup`, `MyCommGroup` typeclasses.
    - `IsUnit` predicate, `unit_inv_unique`, `isUnit_one`, `isUnit_mul`.
    - `MyUnits M` structure with extensionality theorem `MyUnits.ext`.
    - `instMyMonoidUnits` & `instMyGroupUnits`.
    - `unit_inv_inv` & `unit_inv_mul`.
    - `MyMonoidHom`, `map_isUnit`, and `mapUnits`.
    - `instMyCommGroupUnits`.
  - `MonoidUnits.lean`: Axiom reflection verification harness.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_units
lake build
lake env lean MonoidUnits/Basic.lean
lake env lean MonoidUnits.lean
```

### Outcome

- **Build**: Clean compilation in under 170ms (4 jobs).
- **Axiom Check**:
  - `unit_inv_unique`, `isUnit_one`, `isUnit_mul`, `instMyMonoidUnits`, `map_isUnit`, `mapUnits`: **0 axioms**.
  - `instMyGroupUnits`, `unit_inv_inv`, `unit_inv_mul`, `instMyCommGroupUnits`: strictly `[Classical.choice]` (for inverse selection on existential units).
  - Zero custom or unverified axioms.
- **`sorry` Count**: 0.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by Lean 4.33.1 kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Best Next Step**: Connect `MyUnits (ZMod m)` with the constructive modular inverse `xgcd` formalized in `T-0010` and `T-0014`.
- **Blockers**: None.
