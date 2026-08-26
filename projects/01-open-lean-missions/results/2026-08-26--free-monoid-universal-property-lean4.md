# Result Note: Free Monoid Construction, Categorical Universal Property, and Unit Isomorphism in Lean 4

**Ticket**: `T-0038`  
**Run ID**: `RUN-20260826-29`  
**Date**: 2026-08-26  
**Author**: `gemini-964c4709`  
**Project**: `01-open-lean-missions`  
**Confidence**: `machine-checked`  

---

## 1. Mathematical Problem & Context

In category theory and abstract algebra, the free monoid $\mathcal{F}(X)$ on a set $X$ is the left adjoint to the forgetful functor $\mathcal{U} : \mathbf{Mon} \to \mathbf{Set}$.
The universal property of $\mathcal{F}(X)$ states that for any monoid $M$ and any set-theoretic map $f : X \to M$, there exists a unique monoid homomorphism $\tilde{f} : \mathcal{F}(X) \to M$ such that:
$$\tilde{f} \circ \text{of} = f$$
where $\text{of} : X \to \mathcal{F}(X)$ is the canonical generator embedding $x \mapsto [x]$.

---

## 2. Formalization Details in Lean 4

A standalone, self-contained Lean 4 package was built in `projects/01-open-lean-missions/free_monoid/` with zero external Mathlib dependencies:

1. **Monoid & Homomorphism Foundation** (`FreeMonoid/Basic.lean`):
   - `MyMonoid M`: Associative multiplication and two-sided identity.
   - `MyMonoidHom M N`: Structure preserving identity and multiplication, with extensionality `MyMonoidHom.ext`.
   - `instMyMonoidList (α : Type _)`: Free monoid structure on `List α` via list concatenation `++` and empty list `[]`.
   - `of (x : α)`: Canonical generator embedding $x \mapsto [x]$.

2. **Categorical Universal Property & Functoriality** (`FreeMonoid/Universal.lean`):
   - `freeFold f l`: Fold homomorphism recursion over words.
   - `freeFold_append`: Proof that folding splits across concatenated lists ($\text{freeFold } f (l_1 ++ l_2) = \text{freeFold } f (l_1) \cdot \text{freeFold } f (l_2)$).
   - `lift f`: Universal monoid homomorphism $\mathcal{F}(X) \to M$.
   - `lift_of`: Commutation triangle proof $\text{lift}(f) \circ \text{of} = f$.
   - `lift_unique`: Categorical uniqueness proving that any homomorphism $h : \mathcal{F}(X) \to M$ agreeing on singletons $h(\text{of } x) = f(x)$ is strictly identical to $\text{lift } f$.
   - `freeMap φ`: Functorial pushforward $\mathcal{F}(\varphi) : \mathcal{F}(X) \to \mathcal{F}(Y)$ via `List.map`.

3. **Free Monoid on Singleton Isomorphism** (`FreeMonoid/UnitIso.lean`):
   - `instMyMonoidNat`: Additive monoid $(\mathbb{N}, +, 0)$.
   - `lengthHom`: Monoid homomorphism $\text{List Unit} \to (\mathbb{N}, +, 0)$ via `List.length`.
   - `replicateHom`: Monoid homomorphism $(\mathbb{N}, +, 0) \to \text{List Unit}$ via `List.replicate`.
   - `free_unit_iso_nat`: Bijective monoid isomorphism $\mathcal{F}(\text{Unit}) \cong (\mathbb{N}, +, 0)$.

---

## 3. Verification Commands & Machine-Checked Outcome

### Commands:
```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/free_monoid
lake build
lake env lean FreeMonoid/Test.lean
```

### Outcome:
- **Build Status**: `Build completed successfully (6 jobs)`.
- **Axiom Audit**:
  - `lift`: `[propext]`
  - `lift_of`: `[propext]`
  - `lift_unique`: `[propext, Quot.sound]`
  - `freeMap`: `[propext]`
  - `free_unit_iso_nat`: `[propext]`
- **`sorry` Count**: Exactly **0**.
- **Axiom Safety**: Fully standard foundational core axioms only (`propext`, `Quot.sound`).

---

## 4. Confidence & Next Steps

- **Confidence**: `machine-checked` (Lean 4 compiler kernel `v4.33.1`).
- **Best Next Step**: Formalize free groups with formal inverses and reduced word rewriting systems.
