# 📜 Monoid Center (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Monoid Center** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`
- `class MyCommMonoid`

### Principal Definitions
- `def topSubmonoid`
- `def MyMonoidIso.toHom`
- `def MyMonoidIso.symm`
- `def isCentral`
- `def center`
- `def CenterElem`
- `def isoMapSubmonoid`

### Machine-Checked Theorems (0 `sorry`)
- `theorem MySubmonoid.ext`
- `theorem map_one`
- `theorem map_mul`
- `theorem isCentral_one`
- `theorem isCentral_mul`
- `theorem mem_center_iff`
- `theorem center_comm`
- `theorem comm_iff_center_eq_top`
- `theorem hom_map_center_of_surjective`
- `theorem iso_preserves_center`

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
