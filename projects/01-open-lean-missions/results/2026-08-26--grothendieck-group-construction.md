# Result Note: Formalization of the Grothendieck Group Construction and Universal Property in Lean 4 (Ticket T-0041)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0109` (Ticket `T-0041`)
- **Candidate Title**: Formalization of the Grothendieck Group Construction and Universal Property in Lean 4
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Grothendieck group (Wikipedia)](https://en.wikipedia.org/wiki/Grothendieck_group)
  - [Grothendieck group (nLab)](https://ncatlab.org/nlab/show/Grothendieck+group)
  - [Lean 4 Documentation](https://leanprover-community.github.io/documentation.html)

---

## 2. Precise Claim & Goal

Formalize from first principles in Lean 4 (with zero external Mathlib dependencies):
1. **Grothendieck Equivalence Relation**: On $M \times M$ for a commutative additive monoid $(M, +, 0)$, define $(a, b) \sim (c, d) \iff \exists k \in M, a + d + k = c + b + k$. Prove reflexivity, symmetry, transitivity, and congruence with addition (0 axioms).
2. **Grothendieck Abelian Group**: The quotient type $\mathcal{K}(M) = (M \times M) / \sim$ forms a strict abelian group under addition $\overline{(a, b)} + \overline{(c, d)} = \overline{(a+c, b+d)}$, zero $\overline{(0, 0)}$, and inverse $-\overline{(a, b)} = \overline{(b, a)}$.
3. **Canonical Homomorphism**: $\iota : M \to \mathcal{K}(M)$ with $m \mapsto \overline{(m, 0)}$ is a valid additive monoid homomorphism.
4. **Universal Factorization Property**: For any abelian group $G$ and additive monoid homomorphism $f : M \to G$, the quotient lift $\bar{f}(\overline{(a, b)}) = f(a) - f(b)$ is a well-defined group homomorphism satisfying $\bar{f} \circ \iota = f$.
5. **Categorical Uniqueness**: Any homomorphism $h : \mathcal{K}(M) \to G$ satisfying $h \circ \iota = f$ is strictly identical to $\bar{f}$ ($h = \bar{f}$).

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/grothendieck_group/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `GrothendieckGroup/Basic.lean`: Self-contained formal library (305 lines) containing:
    - `MyAddCommMonoid`, `MyAddCommGroup`, and `MyAddMonoidHom` typeclasses and structures.
    - `grothendieckRel`, `grothendieckRel_refl`, `grothendieckRel_symm`, `grothendieckRel_trans`, `grothendieckRel_add_congr`.
    - `GrothendieckGroup M` quotient definition and `MyAddCommGroup (GrothendieckGroup M)` instance.
    - `canonicalHom`, `universalLift`, `universalLift_canonical`, and `universalLift_unique`.
  - `GrothendieckGroup.lean`: Axiom reflection verification harness.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/grothendieck_group
lake build
lake env lean GrothendieckGroup/Basic.lean
lake env lean GrothendieckGroup.lean
```

### Outcome

- **Build**: Clean compilation in 170ms (4 jobs).
- **Axiom Check**:
  - `grothendieckRel_refl`, `grothendieckRel_symm`, `grothendieckRel_trans`, `grothendieckRel_add_congr`: **0 axioms**.
  - `canonicalHom`, `universalLift`, `universalLift_canonical`, `universalLift_unique`: strictly `[Quot.sound]` (from quotient lifts and extensionality).
  - Zero custom or unverified axioms.
- **`sorry` Count**: 0.

---

## 5. Confidence

**`machine-checked`** (Compiled and verified by Lean 4.33.1 kernel with 0 `sorry`).

---

## 6. Best Next Step & Blockers

- **Best Next Step**: Specialize to $\mathcal{K}(\mathbb{N}) \cong \mathbb{Z}$ and formalize the Grothendieck ring completion for commutative semirings.
- **Blockers**: None.
