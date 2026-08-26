import SubmonoidLattice.Basic

namespace SubmonoidLattice

variable {M : Type u} [MyMonoid M]

theorem subset_closure (X : M → Prop) (x : M) (h : X x) : (closure X).carrier x :=
  InClosure.of x h

theorem closure_le_submonoid {X : M → Prop} (S : Submonoid M) (h : ∀ x : M, X x → S.carrier x) :
    closure X ≤ S := by
  intro x hx
  induction hx with
  | of a ha => exact h a ha
  | one => exact S.one_mem
  | mul _ _ iha ihb => exact S.mul_mem iha ihb

theorem closure_mono {X Y : M → Prop} (hXY : ∀ x : M, X x → Y x) :
    closure X ≤ closure Y :=
  closure_le_submonoid (closure Y) (fun x hx => subset_closure Y x (hXY x hx))

theorem closure_idem (X : M → Prop) :
    closure (closure X).carrier ≤ closure X :=
  closure_le_submonoid (closure X) (fun _ h => h)

def sup (S T : Submonoid M) : Submonoid M :=
  closure (fun x => S.carrier x ∨ T.carrier x)

scoped infixl:65 " ⊔ " => sup

theorem le_sup_left (S T : Submonoid M) : S ≤ S ⊔ T :=
  fun {x} hx => subset_closure (fun y => S.carrier y ∨ T.carrier y) x (Or.inl hx)

theorem le_sup_right (S T : Submonoid M) : T ≤ S ⊔ T :=
  fun {x} hx => subset_closure (fun y => S.carrier y ∨ T.carrier y) x (Or.inr hx)

theorem sup_le {S T U : Submonoid M} (hSU : S ≤ U) (hTU : T ≤ U) : S ⊔ T ≤ U := by
  apply closure_le_submonoid U
  intro x hx
  cases hx with
  | inl hs => exact hSU hs
  | inr ht => exact hTU ht

end SubmonoidLattice
