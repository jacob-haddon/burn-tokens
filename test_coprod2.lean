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
theorem MyMonoidHom.ext {M N : Type _} [MyMonoid M] [MyMonoid N] {f g : MyMonoidHom M N}
    (h : ∀ x : M, f x = g x) : f = g := by
  cases f
  cases g
  congr
  funext x
  exact h x

instance instMyMonoidProd (M N : Type _) [MyMonoid M] [MyMonoid N] : MyMonoid (M × N) where
  mul p1 p2 := (p1.1 * p2.1, p1.2 * p2.2)
  one := (1, 1)
  mul_assoc a b c := by
    show ((a.1 * b.1) * c.1, (a.2 * b.2) * c.2) = (a.1 * (b.1 * c.1), a.2 * (b.2 * c.2))
    rw [mul_assoc_thm, mul_assoc_thm]
  one_mul a := by
    show (1 * a.1, 1 * a.2) = (a.1, a.2)
    rw [one_mul_thm, one_mul_thm]
  mul_one a := by
    show (a.1 * 1, a.2 * 1) = (a.1, a.2)
    rw [mul_one_thm, mul_one_thm]

instance instMyCommMonoidProd (M N : Type _) [MyCommMonoid M] [MyCommMonoid N] :
    MyCommMonoid (M × N) where
  mul_comm a b := by
    show (a.1 * b.1, a.2 * b.2) = (b.1 * a.1, b.2 * a.2)
    rw [mul_comm_thm, mul_comm_thm]

def inlHom (M N : Type _) [MyCommMonoid M] [MyCommMonoid N] :
    MyMonoidHom M (M × N) where
  toFun m := (m, 1)
  map_one' := rfl
  map_mul' m1 m2 := by
    show (m1 * m2, 1) = (m1 * m2, 1 * 1)
    rw [mul_one_thm]

def inrHom (M N : Type _) [MyCommMonoid M] [MyCommMonoid N] :
    MyMonoidHom N (M × N) where
  toFun n := (1, n)
  map_one' := rfl
  map_mul' n1 n2 := by
    show (1, n1 * n2) = (1 * 1, n1 * n2)
    rw [one_mul_thm]

theorem prod_eq_inl_mul_inr {M N : Type _} [MyCommMonoid M] [MyCommMonoid N] (p : M × N) :
    p = (inlHom M N p.1) * (inrHom M N p.2) := by
  show (p.1, p.2) = (p.1 * 1, 1 * p.2)
  rw [mul_one_thm, one_mul_thm]

def copair {M N P : Type _} [MyCommMonoid M] [MyCommMonoid N] [MyCommMonoid P]
    (f : MyMonoidHom M P) (g : MyMonoidHom N P) : MyMonoidHom (M × N) P where
  toFun p := f p.1 * g p.2
  map_one' := by
    show f 1 * g 1 = 1
    rw [f.map_one', g.map_one', one_mul_thm]
  map_mul' p1 p2 := by
    show f (p1.1 * p2.1) * g (p1.2 * p2.2) = (f p1.1 * g p1.2) * (f p2.1 * g p2.2)
    rw [f.map_mul', g.map_mul']
    calc
      (f p1.1 * f p2.1) * (g p1.2 * g p2.2)
        = f p1.1 * (f p2.1 * (g p1.2 * g p2.2)) := mul_assoc_thm _ _ _
      _ = f p1.1 * ((f p2.1 * g p1.2) * g p2.2) := by rw [mul_assoc_thm (f p2.1) (g p1.2) _]
      _ = f p1.1 * ((g p1.2 * f p2.1) * g p2.2) := by rw [mul_comm_thm (f p2.1) (g p1.2)]
      _ = f p1.1 * (g p1.2 * (f p2.1 * g p2.2)) := by rw [mul_assoc_thm (g p1.2) (f p2.1) _]
      _ = (f p1.1 * g p1.2) * (f p2.1 * g p2.2) := (mul_assoc_thm (f p1.1) (g p1.2) _).symm

theorem copair_inl {M N P : Type _} [MyCommMonoid M] [MyCommMonoid N] [MyCommMonoid P]
    (f : MyMonoidHom M P) (g : MyMonoidHom N P) (m : M) :
    copair f g (inlHom M N m) = f m := by
  show f m * g 1 = f m
  rw [g.map_one', mul_one_thm]

theorem copair_inr {M N P : Type _} [MyCommMonoid M] [MyCommMonoid N] [MyCommMonoid P]
    (f : MyMonoidHom M P) (g : MyMonoidHom N P) (n : N) :
    copair f g (inrHom M N n) = g n := by
  show f 1 * g n = g n
  rw [f.map_one', one_mul_thm]

theorem coprod_universal_unique {M N P : Type _} [MyCommMonoid M] [MyCommMonoid N] [MyCommMonoid P]
    (f : MyMonoidHom M P) (g : MyMonoidHom N P)
    (h : MyMonoidHom (M × N) P)
    (h_inl : ∀ m : M, h (inlHom M N m) = f m)
    (h_inr : ∀ n : N, h (inrHom M N n) = g n) :
    h = copair f g := by
  ext p
  have h_split := prod_eq_inl_mul_inr p
  calc
    h p = h (inlHom M N p.1 * inrHom M N p.2) := by rw [h_split]
    _   = h (inlHom M N p.1) * h (inrHom M N p.2) := h.map_mul' (inlHom M N p.1) (inrHom M N p.2)
    _   = f p.1 * g p.2                           := by rw [h_inl p.1, h_inr p.2]
    _   = copair f g p                           := rfl

