/-
  Autonomous Research Lab: Project 01 (Open Lean Missions)
  Mission: Formalization of Monoid Direct Products & Universal Property in Lean 4
  Target: Standalone machine-checked Lean 4 formalization with 0 sorry and 0 custom axioms.
-/

namespace MonoidProductFormalization

/-- Monoid typeclass with explicit operations. -/
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

/-- Commutative monoid typeclass. -/
class MyCommMonoid (M : Type _) extends MyMonoid M where
  mul_comm : ∀ a b : M, mul a b = mul b a

theorem mul_comm_thm {M : Type _} [MyCommMonoid M] (a b : M) :
    a * b = b * a := MyCommMonoid.mul_comm a b

/-- Monoid homomorphism structure. -/
structure MyMonoidHom (M N : Type _) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ x y : M, toFun (x * y) = toFun x * toFun y

instance (M N : Type _) [MyMonoid M] [MyMonoid N] : CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

@[ext]
theorem MyMonoidHom.ext {M N : Type _} [MyMonoid M] [MyMonoid N]
    {f g : MyMonoidHom M N} (h : ∀ x, f x = g x) : f = g := by
  cases f
  cases g
  congr
  exact funext h

/-- Direct product monoid instance on M × N. -/
instance instMyMonoidProd (M N : Type _) [MyMonoid M] [MyMonoid N] : MyMonoid (M × N) where
  mul p1 p2 := (p1.1 * p2.1, p1.2 * p2.2)
  one := (1, 1)
  mul_assoc a b c := by
    show (a.1 * b.1 * c.1, a.2 * b.2 * c.2) = (a.1 * (b.1 * c.1), a.2 * (b.2 * c.2))
    rw [mul_assoc_thm, mul_assoc_thm]
  one_mul a := by
    show (1 * a.1, 1 * a.2) = a
    rw [one_mul_thm, one_mul_thm]
  mul_one a := by
    show (a.1 * 1, a.2 * 1) = a
    rw [mul_one_thm, mul_one_thm]

/-- Canonical first coordinate projection homomorphism π₁ : M × N → M. -/
def fstHom (M N : Type _) [MyMonoid M] [MyMonoid N] : MyMonoidHom (M × N) M where
  toFun p := p.1
  map_one' := rfl
  map_mul' _ _ := rfl

/-- Canonical second coordinate projection homomorphism π₂ : M × N → N. -/
def sndHom (M N : Type _) [MyMonoid M] [MyMonoid N] : MyMonoidHom (M × N) N where
  toFun p := p.2
  map_one' := rfl
  map_mul' _ _ := rfl

/-- Categorical mediating pairing homomorphism ⟨f, g⟩ : P → M × N. -/
def prodPair {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) : MyMonoidHom P (M × N) where
  toFun p := (f p, g p)
  map_one' := by
    show (f 1, g 1) = (1, 1)
    rw [f.map_one', g.map_one']
  map_mul' x y := by
    show (f (x * y), g (x * y)) = (f x * f y, g x * g y)
    rw [f.map_mul', g.map_mul']

/-- Commutation triangle for first projection: π₁ ∘ ⟨f, g⟩ = f. -/
theorem fst_comp_prodPair {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) (p : P) :
    fstHom M N (prodPair f g p) = f p := rfl

/-- Commutation triangle for second projection: π₂ ∘ ⟨f, g⟩ = g. -/
theorem snd_comp_prodPair {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) (p : P) :
    sndHom M N (prodPair f g p) = g p := rfl

/-- Main Theorem 1: Universal Property Uniqueness.
    Any homomorphism h : P → M × N satisfying the projection factorization equations is
    strictly equal to prodPair f g. -/
theorem prod_universal_unique {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) (h : MyMonoidHom P (M × N))
    (h1 : ∀ p, fstHom M N (h p) = f p)
    (h2 : ∀ p, sndHom M N (h p) = g p) :
    h = prodPair f g := by
  ext p
  · exact h1 p
  · exact h2 p

/-- Direct product commutative monoid instance. -/
instance instMyCommMonoidProd (M N : Type _) [MyCommMonoid M] [MyCommMonoid N] :
    MyCommMonoid (M × N) where
  mul_comm a b := by
    show (a.1 * b.1, a.2 * b.2) = (b.1 * a.1, b.2 * a.2)
    rw [mul_comm_thm a.1 b.1, mul_comm_thm a.2 b.2]

/-- Main Theorem 2: Direct product commutativity characterization.
    M × N is commutative if and only if both M and N are commutative. -/
theorem prod_comm_iff (M N : Type _) [MyMonoid M] [MyMonoid N] :
    (∀ (x y : M × N), x * y = y * x) ↔
    (∀ (m1 m2 : M), m1 * m2 = m2 * m1) ∧ (∀ (n1 n2 : N), n1 * n2 = n2 * n1) := by
  constructor
  · intro h
    constructor
    · intro m1 m2
      have hpair := h (m1, 1) (m2, 1)
      have : (m1 * m2, (1 : N) * 1) = (m2 * m1, (1 : N) * 1) := hpair
      have hm : (m1 * m2, (1 : N) * 1).1 = (m2 * m1, (1 : N) * 1).1 := by rw [this]
      exact hm
    · intro n1 n2
      have hpair := h (1, n1) (1, n2)
      have : ((1 : M) * 1, n1 * n2) = ((1 : M) * 1, n2 * n1) := hpair
      have hn : ((1 : M) * 1, n1 * n2).2 = ((1 : M) * 1, n2 * n1).2 := by rw [this]
      exact hn
  · intro ⟨hM, hN⟩ ⟨m1, n1⟩ ⟨m2, n2⟩
    show (m1 * m2, n1 * n2) = (m2 * m1, n2 * n1)
    rw [hM m1 m2, hN n1 n2]

end MonoidProductFormalization
