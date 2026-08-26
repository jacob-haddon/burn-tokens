# Result Note: Monoid Direct Product & Categorical Universal Property in Lean 4

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0106` / Ticket `T-0019`
- **Candidate Title**: Monoid Direct Product & Categorical Universal Property in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Direct product of groups/monoids on Wikipedia](https://en.wikipedia.org/wiki/Direct_product_of_groups)
  - [Product (Category Theory) on Wikipedia](https://en.wikipedia.org/wiki/Product_(category_theory))
  - Proposal [`proposals/P-2026-08-26--gemini-54adf27a--monoid-product-universal-property.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-54adf27a--monoid-product-universal-property.md)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (without external Mathlib dependencies):
1. The **cartesian direct product monoid** $M \times N$ for arbitrary monoids $(M, \cdot, 1_M)$ and $(N, \cdot, 1_N)$.
2. The canonical projection homomorphisms $\pi_1 : M \times N \to M$ and $\pi_2 : M \times N \to N$.
3. The **categorical universal property**: For any monoid $P$ and homomorphisms $f : P \to M$ and $g : P \to N$, there exists a unique homomorphism $\langle f, g \rangle : P \to M \times N$ satisfying $\pi_1 \circ \langle f, g \rangle = f$ and $\pi_2 \circ \langle f, g \rangle = g$.
4. The **commutativity characterization**: $M \times N$ is commutative $\iff$ both $M$ and $N$ are commutative.
5. Associativity and symmetry isomorphisms of direct products: $(M \times N) \times P \cong M \times (N \times P)$ and $M \times N \cong N \times M$.
6. Zero `sorry` declarations and standard core Lean 4 foundational axioms.

---

## 3. What Was Produced

1. **Lean 4 Workspace** (`projects/01-open-lean-missions/monoid_product/`):
   - `MonoidProduct/Basic.lean`: Complete formal definitions and proofs.
   - `MonoidProduct.lean`: Axiom reflection and verification harness.
2. **Formally Proved Theorems**:
   - `instProdMonoid`: Direct product monoid instance with verified associativity and two-sided unit laws.
   - `fstHom`, `sndHom`: Canonical projection homomorphisms.
   - `prodHom`: Pairing homomorphism $\langle f, g \rangle$.
   - `fst_comp_prodHom`, `snd_comp_prodHom`: Universal diagram commutativity.
   - `prodHom_unique`: Universal mediating morphism uniqueness.
   - `prod_isCommutative_iff`: If and only if characterization of product commutativity.
   - `prodCommHom_involutive`: Involutive product symmetry isomorphism.
   - `prodAssoc_left_inv`, `prodAssoc_right_inv`: Product associativity isomorphism.
   - `leftUnit_left_inv`, `leftUnit_right_inv`: Trivial monoid product unit isomorphism.

---

## 4. Verification Commands and Outcome

### Commands

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_product
lake build
lake env lean MonoidProduct.lean
```

### Outcome Summary

- Lean 4 compiler exited with code **0**.
- Zero `sorry` declarations.
- `#print axioms` confirmed standard foundational axioms:
  - `prod_isCommutative_iff`: **0 axioms**
  - `prodHom_unique`: `[Quot.sound]` (function extensionality)
  - `prodAssoc_left_inv`, `prodAssoc_right_inv`: `[Quot.sound]`
  - `leftUnit_left_inv`: `[Quot.sound]`

---

## 5. Confidence

**`machine-checked`** (Compiled with Lean 4.33.1 kernel, 0 `sorry`, 0 custom axioms).

---

## 6. Best Next Step & Blockers

- **Next Step**: Formalize coproducts (free products of monoids) or monoid quotient structures.
- **Blockers**: None.
