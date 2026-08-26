/-!
# Formalization of Monoid Ideals, Rees Congruences, and Rees Quotient Monoids in Lean 4
Ticket: T-0043
Autonomous Research Lab — 01-open-lean-missions

This module formalizes:
1. `MyMonoid` and `MyMonoidHom` typeclasses and structures.
2. `MonoidIdeal M`: Two-sided semigroup ideals in a monoid.
3. `reesRel`: The Rees equivalence relation $x \sim y \iff x = y \lor (x \in I \land y \in I)$.
4. `reesSetoid` and proof that `reesRel` is a compatible monoid congruence.
5. `ReesQuotient I` and its canonical monoid instance `instMyMonoidReesQuotient`.
6. Canonical projection homomorphism `reesProj I : MyMonoidHom M (ReesQuotient I)`.
7. Zero element collapse: All elements in $I$ map to a common zero class $\mathbf{0}_I$.
8. Zero absorption theorems: $\mathbf{0}_I \cdot q = \mathbf{0}_I$ and $q \cdot \mathbf{0}_I = \mathbf{0}_I$.
9. Universal mapping property: `reesLift` for homomorphisms annihilating the ideal $I$.
10. Zero `sorry` declarations and standard core axioms (`[propext, Quot.sound]`).
-/

namespace MonoidReesFormalization

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

-- =========================================================================
--  MONOID IDEALS
-- =========================================================================

/-- A two-sided ideal of a monoid `M`. -/
structure MonoidIdeal (M : Type u) [MyMonoid M] where
  carrier : M → Prop
  mul_left : ∀ (m x : M), carrier x → carrier (m * x)
  mul_right : ∀ (m x : M), carrier x → carrier (x * m)

-- =========================================================================
--  REES CONGRUENCE RELATION
-- =========================================================================

/-- The Rees relation modulo ideal `I`: `x ~ y ↔ x = y ∨ (x ∈ I ∧ y ∈ I)`. -/
def reesRel {M : Type u} [MyMonoid M] (I : MonoidIdeal M) (x y : M) : Prop :=
  x = y ∨ (I.carrier x ∧ I.carrier y)

theorem reesRel_refl {M : Type u} [MyMonoid M] (I : MonoidIdeal M) (x : M) :
    reesRel I x x :=
  Or.inl rfl

theorem reesRel_symm {M : Type u} [MyMonoid M] (I : MonoidIdeal M) {x y : M}
    (h : reesRel I x y) : reesRel I y x := by
  cases h with
  | inl h_eq => exact Or.inl h_eq.symm
  | inr h_in => exact Or.inr ⟨h_in.2, h_in.1⟩

theorem reesRel_trans {M : Type u} [MyMonoid M] (I : MonoidIdeal M) {x y z : M}
    (h1 : reesRel I x y) (h2 : reesRel I y z) : reesRel I x z := by
  cases h1 with
  | inl h_eq1 =>
    subst h_eq1
    exact h2
  | inr h_in1 =>
    cases h2 with
    | inl h_eq2 =>
      subst h_eq2
      exact Or.inr h_in1
    | inr h_in2 =>
      exact Or.inr ⟨h_in1.1, h_in2.2⟩

/-- The Setoid instance induced by the Rees equivalence relation. -/
def reesSetoid {M : Type u} [MyMonoid M] (I : MonoidIdeal M) : Setoid M where
  r := reesRel I
  iseqv := {
    refl := reesRel_refl I
    symm := reesRel_symm I
    trans := reesRel_trans I
  }

/-- Rees relation is compatible with monoid multiplication (monoid congruence). -/
theorem rees_mul_compat {M : Type u} [MyMonoid M] (I : MonoidIdeal M)
    {a b c d : M} (h1 : reesRel I a c) (h2 : reesRel I b d) :
    reesRel I (a * b) (c * d) := by
  cases h1 with
  | inl ha_eq =>
    subst ha_eq
    cases h2 with
    | inl hb_eq =>
      subst hb_eq
      exact Or.inl rfl
    | inr hb_in =>
      have h_left : I.carrier (a * b) := I.mul_left a b hb_in.1
      have h_right : I.carrier (a * d) := I.mul_left a d hb_in.2
      exact Or.inr ⟨h_left, h_right⟩
  | inr ha_in =>
    cases h2 with
    | inl hb_eq =>
      subst hb_eq
      have h_left : I.carrier (a * b) := I.mul_right b a ha_in.1
      have h_right : I.carrier (c * b) := I.mul_right b c ha_in.2
      exact Or.inr ⟨h_left, h_right⟩
    | inr hb_in =>
      have h_left : I.carrier (a * b) := I.mul_right b a ha_in.1
      have h_right : I.carrier (c * d) := I.mul_right d c ha_in.2
      exact Or.inr ⟨h_left, h_right⟩

-- =========================================================================
--  REES QUOTIENT MONOID
-- =========================================================================

/-- The Rees quotient type `M / I`. -/
def ReesQuotient {M : Type u} [MyMonoid M] (I : MonoidIdeal M) : Type u :=
  Quotient (reesSetoid I)

/-- Canonical projection to the quotient. -/
def toRees {M : Type u} [MyMonoid M] (I : MonoidIdeal M) (x : M) : ReesQuotient I :=
  Quotient.mk (reesSetoid I) x

