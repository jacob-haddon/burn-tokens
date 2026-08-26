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

class MyGroup (G : Type _) extends MyMonoid G where
  inv : G → G
  inv_mul_cancel : ∀ a : G, inv a * a = 1
  mul_inv_cancel : ∀ a : G, a * inv a = 1

instance (G : Type _) [MyGroup G] : Inv G := ⟨MyGroup.inv⟩

class MyCommGroup (G : Type _) extends MyGroup G, MyCommMonoid G

def IsUnit (M : Type _) [MyMonoid M] (u : M) : Prop :=
  ∃ v : M, u * v = 1 ∧ v * u = 1

theorem unit_inv_unique {M : Type _} [MyMonoid M] (u v1 v2 : M)
    (h1 : u * v1 = 1 ∧ v1 * u = 1) (h2 : u * v2 = 1 ∧ v2 * u = 1) : v1 = v2 := by
  calc
    v1 = v1 * 1        := (mul_one_thm v1).symm
    _  = v1 * (u * v2) := by rw [h2.1]
    _  = (v1 * u) * v2 := (mul_assoc_thm v1 u v2).symm
    _  = 1 * v2        := by rw [h1.2]
    _  = v2            := one_mul_thm v2

theorem isUnit_one (M : Type _) [MyMonoid M] : IsUnit M 1 := by
  refine ⟨1, ?_, ?_⟩
  · exact mul_one_thm 1
  · exact mul_one_thm 1

theorem isUnit_mul {M : Type _} [MyMonoid M] {u1 u2 : M}
    (h1 : IsUnit M u1) (h2 : IsUnit M u2) : IsUnit M (u1 * u2) := by
  rcases h1 with ⟨v1, hv1_r, hv1_l⟩
  rcases h2 with ⟨v2, hv2_r, hv2_l⟩
  refine ⟨v2 * v1, ?_, ?_⟩
  · calc
      (u1 * u2) * (v2 * v1) = u1 * (u2 * (v2 * v1)) := mul_assoc_thm u1 u2 (v2 * v1)
      _                     = u1 * ((u2 * v2) * v1) := by rw [mul_assoc_thm u2 v2 v1]
      _                     = u1 * (1 * v1)         := by rw [hv2_r]
      _                     = u1 * v1               := by rw [one_mul_thm v1]
      _                     = 1                     := hv1_r
  · calc
      (v2 * v1) * (u1 * u2) = v2 * (v1 * (u1 * u2)) := mul_assoc_thm v2 v1 (u1 * u2)
      _                     = v2 * ((v1 * u1) * u2) := by rw [mul_assoc_thm v1 u1 u2]
      _                     = v2 * (1 * u2)         := by rw [hv1_l]
      _                     = v2 * u2               := by rw [one_mul_thm u2]
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

theorem unitInv_val_right {M : Type _} [MyMonoid M] (u : MyUnits M) :
    u.val * (unitInv u).val = 1 :=
  (Classical.choose_spec u.is_unit).1

theorem unitInv_val_left {M : Type _} [MyMonoid M] (u : MyUnits M) :
    (unitInv u).val * u.val = 1 :=
  (Classical.choose_spec u.is_unit).2

instance instMyMonoidUnits (M : Type _) [MyMonoid M] : MyMonoid (MyUnits M) where
  mul := unitMul
  one := unitOne M
  mul_assoc a b c := by
    apply MyUnits.ext
    dsimp [unitMul]
    exact mul_assoc_thm a.val b.val c.val
  one_mul a := by
    apply MyUnits.ext
    dsimp [unitMul, unitOne]
    exact one_mul_thm a.val
  mul_one a := by
    apply MyUnits.ext
    dsimp [unitMul, unitOne]
    exact mul_one_thm a.val

noncomputable instance instMyGroupUnits (M : Type _) [MyMonoid M] : MyGroup (MyUnits M) where
  inv := unitInv
  inv_mul_cancel a := by
    apply MyUnits.ext
    exact unitInv_val_left a
  mul_inv_cancel a := by
    apply MyUnits.ext
    exact unitInv_val_right a

