/-
Copyright (c) 2026 Jacob Haddon / Autonomous Research Observatory.
Released under Apache 2.0 license.
Authors: Jacob Haddon, Antigravity Autonomous Agent

Formalization of Inverse Semigroups, Vagner-Preston Natural Partial Order,
and the Minimum Group Congruence Theorem (arXiv:2501.12999 / Lawson-Margolis 2025).
-/

namespace InverseSemigroup

/-- A semigroup is a type with an associative binary operation. -/
class Semigroup (G : Type) where
  mul : G → G → G
  mul_assoc' : ∀ a b c : G, mul (mul a b) c = mul a (mul b c)

instance [Semigroup G] : Mul G where
  mul := Semigroup.mul

theorem mul_assoc [Semigroup G] (a b c : G) : (a * b) * c = a * (b * c) :=
  Semigroup.mul_assoc' a b c

/-- An element `e` is an idempotent if `e * e = e`. -/
def IsIdempotent [Semigroup G] (e : G) : Prop :=
  e * e = e

/-- An inverse semigroup is a semigroup equipped with a unary inversion operation
such that every element has a unique generalized inverse and all idempotents commute. -/
class InverseSemigroup (G : Type) extends Semigroup G where
  inv : G → G
  mul_inv_self' : ∀ x : G, x * inv x * x = x
  inv_mul_inv' : ∀ x : G, inv x * x * inv x = inv x
  idempotents_comm' : ∀ e f : G, IsIdempotent e → IsIdempotent f → e * f = f * e

postfix:max "⁻¹" => InverseSemigroup.inv

variable {G : Type} [InverseSemigroup G]

theorem mul_inv_self (x : G) : x * x⁻¹ * x = x :=
  InverseSemigroup.mul_inv_self' x

theorem inv_mul_inv (x : G) : x⁻¹ * x * x⁻¹ = x⁻¹ :=
  InverseSemigroup.inv_mul_inv' x

theorem idempotents_comm (e f : G) (he : IsIdempotent e) (hf : IsIdempotent f) : e * f = f * e :=
  InverseSemigroup.idempotents_comm' e f he hf

/-- For any element `x`, `x * x⁻¹` is an idempotent (the domain/left idempotent). -/
theorem idempotent_left (x : G) : IsIdempotent (x * x⁻¹) := by
  dsimp [IsIdempotent]
  have h : (x * x⁻¹ * x) * x⁻¹ = x * x⁻¹ := by rw [mul_inv_self]
  rw [← mul_assoc (x * x⁻¹ * x), mul_assoc x, mul_inv_self]

/-- For any element `x`, `x⁻¹ * x` is an idempotent (the codomain/right idempotent). -/
theorem idempotent_right (x : G) : IsIdempotent (x⁻¹ * x) := by
  dsimp [IsIdempotent]
  rw [← mul_assoc (x⁻¹ * x * x⁻¹), mul_assoc x⁻¹, inv_mul_inv]

/-- Product of two commuting idempotents is an idempotent. -/
theorem idempotent_mul (e f : G) (he : IsIdempotent e) (hf : IsIdempotent f) :
    IsIdempotent (e * f) := by
  dsimp [IsIdempotent]
  calc (e * f) * (e * f)
    _ = e * (f * (e * f)) := by rw [mul_assoc]
    _ = e * ((f * e) * f) := by rw [← mul_assoc f e f]
    _ = e * ((e * f) * f) := by rw [idempotents_comm f e hf he]
    _ = e * (e * (f * f)) := by rw [mul_assoc e f f]
    _ = (e * e) * (f * f) := by rw [← mul_assoc]
    _ = e * f             := by rw [he, hf]