/-- Multiplication on the Rees quotient. -/
def reesMul {M : Type u} [MyMonoid M] (I : MonoidIdeal M) :
    ReesQuotient I → ReesQuotient I → ReesQuotient I :=
  Quotient.lift₂ (fun a b => toRees I (a * b))
    (fun a b c d h1 h2 => @Quotient.sound M (reesSetoid I) (a * b) (c * d) (rees_mul_compat I h1 h2))

instance (M : Type u) [MyMonoid M] (I : MonoidIdeal M) : Mul (ReesQuotient I) where
  mul := reesMul I

instance (M : Type u) [MyMonoid M] (I : MonoidIdeal M) : One (ReesQuotient I) where
  one := toRees I (1 : M)

/-- `ReesQuotient I` forms a valid monoid. -/
instance instMyMonoidReesQuotient (M : Type u) [MyMonoid M] (I : MonoidIdeal M) :
    MyMonoid (ReesQuotient I) where
  mul_assoc qa qb qc := by
    refine Quotient.inductionOn₃ qa qb qc (fun a b c => ?_)
    show toRees I ((a * b) * c) = toRees I (a * (b * c))
    rw [MyMonoid.mul_assoc]
  one_mul qa := by
    refine Quotient.inductionOn qa (fun a => ?_)
    show toRees I (1 * a) = toRees I a
    rw [MyMonoid.one_mul]
  mul_one qa := by
    refine Quotient.inductionOn qa (fun a => ?_)
    show toRees I (a * 1) = toRees I a
    rw [MyMonoid.mul_one]

-- =========================================================================
--  CANONICAL PROJECTION & ZERO ABSORPTION
-- =========================================================================

/-- Canonical projection homomorphism `M → M / I`. -/
def reesProj {M : Type u} [MyMonoid M] (I : MonoidIdeal M) :
    MyMonoidHom M (ReesQuotient I) where
  toFun x := toRees I x
  map_one' := rfl
  map_mul' _ _ := rfl

/-- Theorem: Any two elements of the ideal collapse to the same equivalence class in `M / I`. -/
theorem rees_ideal_collapse {M : Type u} [MyMonoid M] (I : MonoidIdeal M)
    (x y : M) (hx : I.carrier x) (hy : I.carrier y) :
    toRees I x = toRees I y := by
  apply @Quotient.sound M (reesSetoid I) x y
  exact Or.inr ⟨hx, hy⟩

/-- Theorem: Left-zero absorption for the ideal equivalence class. -/
theorem reesZero_mul_left {M : Type u} [MyMonoid M] (I : MonoidIdeal M)
    (z : M) (hz : I.carrier z) (q : ReesQuotient I) :
    toRees I z * q = toRees I z := by
  refine Quotient.inductionOn q (fun x => ?_)
  show toRees I (z * x) = toRees I z
  apply @Quotient.sound M (reesSetoid I) (z * x) z
  have h_zx : I.carrier (z * x) := I.mul_right x z hz
  exact Or.inr ⟨h_zx, hz⟩

/-- Theorem: Right-zero absorption for the ideal equivalence class. -/
theorem reesZero_mul_right {M : Type u} [MyMonoid M] (I : MonoidIdeal M)
    (z : M) (hz : I.carrier z) (q : ReesQuotient I) :
    q * toRees I z = toRees I z := by
  refine Quotient.inductionOn q (fun x => ?_)
  show toRees I (x * z) = toRees I z
  apply @Quotient.sound M (reesSetoid I) (x * z) z
  have h_xz : I.carrier (x * z) := I.mul_left x z hz
  exact Or.inr ⟨h_xz, hz⟩

-- =========================================================================
--  REES UNIVERSAL FACTORIZATION PROPERTY
-- =========================================================================

/-- Factorization of a homomorphism annihilating the ideal `I` across the Rees quotient. -/
def reesLift {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (I : MonoidIdeal M) (f : MyMonoidHom M N) (zN : N)
    (h_annihilate : ∀ x : M, I.carrier x → f x = zN) :
    MyMonoidHom (ReesQuotient I) N where
  toFun := Quotient.lift f.toFun (by
    intro a b h_rel
    cases h_rel with
    | inl h_eq => subst h_eq; rfl
    | inr h_in =>
      have ha : f.toFun a = zN := h_annihilate a h_in.1
      have hb : f.toFun b = zN := h_annihilate b h_in.2
      rw [ha, hb])
  map_one' := f.map_one'
  map_mul' qa qb := by
    refine Quotient.inductionOn₂ qa qb (fun a b => ?_)
    exact f.map_mul' a b

/-- Factoring triangle commutes: `reesLift f ∘ reesProj = f`. -/
theorem reesLift_comp {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (I : MonoidIdeal M) (f : MyMonoidHom M N) (zN : N)
    (h_annihilate : ∀ x : M, I.carrier x → f x = zN) (x : M) :
    reesLift I f zN h_annihilate (toRees I x) = f x := rfl

/-- Factoring homomorphism is unique. -/
theorem reesLift_unique {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (I : MonoidIdeal M) (f : MyMonoidHom M N) (zN : N)
    (h_annihilate : ∀ x : M, I.carrier x → f x = zN)
    (h : MyMonoidHom (ReesQuotient I) N)
    (h_comp : ∀ x : M, h (toRees I x) = f x) :
    h = reesLift I f zN h_annihilate := by
  apply MyMonoidHom.ext
  intro q
  refine Quotient.inductionOn q (fun x => ?_)
  exact h_comp x

end MonoidReesFormalization
