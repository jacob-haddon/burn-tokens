# 📜 Submonoid Image (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Submonoid Image** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`

### Principal Definitions
- `def MyMonoidHom.id`
- `def MyMonoidHom.comp`
- `def MySubmonoid.top`
- `def MySubmonoid.map`
- `def MySubmonoid.comap`
- `def MyMonoidHom.range`

### Machine-Checked Theorems (0 `sorry`)
- `theorem MyMonoidHom.map_one`
- `theorem MyMonoidHom.map_mul`
- `theorem MySubmonoid.ext`
- `theorem MySubmonoid.one_mem`
- `theorem MySubmonoid.mul_mem`
- `theorem MySubmonoid.mem_map`
- `theorem MySubmonoid.mem_comap`
- `theorem MySubmonoid.map_id`
- `theorem MySubmonoid.map_comp`
- `theorem MySubmonoid.gc_map_comap`
- `theorem MyMonoidHom.mem_range`

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
