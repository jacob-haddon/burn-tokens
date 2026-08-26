namespace DistributiveLattice

class Lattice (α : Type u) where
  inf : α → α → α
  sup : α → α → α
  inf_assoc : ∀ a b c : α, inf (inf a b) c = inf a (inf b c)
  inf_comm : ∀ a b : α, inf a b = inf b a
  inf_idem : ∀ a : α, inf a a = a
  sup_assoc : ∀ a b c : α, sup (sup a b) c = sup a (sup b c)
  sup_comm : ∀ a b : α, sup a b = sup b a
  sup_idem : ∀ a : α, sup a a = a
  inf_sup_absorb : ∀ a b : α, inf a (sup a b) = a
  sup_inf_absorb : ∀ a b : α, sup a (inf a b) = a

scoped infixl:70 " ⊓ " => Lattice.inf
scoped infixl:65 " ⊔ " => Lattice.sup

class DistributiveLattice (α : Type u) extends Lattice α where
  inf_sup_distrib : ∀ a b c : α, inf a (sup b c) = sup (inf a b) (inf a c)

class BoundedDistributiveLattice (α : Type u) extends DistributiveLattice α where
  bot : α
  top : α
  bot_inf : ∀ a : α, inf bot a = bot
  bot_sup : ∀ a : α, sup bot a = a
  top_inf : ∀ a : α, inf top a = a
  top_sup : ∀ a : α, sup top a = top

scoped notation "⊥" => BoundedDistributiveLattice.bot
scoped notation "⊤" => BoundedDistributiveLattice.top

class BooleanAlgebra (α : Type u) extends BoundedDistributiveLattice α where
  compl : α → α
  inf_compl_self : ∀ a : α, inf a (compl a) = bot
  sup_compl_self : ∀ a : α, sup a (compl a) = top

scoped prefix:75 "∼" => BooleanAlgebra.compl

def le {α : Type u} [Lattice α] (a b : α) : Prop :=
  a ⊓ b = a

scoped infix:50 " ≼ " => le

theorem le_refl {α : Type u} [Lattice α] (a : α) : a ≼ a :=
  Lattice.inf_idem a

theorem le_antisymm {α : Type u} [Lattice α] {a b : α} (h1 : a ≼ b) (h2 : b ≼ a) : a = b := by
  have h1' : a ⊓ b = a := h1
  have h2' : b ⊓ a = b := h2
  rw [← h1', Lattice.inf_comm, h2']

theorem le_trans {α : Type u} [Lattice α] {a b c : α} (h1 : a ≼ b) (h2 : b ≼ c) : a ≼ c := by
  change a ⊓ c = a
  have h1' : a ⊓ b = a := h1
  have h2' : b ⊓ c = b := h2
  rw [← h1', Lattice.inf_assoc, h2', h1']

theorem le_iff_sup_eq {α : Type u} [Lattice α] (a b : α) : a ≼ b ↔ a ⊔ b = b := by
  constructor
  · intro h
    have h_inf : a ⊓ b = a := h
    rw [← h_inf, Lattice.sup_comm, Lattice.inf_comm, Lattice.sup_inf_absorb]
  · intro h
    change a ⊓ b = a
    rw [← h, Lattice.inf_sup_absorb]

end DistributiveLattice
