# 📜 Galois Connection (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Galois Connection** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyPreorder`
- `class MyPartialOrder`

### Principal Definitions
- `def GaloisConnection`
- `def IsClosed`
- `def IsOpen`
- `def main`

### Machine-Checked Theorems (0 `sorry`)
- `theorem my_le_refl`
- `theorem my_le_trans`
- `theorem my_le_antisymm`
- `theorem gc_le_g_f`
- `theorem gc_f_g_le`
- `theorem gc_monotone_l`
- `theorem gc_monotone_u`
- `theorem gc_monotone_gf`
- `theorem gc_monotone_fg`
- `theorem gc_f_g_f`
- `theorem gc_g_f_g`
- `theorem gc_closure_operator_gf`
- `theorem gc_kernel_operator_fg`
- `theorem is_closed_iff_mem_range`
- `theorem is_open_iff_mem_range`
- `theorem f_is_open`
- `theorem g_is_closed`
- `theorem closed_open_inverse_f`
- `theorem closed_open_inverse_g`
- `theorem closed_open_equiv`

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
