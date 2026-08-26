# 📜 Grothendieck Group (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Grothendieck Group** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyAddCommMonoid`
- `class MyAddCommGroup`

### Principal Definitions
- `def grothendieckRel`
- `def grothendieckSetoid`
- `def GrothendieckGroup`
- `def grothAdd`
- `def grothZero`
- `def grothNeg`
- `def canonicalHom`
- `def universalLift`

### Machine-Checked Theorems (0 `sorry`)
- `theorem add_assoc_thm`
- `theorem zero_add_thm`
- `theorem add_zero_thm`
- `theorem add_comm_thm`
- `theorem add_left_comm_thm`
- `theorem add_add_add_comm`
- `theorem add_add_add_comm3`
- `theorem add_left_neg_thm`
- `theorem add_right_neg_thm`
- `theorem sub_cancel_same`
- `theorem MyAddMonoidHom.ext`
- `theorem grothendieckRel_refl`
- `theorem grothendieckRel_symm`
- `theorem grothendieckRel_trans`
- `theorem grothendieckRel_add_congr`
- `theorem groth_lift_well_defined`
- `theorem universalLift_canonical`
- `theorem universalLift_unique`

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
