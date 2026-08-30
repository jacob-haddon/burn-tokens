/-
Copyright (c) 2026 Jacob Haddon / Autonomous Research Observatory.
Released under Apache 2.0 license.
Authors: Jacob Haddon, Antigravity Autonomous Agent

Formalization of Residuated Posets, Quantale Adjunctions, and Invertible Residuals
(citing arXiv:2502.04561 / Galatos-Jipsen 2025).
-/

namespace ResiduatedLattice

/-- A partially ordered set with reflexive, antisymmetric, and transitive relation `≤`. -/
class PartialOrder (α : Type) where
  le : α → α → Prop
  le_refl : ∀ a : α, le a a
  le_antisymm : ∀ a b : α, le a b → le b a → a = b
  le_trans : ∀ a b c : α, le a b → le b c → le a c

instance [PartialOrder α] : LE α where
  le := PartialOrder.le

theorem le_refl [PartialOrder α] (a : α) : a ≤ a := PartialOrder.le_refl a
theorem le_antisymm [PartialOrder α] (a b : α) : a ≤ b → b ≤ a → a = b := PartialOrder.le_antisymm a b
theorem le_trans [PartialOrder α] (a b c : α) : a ≤ b → b ≤ c → a ≤ c := PartialOrder.le_trans a b c

/-- A monoid structure on a poset. -/
class Monoid (α : Type) extends PartialOrder α where
  mul : α → α → α
  one : α
  mul_assoc' : ∀ a b c : α, mul (mul a b) c = mul a (mul b c)
  one_mul' : ∀ a : α, mul one a = a
  mul_one' : ∀ a : α, mul a one = a

instance [Monoid α] : Mul α where
  mul := Monoid.mul

instance [Monoid α] : OfNat α 1 where
  ofNat := Monoid.one

theorem mul_assoc [Monoid α] (a b c : α) : (a * b) * c = a * (b * c) := Monoid.mul_assoc' a b c
theorem one_mul [Monoid α] (a : α) : (1 : α) * a = a := Monoid.one_mul' a
theorem mul_one [Monoid α] (a : α) : a * (1 : α) = a := Monoid.mul_one' a

