import DistributiveLattice.Basic
import DistributiveLattice.Distributive

namespace DistributiveLattice

variable {α : Type u} [BooleanAlgebra α]

theorem is_complement_compl (a : α) : IsComplement a (∼a) :=
  ⟨BooleanAlgebra.inf_compl_self a, BooleanAlgebra.sup_compl_self a⟩

theorem compl_unique {a b : α} (h : IsComplement a b) : b = ∼a :=
  complement_unique h (is_complement_compl a)

theorem compl_compl (a : α) : ∼(∼a) = a := by
  have h1 : IsComplement (∼a) a := complement_symm (is_complement_compl a)
  have h2 : IsComplement (∼a) (∼(∼a)) := is_complement_compl (∼a)
  exact (complement_unique h1 h2).symm

theorem de_morgan_sup (a b : α) : ∼(a ⊔ b) = ∼a ⊓ ∼b := by
  have h_comp : IsComplement (a ⊔ b) (∼a ⊓ ∼b) := by
    constructor
    · -- (a ⊔ b) ⊓ (∼a ⊓ ∼b) = ⊥
      have h1 : (a ⊔ b) ⊓ (∼a ⊓ ∼b) = (a ⊓ (∼a ⊓ ∼b)) ⊔ (b ⊓ (∼a ⊓ ∼b)) := by
        rw [Lattice.inf_comm, DistributiveLattice.inf_sup_distrib, Lattice.inf_comm (∼a ⊓ ∼b) a, Lattice.inf_comm (∼a ⊓ ∼b) b]
      have h2 : a ⊓ (∼a ⊓ ∼b) = (a ⊓ ∼a) ⊓ ∼b := by
        rw [← Lattice.inf_assoc]
      have h3 : (a ⊓ ∼a) ⊓ ∼b = ⊥ ⊓ ∼b := by
        rw [BooleanAlgebra.inf_compl_self a]
      have h4 : ⊥ ⊓ ∼b = ⊥ := BoundedDistributiveLattice.bot_inf (∼b)
      have ha : a ⊓ (∼a ⊓ ∼b) = ⊥ := by rw [h2, h3, h4]

      have h5 : b ⊓ (∼a ⊓ ∼b) = (b ⊓ ∼b) ⊓ ∼a := by
        rw [Lattice.inf_comm (∼a) (∼b), ← Lattice.inf_assoc]
      have h6 : (b ⊓ ∼b) ⊓ ∼a = ⊥ ⊓ ∼a := by
        rw [BooleanAlgebra.inf_compl_self b]
      have h7 : ⊥ ⊓ ∼a = ⊥ := BoundedDistributiveLattice.bot_inf (∼a)
      have hb : b ⊓ (∼a ⊓ ∼b) = ⊥ := by rw [h5, h6, h7]

      rw [h1, ha, hb, BoundedDistributiveLattice.bot_sup]
    · -- (a ⊔ b) ⊔ (∼a ⊓ ∼b) = ⊤
      have h1 : (a ⊔ b) ⊔ (∼a ⊓ ∼b) = ((a ⊔ b) ⊔ ∼a) ⊓ ((a ⊔ b) ⊔ ∼b) :=
        sup_inf_distrib (a ⊔ b) (∼a) (∼b)
      have h2 : (a ⊔ b) ⊔ ∼a = (b ⊔ a) ⊔ ∼a := by rw [Lattice.sup_comm a b]
      have h3 : (b ⊔ a) ⊔ ∼a = b ⊔ (a ⊔ ∼a) := Lattice.sup_assoc b a (∼a)
      have h4 : b ⊔ (a ⊔ ∼a) = b ⊔ ⊤ := by rw [BooleanAlgebra.sup_compl_self a]
      have h5 : b ⊔ ⊤ = ⊤ := by rw [Lattice.sup_comm, BoundedDistributiveLattice.top_sup]
      have ha : (a ⊔ b) ⊔ ∼a = ⊤ := by rw [h2, h3, h4, h5]

      have h6 : (a ⊔ b) ⊔ ∼b = a ⊔ (b ⊔ ∼b) := Lattice.sup_assoc a b (∼b)
      have h7 : a ⊔ (b ⊔ ∼b) = a ⊔ ⊤ := by rw [BooleanAlgebra.sup_compl_self b]
      have h8 : a ⊔ ⊤ = ⊤ := by rw [Lattice.sup_comm, BoundedDistributiveLattice.top_sup]
      have hb : (a ⊔ b) ⊔ ∼b = ⊤ := by rw [h6, h7, h8]

      rw [h1, ha, hb, Lattice.inf_comm, BoundedDistributiveLattice.top_inf]
  exact (compl_unique h_comp).symm

theorem de_morgan_inf (a b : α) : ∼(a ⊓ b) = ∼a ⊔ ∼b := by
  have h := de_morgan_sup (∼a) (∼b)
  rw [compl_compl a, compl_compl b] at h
  have h2 : ∼(a ⊓ b) = ∼(∼(∼a ⊔ ∼b)) := by rw [← h]
  rw [compl_compl] at h2
  exact h2

end DistributiveLattice
