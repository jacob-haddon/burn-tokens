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

class MyCommMonoid (M : Type _) extends MyMonoid M where
  mul_comm : ∀ a b : M, mul a b = mul b a

theorem mul_comm_thm {M : Type _} [MyCommMonoid M] (a b : M) :
    a * b = b * a := MyCommMonoid.mul_comm a b

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

def fstHom (M N : Type _) [MyMonoid M] [MyMonoid N] : MyMonoidHom (M × N) M where
  toFun p := p.1
  map_one' := rfl
  map_mul' _ _ := rfl

def sndHom (M N : Type _) [MyMonoid M] [MyMonoid N] : MyMonoidHom (M × N) N where
  toFun p := p.2
  map_one' := rfl
  map_mul' _ _ := rfl

def prodPair {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) : MyMonoidHom P (M × N) where
  toFun p := (f p, g p)
  map_one' := by
    show (f 1, g 1) = (1, 1)
    rw [f.map_one', g.map_one']
  map_mul' x y := by
    show (f (x * y), g (x * y)) = (f x * f y, g x * g y)
    rw [f.map_mul', g.map_mul']

theorem fst_comp_prodPair {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) (p : P) :
    fstHom M N (prodPair f g p) = f p := rfl

theorem snd_comp_prodPair {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) (p : P) :
    sndHom M N (prodPair f g p) = g p := rfl

theorem prod_universal_unique {P M N : Type _} [MyMonoid P] [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom P M) (g : MyMonoidHom P N) (h : MyMonoidHom P (M × N))
    (h1 : ∀ p, fstHom M N (h p) = f p)
    (h2 : ∀ p, sndHom M N (h p) = g p) :
    h = prodPair f g := by
  ext p
  have hf := h1 p
  have hg := h2 p
  dsimp [fstHom] at hf
  dsimp [sndHom] at hg
  dsimp [prodPair]
  exact Prod.ext hf hg

instance instMyCommMonoidProd (M N : Type _) [MyCommMonoid M] [MyCommMonoid N] :
    MyCommMonoid (M × N) where
  mul_comm a b := by
    show (a.1 * b.1, a.2 * b.2) = (b.1 * a.1, b.2 * a.2)
    rw [mul_comm_thm a.1 b.1, mul_comm_thm a.2 b.2]

theorem prod_comm_iff (M N : Type _) [MyMonoid M] [MyMonoid N] :
    (∀ (x y : M × N), x * y = y * x) ↔
    (∀ (m1 m2 : M), m1 * m2 = m2 * m1) ∧ (∀ (n1 n2 : N), n1 * n2 = n2 * n1) := by
  constructor
  · intro h
    constructor
    · intro m1 m2
      have hpair := h (m1, 1) (m2, 1)
      have : (m1 * m2, (1 : N) * (1 : N)) = (m2 * m1, (1 : N) * (1 : N)) := hpair
      injection this with hm _
      exact hm
    · intro n1 n2
      have hpair := h (1, n1) (1, n2)
      have : ((1 : M) * (1 : M), n1 * n2) = ((1 : M) * (1 : M), n2 * n1) := hpair
      injection this with _ hn
      exact hn
  · intro ⟨hM, hN⟩ ⟨m1, n1⟩ ⟨m2, n2⟩
    show (m1 * m2, n1 * n2) = (m2 * m1, n2 * n1)
    rw [hM m1 m2, hN n1 n2]

