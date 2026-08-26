# 📜 Free Monoid (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Free Monoid** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`

### Principal Definitions
- `def of`
- `def freeFold`
- `def lift`
- `def freeMap`
- `def lengthHom`
- `def replicateHom`
- `def free_unit_iso_nat`

### Machine-Checked Theorems (0 `sorry`)
- `theorem mul_assoc_thm`
- `theorem one_mul_thm`
- `theorem mul_one_thm`
- `theorem MyMonoidHom.ext`
- `theorem freeFold_nil`
- `theorem freeFold_cons`
- `theorem freeFold_append`
- `theorem lift_of`
- `theorem list_cons_eq_of_append`
- `theorem lift_unique`
- `theorem freeMap_of`
- `theorem replicate_unit_add`
- `theorem length_replicate_unit`
- `theorem replicate_length_unit`

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
