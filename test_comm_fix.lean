class MyMonoid (M : Type _) where
  mul : M → M → M
  one : M
  mul_assoc : ∀ a b c : M, mul (mul a b) c = mul a (mul b c)
  one_mul : ∀ a : M, mul one a = a
  mul_one : ∀ a : M, mul a one = a

instance (M : Type _) [MyMonoid M] : Mul M := ⟨MyMonoid.mul⟩
instance (M : Type _) [MyMonoid M] : One M := ⟨MyMonoid.one⟩

class MyCommMonoid (M : Type _) extends MyMonoid M where
  mul_comm : ∀ a b : M, mul a b = mul b a

theorem mul_comm_thm {M : Type _} [MyCommMonoid M] (a b : M) :
    a * b = b * a := MyCommMonoid.mul_comm a b

class MyGroup (G : Type _) extends MyMonoid G where
  inv : G → G
  inv_mul_cancel : ∀ a : G, inv a * a = 1
  mul_inv_cancel : ∀ a : G, a * inv a = 1

class MyCommGroup (G : Type _) extends MyGroup G, MyCommMonoid G

def IsUnit (M : Type _) [MyMonoid M] (u : M) : Prop :=
  ∃ v : M, u * v = 1 ∧ v * u = 1

theorem isUnit_one (M : Type _) [MyMonoid M] : IsUnit M 1 := by
  refine ⟨1, MyMonoid.mul_one 1, MyMonoid.mul_one 1⟩

theorem isUnit_mul {M : Type _} [MyMonoid M] {u1 u2 : M}
    (h1 : IsUnit M u1) (h2 : IsUnit M u2) : IsUnit M (u1 * u2) := by
  rcases h1 with ⟨v1, hv1_r, hv1_l⟩
  rcases h2 with ⟨v2, hv2_r, hv2_l⟩
  refine ⟨v2 * v1, ?_, ?_⟩
  · calc
      (u1 * u2) * (v2 * v1) = u1 * (u2 * (v2 * v1)) := MyMonoid.mul_assoc u1 u2 (v2 * v1)
      _                     = u1 * ((u2 * v2) * v1) := by rw [MyMonoid.mul_assoc u2 v2 v1]
      _                     = u1 * (1 * v1)         := by rw [hv2_r]
      _                     = u1 * v1               := by rw [MyMonoid.one_mul v1]
      _                     = 1                     := hv1_r
  · calc
      (v2 * v1) * (u1 * u2) = v2 * (v1 * (u1 * u2)) := MyMonoid.mul_assoc v2 v1 (u1 * u2)
      _                     = v2 * ((v1 * u1) * u2) := by rw [MyMonoid.mul_assoc v1 u1 u2]
      _                     = v2 * (1 * u2)         := by rw [hv1_l]
      _                     = v2 * u2               := by rw [MyMonoid.one_mul u2]
      _                     = 1                     := hv2_l

structure MyUnits (M : Type _) [MyMonoid M] where
  val : M
  is_unit : IsUnit M val

@[ext]
theorem MyUnits.ext {M : Type _} [MyMonoid M] {u1 u2 : MyUnits M} (h : u1.val = u2.val) : u1 = u2 := by
  cases u1
  cases u2
  congr

def unitOne (M : Type _) [MyMonoid M] : MyUnits M :=
  ⟨1, isUnit_one M⟩

def unitMul {M : Type _} [MyMonoid M] (u1 u2 : MyUnits M) : MyUnits M :=
  ⟨u1.val * u2.val, isUnit_mul u1.is_unit u2.is_unit⟩

noncomputable def unitInv {M : Type _} [MyMonoid M] (u : MyUnits M) : MyUnits M :=
  let v := Classical.choose u.is_unit
  have hv := Classical.choose_spec u.is_unit
  ⟨v, ⟨u.val, hv.2, hv.1⟩⟩

instance instMyMonoidUnits (M : Type _) [MyMonoid M] : MyMonoid (MyUnits M) where
  mul := unitMul
  one := unitOne M
  mul_assoc a b c := by
    apply MyUnits.ext
    exact MyMonoid.mul_assoc a.val b.val c.val
  one_mul a := by
    apply MyUnits.ext
    exact MyMonoid.one_mul a.val
  mul_one a := by
    apply MyUnits.ext
    exact MyMonoid.mul_one a.val

noncomputable instance instMyGroupUnits (M : Type _) [MyMonoid M] : MyGroup (MyUnits M) where
  inv := unitInv
  inv_mul_cancel a := by
    apply MyUnits.ext
    exact (Classical.choose_spec a.is_unit).2
  mul_inv_cancel a := by
    apply MyUnits.ext
    exact (Classical.choose_spec a.is_unit).1

noncomputable instance instMyCommGroupUnits (M : Type _) [MyCommMonoid M] : MyCommGroup (MyUnits M) where
  mul_comm a b := by
    apply MyUnits.ext
    exact mul_comm_thm a.val b.val

