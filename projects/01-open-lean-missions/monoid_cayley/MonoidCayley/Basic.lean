/-!
# Formalization of Cayley's Embedding Theorem & Transformation Monoids in Lean 4
Ticket: T-0032
Autonomous Research Lab — 01-open-lean-missions

This module formalizes:
1. The algebraic structures of `MyMonoid`, `MyMonoidHom`, and `MyMonoidIso` from first principles.
2. The full transformation monoid `EndMonoid M = (M → M, ∘, id)`.
3. The left-regular representation `cayleyHom : MyMonoidHom M (EndMonoid M)` mapping `a ↦ (x ↦ a * x)`.
4. Strict injectivity (faithfulness) of `cayleyHom`: `cayleyHom a = cayleyHom b → a = b`.
5. The image submonoid `CayleyRange M` and the constructive isomorphism `cayleyIso : MyMonoidIso M (CayleyRange M)`.
6. Zero `sorry` declarations and standard core axioms.
-/

namespace MonoidCayleyFormalization

/-- Typeclass for monoids with associative multiplication and two-sided identity. -/
class MyMonoid (M : Type u) extends Mul M, One M where
  mul_assoc : ∀ a b c : M, (a * b) * c = a * (b * c)
  one_mul : ∀ a : M, (1 : M) * a = a
  mul_one : ∀ a : M, a * (1 : M) = a

/-- Monoid homomorphisms preserving identity and binary operation. -/
structure MyMonoidHom (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ a b : M, toFun (a * b) = toFun a * toFun b

instance (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] :
    CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

theorem MyMonoidHom.ext {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f g : MyMonoidHom M N) (h : ∀ x : M, f x = g x) : f = g := by
  cases f with
  | mk f1 o1 m1 =>
    cases g with
    | mk f2 o2 m2 =>
      have heq : f1 = f2 := funext h
      subst heq
      rfl

/-- Monoid isomorphisms. -/
structure MyMonoidIso (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  invFun : N → M
  left_inv : ∀ x : M, invFun (toFun x) = x
  right_inv : ∀ y : N, toFun (invFun y) = y
  map_one' : toFun 1 = 1
  map_mul' : ∀ a b : M, toFun (a * b) = toFun a * toFun b

-- =========================================================================
--  TRANSFORMATION MONOID (EndMonoid)
-- =========================================================================

/-- The transformation monoid of endofunctions `M → M` under function composition. -/
def EndMonoid (M : Type u) : Type u := M → M

instance (M : Type u) : One (EndMonoid M) where
  one := id

instance (M : Type u) : Mul (EndMonoid M) where
  mul f g := f ∘ g

/-- `EndMonoid M` forms a valid monoid. -/
instance (M : Type u) : MyMonoid (EndMonoid M) where
  mul_assoc _ _ _ := rfl
  one_mul _ := rfl
  mul_one _ := rfl

-- =========================================================================
--  CAYLEY REGULAR REPRESENTATION HOMOMORPHISM
-- =========================================================================

/-- The left-multiplication function `x ↦ a * x`. -/
def cayleyFun {M : Type u} [MyMonoid M] (a : M) : EndMonoid M :=
  fun x => a * x

/-- Identity is mapped to the identity endofunction. -/
theorem cayleyFun_one {M : Type u} [MyMonoid M] :
    cayleyFun (1 : M) = 1 := by
  apply funext
  intro x
  show (1 : M) * x = x
  exact MyMonoid.one_mul x

/-- Multiplication is mapped to endofunction composition. -/
theorem cayleyFun_mul {M : Type u} [MyMonoid M] (a b : M) :
    cayleyFun (a * b) = cayleyFun a * cayleyFun b := by
  apply funext
  intro x
  show (a * b) * x = a * (b * x)
  exact MyMonoid.mul_assoc a b x

/-- The Cayley left-regular representation as a monoid homomorphism. -/
def cayleyHom {M : Type u} [MyMonoid M] : MyMonoidHom M (EndMonoid M) where
  toFun := cayleyFun
  map_one' := cayleyFun_one
  map_mul' := cayleyFun_mul

-- =========================================================================
--  STRICT INJECTIVITY (FAITHFULNESS) OF THE CAYLEY HOMOMORPHISM
-- =========================================================================

/-- Theorem 1: The Cayley homomorphism is strictly injective (faithful action). -/
theorem cayleyHom_injective {M : Type u} [MyMonoid M] (a b : M)
    (h : cayleyHom a = cayleyHom b) : a = b := by
  have h_eval : cayleyHom a (1 : M) = cayleyHom b (1 : M) := by
    rw [h]
  change a * 1 = b * 1 at h_eval
  rw [MyMonoid.mul_one, MyMonoid.mul_one] at h_eval
  exact h_eval

-- =========================================================================
--  CAYLEY IMAGE SUBMONOID & MONOID ISOMORPHISM
-- =========================================================================

/-- The image submonoid of `M` under the Cayley representation in `EndMonoid M`. -/
def CayleyRange (M : Type u) [MyMonoid M] : Type u :=
  { f : EndMonoid M // ∃ a : M, cayleyHom a = f }

instance (M : Type u) [MyMonoid M] : One (CayleyRange M) where
  one := ⟨1, ⟨1, cayleyHom.map_one'⟩⟩

instance (M : Type u) [MyMonoid M] : Mul (CayleyRange M) where
  mul f g := ⟨f.val * g.val, by
    rcases f.property with ⟨a, ha⟩
    rcases g.property with ⟨b, hb⟩
    exact ⟨a * b, by rw [cayleyHom.map_mul', ha, hb]⟩⟩

/-- The Cayley range forms a valid submonoid. -/
instance (M : Type u) [MyMonoid M] : MyMonoid (CayleyRange M) where
  mul_assoc a b c := Subtype.ext (MyMonoid.mul_assoc a.val b.val c.val)
  one_mul a := Subtype.ext (MyMonoid.one_mul a.val)
  mul_one a := Subtype.ext (MyMonoid.mul_one a.val)

/-- Theorem 2: Cayley's Theorem for Monoids:
    Every monoid `M` is isomorphic to its image submonoid in the transformation monoid `EndMonoid M`. -/
noncomputable def cayleyIso (M : Type u) [MyMonoid M] : MyMonoidIso M (CayleyRange M) where
  toFun a := ⟨cayleyHom a, ⟨a, rfl⟩⟩
  invFun f := f.property.choose
  left_inv a := by
    have h_choose : cayleyHom (⟨cayleyHom a, ⟨a, rfl⟩⟩ : CayleyRange M).property.choose = cayleyHom a :=
      (⟨cayleyHom a, ⟨a, rfl⟩⟩ : CayleyRange M).property.choose_spec
    exact cayleyHom_injective _ _ h_choose
  right_inv f := by
    apply Subtype.ext
    exact f.property.choose_spec
  map_one' := Subtype.ext cayleyHom.map_one'
  map_mul' a b := Subtype.ext (cayleyHom.map_mul' a b)

end MonoidCayleyFormalization
