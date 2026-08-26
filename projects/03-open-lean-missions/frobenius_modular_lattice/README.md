# 📜 Frobenius Reciprocity, Modular Galois Connections, and Lattice Isomorphisms in Lean 4

Standalone, first-principles machine-checked Lean 4 formalization of the structural connections between **Frobenius Reciprocity**, **Modular Galois Connections**, and **Lattice Isomorphism Theorems** based on Goswami, Janelidze, and Manuell (*Applied Categorical Structures*, 2025; [arXiv:2502.06010](https://arxiv.org/abs/2502.06010)).

Proved from first principles with **0 `sorry`** declarations and **0 external Mathlib dependencies**.

---

## 🔬 Mathematical Frontier & Formalized Theory

This package formalizes the unified framework established in Goswami-Janelidze-Manuell (2025), linking Lawvere's doctrine theory, Grandis's projective homological algebra, and Dilworth's abstract ideal theory:

1. **Lattice Axiomatization & Order Theory**:
   - Meet semi-lattices, join semi-lattices, bounded lattices (`BoundedLattice`), modular lattices (`ModularLattice`), and distributive lattices (`DistributiveLattice`).
   - Fundamental order properties: reflexivity, antisymmetry, transitivity, absorption, idempotence, monotonicity of `⊓` and `⊔`.

2. **Galois Connections (Adjunctions)**:
   - For lattices $L_1, L_2$, monotone adjoint maps $f \dashv g$ satisfying $f(a) \le b \iff a \le g(b)$.
   - Unit ($a \le g(f(a))$) and counit ($f(g(b)) \le b$) identities.
   - Monotonicity of adjoints: $a \le b \implies f(a) \le f(b)$ and $c \le d \implies g(c) \le g(d)$.
   - Closure idempotence: $f(g(f(a))) = f(a)$ and $g(f(g(b))) = g(b)$.
   - Categorical preservation: $f$ preserves binary joins and bottom element ($\bot$); $g$ preserves binary meets and top element ($\top$).
   - General adjunction inequalities: $f(a \wedge g(b)) \le f(a) \wedge b$ and $a \vee g(b) \le g(f(a) \vee b)$.

3. **Lawvere Frobenius Reciprocity (LF0)**:
   - Formulation: $f(a \wedge g(b)) = f(a) \wedge b$ for all $a \in L_1, b \in L_2$.
   - **Theorem 7**: Equivalence of Frobenius reciprocity (LF0) with the down-closed direct image condition (LF1: $\forall c \le f(b), \exists a \le b, c = f(a)$).
   - Specialization to Grandis lower modularity (LM0: $f(g(y)) = y \wedge f(\top)$).

4. **Grandis Modular Connections (RF0)**:
   - Formulation: $g(f(a) \vee b) = a \vee g(b)$ for all $a \in L_1, b \in L_2$.
   - **Theorem 8**: Equivalence of modular connection (RF0) with the up-closed direct image condition (RF1: $\forall b \ge g(c), \exists d \ge c, b = g(d)$).
   - Specialization to Grandis upper modularity (RM0: $g(f(x)) = x \vee g(\bot)$).

5. **Grandis Characterization Theorems (Theorems 3, 4, 5, 6)**:
   - **Theorem 3 (LM Equivalence)**: Equivalence of LM0, LM2 ($f(g(c)) = c \wedge f(g(d))$ for $c \le d$), and LM3 ($f(g(c \wedge d)) = c \wedge f(g(d))$).
   - **Theorem 4 (RM Equivalence)**: Equivalence of RM0, RM2 ($g(f(b)) = b \vee g(f(a))$ for $a \le b$), and RM3 ($g(f(a \vee b)) = a \vee g(f(b))$).
   - **Theorem 5 (RM Fiber Equivalence)**: Equivalence of RM0, RM4 ($f(a) = f(b) \implies a \vee g(\bot) = b \vee g(\bot)$), and RM5 ($f(a) \le f(b) \implies a \le b \vee g(\bot)$).
   - **Theorem 6 (LM Fiber Equivalence)**: Equivalence of LM0, LM4 ($g(c) = g(d) \implies c \wedge f(\top) = d \wedge f(\top)$), and LM5 ($g(c) \le g(d) \implies c \wedge f(\top) \le d$).

6. **Interval Sublattices & Lattice Isomorphism Theorems**:
   - Sublattice structure on intervals $[l, u] = \{ x \mid l \le x \le u \}$ inherits `Lattice`, `ModularLattice`, and `BoundedLattice` properties.
   - **Dedekind Diamond Isomorphism Theorem**: For any modular lattice, $[a \wedge b, b] \cong [a, a \vee b]$ via mutually inverse order isomorphisms $\phi(x) = x \vee a$ and $\psi(y) = y \wedge b$.
   - **Galois Interval Isomorphism Theorem**: For any modular Galois connection satisfying Frobenius reciprocity and interval retraction, $f$ and $g$ induce an order isomorphism $[a \wedge g(b), g(b)] \cong [f(a) \wedge b, b]$.

---

## 📋 Formal Declaration Index

### Classes & Structures
- `class Lattice (α : Type u)`
- `class BoundedLattice (α : Type u) extends Lattice α`
- `class ModularLattice (α : Type u) extends Lattice α`
- `class DistributiveLattice (α : Type u) extends Lattice α`
- `structure GaloisConnection (f : α → β) (g : β → α) : Prop`
- `structure Interval (l u : α)`
- `structure OrderIso (α β : Type*)`

### Definitions
- `def le (a b : α) : Prop`
- `def Monotone (f : α → β) : Prop`
- `def FrobeniusReciprocity (f : α → β) (g : β → α) : Prop`
- `def ModularConnection (f : α → β) (g : β → α) : Prop`
- `def DownClosedImage (f : α → β) : Prop`
- `def UpClosedImage (g : β → α) : Prop`
- `def GrandisLM0 / GrandisLM2 / GrandisLM3 / GrandisLM4 / GrandisLM5`
- `def GrandisRM0 / GrandisRM2 / GrandisRM3 / GrandisRM4 / GrandisRM5`
- `def Interval.meet / Interval.join / Interval.bounded`
- `def OrderIso.symm / OrderIso.refl / OrderIso.trans`
- `def dedekind_diamond_isomorphism`
- `def galois_interval_isomorphism`

### Verified Theorems (0 `sorry`, 0 custom axioms)
- `theorem le_refl`, `theorem le_antisymm`, `theorem le_trans`
- `theorem le_iff_join_eq`, `theorem meet_le_left`, `theorem meet_le_right`, `theorem le_meet`
- `theorem left_le_join`, `theorem right_le_join`, `theorem join_le`
- `theorem meet_mono`, `theorem join_mono`
- `theorem bot_le`, `theorem le_top`, `theorem bot_meet`, `theorem meet_bot`, `theorem top_join`, `theorem join_top`, `theorem bot_join`, `theorem join_bot`, `theorem top_meet`, `theorem meet_top`
- `theorem gc_unit`, `theorem gc_counit`
- `theorem gc_monotone_lower`, `theorem gc_monotone_upper`
- `theorem gc_closure_idempotent_lower`, `theorem gc_closure_idempotent_upper`
- `theorem gc_preserves_join`, `theorem gc_preserves_meet`
- `theorem gc_preserves_bot`, `theorem gc_preserves_top`
- `theorem gc_frobenius_le`, `theorem gc_modular_le`
- `theorem frobenius_iff_down_closed` (Goswami-Janelidze-Manuell Thm 7)
- `theorem modular_connection_iff_up_closed` (Goswami-Janelidze-Manuell Thm 8)
- `theorem frobenius_implies_lm0`, `theorem modular_connection_implies_rm0`
- `theorem lm3_implies_lm2`, `theorem lm2_implies_lm0`, `theorem lm0_implies_lm3` (Thm 3)
- `theorem rm3_implies_rm2`, `theorem rm2_implies_rm0`, `theorem rm0_implies_rm3` (Thm 4)
- `theorem rm0_implies_rm5`, `theorem rm5_implies_rm4`, `theorem rm4_implies_rm0` (Thm 5)
- `theorem lm0_implies_lm5`, `theorem lm5_implies_lm4`, `theorem lm4_implies_lm0` (Thm 6)
- `theorem interval_ext`, `theorem interval_le_iff`
- `theorem OrderIso.toFun_mono`, `theorem OrderIso.invFun_mono`, `theorem OrderIso.map_meet`, `theorem OrderIso.map_join`

---

## 🛠️ Verification & Build Instructions

Compile and verify clean build with:

```bash
# Build the package
lake build

# Inspect axioms and ensure zero axioms beyond core Lean
lake env lean FrobeniusModularLattice/Test.lean
```

---

## 📚 References
- Amartya Goswami, Zurab Janelidze, Graham Manuell. *Lawvere's Frobenius reciprocity, the modular connections of Grandis and Dilworth's abstract principal ideals*. *Applied Categorical Structures*, 33(16), 2025. [arXiv:2502.06010](https://arxiv.org/abs/2502.06010).
- Marco Grandis. *Homological Algebra: The interplay of homology with distributive lattices and orthodox semigroups*. World Scientific, 2012.
- F. William Lawvere. *Equality in hyperdoctrines and comprehension schema as an adjoint functor*. In *Applications of Categorical Logic*, Proc. Sympos. Pure Math., XVII, AMS, 1970.
- Richard P. Dilworth. *Abstract commutative ideal theory*. *Pacific Journal of Mathematics*, 12(2):481–498, 1962.
