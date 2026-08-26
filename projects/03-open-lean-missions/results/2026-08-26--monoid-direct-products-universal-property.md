# Result Note: Lean 4 Formalization of Monoid Direct Products & Universal Property (Ticket T-0019)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0105` (Ticket `T-0019`)
- **Candidate Title**: Lean 4 Formalization of Monoid Direct Products & Universal Property
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Direct Product of Monoids / Groups (Wikipedia)](https://en.wikipedia.org/wiki/Direct_product_of_groups)
  - [Product (Category Theory)](https://en.wikipedia.org/wiki/Product_(category_theory))
  - [Lean 4 Documentation](https://leanprover-community.github.io/documentation.html)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Direct Product Monoid**: $M \times N$ forms a valid monoid under componentwise multiplication and unit $(1_M, 1_N)$ with zero axioms.
2. **Canonical Projections**: Projections $\pi_1 : M \times N \to M$ and $\pi_2 : M \times N \to N$ are valid monoid homomorphisms (zero axioms).
3. **Mediating Homomorphism**: For any homomorphisms $f : P \to M, g : P \to N$, the pairing arrow $\langle f, g \rangle : P \to M \times N$ is a monoid homomorphism satisfying $\pi_1 \circ \langle f, g \rangle = f$ and $\pi_2 \circ \langle f, g \rangle = g$ (zero axioms).
4. **Categorical Universal Property Uniqueness**: Any homomorphism $h : P \to M \times N$ satisfying $\pi_1 \circ h = f$ and $\pi_2 \circ h = g$ is strictly equal to $\langle f, g \rangle$ (proved with standard function extensionality `Quot.sound`).
5. **Commutativity Characterization**: $M \times N$ is commutative $\iff M$ and $N$ are both commutative (zero axioms).

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/monoid_product/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `MonoidProduct/Basic.lean`: Self-contained formalization (124 lines) containing:
    - `MyMonoid` & `MyCommMonoid` typeclasses and algebraic rewrite lemmas.
    - `MyMonoidHom` structure with extensionality `MyMonoidHom.ext`.
    - `instMyMonoidProd`: Direct product monoid instance.
    - `fstHom` & `sndHom`: Coordinate projection homomorphisms.
    - `prodPair`: Mediating arrow $\langle f, g \rangle$.
    - `fst_comp_prodPair` & `snd_comp_prodPair`: Projection commutation equations.
    - `prod_universal_unique`: Categorical uniqueness of the mediating arrow.
    - `instMyCommMonoidProd`: Product commutative monoid instance.
    - `prod_comm_iff`: Bidirectional commutativity characterization.
  - `MonoidProduct.lean`: Axiom reflection verification harness.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_product
lake build
lake env lean MonoidProduct/Basic.lean
lake env lean MonoidProduct.lean
```

### Outcome

- **Build**: Clean compilation in 150ms (4 jobs).
- **Axiom Check**:
  - `instMyMonoidProd`, `fstHom`, `sndHom`, `prodPair`, `fst_comp_prodPair`, `snd_comp_prodPair`, `instMyCommMonoidProd`, `prod_comm_iff`: **0 axioms**.
  - `prod_universal_unique`: `[Quot.sound]` (from function extensionality).
  - Zero custom or unverified axioms.
- **`sorry` Count**: 0.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by the Lean 4 kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Best Next Step**: Formalize coproducts / free products of monoids and the dual universal property.
- **Blockers**: None.
