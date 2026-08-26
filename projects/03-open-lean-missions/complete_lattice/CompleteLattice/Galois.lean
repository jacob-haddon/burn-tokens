import CompleteLattice.Basic

namespace CompleteLattice

variable {α : Type u} {β : Type v}

theorem gc_unit [PartialOrder α] [PartialOrder β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (a : α) : a ≤ g (f a) :=
  (gc.adjunction a (f a)).mp (refl (f a))

theorem gc_counit [PartialOrder α] [PartialOrder β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (b : β) : f (g b) ≤ b :=
  (gc.adjunction (g b) b).mpr (refl (g b))

theorem gc_monotone_lower [PartialOrder α] [PartialOrder β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : Monotone f := by
  intro a b hab
  have h1 : a ≤ g (f b) := trans hab (gc_unit gc b)
  exact (gc.adjunction a (f b)).mpr h1

theorem gc_monotone_upper [PartialOrder α] [PartialOrder β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : Monotone g := by
  intro a b hab
  have h1 : f (g a) ≤ b := trans (gc_counit gc a) hab
  exact (gc.adjunction (g a) b).mp h1

theorem gc_preserves_sSup [CompleteLattice α] [CompleteLattice β]
    {f : α → β} {g : β → α} (gc : GaloisConnection f g) (s : α → Prop) :
    f (CompleteLattice.sSup s) = CompleteLattice.sSup (image f s) := by
  apply antisymm
  · -- f (sSup s) ≤ sSup (image f s)
    apply (gc.adjunction (CompleteLattice.sSup s) (CompleteLattice.sSup (image f s))).mpr
    apply CompleteLattice.sSup_le
    intro x hx
    apply (gc.adjunction x (CompleteLattice.sSup (image f s))).mp
    apply CompleteLattice.le_sSup (image f s) (f x)
    exact ⟨x, hx, rfl⟩
  · -- sSup (image f s) ≤ f (sSup s)
    apply CompleteLattice.sSup_le
    intro y hy
    rcases hy with ⟨x, hx, rfl⟩
    have hx_le : x ≤ CompleteLattice.sSup s := CompleteLattice.le_sSup s x hx
    exact gc_monotone_lower gc hx_le

theorem gc_preserves_sInf [CompleteLattice α] [CompleteLattice β]
    {f : α → β} {g : β → α} (gc : GaloisConnection f g) (t : β → Prop) :
    g (CompleteLattice.sInf t) = CompleteLattice.sInf (image g t) := by
  apply antisymm
  · -- g (sInf t) ≤ sInf (image g t)
    apply CompleteLattice.le_sInf
    intro x hx
    rcases hx with ⟨y, hy, rfl⟩
    have hy_le : CompleteLattice.sInf t ≤ y := CompleteLattice.sInf_le t y hy
    exact gc_monotone_upper gc hy_le
  · -- sInf (image g t) ≤ g (sInf t)
    apply (gc.adjunction (CompleteLattice.sInf (image g t)) (CompleteLattice.sInf t)).mp
    apply CompleteLattice.le_sInf
    intro y hy
    apply (gc.adjunction (CompleteLattice.sInf (image g t)) y).mpr
    apply CompleteLattice.sInf_le (image g t) (g y)
    exact ⟨y, hy, rfl⟩

end CompleteLattice