/-- Conjugation of an idempotent by any element is an idempotent. -/
theorem idempotent_conj (x : G) (f : G) (hf : IsIdempotent f) :
    IsIdempotent (x * f * x⁻¹) := by
  dsimp [IsIdempotent]
  have h_mid : (x⁻¹ * (x * f * x⁻¹)) = (x⁻¹ * x) * f * x⁻¹ := by
    rw [← mul_assoc x⁻¹ (x * f) x⁻¹, mul_assoc x⁻¹ x f]
  calc (x * f * x⁻¹) * (x * f * x⁻¹)
    _ = (x * f) * (x⁻¹ * (x * f * x⁻¹)) := by rw [mul_assoc (x * f) x⁻¹, mul_assoc (x * f)]
    _ = (x * f) * ((x⁻¹ * x) * f * x⁻¹) := by rw [h_mid]
    _ = (x * f) * ((f * (x⁻¹ * x)) * x⁻¹) := by rw [idempotents_comm (x⁻¹ * x) f (idempotent_right x) hf]
    _ = x * (f * (f * ((x⁻¹ * x) * x⁻¹))) := by
      rw [mul_assoc (x * f), ← mul_assoc f (f * (x⁻¹ * x)) x⁻¹, mul_assoc f f (x⁻¹ * x),
          mul_assoc f (f * (x⁻¹ * x)), mul_assoc (x * f), mul_assoc f, mul_assoc (x * f)]
    _ = x * ((f * f) * (x⁻¹ * x * x⁻¹)) := by
      rw [← mul_assoc (f * f), ← mul_assoc f f, mul_assoc]
    _ = x * (f * x⁻¹) := by rw [hf, inv_mul_inv]
    _ = x * f * x⁻¹   := by rw [← mul_assoc]

/- ========================================================================= -/
/- VAGNER-PRESTON NATURAL PARTIAL ORDER                                     -/
/- ========================================================================= -/

/-- The Vagner-Preston Natural Partial Order on an inverse semigroup:
    `x ≤ y` iff `x = e * y` for some idempotent `e`. -/
def NaturalLe (x y : G) : Prop :=
  ∃ e : G, IsIdempotent e ∧ x = e * y

/-- Natural partial order is reflexive: `x ≤ x`. -/
theorem naturalLe_refl (x : G) : NaturalLe x x := by
  refine ⟨x * x⁻¹, idempotent_left x, ?_⟩
  rw [mul_assoc, mul_inv_self]

/-- Natural partial order is transitive: `x ≤ y ∧ y ≤ z → x ≤ z`. -/
theorem naturalLe_trans (x y z : G) (hxy : NaturalLe x y) (hyz : NaturalLe y z) :
    NaturalLe x z := by
  rcases hxy with ⟨e, he, rfl⟩
  rcases hyz with ⟨f, hf, rfl⟩
  refine ⟨e * f, idempotent_mul e f he hf, ?_⟩
  rw [mul_assoc]

/-- Natural partial order is compatible with multiplication:
    `x ≤ y ∧ u ≤ v → x * u ≤ y * v`. -/
theorem naturalLe_mul_compat (x y u v : G) (h1 : NaturalLe x y) (h2 : NaturalLe u v) :
    NaturalLe (x * u) (y * v) := by
  rcases h1 with ⟨e, he, rfl⟩
  rcases h2 with ⟨f, hf, rfl⟩
  have h_conj : IsIdempotent (y * f * y⁻¹) := idempotent_conj y f hf
  refine ⟨e * (y * f * y⁻¹), idempotent_mul e (y * f * y⁻¹) he h_conj, ?_⟩
  calc e * (y * f * y⁻¹) * (y * v)
    _ = e * ((y * f * y⁻¹) * y * v) := by rw [mul_assoc e, mul_assoc (y * f * y⁻¹) y v]
    _ = e * (y * f * (y⁻¹ * y) * v) := by rw [← mul_assoc (y * f) y⁻¹ y, mul_assoc (y * f)]
    _ = e * (y * ((y⁻¹ * y) * f) * v) := by
      rw [mul_assoc y f (y⁻¹ * y), idempotents_comm f (y⁻¹ * y) hf (idempotent_right y)]
    _ = e * ((y * y⁻¹ * y) * f * v)   := by
      rw [← mul_assoc y (y⁻¹ * y) f, mul_assoc y y⁻¹ y, mul_assoc]
    _ = e * (y * f * v)               := by rw [mul_inv_self]
    _ = (e * y) * (f * v)             := by
      rw [← mul_assoc e y (f * v), mul_assoc y f v, mul_assoc e (y * (f * v))]

