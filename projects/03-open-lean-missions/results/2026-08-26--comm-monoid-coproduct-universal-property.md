# Result Note: Coproduct Universal Property of Commutative Monoids in Lean 4 (Ticket T-0035)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0108` (Ticket `T-0035`)
- **Candidate Title**: Formalization of the Coproduct Universal Property of Commutative Monoids in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Coproduct (Category Theory)](https://en.wikipedia.org/wiki/Coproduct)
  - [Biproduct (nLab)](https://ncatlab.org/nlab/show/biproduct)
  - [Lean 4 Documentation](https://leanprover-community.github.io/documentation.html)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Canonical Inclusions**: The projection injections $\iota_1 : M \to M \times N$ ($m \mapsto (m, 1)$) and $\iota_2 : N \to M \times N$ ($n \mapsto (1, n)$) are valid monoid homomorphisms (0 axioms).
2. **Biproduct Splitting**: The identity $(m, n) = \iota_1(m) \cdot \iota_2(n)$ holds for all pairs in $M \times N$ (0 axioms).
3. **Universal Copairing**: For any commutative monoid $P$ and homomorphisms $f : M \to P$ and $g : N \to P$, the map $[f, g] : M \times N \to P$ given by $(m, n) \mapsto f(m) \cdot g(n)$ is a valid monoid homomorphism (0 axioms).
4. **Triangle Commutation Identities**:
   - `copair_inl`: $[f, g] \circ \iota_1 = f$ (0 axioms).
   - `copair_inr`: $[f, g] \circ \iota_2 = g$ (0 axioms).
5. **Categorical Coproduct Uniqueness**: Any homomorphism $h : M \times N \to P$ satisfying $h \circ \iota_1 = f$ and $h \circ \iota_2 = g$ is strictly equal to $[f, g]$ ($h = [f, g]$).

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/comm_monoid_coproduct/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `CommMonoidCoproduct/Basic.lean`: Self-contained formal library (128 lines) containing:
    - `MyMonoid`, `MyCommMonoid`, and `MyMonoidHom` typeclasses and structures.
    - `instMyMonoidProd` and `instMyCommMonoidProd`.
    - `inlHom` and `inrHom`.
    - `prod_eq_inl_mul_inr`.
    - `copair`, `copair_inl`, and `copair_inr`.
    - `coprod_universal_unique`.
  - `CommMonoidCoproduct.lean`: Axiom reflection verification harness.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/comm_monoid_coproduct
lake build
lake env lean CommMonoidCoproduct/Basic.lean
lake env lean CommMonoidCoproduct.lean
```

### Outcome

- **Build**: Clean compilation in 150ms (4 jobs).
- **Axiom Check**:
  - `instMyMonoidProd`, `instMyCommMonoidProd`, `inlHom`, `inrHom`, `prod_eq_inl_mul_inr`, `copair`, `copair_inl`, `copair_inr`: **0 axioms**.
  - `coprod_universal_unique`: strictly `[Quot.sound]` (from function extensionality on homomorphisms).
  - Zero custom or unverified axioms.
- **`sorry` Count**: 0.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by Lean 4.33.1 kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Best Next Step**: Extend to finite $n$-ary biproducts and the semi-additive category of commutative monoids $\mathbf{CommMonoid}$.
- **Blockers**: None.
