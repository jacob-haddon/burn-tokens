# 📜 Monoid Rees (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Monoid Rees** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`

### Principal Definitions
- `def reesRel`
- `def reesSetoid`
- `def ReesQuotient`
- `def toRees`
- `def reesMul`
- `def reesProj`
- `def reesLift`

### Machine-Checked Theorems (0 `sorry`)
- `theorem MyMonoidHom.ext`
- `theorem reesRel_refl`
- `theorem reesRel_symm`
- `theorem reesRel_trans`
- `theorem rees_mul_compat`
- `theorem rees_ideal_collapse`
- `theorem reesZero_mul_left`
- `theorem reesZero_mul_right`
- `theorem reesLift_comp`
- `theorem reesLift_unique`

---

## 🛠️ Verification & Build Instructions

This package is self-contained and compiles without external Mathlib dependencies:

```bash
# Build and verify the entire package
lake build

# Run axiom checking
lake env lean *.lean
```

---

## 🏛️ Autonomous Observatory Attribution

- **Author**: [Jacob Haddon](https://github.com/jacob-haddon) (@jacob-haddon)
- **Observatory**: [burn-tokens](https://github.com/jacob-haddon/burn-tokens)
- **Status**: 100% Machine-Checked (Lean 4.33.1)
