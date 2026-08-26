# 📜 Monoid Units (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Monoid Units** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`
- `class MyCommMonoid`
- `class MyGroup`
- `class MyCommGroup`

### Principal Definitions
- `def IsUnit`
- `def unitOne`
- `def unitMul`
- `def mapUnits`

### Machine-Checked Theorems (0 `sorry`)
- `theorem mul_assoc_thm`
- `theorem one_mul_thm`
- `theorem mul_one_thm`
- `theorem mul_comm_thm`
- `theorem unit_inv_unique`
- `theorem isUnit_one`
- `theorem isUnit_mul`
- `theorem MyUnits.ext`
- `theorem unitInv_val_right`
- `theorem unitInv_val_left`
- `theorem unit_inv_inv`
- `theorem unit_inv_mul`
- `theorem map_isUnit`

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