/-- A Residuated Monoid / Residuated Poset is a partially ordered monoid
equipped with left division (`ldiv`, `\`) and right division (`rdiv`, `/`)
satisfying the Galois adjunction equivalences:
`x * y ≤ z ↔ y ≤ x \ z ↔ x ≤ z / y`. -/
class ResiduatedPoset (α : Type) extends Monoid α where
  ldiv : α → α → α
  rdiv : α → α → α
  mul_le_iff_le_ldiv' : ∀ x y z : α, mul x y ≤ z ↔ y ≤ ldiv x z
  mul_le_iff_le_rdiv' : ∀ x y z : α, mul x y ≤ z ↔ x ≤ rdiv z y

infixr:70 " \\ " => ResiduatedPoset.ldiv
infixl:70 " // " => ResiduatedPoset.rdiv

variable {L : Type} [ResiduatedPoset L]

theorem mul_le_iff_le_ldiv (x y z : L) : x * y ≤ z ↔ y ≤ x \ z :=
  ResiduatedPoset.mul_le_iff_le_ldiv' x y z

theorem mul_le_iff_le_rdiv (x y z : L) : x * y ≤ z ↔ x ≤ z // y :=
  ResiduatedPoset.mul_le_iff_le_rdiv' x y z

/- ========================================================================= -/
/- CANONICAL ADJUNCTION COUNITS & UNITS                                      -/
/- ========================================================================= -/

/-- Left counit (Modus Ponens in substructural logic): `x * (x \ z) ≤ z`. -/
theorem ldiv_counit (x z : L) : x * (x \ z) ≤ z :=
  (mul_le_iff_le_ldiv x (x \ z) z).mpr (le_refl (x \ z))

/-- Right counit: `(z // y) * y ≤ z`. -/
theorem rdiv_counit (y z : L) : (z // y) * y ≤ z :=
  (mul_le_iff_le_rdiv (z // y) y z).mpr (le_refl (z // y))

/-- Left unit: `y ≤ x \ (x * y)`. -/
theorem ldiv_unit (x y : L) : y ≤ x \ (x * y) :=
  (mul_le_iff_le_ldiv x y (x * y)).mp (le_refl (x * y))

/-- Right unit: `x ≤ (x * y) // y`. -/
theorem rdiv_unit (x y : L) : x ≤ (x * y) // y :=
  (mul_le_iff_le_rdiv x y (x * y)).mp (le_refl (x * y))

/- ========================================================================= -/
/- MONOTONICITY & VARIANCE OF RESIDUALS                                      -/
/- ========================================================================= -/

/-- Left division is covariant in the numerator: `z1 ≤ z2 → x \ z1 ≤ x \ z2`. -/
theorem ldiv_mono_right (x z1 z2 : L) (h : z1 ≤ z2) : (x \ z1) ≤ (x \ z2) := by
  have h1 : x * (x \ z1) ≤ z1 := ldiv_counit x z1
  have h2 : x * (x \ z1) ≤ z2 := le_trans (x * (x \ z1)) z1 z2 h1 h
  exact (mul_le_iff_le_ldiv x (x \ z1) z2).mp h2

/-- Left division is contravariant in the denominator: `x1 ≤ x2 → x2 \ z ≤ x1 \ z`. -/
theorem ldiv_anti_left (x1 x2 z : L) (h : x1 ≤ x2) : (x2 \ z) ≤ (x1 \ z) := by
  have h1 : x1 * (x2 \ z) ≤ x2 * (x2 \ z) := by
    have h_adj : x2 ≤ z // (x2 \ z) := (mul_le_iff_le_rdiv x2 (x2 \ z) z).mp (ldiv_counit x2 z)
    have h_le : x1 ≤ z // (x2 \ z) := le_trans x1 x2 (z // (x2 \ z)) h h_adj
    exact (mul_le_iff_le_rdiv x1 (x2 \ z) z).mpr h_le
  have h2 : x2 * (x2 \ z) ≤ z := ldiv_counit x2 z
  have h3 : x1 * (x2 \ z) ≤ z := le_trans (x1 * (x2 \ z)) (x2 * (x2 \ z)) z h1 h2
  exact (mul_le_iff_le_ldiv x1 (x2 \ z) z).mp h3

/-- Right division is covariant in the numerator: `z1 ≤ z2 → z1 // y ≤ z2 // y`. -/
theorem rdiv_mono_left (y z1 z2 : L) (h : z1 ≤ z2) : (z1 // y) ≤ (z2 // y) := by
  have h1 : (z1 // y) * y ≤ z1 := rdiv_counit y z1
  have h2 : (z1 // y) * y ≤ z2 := le_trans ((z1 // y) * y) z1 z2 h1 h
  exact (mul_le_iff_le_rdiv (z1 // y) y z2).mp h2

/-- Right division is contravariant in the denominator: `y1 ≤ y2 → z // y2 ≤ z // y1`. -/
theorem rdiv_anti_right (y1 y2 z : L) (h : y1 ≤ y2) : (z // y2) ≤ (z // y1) := by
  have h1 : (z // y2) * y1 ≤ (z // y2) * y2 := by
    have h_adj : y2 ≤ (z // y2) \ z := (mul_le_iff_le_ldiv (z // y2) y2 z).mp (rdiv_counit y2 z)
    have h_le : y1 ≤ (z // y2) \ z := le_trans y1 y2 ((z // y2) \ z) h h_adj
    exact (mul_le_iff_le_ldiv (z // y2) y1 z).mpr h_le
  have h2 : (z // y2) * y2 ≤ z := rdiv_counit y2 z
  have h3 : (z // y2) * y1 ≤ z := le_trans ((z // y2) * y1) ((z // y2) * y2) z h1 h2
  exact (mul_le_iff_le_rdiv (z // y2) y1 z).mp h3

/- ========================================================================= -/
/- RESIDUAL IDEMPOTENCE & CLOSURE LAWS                                       -/
/- ========================================================================= -/

/-- Closure idempotence for left division: `x \ (x * (x \ z)) = x \ z`. -/
theorem ldiv_closure_idempotent (x z : L) : x \ (x * (x \ z)) = x \ z := by
  apply le_antisymm
  · exact ldiv_mono_right x (x * (x \ z)) z (ldiv_counit x z)
  · exact ldiv_unit x (x \ z)

/-- Closure idempotence for right division: `((z // y) * y) // y = z // y`. -/
theorem rdiv_closure_idempotent (y z : L) : ((z // y) * y) // y = z // y := by
  apply le_antisymm
  · exact rdiv_mono_left y ((z // y) * y) z (rdiv_counit y z)
  · exact rdiv_unit (z // y) y

/- ========================================================================= -/
/- RESIDUAL ASSOCIATIVITY & IDENTITY LAWS                                    -/
/- ========================================================================= -/

/-- Associativity of residuals: `(x \ y) // z = x \ (y // z)`. -/
theorem residual_associativity (x y z : L) : (x \ y) // z = x \ (y // z) := by
  apply le_antisymm
  · -- (x \ y) // z ≤ x \ (y // z) ↔ x * ((x \ y) // z) ≤ y // z ↔ (x * ((x \ y) // z)) * z ≤ y
    rw [← mul_le_iff_le_ldiv, ← mul_le_iff_le_rdiv]
    rw [mul_assoc]
    have h1 : x * (x \ y) ≤ y := ldiv_counit x y
    have h2 : ((x \ y) // z) * z ≤ x \ y := rdiv_counit z (x \ y)
    have h3 : x * (((x \ y) // z) * z) ≤ x * (x \ y) := by
      have h_adj : ((x \ y) // z) * z ≤ x \ y := h2
      have h_mul : x * (((x \ y) // z) * z) ≤ x * (x \ y) := by
        have h_sub : ((x \ y) // z) * z ≤ x \ (x * (x \ y)) :=
          le_trans (((x \ y) // z) * z) (x \ y) (x \ (x * (x \ y))) h2 (ldiv_unit x (x \ y))
        exact (mul_le_iff_le_ldiv x (((x \ y) // z) * z) (x * (x \ y))).mpr h_sub
      exact h_mul
    exact le_trans (x * (((x \ y) // z) * z)) (x * (x \ y)) y h3 h1
  · -- x \ (y // z) ≤ (x \ y) // z ↔ (x \ (y // z)) * z ≤ x \ y ↔ x * ((x \ (y // z)) * z) ≤ y
    rw [← mul_le_iff_le_rdiv, ← mul_le_iff_le_ldiv]
    rw [← mul_assoc]
    have h1 : (x * (x \ (y // z))) * z ≤ (y // z) * z := by
      have h_counit : x * (x \ (y // z)) ≤ y // z := ldiv_counit x (y // z)
      have h_sub : x * (x \ (y // z)) ≤ ((y // z) * z) // z :=
        le_trans (x * (x \ (y // z))) (y // z) (((y // z) * z) // z) h_counit (rdiv_unit (y // z) z)
      exact (mul_le_iff_le_rdiv (x * (x \ (y // z))) z ((y // z) * z)).mpr h_sub
    have h2 : (y // z) * z ≤ y := rdiv_counit z y
    exact le_trans ((x * (x \ (y // z))) * z) ((y // z) * z) y h1 h2

/-- Left identity law for division: `(1 \ x) = x`. -/
theorem one_ldiv (x : L) : ((1 : L) \ x) = x := by
  apply le_antisymm
  · have h : (1 : L) * ((1 : L) \ x) ≤ x := ldiv_counit 1 x
    rw [one_mul] at h
    exact h
  · have h : x ≤ (1 : L) \ ((1 : L) * x) := ldiv_unit 1 x
    rw [one_mul] at h
    exact h

/-- Right identity law for division: `(x // 1) = x`. -/
theorem rdiv_one (x : L) : (x // (1 : L)) = x := by
  apply le_antisymm
  · have h : (x // (1 : L)) * 1 ≤ x := rdiv_counit 1 x
    rw [mul_one] at h
    exact h
  · have h : x ≤ (x * 1) // (1 : L) := rdiv_unit x 1
    rw [mul_one] at h
    exact h

/- ========================================================================= -/
/- INVERTIBLE ELEMENTS: RESIDUALS COINCIDE WITH GROUP MULTIPLICATION         -/
/- ========================================================================= -/

/-- If `x` has a two-sided inverse `x_inv` (`x * x_inv = 1` and `x_inv * x = 1`),
then left division by `x` coincides with multiplication by `x_inv`: `x \ z = x_inv * z`. -/
theorem invertible_ldiv (x x_inv z : L) (h1 : x * x_inv = 1) (h2 : x_inv * x = 1) :
    (x \ z) = x_inv * z := by
  apply le_antisymm
  · -- x \ z ≤ x_inv * z ↔ x * (x \ z) ≤ z
    have h_counit : x * (x \ z) ≤ z := ldiv_counit x z
    have h_mono : x_inv * (x * (x \ z)) ≤ x_inv * z := by
      have h_sub : x * (x \ z) ≤ x_inv \ (x_inv * z) :=
        le_trans (x * (x \ z)) z (x_inv \ (x_inv * z)) h_counit (ldiv_unit x_inv z)
      exact (mul_le_iff_le_ldiv x_inv (x * (x \ z)) (x_inv * z)).mpr h_sub
    rw [← mul_assoc, h2, one_mul] at h_mono
    exact h_mono
  · -- x_inv * z ≤ x \ z ↔ x * (x_inv * z) ≤ z
    rw [← mul_le_iff_le_ldiv, mul_assoc, h1, one_mul]

/-- If `x` has a two-sided inverse `x_inv`,
then right division by `x` coincides with multiplication by `x_inv`: `z // x = z * x_inv`. -/
theorem invertible_rdiv (x x_inv z : L) (h1 : x * x_inv = 1) (h2 : x_inv * x = 1) :
    (z // x) = z * x_inv := by
  apply le_antisymm
  · -- z // x ≤ z * x_inv ↔ (z // x) * x ≤ z
    have h_counit : (z // x) * x ≤ z := rdiv_counit x z
    have h_mono : ((z // x) * x) * x_inv ≤ z * x_inv := by
      have h_sub : (z // x) * x ≤ (z * x_inv) // x_inv :=
        le_trans ((z // x) * x) z ((z * x_inv) // x_inv) h_counit (rdiv_unit z x_inv)
      exact (mul_le_iff_le_rdiv ((z // x) * x) x_inv (z * x_inv)).mpr h_sub
    rw [mul_assoc, h1, mul_one] at h_mono
    exact h_mono
  · -- z * x_inv ≤ z // x ↔ (z * x_inv) * x ≤ z
    rw [← mul_le_iff_le_rdiv, ← mul_assoc, h2, mul_one]

end ResiduatedLattice
