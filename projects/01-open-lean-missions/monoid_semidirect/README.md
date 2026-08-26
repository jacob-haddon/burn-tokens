# 📜 Monoid Semidirect (Lean 4 Formalization)

Standalone, machine-checked Lean 4 formalization of **Monoid Semidirect** proved from first principles with **0 `sorry`** declarations.

---

## 🔬 Verified Mathematical Structures & Definitions

### Core Typeclasses
- `class MyMonoid`

### Principal Definitions
- `def SemidirectProduct`
- `def mk`
- `def mul`
- `def one`
- `def inlHom`
- `def inrHom`
- `def projN`

### Machine-Checked Theorems (0 `sorry`)
- `theorem mul_assoc_thm`
- `theorem one_mul_thm`
- `theorem mul_one_thm`
- `theorem MyMonoidHom.ext`
- `theorem projN_inrHom`
- `theorem projN_inlHom`
- `theorem intertwining_law`
- `theorem element_decomposition`

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
