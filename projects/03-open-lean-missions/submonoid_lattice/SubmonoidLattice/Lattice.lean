import SubmonoidLattice.Basic
import SubmonoidLattice.Closure

namespace SubmonoidLattice

variable {M : Type u} [MyMonoid M]

def sInf (family : Submonoid M → Prop) : Submonoid M where
  carrier x := ∀ S : Submonoid M, family S → S.carrier x
  one_mem S hS := S.one_mem
  mul_mem ha hb S hS := S.mul_mem (ha S hS) (hb S hS)

theorem sInf_le {family : Submonoid M → Prop} (S : Submonoid M) (hS : family S) :
    sInf family ≤ S :=
  fun {x} hx => hx S hS

theorem le_sInf {family : Submonoid M → Prop} (T : Submonoid M) (h : ∀ S : Submonoid M, family S → T ≤ S) :
    T ≤ sInf family :=
  fun {x} hx S hS => (h S hS) hx

def sSup (family : Submonoid M → Prop) : Submonoid M :=
  closure (fun x => ∃ S : Submonoid M, family S ∧ S.carrier x)

theorem le_sSup {family : Submonoid M → Prop} (S : Submonoid M) (hS : family S) :
    S ≤ sSup family :=
  fun {x} hx => subset_closure _ x ⟨S, hS, hx⟩

theorem sSup_le {family : Submonoid M → Prop} (T : Submonoid M) (h : ∀ S : Submonoid M, family S → S ≤ T) :
    sSup family ≤ T := by
  apply closure_le_submonoid T
  intro x ⟨S, hS, hx⟩
  exact h S hS hx

def bot : Submonoid M where
  carrier x := x = 1
  one_mem := rfl
  mul_mem {a b} ha hb := by
    change MyMonoid.mul a b = 1
    rw [ha, hb]
    exact MyMonoid.one_mul 1

theorem bot_le (S : Submonoid M) : bot ≤ S := by
  intro x hx
  change x = 1 at hx
  rw [hx]
  exact S.one_mem

end SubmonoidLattice
