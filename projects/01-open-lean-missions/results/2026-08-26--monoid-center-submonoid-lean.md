# Result Note: Formalization of Monoid Center Submonoid and Commutativity Duality in Lean 4

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0103` / Ticket `T-0016`
- **Candidate Title**: Formalization of Monoid Center Submonoid and Commutativity Duality in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Center of a Group / Monoid (Wikipedia)](https://en.wikipedia.org/wiki/Center_(group_theory))
  - [Mathlib4 Docs: Submonoid Center](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/Group/Submonoid/Center.html)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (without external Mathlib dependencies):
1. The predicate `isCentral M z : Prop := ∀ x : M, z * x = x * z`.
2. Identity and product preservation: $1 \in Z(M)$ and $a, b \in Z(M) \implies a \cdot b \in Z(M)$.
3. Formation of the center as a submonoid `center M : MySubmonoid M`.
4. Commutativity of $Z(M)$: $\forall a, b \in Z(M), a \cdot b = b \cdot a$, and subtype instance `MyCommMonoid (CenterElem M)`.
5. Commutativity duality: $M$ is commutative if and only if $\text{center}(M) = \top$.
6. Homomorphism and isomorphism preservation:
   - For surjective $f : M \to N$, $f(Z(M)) \subseteq Z(N)$.
   - For isomorphism $f : M \cong N$, $f(Z(M)) = Z(N)$.

---

## 3. What Was Produced

- **Standalone Lean 4 Package**: `projects/01-open-lean-missions/monoid_center/` pinned to Lean 4.33.1.
- **Source Files**:
  - `projects/01-open-lean-missions/monoid_center/MonoidCenter/Basic.lean`
  - `projects/01-open-lean-missions/monoid_center/MonoidCenter.lean`
  - `projects/01-open-lean-missions/monoid_center/lakefile.toml`
  - `projects/01-open-lean-missions/monoid_center/lean-toolchain`

---

## 4. Verification Commands and Outcome

### Commands

```bash
cd projects/01-open-lean-missions/monoid_center
/home/ging/.elan/bin/lake build
/home/ging/.elan/bin/lake env lean MonoidCenter.lean
```

### Outcome

- Compilation succeeded with zero errors, zero warnings, and zero `sorry` tokens.
- Axiom reflection `#print axioms`:
  - `isCentral_one`: no axioms.
  - `isCentral_mul`: no axioms.
  - `center_comm`: no axioms.
  - `comm_iff_center_eq_top`: `[propext, Quot.sound]`.
  - `hom_map_center_of_surjective`: `[propext]`.
  - `iso_preserves_center`: `[propext, Quot.sound]`.
- No non-standard or custom axioms declared.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by the Lean 4 kernel).

---

## 6. Best Next Step & Blockers

- **Next Step**: Connect center submonoid definitions with normal submonoid quotient constructions.
- **Blockers**: None.
