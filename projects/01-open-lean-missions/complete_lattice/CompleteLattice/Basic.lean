namespace CompleteLattice

class PartialOrder (α : Type u) extends LE α where
  le_refl : ∀ a : α, a ≤ a
  le_trans : ∀ a b c : α, a ≤ b → b ≤ c → a ≤ c
  le_antisymm : ∀ a b : α, a ≤ b → b ≤ a → a = b

theorem refl {α : Type u} [PartialOrder α] (a : α) : a ≤ a :=
  PartialOrder.le_refl a

theorem trans {α : Type u} [PartialOrder α] {a b c : α} (h1 : a ≤ b) (h2 : b ≤ c) : a ≤ c :=
  PartialOrder.le_trans a b c h1 h2

theorem antisymm {α : Type u} [PartialOrder α] {a b : α} (h1 : a ≤ b) (h2 : b ≤ a) : a = b :=
  PartialOrder.le_antisymm a b h1 h2

class CompleteLattice (α : Type u) extends PartialOrder α where
  sSup : (α → Prop) → α
  sInf : (α → Prop) → α
  le_sSup : ∀ (s : α → Prop) (a : α), s a → a ≤ sSup s
  sSup_le : ∀ (s : α → Prop) (a : α), (∀ x, s x → x ≤ a) → sSup s ≤ a
  sInf_le : ∀ (s : α → Prop) (a : α), s a → sInf s ≤ a
  le_sInf : ∀ (s : α → Prop) (a : α), (∀ x, s x → a ≤ x) → a ≤ sInf s

def image {α : Type u} {β : Type v} (f : α → β) (s : α → Prop) : β → Prop :=
  fun y => ∃ x, s x ∧ f x = y

structure GaloisConnection {α : Type u} {β : Type v} [PartialOrder α] [PartialOrder β] (f : α → β) (g : β → α) : Prop where
  adjunction : ∀ (a : α) (b : β), f a ≤ b ↔ a ≤ g b

def Monotone {α : Type u} {β : Type v} [PartialOrder α] [PartialOrder β] (f : α → β) : Prop :=
  ∀ ⦃a b : α⦄, a ≤ b → f a ≤ f b

end CompleteLattice
