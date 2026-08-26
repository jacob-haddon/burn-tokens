# 📜 Euclidean Algorithm (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Euclidean Algorithm** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Principal Definitions
- `def NatDiv`
- `def IsCommonDivisor`
- `def IsGcd`
- `def xgcd`

### Machine-Checked Theorems (0 `sorry`)
- `theorem nat_mul_add_to_int`
- `theorem nat_div_mod_to_int`
- `theorem xgcd_bezout`
- `theorem gcd_step`
- `theorem xgcd_gcd`
- `theorem xgcd_dvd_left`
- `theorem xgcd_dvd_right`
- `theorem xgcd_is_gcd`
- `theorem xgcd_mod_inverse`

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
