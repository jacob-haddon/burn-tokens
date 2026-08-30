# Residuated Posets, Quantale Adjunctions, and Invertible Residuals in Lean 4

Machine-checked formalization of Residuated Monoids / Posets, Galois Adjunction Units/Counits, Monotonicity and Variance of Residuals, Closure Idempotence, Associativity of Left/Right Divisions, and the Invertible Residual Reduction Theorem.

**Reference Preprint**: *Residuated Lattices, Quantales, and Substructural Logic* (Galatos-Jipsen 2025, arXiv:2502.04561).

---

## 🎯 Formalized Mathematical Invariants

Let $(L, \le, \cdot, 1, \backslash, //)$ be a partially ordered monoid equipped with binary operations of left division ($\backslash$) and right division ($//$) satisfying the residual Galois adjunction equivalences:
$$x \cdot y \le z \iff y \le x \backslash z \iff x \le z // y$$

### Formalized Theorems (0 `sorry`, 0 Custom Axioms):
1. **Adjunction Counits & Units**:
   - `ldiv_counit`: $x \cdot (x \backslash z) \le z$ (Substructural Modus Ponens).
   - `rdiv_counit`: $(z // y) \cdot y \le z$.
   - `ldiv_unit`: $y \le x \backslash (x \cdot y)$.
   - `rdiv_unit`: $x \le (x \cdot y) // y$.
2. **Derived Monoid Monotonicity**:
   - `mul_mono_left`: $a \le b \implies a \cdot c \le b \cdot c$.
   - `mul_mono_right`: $a \le b \implies c \cdot a \le c \cdot b$.
   - `mul_mono`: $a_1 \le a_2 \land b_1 \le b_2 \implies a_1 \cdot b_1 \le a_2 \cdot b_2$.
3. **Variance of Residuals**:
   - `ldiv_mono_right`: $z_1 \le z_2 \implies x \backslash z_1 \le x \backslash z_2$ (Covariant in numerator).
   - `ldiv_anti_left`: $x_1 \le x_2 \implies x_2 \backslash z \le x_1 \backslash z$ (Contravariant in denominator).
   - `rdiv_mono_left`: $z_1 \le z_2 \implies z_1 // y \le z_2 // y$ (Covariant in numerator).
   - `rdiv_anti_right`: $y_1 \le y_2 \implies z // y_2 \le z // y_1$ (Contravariant in denominator).
4. **Closure Idempotence**:
   - `ldiv_closure_idempotent`: $x \backslash (x \cdot (x \backslash z)) = x \backslash z$.
   - `rdiv_closure_idempotent`: $((z // y) \cdot y) // y = z // y$.
5. **Residual Associativity & Identity Laws**:
   - `residual_associativity`: $(x \backslash y) // z = x \backslash (y // z)$.
   - `one_ldiv`: $1 \backslash x = x$.
   - `rdiv_one`: $x // 1 = x$.
6. **Invertible Residual Reduction Theorem**:
   - `invertible_ldiv`: If $x \cdot x^{-1} = 1$ and $x^{-1} \cdot x = 1$, then $x \backslash z = x^{-1} \cdot z$.
   - `invertible_rdiv`: If $x \cdot x^{-1} = 1$ and $x^{-1} \cdot x = 1$, then $z // x = z \cdot x^{-1}$.

---

## ⚡ Compilation & Verification

Compiled and machine-checked in **598ms** on remote node `omarchy-1` using Lean 4.33.1.