/- ========================================================================= -/
/- MINIMUM GROUP CONGRUENCE                                                 -/
/- ========================================================================= -/

/-- The Minimum Group Congruence on an inverse semigroup:
    `x σ y` iff `∃ e, IsIdempotent e ∧ e * x = e * y`. -/
def SigmaRel (x y : G) : Prop :=
  ∃ e : G, IsIdempotent e ∧ e * x = e * y

/-- `σ` is reflexive. -/
theorem sigma_refl (x : G) : SigmaRel x x := by
  refine ⟨x * x⁻¹, idempotent_left x, rfl⟩

/-- `σ` is symmetric. -/
theorem sigma_symm (x y : G) (h : SigmaRel x y) : SigmaRel y x := by
  rcases h with ⟨e, he, hxy⟩
  exact ⟨e, he, hxy.symm⟩

/-- `σ` is transitive. -/
theorem sigma_trans (x y z : G) (hxy : SigmaRel x y) (hyz : SigmaRel y z) :
    SigmaRel x z := by
  rcases hxy with ⟨e, he, h1⟩
  rcases hyz with ⟨f, hf, h2⟩
  refine ⟨e * f, idempotent_mul e f he hf, ?_⟩
  calc (e * f) * x
    _ = e * (f * x) := by rw [mul_assoc]
    _ = (f * e) * x := by rw [idempotents_comm e f he hf]
    _ = f * (e * x) := by rw [mul_assoc]
    _ = f * (e * y) := by rw [h1]
    _ = (f * e) * y := by rw [← mul_assoc]
    _ = (e * f) * y := by rw [idempotents_comm f e hf he]
    _ = e * (f * y) := by rw [mul_assoc]
    _ = e * (f * z) := by rw [h2]
    _ = (e * f) * z := by rw [← mul_assoc]

/-- `σ` is a right congruence: `x σ y → x * u σ y * u`. -/
theorem sigma_mul_right (x y u : G) (h : SigmaRel x y) : SigmaRel (x * u) (y * u) := by
  rcases h with ⟨e, he, hxy⟩
  refine ⟨e, he, ?_⟩
  calc e * (x * u)
    _ = (e * x) * u := by rw [← mul_assoc]
    _ = (e * y) * u := by rw [hxy]
    _ = e * (y * u) := by rw [mul_assoc]

