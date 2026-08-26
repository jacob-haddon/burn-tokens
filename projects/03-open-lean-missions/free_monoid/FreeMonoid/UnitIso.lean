import FreeMonoid.Basic
import FreeMonoid.Universal

namespace FreeMonoidFormalization

/-- Additive monoid structure on the natural numbers (ℕ, +, 0). -/
instance instMyMonoidNat : MyMonoid Nat where
  mul a b := a + b
  one := 0
  mul_assoc a b c := Nat.add_assoc a b c
  one_mul a := Nat.zero_add a
  mul_one a := Nat.add_zero a

/-- Monoid isomorphism structure between two monoids. -/
structure MyMonoidIso (M N : Type _) [MyMonoid M] [MyMonoid N] where
  toHom : MyMonoidHom M N
  invHom : MyMonoidHom N M
  left_inv : ∀ x : M, invHom (toHom x) = x
  right_inv : ∀ y : N, toHom (invHom y) = y

/-- The length function is a monoid homomorphism from List Unit to (ℕ, +, 0). -/
def lengthHom : MyMonoidHom (List Unit) Nat where
  toFun := List.length
  map_one' := rfl
  map_mul' _ _ := List.length_append

/-- Helper lemma: List.replicate (a + b) () = List.replicate a () ++ List.replicate b (). -/
theorem replicate_unit_add (n1 n2 : Nat) :
    List.replicate (n1 + n2) () = List.replicate n1 () ++ List.replicate n2 () := by
  induction n1 with
  | zero =>
    rw [Nat.zero_add, List.replicate, List.nil_append]
  | succ n1 ih =>
    rw [Nat.succ_add, List.replicate, List.replicate, List.cons_append, ih]

/-- The replicate function is a monoid homomorphism from (ℕ, +, 0) to List Unit. -/
def replicateHom : MyMonoidHom Nat (List Unit) where
  toFun n := List.replicate n ()
  map_one' := rfl
  map_mul' n1 n2 := replicate_unit_add n1 n2

/-- Round-trip identity 1: length of replicate n () is n. -/
theorem length_replicate_unit (n : Nat) : (List.replicate n ()).length = n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [List.replicate, List.length_cons, ih]

/-- Round-trip identity 2: replicating the length of a Unit list recovers the original list. -/
theorem replicate_length_unit (l : List Unit) : List.replicate l.length () = l := by
  induction l with
  | nil => rfl
  | cons u xs ih =>
    cases u
    rw [List.length_cons, List.replicate, ih]

/-- Main Theorem 4: The free monoid on a singleton set (List Unit) is isomorphic to (ℕ, +, 0). -/
def free_unit_iso_nat : MyMonoidIso (List Unit) Nat where
  toHom := lengthHom
  invHom := replicateHom
  left_inv l := replicate_length_unit l
  right_inv n := length_replicate_unit n

end FreeMonoidFormalization
