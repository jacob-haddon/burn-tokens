# Handoff: Lean 4 Formalization of Submonoid Image under Homomorphism

- **Ticket**: `T-0002`
- **Agent ID**: `gemini-1a360f98`
- **Model**: `Gemini 3.7 Flash (High)`
- **Project**: `projects/01-open-lean-missions`
- **Date**: 2026-08-26
- **Status**: Ready for Review

---

## 1. Task & Mathematical Scope

Formalize in Lean 4 without `sorry` the theorem that the forward image $f(S)$ of a submonoid $S \subseteq M$ under a monoid homomorphism $f : M \to N$ forms a valid submonoid of $N$.

### Key Formal Constructs
1. `MyMonoid M`: Typeclass for monoids (associative binary op, left/right identity 1).
2. `MyMonoidHom M N`: Structure for monoid homomorphisms ($f(1)=1$, $f(ab)=f(a)f(b)$).
3. `MySubmonoid M`: Predicate $S \subseteq M$ with $1 \in S$ and closure under multiplication.
4. `MySubmonoid.map`: Constructing the image submonoid $f(S) = \{ y \in N \mid \exists x \in S, f(x) = y \}$.
5. `MySubmonoid.comap`: Constructing the preimage submonoid $f^{-1}(T) = \{ x \in M \mid f(x) \in T \}$.
6. `MySubmonoid.gc_map_comap`: Machine-checked proof of the Galois connection $f(S) \le T \iff S \le f^{-1}(T)$.
7. `MySubmonoid.map_comp` and `MySubmonoid.map_id`: Functorial laws of submonoid forward image.

---

## 2. Source URLs

- [Mathlib Submonoid Operations Documentation](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/Group/Submonoid/Operations.html)
- [Lean 4 Reference Manual](https://leanprover.github.io/lean4/doc/)

---

## 3. Files Created & Modified

- `projects/01-open-lean-missions/submonoid_image/lakefile.toml`: Package configuration.
- `projects/01-open-lean-missions/submonoid_image/lean-toolchain`: Pinned Lean 4.33.1.
- `projects/01-open-lean-missions/submonoid_image/SubmonoidImage/Basic.lean`: Complete standalone formalization.
- `projects/01-open-lean-missions/submonoid_image/SubmonoidImage.lean`: Module entrypoint and axiom reflection tests.
- `projects/01-open-lean-missions/results/2026-08-26--monoid-hom-image-submonoid.md`: Result note.

---

## 4. Verification Commands & Outputs

```bash
cd projects/01-open-lean-missions/submonoid_image
export PATH="/home/ging/.elan/bin:$PATH"
lake build
lake env lean SubmonoidImage/Basic.lean
```

**Output**:
- `lake build` compiled all 4 jobs successfully in 250ms with 0 warnings and 0 errors.
- `lake env lean SubmonoidImage/Basic.lean` exited cleanly (code 0).
- `#print axioms MySubmonoid.map` reported 0 axioms.
- `#print axioms MySubmonoid.gc_map_comap` reported 0 axioms.

---

## 5. Mathlib Duplication Assessment

In Mathlib 4, this concept is implemented as `Submonoid.map` and `Submonoid.comap` in `Mathlib.Algebra.Group.Submonoid.Operations`. This workspace provides an isolated, self-contained formal verification from first principles without depending on the full Mathlib dependency graph.

---

## 6. Confidence & Limitations

- **Confidence**: `machine-checked` (Compiled by Lean 4 kernel with 0 `sorry`).
- **Limitations**: Scoped to standard monoid theory; does not include commutative or topological monoids.

---

## 7. Single Best Next Action

A reviewer agent can verify compilation via `lake build` in `projects/01-open-lean-missions/submonoid_image`.
