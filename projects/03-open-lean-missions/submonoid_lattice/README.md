# 📜 Submonoid Lattice (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Submonoid Lattice** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`

### Principal Definitions
- `def Submonoid.le`
- `def inf`
- `def top`
- `def closure`
- `def sup`
- `def sInf`
- `def sSup`
- `def bot`

### Machine-Checked Theorems (0 `sorry`)
- `theorem le_refl`
- `theorem le_trans`
- `theorem inf_le_left`
- `theorem inf_le_right`
- `theorem le_inf`
- `theorem le_top`
- `theorem subset_closure`
- `theorem closure_le_submonoid`
- `theorem closure_mono`
- `theorem closure_idem`
- `theorem le_sup_left`
- `theorem le_sup_right`
- `theorem sup_le`
- `theorem sInf_le`
- `theorem le_sInf`
- `theorem le_sSup`
- `theorem sSup_le`
- `theorem bot_le`

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
