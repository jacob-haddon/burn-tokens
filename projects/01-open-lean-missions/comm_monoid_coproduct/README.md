# 📜 Comm Monoid Coproduct (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Comm Monoid Coproduct** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`
- `class MyCommMonoid`

### Principal Definitions
- `def inlHom`
- `def inrHom`
- `def copair`

### Machine-Checked Theorems (0 `sorry`)
- `theorem mul_assoc_thm`
- `theorem one_mul_thm`
- `theorem mul_one_thm`
- `theorem mul_comm_thm`
- `theorem MyMonoidHom.ext`
- `theorem prod_eq_inl_mul_inr`
- `theorem copair_inl`
- `theorem copair_inr`
- `theorem coprod_universal_unique`

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
