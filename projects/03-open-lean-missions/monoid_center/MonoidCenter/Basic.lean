/-!
# Formalization of the Monoid Center as a Submonoid and Commutativity Invariants
Ticket: T-0016
Autonomous Research Lab — 01-open-lean-missions

This module defines the algebraic structure of monoids, submonoids, monoid homomorphisms,
and isomorphisms from first principles in Lean 4 without external Mathlib dependencies.

It formally proves:
1. The center predicate `isCentral M z` is closed under identity (`1`) and multiplication (`*`).
2. The center `center M` forms a valid submonoid of `M`.
3. The center is commutative: elements of `center M` commute with each other.
4. Characterization: `M` is commutative if and only if `center M = topSubmonoid M`.
5. Surjective monoid homomorphisms map `center M` into `center N`.
6. Monoid isomorphisms preserve centers: `f '' (center M) = center N`.
-/

namespace MonoidCenter

/-- Typeclass for monoids with associative multiplication and two-sided identity. -/
class MyMonoid (M : Type u) extends Mul M, One M where
  mul_assoc : ∀ a b c : M, (a * b) * c = a * (b * c)
  one_mul : ∀ a : M, (1 : M) * a = a
  mul_one : ∀ a : M, a * (1 : M) = a

/-- Typeclass for commutative monoids. -/
class MyCommMonoid (M : Type u) extends MyMonoid M where
  mul_comm : ∀ a b : M, a * b = b * a

/-- A structure for submonoids of a monoid `M`. -/
structure MySubmonoid (M : Type u) [MyMonoid M] where
  carrier : M → Prop
  one_mem' : carrier 1
  mul_mem' : ∀ {a b : M}, carrier a → carrier b → carrier (a * b)

instance (M : Type u) [MyMonoid M] : Membership M (MySubmonoid M) where
  mem S x := S.carrier x

