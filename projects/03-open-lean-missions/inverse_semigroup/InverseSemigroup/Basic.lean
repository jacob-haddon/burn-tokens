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
  rw [← mul_assoc (x * x⁻¹) x x⁻¹, mul_inv_self]

/-- For any element `x`, `x⁻¹ * x` is an idempotent (the codomain/right idempotent). -/
theorem idempotent_right (x : G) : IsIdempotent (x⁻¹ * x) := by
  dsimp [IsIdempotent]
  rw [← mul_assoc (x⁻¹ * x) x⁻¹ x, inv_mul_inv]

/-- Product of two commuting idempotents is an idempotent. -/
theorem idempotent_mul (e f : G) (he : IsIdempotent e) (hf : IsIdempotent f) :
    IsIdempotent (e * f) := by
  dsimp [IsIdempotent]
  have h1 : (e * f) * (e * f) = e * (f * (e * f)) := mul_assoc e f (e * f)
  have h2 : f * (e * f) = (f * e) * f := (mul_assoc f e f).symm
  have h3 : f * e = e * f := idempotents_comm f e hf he
  have h4 : (e * f) * f = e * (f * f) := mul_assoc e f f
  rw [h1, h2, h3, h4, hf, ← mul_assoc, he]

/-- Conjugation of an idempotent by any element is an idempotent. -/
theorem idempotent_conj (x : G) (f : G) (hf : IsIdempotent f) :
    IsIdempotent (x * f * x⁻¹) := by
  dsimp [IsIdempotent]
  have hcomm : f * (x⁻¹ * x) = (x⁻¹ * x) * f :=
    idempotents_comm f (x⁻¹ * x) hf (idempotent_right x)
  have h0 : (x * f * x⁻¹) * (x * f * x⁻¹) = (x * f * x⁻¹) * (x * (f * x⁻¹)) := by
    rw [mul_assoc x f x⁻¹]
  calc (x * f * x⁻¹) * (x * f * x⁻¹)
    _ = (x * f * x⁻¹) * (x * (f * x⁻¹)) := h0
    _ = (x * f * x⁻¹ * x) * (f * x⁻¹) := (mul_assoc (x * f * x⁻¹) x (f * x⁻¹)).symm
    _ = (x * f * (x⁻¹ * x)) * (f * x⁻¹) := by rw [mul_assoc (x * f) x⁻¹ x]
    _ = (x * (f * (x⁻¹ * x))) * (f * x⁻¹) := by rw [mul_assoc x f (x⁻¹ * x)]
    _ = (x * ((x⁻¹ * x) * f)) * (f * x⁻¹) := by rw [hcomm]
    _ = ((x * (x⁻¹ * x)) * f) * (f * x⁻¹) := by rw [← mul_assoc x (x⁻¹ * x) f]
    _ = ((x * x⁻¹ * x) * f) * (f * x⁻¹)   := by rw [← mul_assoc x x⁻¹ x]
    _ = (x * f) * (f * x⁻¹)               := by rw [mul_inv_self]
    _ = x * (f * (f * x⁻¹))               := mul_assoc x f (f * x⁻¹)
    _ = x * ((f * f) * x⁻¹)               := by rw [← mul_assoc f f x⁻¹]
    _ = x * (f * x⁻¹)                     := by rw [hf]
    _ = x * f * x⁻¹                       := (mul_assoc x f x⁻¹).symm

/- ========================================================================= -/
/- VAGNER-PRESTON NATURAL PARTIAL ORDER                                     -/
/- ========================================================================= -/

/-- The Vagner-Preston Natural Partial Order on an inverse semigroup:
    `x ≤ y` iff `x = e * y` for some idempotent `e`. -/
def NaturalLe (x y : G) : Prop :=
  ∃ e : G, IsIdempotent e ∧ x = e * y

/-- Natural partial order is reflexive: `x ≤ x`. -/
theorem naturalLe_refl (x : G) : NaturalLe x x :=
  ⟨x * x⁻¹, idempotent_left x, (mul_inv_self x).symm⟩

