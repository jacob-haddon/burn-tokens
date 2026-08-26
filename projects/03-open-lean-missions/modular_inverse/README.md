# 📜 Modular Inverse (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Modular Inverse** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Principal Definitions
- `def ModEq`
- `def IsModInverse`
- `def extGcdFuel`
- `def extGcd`
- `def modInverse`

### Machine-Checked Theorems (0 `sorry`)
- `theorem modEq_refl`
- `theorem modEq_symm`
- `theorem modEq_trans`
- `theorem modEq_add`
- `theorem modEq_mul`
- `theorem mod_inverse_of_bezout`
- `theorem mod_inverse_congr`
- `theorem unique_residue`
- `theorem mod_inverse_unique`
- `theorem mod_inverse_pos`
- `theorem mod_inv_symm`
- `theorem mod_inv_prod`
- `theorem test_inv_3_7`
- `theorem test_inv_5_11`
- `theorem test_inv_7_13`
- `theorem test_inv_2_6`

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
