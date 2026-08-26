import DistributiveLattice.Basic

namespace DistributiveLattice

variable {α : Type u}

theorem sup_inf_distrib [DistributiveLattice α] (a b c : α) :
    a ⊔ (b ⊓ c) = (a ⊔ b) ⊓ (a ⊔ c) := by
  have h1 : (a ⊔ b) ⊓ (a ⊔ c) = ((a ⊔ b) ⊓ a) ⊔ ((a ⊔ b) ⊓ c) := by
    rw [DistributiveLattice.inf_sup_distrib]
  have h2 : (a ⊔ b) ⊓ a = a := by
    rw [Lattice.inf_comm, Lattice.inf_sup_absorb]
  have h3 : (a ⊔ b) ⊓ c = (a ⊓ c) ⊔ (b ⊓ c) := by
    rw [Lattice.inf_comm, DistributiveLattice.inf_sup_distrib, Lattice.inf_comm c a, Lattice.inf_comm c b]
  have h4 : a ⊔ ((a ⊓ c) ⊔ (b ⊓ c)) = (a ⊔ (a ⊓ c)) ⊔ (b ⊓ c) := by
    rw [Lattice.sup_assoc]
  have h5 : a ⊔ (a ⊓ c) = a := Lattice.sup_inf_absorb a c
  rw [h1, h2, h3, h4, h5]

def IsComplement [BoundedDistributiveLattice α] (a b : α) : Prop :=
  a ⊓ b = ⊥ ∧ a ⊔ b = ⊤

theorem complement_symm [BoundedDistributiveLattice α] {a b : α} (h : IsComplement a b) : IsComplement b a := by
  constructor
  · rw [Lattice.inf_comm, h.1]
  · rw [Lattice.sup_comm, h.2]

theorem complement_unique [BoundedDistributiveLattice α] {a b1 b2 : α}
    (h1 : IsComplement a b1) (h2 : IsComplement a b2) : b1 = b2 := by
  have hb1 : b1 = b1 ⊓ b2 := by
    calc
      b1 = b1 ⊓ ⊤ := by rw [Lattice.inf_comm, BoundedDistributiveLattice.top_inf]
      _  = b1 ⊓ (a ⊔ b2) := by rw [h2.2]
      _  = (b1 ⊓ a) ⊔ (b1 ⊓ b2) := by rw [DistributiveLattice.inf_sup_distrib]
      _  = ⊥ ⊔ (b1 ⊓ b2) := by rw [Lattice.inf_comm b1 a, h1.1]
      _  = b1 ⊓ b2 := by rw [BoundedDistributiveLattice.bot_sup]

  have hb2 : b2 = b1 ⊓ b2 := by
    calc
      b2 = b2 ⊓ ⊤ := by rw [Lattice.inf_comm, BoundedDistributiveLattice.top_inf]
      _  = b2 ⊓ (a ⊔ b1) := by rw [h1.2]
      _  = (b2 ⊓ a) ⊔ (b2 ⊓ b1) := by rw [DistributiveLattice.inf_sup_distrib]
      _  = ⊥ ⊔ (b2 ⊓ b1) := by rw [Lattice.inf_comm b2 a, h2.1]
      _  = b2 ⊓ b1 := by rw [BoundedDistributiveLattice.bot_sup]
      _  = b1 ⊓ b2 := by rw [Lattice.inf_comm]

  exact hb1.trans hb2.symm

end DistributiveLattice