/-- Natural partial order is transitive: `x ≤ y ∧ y ≤ z → x ≤ z`. -/
theorem naturalLe_trans (x y z : G) (hxy : NaturalLe x y) (hyz : NaturalLe y z) :
    NaturalLe x z := by
  rcases hxy with ⟨e, he, rfl⟩
  rcases h2 with ⟨f, hf, rfl⟩
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
  have hcomm : f * (y⁻¹ * y) = (y⁻¹ * y) * f :=
    idempotents_comm f (y⁻¹ * y) hf (idempotent_right y)
  have hmid : (y * f * y⁻¹) * y = y * f := by
    calc (y * f * y⁻¹) * y
      _ = (y * f) * (y⁻¹ * y) := mul_assoc (y * f) y⁻¹ y
      _ = y * (f * (y⁻¹ * y)) := mul_assoc y f (y⁻¹ * y)
      _ = y * ((y⁻¹ * y) * f) := by rw [hcomm]
      _ = (y * (y⁻¹ * y)) * f := (mul_assoc y (y⁻¹ * y) f).symm
      _ = (y * y⁻¹ * y) * f   := by rw [← mul_assoc y y⁻¹ y]
      _ = y * f               := by rw [mul_inv_self]
  have h_mid : e * (y * f * y⁻¹) * (y * v) = (e * y) * (f * v) := by
    calc e * (y * f * y⁻¹) * (y * v)
      _ = e * ((y * f * y⁻¹) * (y * v)) := mul_assoc e (y * f * y⁻¹) (y * v)
      _ = e * (((y * f * y⁻¹) * y) * v) := by rw [← mul_assoc (y * f * y⁻¹) y v]
      _ = e * ((y * f) * v)             := by rw [hmid]
      _ = (e * y) * (f * v)             := by
        rw [mul_assoc y f v, ← mul_assoc e y (f * v), mul_assoc e y (f * v),
            ← mul_assoc e (y * f) v, mul_assoc e y f]
  rw [h_mid]

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
  have hcomm : e * f = f * e := idempotents_comm e f he hf
  have he_assoc : (e * f) * x = f * (e * x) := by
    rw [hcomm, mul_assoc]
  have hf_assoc : (e * f) * z = e * (f * z) := mul_assoc e f z
  have h_mid : f * (e * y) = e * (f * y) := by
    rw [← mul_assoc, ← hcomm, mul_assoc]
  rw [he_assoc, h1, h_mid, h2, ← hf_assoc]

/-- `σ` is a right congruence: `x σ y → x * u σ y * u`. -/
theorem sigma_mul_right (x y u : G) (h : SigmaRel x y) : SigmaRel (x * u) (y * u) := by
  rcases h with ⟨e, he, hxy⟩
  refine ⟨e, he, ?_⟩
  rw [← mul_assoc, hxy, mul_assoc]

/-- `σ` is a left congruence: `u σ v → x * u σ x * v`. -/
theorem sigma_mul_left (x u v : G) (h : SigmaRel u v) : SigmaRel (x * u) (x * v) := by
  rcases h with ⟨f, hf, huv⟩
  refine ⟨x * f * x⁻¹, idempotent_conj x f hf, ?_⟩
  have hcomm : f * (x⁻¹ * x) = (x⁻¹ * x) * f :=
    idempotents_comm f (x⁻¹ * x) hf (idempotent_right x)
  have h_eval (w : G) : (x * f * x⁻¹) * (x * w) = x * (f * w) := by
    calc (x * f * x⁻¹) * (x * w)
      _ = (x * f * x⁻¹ * x) * w := (mul_assoc (x * f * x⁻¹) x w).symm
      _ = (x * f * (x⁻¹ * x)) * w := by rw [mul_assoc (x * f) x⁻¹ x]
      _ = (x * (f * (x⁻¹ * x))) * w := by rw [mul_assoc x f (x⁻¹ * x)]
      _ = (x * ((x⁻¹ * x) * f)) * w := by rw [hcomm]
      _ = ((x * (x⁻¹ * x)) * f) * w := by rw [← mul_assoc x (x⁻¹ * x) f]
      _ = ((x * x⁻¹ * x) * f) * w   := by rw [← mul_assoc x x⁻¹ x]
      _ = (x * f) * w               := by rw [mul_inv_self]
      _ = x * (f * w)               := mul_assoc x f w
  rw [h_eval u, huv, ← h_eval v]

/-- `σ` is compatible with multiplication (congruence relation):
    `x σ y ∧ u σ v → x * u σ y * v`. -/
theorem sigma_mul_compat (x y u v : G) (h1 : SigmaRel x y) (h2 : SigmaRel u v) :
    SigmaRel (x * u) (y * v) :=
  sigma_trans (x * u) (y * u) (y * v) (sigma_mul_right x y u h1) (sigma_mul_left y u v h2)

/-- All idempotents in `G` belong to the same `σ`-equivalence class (the group identity). -/
theorem idempotents_sigma_equiv (e f : G) (he : IsIdempotent e) (hf : IsIdempotent f) :
    SigmaRel e f := by
  refine ⟨e * f, idempotent_mul e f he hf, ?_⟩
  have hcomm : e * f = f * e := idempotents_comm e f he hf
  have he1 : (e * f) * e = e * f := by
    rw [hcomm, mul_assoc, he]
  have hf1 : (e * f) * f = e * f := by
    rw [mul_assoc, hf]
  rw [he1, hf1]

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
  rw [← mul_assoc, h]

end InverseSemigroup
