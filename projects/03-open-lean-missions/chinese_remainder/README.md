# 📜 Chinese Remainder (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Chinese Remainder** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Principal Definitions
- `def ModEq`
- `def crtRaw`
- `def extGcdFuel`
- `def crtSolve`

### Machine-Checked Theorems (0 `sorry`)
- `theorem modEq_refl`
- `theorem modEq_symm`
- `theorem modEq_trans`
- `theorem modEq_add`
- `theorem modEq_sub`
- `theorem crtRaw_mod_left`
- `theorem crtRaw_mod_right`
- `theorem simultaneous_modEq_product`
- `theorem crt_unique`
- `theorem crt_test_3_5`
- `theorem crt_test_7_11`
- `theorem crt_test_2_3`
- `theorem crt_test_5_7`

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