theorem unit_inv_inv {M : Type _} [MyMonoid M] (u : MyUnits M) :
    unitInv (unitInv u) = u := by
  apply MyUnits.ext
  dsimp [unitInv]
  have h1 : (unitInv (unitInv u)).val * (unitInv u).val = 1 := unitInv_val_left (unitInv u)
  have h2 : (unitInv u).val * (unitInv (unitInv u)).val = 1 := unitInv_val_right (unitInv u)
  have hu1 : u.val * (unitInv u).val = 1 := unitInv_val_right u
  have hu2 : (unitInv u).val * u.val = 1 := unitInv_val_left u
  exact unit_inv_unique (unitInv u).val (unitInv (unitInv u)).val u.val ⟨h2, h1⟩ ⟨hu2, hu1⟩

theorem unit_inv_mul {M : Type _} [MyMonoid M] (u1 u2 : MyUnits M) :
    unitInv (unitMul u1 u2) = unitMul (unitInv u2) (unitInv u1) := by
  apply MyUnits.ext
  dsimp [unitMul, unitInv]
  have h_prod_r : (u1.val * u2.val) * ((unitInv u2).val * (unitInv u1).val) = 1 := by
    calc
      (u1.val * u2.val) * ((unitInv u2).val * (unitInv u1).val)
        = u1.val * (u2.val * ((unitInv u2).val * (unitInv u1).val)) := mul_assoc_thm u1.val u2.val _
      _ = u1.val * ((u2.val * (unitInv u2).val) * (unitInv u1).val) := by rw [mul_assoc_thm u2.val (unitInv u2).val _]
      _ = u1.val * (1 * (unitInv u1).val)                           := by rw [unitInv_val_right u2]
      _ = u1.val * (unitInv u1).val                                 := by rw [one_mul_thm (unitInv u1).val]
      _ = 1                                                         := unitInv_val_right u1
  have h_prod_l : ((unitInv u2).val * (unitInv u1).val) * (u1.val * u2.val) = 1 := by
    calc
      ((unitInv u2).val * (unitInv u1).val) * (u1.val * u2.val)
        = (unitInv u2).val * ((unitInv u1).val * (u1.val * u2.val)) := mul_assoc_thm _ _ _
      _ = (unitInv u2).val * (((unitInv u1).val * u1.val) * u2.val) := by rw [mul_assoc_thm _ u1.val _]
      _ = (unitInv u2).val * (1 * u2.val)                           := by rw [unitInv_val_left u1]
      _ = (unitInv u2).val * u2.val                                 := by rw [one_mul_thm u2.val]
      _ = 1                                                         := unitInv_val_left u2
  have h_inv_r : (u1.val * u2.val) * (unitInv (unitMul u1 u2)).val = 1 := unitInv_val_right (unitMul u1 u2)
  have h_inv_l : (unitInv (unitMul u1 u2)).val * (u1.val * u2.val) = 1 := unitInv_val_left (unitMul u1 u2)
  exact (unit_inv_unique (u1.val * u2.val) (unitInv (unitMul u1 u2)).val ((unitInv u2).val * (unitInv u1).val)
    ⟨h_inv_r, h_inv_l⟩ ⟨h_prod_r, h_prod_l⟩)

structure MyMonoidHom (M N : Type _) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ x y : M, toFun (x * y) = toFun x * toFun y

instance (M N : Type _) [MyMonoid M] [MyMonoid N] : CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

theorem map_isUnit {M N : Type _} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (u : M) (h : IsUnit M u) : IsUnit N (f u) := by
  rcases h with ⟨v, hv_r, hv_l⟩
  refine ⟨f v, ?_, ?_⟩
  · rw [← f.map_mul', hv_r, f.map_one']
  · rw [← f.map_mul', hv_l, f.map_one']

def mapUnits {M N : Type _} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) : MyMonoidHom (MyUnits M) (MyUnits N) where
  toFun u := ⟨f u.val, map_isUnit f u.val u.is_unit⟩
  map_one' := by
    apply MyUnits.ext
    dsimp
    exact f.map_one'
  map_mul' x y := by
    apply MyUnits.ext
    dsimp [instMyMonoidUnits, unitMul]
    exact f.map_mul' x.val y.val

noncomputable instance instMyCommGroupUnits (M : Type _) [MyCommMonoid M] : MyCommGroup (MyUnits M) where
  mul_comm a b := by
    apply MyUnits.ext
    dsimp [instMyMonoidUnits, unitMul]
    exact mul_comm_thm a.val b.val

