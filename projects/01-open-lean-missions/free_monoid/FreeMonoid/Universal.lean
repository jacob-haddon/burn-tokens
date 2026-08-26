import FreeMonoid.Basic

namespace FreeMonoidFormalization

variable {α β : Type _} {M : Type _} [MyMonoid M]

/-- Fold evaluation of a word in the free monoid given an interpretation f : α → M. -/
def freeFold (f : α → M) : List α → M
  | [] => 1
  | x :: xs => f x * freeFold f xs

@[simp]
theorem freeFold_nil (f : α → M) : freeFold f [] = 1 := rfl

@[simp]
theorem freeFold_cons (f : α → M) (x : α) (xs : List α) :
    freeFold f (x :: xs) = f x * freeFold f xs := rfl

/-- Key algebraic homomorphism property: folding over concatenated lists splits as multiplication in M. -/
theorem freeFold_append (f : α → M) (l1 l2 : List α) :
    freeFold f (l1 ++ l2) = freeFold f l1 * freeFold f l2 := by
  induction l1 with
  | nil =>
    show freeFold f l2 = 1 * freeFold f l2
    rw [one_mul_thm]
  | cons x xs ih =>
    show f x * freeFold f (xs ++ l2) = (f x * freeFold f xs) * freeFold f l2
    rw [ih, mul_assoc_thm]

/-- Main Theorem 1: The universal lift of any set function f : α → M to a monoid homomorphism List α → M. -/
def lift (f : α → M) : MyMonoidHom (List α) M where
  toFun := freeFold f
  map_one' := rfl
  map_mul' l1 l2 := freeFold_append f l1 l2

/-- Main Theorem 2: The universal commutation triangle: lift(f) ∘ of = f. -/
theorem lift_of (f : α → M) (x : α) : lift f (of x) = f x := by
  show f x * 1 = f x
  rw [mul_one_thm]

/-- Auxiliary lemma: singleton and sublist concatenation split. -/
theorem list_cons_eq_of_append (x : α) (xs : List α) :
    x :: xs = (of x) * xs := rfl

/-- Main Theorem 3: Categorical Free Monoid Universal Uniqueness.
    Any monoid homomorphism agreeing on singletons is strictly equal to the lift. -/
theorem lift_unique (f : α → M) (h : MyMonoidHom (List α) M)
    (h_of : ∀ x : α, h (of x) = f x) : h = lift f := by
  ext l
  induction l with
  | nil =>
    show h 1 = lift f 1
    rw [h.map_one', (lift f).map_one']
  | cons x xs ih =>
    have h_split : x :: xs = (of x) * xs := rfl
    have h_eval : h (x :: xs) = h (of x) * h xs := by
      rw [h_split]
      exact h.map_mul' (of x) xs
    rw [h_eval, h_of x, ih]
    rfl

/-- Functorial action of the free monoid construction on functions: List.map as a homomorphism. -/
def freeMap (φ : α → β) : MyMonoidHom (List α) (List β) where
  toFun := List.map φ
  map_one' := rfl
  map_mul' _ _ := List.map_append

theorem freeMap_of (φ : α → β) (x : α) : freeMap φ (of x) = of (φ x) := rfl

end FreeMonoidFormalization
