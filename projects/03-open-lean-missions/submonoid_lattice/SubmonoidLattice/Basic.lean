namespace SubmonoidLattice

class MyMonoid (M : Type u) where
  mul : M → M → M
  one : M
  mul_assoc : ∀ a b c : M, mul (mul a b) c = mul a (mul b c)
  one_mul : ∀ a : M, mul one a = a
  mul_one : ∀ a : M, mul a one = a

instance (M : Type u) [MyMonoid M] : Mul M := ⟨MyMonoid.mul⟩
instance (M : Type u) [MyMonoid M] : One M := ⟨MyMonoid.one⟩

variable {M : Type u} [MyMonoid M]

structure Submonoid (M : Type u) [MyMonoid M] where
  carrier : M → Prop
  one_mem : carrier 1
  mul_mem : ∀ {a b : M}, carrier a → carrier b → carrier (a * b)

def Submonoid.le (S T : Submonoid M) : Prop :=
  ∀ {x : M}, S.carrier x → T.carrier x

instance : LE (Submonoid M) := ⟨Submonoid.le⟩

theorem le_refl (S : Submonoid M) : S ≤ S :=
  fun h => h

theorem le_trans {S T U : Submonoid M} (hST : S ≤ T) (hTU : T ≤ U) : S ≤ U :=
  fun h => hTU (hST h)

def inf (S T : Submonoid M) : Submonoid M where
  carrier x := S.carrier x ∧ T.carrier x
  one_mem := ⟨S.one_mem, T.one_mem⟩
  mul_mem ha hb := ⟨S.mul_mem ha.1 hb.1, T.mul_mem ha.2 hb.2⟩

instance : Min (Submonoid M) := ⟨inf⟩

scoped infixl:70 " ⊓ " => inf

theorem inf_le_left (S T : Submonoid M) : S ⊓ T ≤ S :=
  fun h => h.1

theorem inf_le_right (S T : Submonoid M) : S ⊓ T ≤ T :=
  fun h => h.2

theorem le_inf {S T U : Submonoid M} (hUS : U ≤ S) (hUT : U ≤ T) : U ≤ S ⊓ T :=
  fun h => ⟨hUS h, hUT h⟩

def top : Submonoid M where
  carrier _ := True
  one_mem := True.intro
  mul_mem _ _ := True.intro

theorem le_top (S : Submonoid M) : S ≤ top :=
  fun _ => True.intro

inductive InClosure (X : M → Prop) : M → Prop where
  | of (x : M) : X x → InClosure X x
  | one : InClosure X 1
  | mul {a b : M} : InClosure X a → InClosure X b → InClosure X (a * b)

def closure (X : M → Prop) : Submonoid M where
  carrier := InClosure X
  one_mem := InClosure.one
  mul_mem := InClosure.mul

end SubmonoidLattice
