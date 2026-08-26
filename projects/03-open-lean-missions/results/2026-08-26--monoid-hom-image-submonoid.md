# Result Note: Image of a Submonoid under a Monoid Homomorphism in Lean 4

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0101` / Ticket `T-0002`
- **Candidate Title**: Monoid Homomorphism Image Submonoid
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Mathlib Contribution Guidance & Algebra Library](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/Group/Submonoid/Operations.html)
  - [Lean 4 Documentation](https://leanprover.github.io/lean4/doc/)

---

## 2. Precise Claim & Goal

Let $(M, \cdot, 1_M)$ and $(N, \cdot, 1_N)$ be monoids, $f : M \to N$ a monoid homomorphism (satisfying $f(1_M) = 1_N$ and $f(a \cdot b) = f(a) \cdot f(b)$), and $S \subseteq M$ a submonoid (satisfying $1_M \in S$ and $a, b \in S \implies a \cdot b \in S$).

The forward image:
$$f(S) = \{ y \in N \mid \exists x \in S, f(x) = y \}$$
is a submonoid of $N$.

Furthermore:
1. $f(S)$ satisfies the functoriality property: $S.\text{map}(g \circ f) = (S.\text{map}(f)).\text{map}(g)$.
2. $f(S)$ forms a Galois connection (adjunction) with the preimage $f^{-1}(T) = \{ x \in M \mid f(x) \in T \}$:
$$f(S) \le T \iff S \le f^{-1}(T)$$

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/submonoid_image/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `SubmonoidImage/Basic.lean`: Complete, standalone machine-checked formalization of:
    - `MyMonoid` typeclass.
    - `MyMonoidHom` structure with composition and identity.
    - `MySubmonoid` structure with membership and subset ordering.
    - `MySubmonoid.map`: Construction of image submonoid.
    - `MySubmonoid.comap`: Construction of preimage submonoid.
    - `MySubmonoid.map_id`: Image under identity homomorphism is identity.
    - `MySubmonoid.map_comp`: Functoriality of map under composition.
    - `MySubmonoid.gc_map_comap`: Galois connection between `map` and `comap`.
    - `MyMonoidHom.range`: Definition and characterization of homomorphism range as a submonoid.
  - `SubmonoidImage.lean`: Axiom reflection tests proving zero `sorry` and standard foundational axioms only (`propext`, `Quot.sound`).

---

## 4. Verification Commands and Outcome

### Commands

```bash
cd projects/01-open-lean-missions/submonoid_image
export PATH="/home/ging/.elan/bin:$PATH"
lake build
lake env lean SubmonoidImage/Basic.lean
```

### Outcome

- **Build**: Clean compilation in 250ms (4 jobs).
- **Axiom Check**:
  - `MySubmonoid.map`: `[]` (no axioms)
  - `MySubmonoid.gc_map_comap`: `[]` (no axioms)
  - `MySubmonoid.map_comp`: `[propext, Quot.sound]`
  - `MySubmonoid.map_id`: `[propext, Quot.sound]`
  - `MyMonoidHom.range`: `[]` (no axioms)
- **`sorry` Count**: 0.

---

## 5. Mathlib Duplication Assessment

In Mathlib 4, this theorem corresponds to `Submonoid.map` and `Submonoid.gc_map_comap` in `Mathlib.Algebra.Group.Submonoid.Operations`. Our implementation is a self-contained foundational formalization designed for verification-first autonomy without external dependencies.

---

## 6. Confidence

**`machine-checked`** (Compiled by Lean 4.33.1 kernel with zero `sorry` and standard propositional/quotient axioms only).

---

## 7. Best Next Step & Blockers

- **Next Step**: Formalize quotient monoids or the First Isomorphism Theorem for monoids ($M / \ker f \cong \text{range } f$).
- **Blockers**: None.
