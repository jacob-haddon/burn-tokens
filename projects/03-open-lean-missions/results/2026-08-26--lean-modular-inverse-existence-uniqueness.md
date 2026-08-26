# Result Note: Lean 4 Formalization of Modular Multiplicative Inverse Existence & Uniqueness (Ticket T-0010)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0103` (Ticket `T-0010`)
- **Candidate Title**: Modular Multiplicative Inverse Existence & Uniqueness in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Lean 4 Documentation](https://leanprover-community.github.io/documentation.html)
  - [Modular Multiplicative Inverse (Wikipedia)](https://en.wikipedia.org/wiki/Modular_multiplicative_inverse)
  - [Bézout's Identity (Wikipedia)](https://en.wikipedia.org/wiki/B%C3%A9zout%27s_identity)

---

## 2. Precise Claim & Goal

Let $a, m \in \mathbb{Z}$ with $m > 1$ and $\gcd(a, m) = 1$ (characterized by Bézout's identity: $\exists x, y \in \mathbb{Z}, a \cdot x + m \cdot y = 1$).

1. **Existence**: There exists an integer $b \in \mathbb{Z}$ such that $a \cdot b \equiv 1 \pmod m$.
2. **Uniqueness Modulo $m$**: If $a \cdot b_1 \equiv 1 \pmod m$ and $a \cdot b_2 \equiv 1 \pmod m$, then $b_1 \equiv b_2 \pmod m$.
3. **Canonical Range Uniqueness**: There exists a strictly unique canonical inverse $b \in \{1, \dots, m-1\}$ such that $a \cdot b \equiv 1 \pmod m$.
4. **Non-Triviality**: For $m > 1$, any modular inverse $b \in \{0, \dots, m-1\}$ satisfies $b \ge 1$ ($b \ne 0$).
5. **Involution & Composition**:
   - $(a^{-1})^{-1} \equiv a \pmod m$.
   - $(a_1 \cdot a_2)^{-1} \equiv a_2^{-1} \cdot a_1^{-1} \pmod m$.

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/modular_inverse/`
  - `lakefile.toml` & `lean-toolchain` (pinned to Lean 4.33.1).
  - `ModularInverse/Basic.lean`: Self-contained machine-checked formalization (196 lines) containing:
    - `ModEq`: Modular congruence relation $a \equiv b \pmod m$.
    - `modeq_refl`, `modeq_symm`, `modeq_trans`: Equivalence relation proofs.
    - `modeq_add`, `modeq_mul`: Congruence compatibility with addition and multiplication.
    - `IsCoprime`: Bézout identity predicate $\exists x, y, a \cdot x + m \cdot y = 1$.
    - `IsModInverse`: Multiplicative inverse predicate.
    - `mod_inverse_exists`: Existence proof from Bézout identity.
    - `mod_inverse_unique_modeq`: Uniqueness up to congruence.
    - `modeq_bounded_eq`: Bounded interval injectivity $[0, m) \to \mathbb{Z}/m\mathbb{Z}$.
    - `mod_inverse_canonical_unique`: Strict uniqueness of canonical bounded inverse.
    - `mod_inverse_nonzero`: Nonzero bound for $m > 1$.
    - `mod_inverse_involution`: Multiplicative inverse involution.
    - `mod_inverse_mul_comp`: Multiplicative inverse composition.
  - `ModularInverse.lean`: Kernel axiom reflection verification harness.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/modular_inverse
lake build
lake env lean ModularInverse/Basic.lean
lake env lean ModularInverse.lean
```

### Outcome

- **Build**: Clean compilation in 160ms (4 jobs).
- **Axiom Check**:
  - All theorems depend strictly on standard core Lean 4 foundational axioms `[propext, Quot.sound]`.
  - Zero custom or unverified axioms.
- **`sorry` Count**: 0.

---

## 5. Mathlib Duplication Assessment

Standard Mathlib formalizes `ZMod.instInv` and unit groups via extensive abstract algebra hierarchies. This package provides a standalone, zero-dependency first-principles construction of the modular inverse and its uniqueness over $\mathbb{Z}$.

---

## 6. Confidence

**`machine-checked`** (Compiled and verified by Lean 4.33.1 kernel with 0 `sorry` and 0 extra axioms).

---

## 7. Best Next Step & Blockers

- **Best Next Step**: Formalize the Extended Euclidean Algorithm as a computable function `xgcd` and prove that it computes the witness $x$ satisfying `IsModInverse a x m`.
- **Blockers**: None.
