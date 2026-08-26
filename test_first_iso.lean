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

structure MyMonoidHom (M N : Type _) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ x y : M, toFun (x * y) = toFun x * toFun y

instance (M N : Type _) [MyMonoid M] [MyMonoid N] : CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

structure MonoidCongruence (M : Type _) [MyMonoid M] where
  rel : M → M → Prop
  iseqv : Equivalence rel
  mul_compat : ∀ a1 a2 b1 b2 : M, rel a1 a2 → rel b1 b2 → rel (a1 * b1) (a2 * b2)

def MonoidCongruence.toSetoid {M : Type _} [MyMonoid M] (R : MonoidCongruence M) : Setoid M :=
  ⟨R.rel, R.iseqv⟩

def quotMul {M : Type _} [MyMonoid M] (R : MonoidCongruence M) :
    Quotient R.toSetoid → Quotient R.toSetoid → Quotient R.toSetoid :=
  Quotient.lift₂ (fun a b => ⟦a * b⟧) (fun a1 b1 a2 b2 h1 h2 => Quotient.sound (R.mul_compat a1 a2 b1 b2 h1 h2))

instance instMyMonoidQuotient {M : Type _} [MyMonoid M] (R : MonoidCongruence M) :
    MyMonoid (Quotient R.toSetoid) where
  mul := quotMul R
  one := ⟦1⟧
  mul_assoc qa qb qc := by
    induction qa using Quotient.inductionOn
    induction qb using Quotient.inductionOn
    induction qc using Quotient.inductionOn
    apply Quotient.sound
    dsimp
    have : (instMyMonoidQuotient R).toSetoid = R.toSetoid := rfl
    rw [mul_assoc_thm]
    exact R.iseqv.1 (qa * (qb * qc))
  one_mul qa := by
    induction qa using Quotient.inductionOn
    apply Quotient.sound
    rw [one_mul_thm]
    exact R.iseqv.1 qa
  mul_one qa := by
    induction qa using Quotient.inductionOn
    apply Quotient.sound
    rw [mul_one_thm]
    exact R.iseqv.1 qa

def projHom {M : Type _} [MyMonoid M] (R : MonoidCongruence M) :
    MyMonoidHom M (Quotient R.toSetoid) where
  toFun x := ⟦x⟧
  map_one' := rfl
  map_mul' x y := rfl

def kerCongruence {M N : Type _} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) : MonoidCongruence M where
  rel a b := f a = f b
  iseqv := {
    refl := fun _ => rfl
    symm := fun h => h.symm
    trans := fun h1 h2 => h1.trans h2
  }
  mul_compat := by
    intro a1 a2 b1 b2 h1 h2
    dsimp at *
    calc
      f (a1 * b1) = f a1 * f b1 := f.map_mul' a1 b1
      _           = f a2 * f b2 := by rw [h1, h2]
      _           = f (a2 * b2) := (f.map_mul' a2 b2).symm

structure MonoidRange {M N : Type _} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N) where
  val : N
  mem : ∃ x : M, f x = val

@[ext]
theorem MonoidRange.ext {M N : Type _} [MyMonoid M] [MyMonoid N] {f : MyMonoidHom M N}
    {r1 r2 : MonoidRange f} (h : r1.val = r2.val) : r1 = r2 := by
  cases r1
  cases r2
  congr

instance instMyMonoidRange {M N : Type _} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N) :
    MyMonoid (MonoidRange f) where
  mul r1 r2 := ⟨r1.val * r2.val, by
    rcases r1.mem with ⟨x1, hx1⟩
    rcases r2.mem with ⟨x2, hx2⟩
    refine ⟨x1 * x2, ?_⟩
    rw [f.map_mul', hx1, hx2]⟩
  one := ⟨1, ⟨1, f.map_one'⟩⟩
  mul_assoc a b c := by
    apply MonoidRange.ext
    exact mul_assoc_thm a.val b.val c.val
  one_mul a := by
    apply MonoidRange.ext
    exact one_mul_thm a.val
  mul_one a := by
    apply MonoidRange.ext
    exact mul_one_thm a.val

def firstIsoHom {M N : Type _} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N) :
    MyMonoidHom (Quotient (kerCongruence f).toSetoid) (MonoidRange f) where
  toFun := Quotient.lift (fun x => ⟨f x, ⟨x, rfl⟩⟩) (by
    intro a b (h : f a = f b)
    apply MonoidRange.ext
    exact h)
  map_one' := by
    apply MonoidRange.ext
    exact f.map_one'
  map_mul' := by
    intro qa qb
    induction qa using Quotient.inductionOn
    induction qb using Quotient.inductionOn
    apply MonoidRange.ext
    exact f.map_mul' _ _

theorem firstIsoHom_injective {M N : Type _} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N)
    (q1 q2 : Quotient (kerCongruence f).toSetoid)
    (h : firstIsoHom f q1 = firstIsoHom f q2) : q1 = q2 := by
  induction q1 using Quotient.inductionOn
  induction q2 using Quotient.inductionOn
  have h_val : (firstIsoHom f ⟦q1⟧).val = (firstIsoHom f ⟦q2⟧).val := by rw [h]
  apply Quotient.sound
  exact h_val

theorem firstIsoHom_surjective {M N : Type _} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N)
    (r : MonoidRange f) : ∃ q : Quotient (kerCongruence f).toSetoid, firstIsoHom f q = r := by
  rcases r.mem with ⟨x, hx⟩
  refine ⟨⟦x⟧, ?_⟩
  apply MonoidRange.ext
  dsimp [firstIsoHom]
  exact hx

structure MyMonoidIso (A B : Type _) [MyMonoid A] [MyMonoid B] where
  toHom : MyMonoidHom A B
  invHom : MyMonoidHom B A
  hom_inv_id : ∀ a : A, invHom (toHom a) = a
  inv_hom_id : ∀ b : B, toHom (invHom b) = b

noncomputable def firstMonoidIso {M N : Type _} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N) :
    MyMonoidIso (Quotient (kerCongruence f).toSetoid) (MonoidRange f) where
  toHom := firstIsoHom f
  invHom := {
    toFun r := Classical.choose (firstIsoHom_surjective f r)
    map_one' := by
      have h := Classical.choose_spec (firstIsoHom_surjective f 1)
      apply firstIsoHom_injective f
      rw [h, (firstIsoHom f).map_one']
    map_mul' r1 r2 := by
      have h1 := Classical.choose_spec (firstIsoHom_surjective f r1)
      have h2 := Classical.choose_spec (firstIsoHom_surjective f r2)
      have h12 := Classical.choose_spec (firstIsoHom_surjective f (r1 * r2))
      apply firstIsoHom_injective f
      rw [h12, (firstIsoHom f).map_mul', h1, h2]
  }
  hom_inv_id q := by
    have h := Classical.choose_spec (firstIsoHom_surjective f (firstIsoHom f q))
    exact firstIsoHom_injective f h
  inv_hom_id r := Classical.choose_spec (firstIsoHom_surjective f r)