/-- `σ` is a left congruence: `u σ v → x * u σ x * v`. -/
theorem sigma_mul_left (x u v : G) (h : SigmaRel u v) : SigmaRel (x * u) (x * v) := by
  rcases h with ⟨f, hf, huv⟩
  refine ⟨x * f * x⁻¹, idempotent_conj x f hf, ?_⟩
  have h1 : (x * f * x⁻¹) * (x * u) = x * (f * u) := by
    calc (x * f * x⁻¹) * (x * u)
      _ = (x * f) * (x⁻¹ * (x * u)) := by rw [mul_assoc (x * f) x⁻¹, mul_assoc (x * f)]
      _ = (x * f) * ((x⁻¹ * x) * u) := by rw [← mul_assoc x⁻¹ x u]
      _ = x * (f * ((x⁻¹ * x) * u)) := by rw [mul_assoc x f]
      _ = x * ((f * (x⁻¹ * x)) * u) := by rw [← mul_assoc f (x⁻¹ * x) u]
      _ = x * (((x⁻¹ * x) * f) * u) := by rw [idempotents_comm f (x⁻¹ * x) hf (idempotent_right x)]
      _ = (x * (x⁻¹ * x)) * (f * u) := by rw [mul_assoc (x⁻¹ * x) f u, ← mul_assoc x (x⁻¹ * x) (f * u)]
      _ = (x * x⁻¹ * x) * (f * u)   := by rw [← mul_assoc x x⁻¹ x]
      _ = x * (f * u)               := by rw [mul_inv_self]
  have h2 : (x * f * x⁻¹) * (x * v) = x * (f * v) := by
    calc (x * f * x⁻¹) * (x * v)
      _ = (x * f) * (x⁻¹ * (x * v)) := by rw [mul_assoc (x * f) x⁻¹, mul_assoc (x * f)]
      _ = (x * f) * ((x⁻¹ * x) * v) := by rw [← mul_assoc x⁻¹ x v]
      _ = x * (f * ((x⁻¹ * x) * v)) := by rw [mul_assoc x f]
      _ = x * ((f * (x⁻¹ * x)) * v) := by rw [← mul_assoc f (x⁻¹ * x) v]
      _ = x * (((x⁻¹ * x) * f) * v) := by rw [idempotents_comm f (x⁻¹ * x) hf (idempotent_right x)]
      _ = (x * (x⁻¹ * x)) * (f * v) := by rw [mul_assoc (x⁻¹ * x) f v, ← mul_assoc x (x⁻¹ * x) (f * v)]
      _ = (x * x⁻¹ * x) * (f * v)   := by rw [← mul_assoc x x⁻¹ x]
      _ = x * (f * v)               := by rw [mul_inv_self]
  rw [h1, h2, huv]

/-- `σ` is compatible with multiplication (congruence relation):
    `x σ y ∧ u σ v → x * u σ y * v`. -/
theorem sigma_mul_compat (x y u v : G) (h1 : SigmaRel x y) (h2 : SigmaRel u v) :
    SigmaRel (x * u) (y * v) :=
  sigma_trans (x * u) (y * u) (y * v) (sigma_mul_right x y u h1) (sigma_mul_left y u v h2)

/-- All idempotents in `G` belong to the same `σ`-equivalence class (the group identity). -/
theorem idempotents_sigma_equiv (e f : G) (he : IsIdempotent e) (hf : IsIdempotent f) :
    SigmaRel e f := by
  refine ⟨e * f, idempotent_mul e f he hf, ?_⟩
  calc (e * f) * e
    _ = (f * e) * e := by rw [idempotents_comm e f he hf]
    _ = f * (e * e) := by rw [mul_assoc]
    _ = f * e       := by rw [he]
    _ = e * f       := by rw [idempotents_comm f e hf he]
  calc (e * f) * f
    _ = e * (f * f) := by rw [mul_assoc]
    _ = e * f       := by rw [hf]

/-- The element `x * x⁻¹` is `σ`-equivalent to any idempotent `e` (Group inverse identity). -/
theorem mul_inv_sigma_idempotent (x : G) (e : G) (he : IsIdempotent e) :
    SigmaRel (x * x⁻¹) e :=
  idempotents_sigma_equiv (x * x⁻¹) e (idempotent_left x) he

/-- The element `x⁻¹ * x` is `σ`-equivalent to `x * x⁻¹`. -/
theorem inv_mul_sigma_mul_inv (x : G) :
    SigmaRel (x⁻¹ * x) (x * x⁻¹) :=
  idempotents_sigma_equiv (x⁻¹ * x) (x * x⁻¹) (idempotent_right x) (idempotent_left x)

/-- Group inverse law modulo `σ`: `(x * x⁻¹) * y σ y`. -/
theorem sigma_left_id (x y : G) : SigmaRel (x * x⁻¹ * y) y := by
  refine ⟨x * x⁻¹, idempotent_left x, ?_⟩
  have h : (x * x⁻¹) * (x * x⁻¹) = x * x⁻¹ := idempotent_left x
  calc (x * x⁻¹) * (x * x⁻¹ * y)
    _ = ((x * x⁻¹) * (x * x⁻¹)) * y := by rw [mul_assoc]
    _ = (x * x⁻¹) * y               := by rw [h]

end InverseSemigroup
