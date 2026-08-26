# 📜 Greens Relations (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Greens Relations** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`

### Principal Definitions
- `def relL`
- `def relR`
- `def relH`
- `def relJ`
- `def relD`

### Machine-Checked Theorems (0 `sorry`)
- `theorem mul_assoc_thm`
- `theorem one_mul_thm`
- `theorem mul_one_thm`
- `theorem relL_refl`
- `theorem relL_symm`
- `theorem relL_trans`
- `theorem relR_refl`
- `theorem relR_symm`
- `theorem relR_trans`
- `theorem relH_refl`
- `theorem relH_symm`
- `theorem relH_trans`
- `theorem relJ_refl`
- `theorem relJ_symm`
- `theorem relJ_trans`
- `theorem relD_comm_fwd`
- `theorem relD_comm`
- `theorem relD_refl`
- `theorem relD_symm`
- `theorem relD_trans`
- `theorem greens_lemma_fwd`
- `theorem greens_lemma_bwd`
- `theorem greens_lemma_r_preservation`
- `theorem greens_lemma_h_fwd`
- `theorem greens_lemma_h_bwd`

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