theorem MySubmonoid.ext {M : Type u} [MyMonoid M] (S T : MySubmonoid M)
    (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T := by
  cases S with
  | mk c1 o1 m1 =>
    cases T with
    | mk c2 o2 m2 =>
      have heq : c1 = c2 := by
        funext x
        exact propext (h x)
      subst heq
      rfl

/-- The top submonoid consisting of the entire monoid `M`. -/
def topSubmonoid (M : Type u) [MyMonoid M] : MySubmonoid M where
  carrier _ := True
  one_mem' := trivial
  mul_mem' _ _ := trivial

/-- Monoid homomorphisms preserving identity and binary operation. -/
structure MyMonoidHom (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ a b : M, toFun (a * b) = toFun a * toFun b

instance (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] :
    CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

@[simp]
theorem map_one {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) : f 1 = 1 :=
  f.map_one'

@[simp]
theorem map_mul {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (a b : M) : f (a * b) = f a * f b :=
  f.map_mul' a b

/-- Monoid isomorphisms. -/
structure MyMonoidIso (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  invFun : N → M
  left_inv : ∀ x : M, invFun (toFun x) = x
  right_inv : ∀ y : N, toFun (invFun y) = y
  map_one' : toFun 1 = 1
  map_mul' : ∀ a b : M, toFun (a * b) = toFun a * toFun b

/-- Coercion from isomorphism to homomorphism. -/
def MyMonoidIso.toHom {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (e : MyMonoidIso M N) : MyMonoidHom M N where
  toFun := e.toFun
  map_one' := e.map_one'
  map_mul' := e.map_mul'

/-- Inverse isomorphism. -/
def MyMonoidIso.symm {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (e : MyMonoidIso M N) : MyMonoidIso N M where
  toFun := e.invFun
  invFun := e.toFun
  left_inv := e.right_inv
  right_inv := e.left_inv
  map_one' := by
    have h : e.toFun (e.invFun 1) = 1 := e.right_inv 1
    have h1 : e.toFun (e.invFun 1) = e.toFun 1 := by
      rw [h, e.map_one']
    have h_inj : ∀ a b, e.toFun a = e.toFun b → a = b := by
      intro a b hab
      have := congrArg e.invFun hab
      rwa [e.left_inv, e.left_inv] at this
    exact h_inj _ _ h1
  map_mul' := by
    intro y1 y2
    have h_inj : ∀ a b, e.toFun a = e.toFun b → a = b := by
      intro a b hab
      have := congrArg e.invFun hab
      rwa [e.left_inv, e.left_inv] at this
    apply h_inj
    rw [e.right_inv, e.map_mul', e.right_inv, e.right_inv]

-- =========================================================================
--  CENTER OF A MONOID
-- =========================================================================

/-- An element `z` of `M` is central if it commutes with every element of `M`. -/
def isCentral (M : Type u) [MyMonoid M] (z : M) : Prop :=
  ∀ x : M, z * x = x * z

/-- Theorem 1: The identity element `1` is central. -/
theorem isCentral_one (M : Type u) [MyMonoid M] : isCentral M (1 : M) := by
  intro x
  rw [MyMonoid.one_mul, MyMonoid.mul_one]

/-- Theorem 2: Central elements are closed under multiplication. -/
theorem isCentral_mul (M : Type u) [MyMonoid M] {a b : M}
    (ha : isCentral M a) (hb : isCentral M b) : isCentral M (a * b) := by
  intro x
  -- (a * b) * x = a * (b * x)
  rw [MyMonoid.mul_assoc]
  -- = a * (x * b)
  rw [hb x]
  -- = (a * x) * b
  rw [← MyMonoid.mul_assoc]
  -- = (x * a) * b
  rw [ha x]
  -- = x * (a * b)
  rw [MyMonoid.mul_assoc]

/-- Definition: The center `center M` as a submonoid of `M`. -/
def center (M : Type u) [MyMonoid M] : MySubmonoid M where
  carrier := isCentral M
  one_mem' := isCentral_one M
  mul_mem' ha hb := isCentral_mul M ha hb

@[simp]
theorem mem_center_iff {M : Type u} [MyMonoid M] (z : M) :
    z ∈ center M ↔ ∀ x : M, z * x = x * z :=
  Iff.rfl

/-- Theorem 3: The center is commutative: elements in `center M` commute with each other. -/
theorem center_comm {M : Type u} [MyMonoid M] (a b : M)
    (ha : a ∈ center M) (_hb : b ∈ center M) : a * b = b * a := by
  exact ha b

/-- Subtype representation of elements in the center. -/
def CenterElem (M : Type u) [MyMonoid M] := { z : M // z ∈ center M }

instance (M : Type u) [MyMonoid M] : One (CenterElem M) where
  one := ⟨1, (center M).one_mem'⟩

instance (M : Type u) [MyMonoid M] : Mul (CenterElem M) where
  mul a b := ⟨a.val * b.val, (center M).mul_mem' a.property b.property⟩

/-- Theorem 4: The center forms a commutative monoid under subtype operations. -/
instance (M : Type u) [MyMonoid M] : MyCommMonoid (CenterElem M) where
  mul_assoc := by
    intro ⟨a, _⟩ ⟨b, _⟩ ⟨c, _⟩
    apply Subtype.ext
    exact MyMonoid.mul_assoc a b c
  one_mul := by
    intro ⟨a, _⟩
    apply Subtype.ext
    exact MyMonoid.one_mul a
  mul_one := by
    intro ⟨a, _⟩
    apply Subtype.ext
    exact MyMonoid.mul_one a
  mul_comm := by
    intro ⟨a, ha⟩ ⟨b, hb⟩
    apply Subtype.ext
    exact center_comm a b ha hb

/-- Theorem 5: `M` is commutative if and only if `center M = topSubmonoid M`. -/
theorem comm_iff_center_eq_top (M : Type u) [MyMonoid M] :
    (∀ a b : M, a * b = b * a) ↔ center M = topSubmonoid M := by
  constructor
  · intro hcomm
    apply MySubmonoid.ext
    intro x
    constructor
    · intro _
      trivial
    · intro _
      rw [mem_center_iff]
      intro y
      exact hcomm x y
  · intro htop a b
    have h_mem : a ∈ center M := by
      rw [htop]
      trivial
    rw [mem_center_iff] at h_mem
    exact h_mem b

/-- Theorem 6: Surjective homomorphisms map central elements to central elements. -/
theorem hom_map_center_of_surjective {M : Type u} {N : Type v}
    [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N) (hsurj : ∀ y : N, ∃ x : M, f x = y)
    (z : M) (hz : z ∈ center M) : f z ∈ center N := by
  rw [mem_center_iff]
  intro y
  rcases hsurj y with ⟨x, rfl⟩
  rw [← map_mul f z x, ← map_mul f x z]
  rw [hz x]

/-- Image of a submonoid under an isomorphism. -/
def isoMapSubmonoid {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (e : MyMonoidIso M N) (S : MySubmonoid M) : MySubmonoid N where
  carrier y := ∃ x : M, x ∈ S ∧ e.toFun x = y
  one_mem' := by
    refine ⟨1, S.one_mem', e.map_one'⟩
  mul_mem' := by
    intro y1 y2 ⟨x1, hx1, he1⟩ ⟨x2, hx2, he2⟩
    refine ⟨x1 * x2, S.mul_mem' hx1 hx2, ?_⟩
    rw [e.map_mul', he1, he2]

/-- Theorem 7: Monoid isomorphisms preserve the center. -/
theorem iso_preserves_center {M : Type u} {N : Type v}
    [MyMonoid M] [MyMonoid N] (e : MyMonoidIso M N) :
    isoMapSubmonoid e (center M) = center N := by
  apply MySubmonoid.ext
  intro y
  constructor
  · rintro ⟨x, hx, rfl⟩
    have hsurj : ∀ b : N, ∃ a : M, e.toHom.toFun a = b := by
      intro b
      exact ⟨e.invFun b, e.right_inv b⟩
    exact hom_map_center_of_surjective e.toHom hsurj x hx
  · intro hy
    have hsurj_symm : ∀ a : M, ∃ b : N, e.symm.toHom.toFun b = a := by
      intro a
      show ∃ b, e.invFun b = a
      exact ⟨e.toFun a, e.left_inv a⟩
    have hx_cent : e.invFun y ∈ center M := by
      have h := hom_map_center_of_surjective e.symm.toHom hsurj_symm y hy
      exact h
    exact ⟨e.invFun y, hx_cent, e.right_inv y⟩

end MonoidCenter
