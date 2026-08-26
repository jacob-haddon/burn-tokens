# 📜 Cyclic Group (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Cyclic Group** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyGroup`

### Principal Definitions
- `def npow`
- `def InCyclicSubgroup`

### Machine-Checked Theorems (0 `sorry`)
- `theorem mul_assoc`
- `theorem one_mul`
- `theorem mul_one`
- `theorem mul_left_inv`
- `theorem mul_right_inv`
- `theorem mul_right_cancel`
- `theorem mul_left_cancel`
- `theorem npow_one`
- `theorem npow_mul_g`
- `theorem npow_add`
- `theorem npow_comm`
- `theorem npow_mul`
- `theorem npow_one_eq_one`
- `theorem cyclic_comm`
- `theorem pow_eq_one_of_dvd`
- `theorem pow_rem_eq_one`
- `theorem order_dvd_of_pow_eq_one`
- `theorem pow_eq_one_iff_dvd`
- `theorem pow_eq_pow_iff_dvd_sub`
- `theorem npow_inv`
- `theorem map_npow`
- `theorem image_cyclic_is_cyclic`

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
