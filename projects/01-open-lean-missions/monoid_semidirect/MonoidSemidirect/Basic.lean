namespace MonoidSemidirectFormalization

/-- Monoid typeclass with associative multiplication and two-sided identity. -/
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

/-- Monoid homomorphism structure. -/
structure MyMonoidHom (M N : Type _) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ x y : M, toFun (x * y) = toFun x * toFun y

instance (M N : Type _) [MyMonoid M] [MyMonoid N] :
    CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

@[ext]
theorem MyMonoidHom.ext {M N : Type _} [MyMonoid M] [MyMonoid N]
    {f g : MyMonoidHom M N} (h : ∀ x : M, f x = g x) : f = g := by
  cases f
  cases g
  congr
  funext x
  exact h x

/-- Action of monoid N on monoid M by monoid endomorphisms. -/
structure MyMonoidAction (N M : Type _) [MyMonoid N] [MyMonoid M] where
  act : N → M → M
  act_mul : ∀ (n : N) (m1 m2 : M), act n (m1 * m2) = act n m1 * act n m2
  act_one : ∀ (n : N), act n 1 = 1
  act_comp : ∀ (n1 n2 : N) (m : M), act (n1 * n2) m = act n1 (act n2 m)
  act_id : ∀ (m : M), act 1 m = m

end MonoidSemidirectFormalization
