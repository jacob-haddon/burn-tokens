namespace FreeMonoidFormalization

/-- Typeclass for monoids (structures equipped with an associative binary operation and neutral element). -/
class MyMonoid (M : Type _) where
  mul : M → M → M
  one : M
  mul_assoc : ∀ a b c : M, mul (mul a b) c = mul a (mul b c)
  one_mul : ∀ a : M, mul one a = a
  mul_one : ∀ a : M, mul a one = a

instance (M : Type _) [MyMonoid M] : Mul M := ⟨MyMonoid.mul⟩
instance (M : Type _) [MyMonoid M] : One M := ⟨MyMonoid.one⟩

theorem mul_assoc_thm {M : Type _} [MyMonoid M] (a b c : M) :
    a * b * c = a * (b * c) := MyMonoid.mul_assoc a b c

theorem one_mul_thm {M : Type _} [MyMonoid M] (a : M) :
    1 * a = a := MyMonoid.one_mul a

theorem mul_one_thm {M : Type _} [MyMonoid M] (a : M) :
    a * 1 = a := MyMonoid.mul_one a

/-- Monoid homomorphism structure between two monoids. -/
structure MyMonoidHom (M N : Type _) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ x y : M, toFun (x * y) = toFun x * toFun y

instance (M N : Type _) [MyMonoid M] [MyMonoid N] : CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

@[ext]
theorem MyMonoidHom.ext {M N : Type _} [MyMonoid M] [MyMonoid N] {f g : MyMonoidHom M N}
    (h : ∀ x : M, f x = g x) : f = g := by
  cases f
  cases g
  congr
  funext x
  exact h x

/-- Free monoid on any type α is given by `List α` with list concatenation. -/
instance instMyMonoidList (α : Type _) : MyMonoid (List α) where
  mul l1 l2 := l1 ++ l2
  one := []
  mul_assoc l1 l2 l3 := List.append_assoc l1 l2 l3
  one_mul l := List.nil_append l
  mul_one l := List.append_nil l

/-- Canonical embedding of generators into the free monoid: of(x) = [x]. -/
def of {α : Type _} (x : α) : List α := [x]

end FreeMonoidFormalization
