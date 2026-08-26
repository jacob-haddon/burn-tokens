/-!
# Frobenius Reciprocity, Modular Galois Connections, and Lattice Isomorphisms

This module provides a standalone, first-principles formalization in Lean 4 of:
1. Bounded, modular, and distributive lattice structures and their algebraic order properties.
2. Galois connections (adjunctions) between lattices with unit/counit identities, closure idempotence, and join/meet preservation.
3. Grandis's Modular Connections (RM0, LM0) and characterizations (Theorems 3, 4, 5, 6 from Goswami-Janelidze-Manuell 2025, arXiv:2502.06010).
4. Lawvere's **Frobenius Reciprocity** (`f (a ⊓ g b) = f a ⊓ b`) and Grandis's **Modular Connections** (`g (f a ⊔ b) = a ⊔ g b`) with characterization via image closure (Theorems 7 & 8).
5. Interval sublattices, order isomorphisms, the classical Dedekind Diamond Isomorphism Theorem, and the Galois-induced Interval Lattice Isomorphism Theorem.

All definitions and proofs are machine-checked with 0 `sorry` and 0 Mathlib dependencies.
-/

namespace FrobeniusModularLattice

/-! ### 1. Lattice Axioms and Fundamental Order Properties -/

class Lattice (α : Type u) where
  meet : α → α → α
  join : α → α → α
  meet_assoc : ∀ a b c : α, meet (meet a b) c = meet a (meet b c)
  meet_comm : ∀ a b : α, meet a b = meet b a
  meet_idem : ∀ a : α, meet a a = a
  join_assoc : ∀ a b c : α, join (join a b) c = join a (join b c)
  join_comm : ∀ a b : α, join a b = join b a
  join_idem : ∀ a : α, join a a = a
  meet_join_absorb : ∀ a b : α, meet a (join a b) = a
  join_meet_absorb : ∀ a b : α, join a (meet a b) = a

scoped infixl:70 " ⊓ " => Lattice.meet
scoped infixl:65 " ⊔ " => Lattice.join

def le {α : Type u} [Lattice α] (a b : α) : Prop :=
  a ⊓ b = a

scoped infix:50 " ≤ " => le

theorem le_refl {α : Type u} [Lattice α] (a : α) : a ≤ a :=
  Lattice.meet_idem a

theorem le_antisymm {α : Type u} [Lattice α] {a b : α} (h1 : a ≤ b) (h2 : b ≤ a) : a = b := by
  have h1' : a ⊓ b = a := h1
  have h2' : b ⊓ a = b := h2
  rw [← h1', Lattice.meet_comm, h2']

theorem le_trans {α : Type u} [Lattice α] {a b c : α} (h1 : a ≤ b) (h2 : b ≤ c) : a ≤ c := by
  change a ⊓ c = a
  have h1' : a ⊓ b = a := h1
  have h2' : b ⊓ c = b := h2
  rw [← h1', Lattice.meet_assoc, h2', h1']

theorem le_iff_join_eq {α : Type u} [Lattice α] (a b : α) : a ≤ b ↔ a ⊔ b = b := by
  constructor
  · intro h
    have h_inf : a ⊓ b = a := h
    rw [← h_inf, Lattice.join_comm, Lattice.meet_comm, Lattice.join_meet_absorb]
  · intro h
    change a ⊓ b = a
    rw [← h, Lattice.meet_join_absorb]

theorem meet_le_left {α : Type u} [Lattice α] (a b : α) : a ⊓ b ≤ a := by
  change (a ⊓ b) ⊓ a = a ⊓ b
  rw [Lattice.meet_comm (a ⊓ b) a, ← Lattice.meet_assoc, Lattice.meet_comm a a, Lattice.meet_idem, Lattice.meet_comm]

theorem meet_le_right {α : Type u} [Lattice α] (a b : α) : a ⊓ b ≤ b := by
  change (a ⊓ b) ⊓ b = a ⊓ b
  rw [Lattice.meet_assoc, Lattice.meet_idem]

theorem le_meet {α : Type u} [Lattice α] {a b c : α} (h1 : a ≤ b) (h2 : a ≤ c) : a ≤ b ⊓ c := by
  change a ⊓ (b ⊓ c) = a
  have h1' : a ⊓ b = a := h1
  have h2' : a ⊓ c = a := h2
  rw [← Lattice.meet_assoc, h1', h2']

theorem left_le_join {α : Type u} [Lattice α] (a b : α) : a ≤ a ⊔ b := by
  rw [le_iff_join_eq]
  rw [← Lattice.join_assoc, Lattice.join_idem]

theorem right_le_join {α : Type u} [Lattice α] (a b : α) : b ≤ a ⊔ b := by
  rw [le_iff_join_eq]
  rw [← Lattice.join_assoc, Lattice.join_comm b a, Lattice.join_assoc, Lattice.join_idem]

theorem join_le {α : Type u} [Lattice α] {a b c : α} (h1 : a ≤ c) (h2 : b ≤ c) : a ⊔ b ≤ c := by
  rw [le_iff_join_eq] at *
  rw [Lattice.join_assoc, h2, h1]

theorem meet_mono {α : Type u} [Lattice α] {a b c d : α} (hab : a ≤ b) (hcd : c ≤ d) : a ⊓ c ≤ b ⊓ d :=
  le_meet (le_trans (meet_le_left a c) hab) (le_trans (meet_le_right a c) hcd)

theorem join_mono {α : Type u} [Lattice α] {a b c d : α} (hab : a ≤ b) (hcd : c ≤ d) : a ⊔ c ≤ b ⊔ d :=
  join_le (le_trans hab (left_le_join b d)) (le_trans hcd (right_le_join b d))

/-! ### 2. Bounded, Modular, and Distributive Lattices -/

class BoundedLattice (α : Type u) extends Lattice α where
  bot : α
  top : α
  bot_le : ∀ a : α, le bot a
  le_top : ∀ a : α, le a top

scoped notation "⊥" => BoundedLattice.bot
scoped notation "⊤" => BoundedLattice.top

theorem bot_le {α : Type u} [BoundedLattice α] (a : α) : ⊥ ≤ a :=
  BoundedLattice.bot_le a

theorem le_top {α : Type u} [BoundedLattice α] (a : α) : a ≤ ⊤ :=
  BoundedLattice.le_top a

theorem bot_meet {α : Type u} [BoundedLattice α] (a : α) : ⊥ ⊓ a = ⊥ :=
  bot_le a

theorem meet_bot {α : Type u} [BoundedLattice α] (a : α) : a ⊓ ⊥ = ⊥ := by
  rw [Lattice.meet_comm, bot_meet]

theorem top_join {α : Type u} [BoundedLattice α] (a : α) : ⊤ ⊔ a = ⊤ := by
  have h := le_top a
  rw [le_iff_join_eq] at h
  rw [Lattice.join_comm, h]

theorem join_top {α : Type u} [BoundedLattice α] (a : α) : a ⊔ ⊤ = ⊤ := by
  rw [Lattice.join_comm, top_join]

theorem bot_join {α : Type u} [BoundedLattice α] (a : α) : ⊥ ⊔ a = a := by
  have h := bot_le a
  rw [le_iff_join_eq] at h
  exact h

theorem join_bot {α : Type u} [BoundedLattice α] (a : α) : a ⊔ ⊥ = a := by
  rw [Lattice.join_comm, bot_join]

theorem top_meet {α : Type u} [BoundedLattice α] (a : α) : ⊤ ⊓ a = a := by
  rw [Lattice.meet_comm]
  exact le_top a

theorem meet_top {α : Type u} [BoundedLattice α] (a : α) : a ⊓ ⊤ = a :=
  le_top a

class ModularLattice (α : Type u) extends Lattice α where
  modular : ∀ a b c : α, a ≤ c → (a ⊔ b) ⊓ c = a ⊔ (b ⊓ c)

class DistributiveLattice (α : Type u) extends Lattice α where
  meet_join_distrib : ∀ a b c : α, a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c)

/-! ### 3. Galois Connections and Adjunction Identities -/

def Monotone {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) : Prop :=
  ∀ ⦃a b : α⦄, a ≤ b → f a ≤ f b

structure GaloisConnection {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) (g : β → α) : Prop where
  adjunction : ∀ (a : α) (b : β), f a ≤ b ↔ a ≤ g b

theorem gc_unit {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (a : α) : a ≤ g (f a) :=
  (gc.adjunction a (f a)).mp (le_refl (f a))

theorem gc_counit {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (b : β) : f (g b) ≤ b :=
  (gc.adjunction (g b) b).mpr (le_refl (g b))

theorem gc_monotone_lower {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : Monotone f := by
  intro a b hab
  have h1 : a ≤ g (f b) := le_trans hab (gc_unit gc b)
  exact (gc.adjunction a (f b)).mpr h1

theorem gc_monotone_upper {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : Monotone g := by
  intro a b hab
  have h1 : f (g a) ≤ b := le_trans (gc_counit gc a) hab
  exact (gc.adjunction (g a) b).mp h1

theorem gc_closure_idempotent_lower {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (a : α) : f (g (f a)) = f a := by
  apply le_antisymm
  · exact gc_counit gc (f a)
  · exact gc_monotone_lower gc (gc_unit gc a)

theorem gc_closure_idempotent_upper {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (b : β) : g (f (g b)) = g b := by
  apply le_antisymm
  · exact gc_monotone_upper gc (gc_counit gc b)
  · exact gc_unit gc (g b)

theorem gc_preserves_join {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (a b : α) : f (a ⊔ b) = f a ⊔ f b := by
  apply le_antisymm
  · rw [gc.adjunction]
    apply join_le
    · exact (gc.adjunction a (f a ⊔ f b)).mp (left_le_join (f a) (f b))
    · exact (gc.adjunction b (f a ⊔ f b)).mp (right_le_join (f a) (f b))
  · apply join_le
    · exact gc_monotone_lower gc (left_le_join a b)
    · exact gc_monotone_lower gc (right_le_join a b)

theorem gc_preserves_meet {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (a b : β) : g (a ⊓ b) = g a ⊓ g b := by
  apply le_antisymm
  · apply le_meet
    · exact gc_monotone_upper gc (meet_le_left a b)
    · exact gc_monotone_upper gc (meet_le_right a b)
  · rw [← gc.adjunction]
    apply le_meet
    · exact (gc.adjunction (g a ⊓ g b) a).mpr (meet_le_left (g a) (g b))
    · exact (gc.adjunction (g a ⊓ g b) b).mpr (meet_le_right (g a) (g b))

theorem gc_preserves_bot {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : f ⊥ = ⊥ := by
  apply le_antisymm
  · rw [gc.adjunction]
    exact bot_le (g ⊥)
  · exact bot_le (f ⊥)

theorem gc_preserves_top {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : g ⊤ = ⊤ := by
  apply le_antisymm
  · exact le_top (g ⊤)
  · rw [← gc.adjunction]
    exact le_top (f ⊤)

theorem gc_frobenius_le {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (a : α) (b : β) : f (a ⊓ g b) ≤ f a ⊓ b := by
  apply le_meet
  · exact gc_monotone_lower gc (meet_le_left a (g b))
  · have h : f (a ⊓ g b) ≤ f (g b) := gc_monotone_lower gc (meet_le_right a (g b))
    exact le_trans h (gc_counit gc b)

theorem gc_modular_le {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (a : α) (b : β) : a ⊔ g b ≤ g (f a ⊔ b) := by
  apply join_le
  · have h : g (f a) ≤ g (f a ⊔ b) := gc_monotone_upper gc (left_le_join (f a) b)
    exact le_trans (gc_unit gc a) h
  · exact gc_monotone_upper gc (right_le_join (f a) b)

/-! ### 4. Frobenius Reciprocity & Modular Connections (Goswami-Janelidze-Manuell 2025) -/

/-- Lawvere's Frobenius reciprocity law (LF0). -/
def FrobeniusReciprocity {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (a : α) (b : β), f (a ⊓ g b) = f a ⊓ b

/-- Grandis's modular connection law (RF0). -/
def ModularConnection {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (a : α) (b : β), g (f a ⊔ b) = a ⊔ g b

/-- Down-closed direct image condition (LF1). -/
def DownClosedImage {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) : Prop :=
  ∀ (c : β) (b : α), c ≤ f b → ∃ a : α, a ≤ b ∧ c = f a

/-- Up-closed direct image condition (RF1). -/
def UpClosedImage {α : Type u} {β : Type v} [Lattice α] [Lattice β] (g : β → α) : Prop :=
  ∀ (b : α) (c : β), g c ≤ b → ∃ d : β, c ≤ d ∧ b = g d

/-- Grandis lower modularity law (LM0). -/
def GrandisLM0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (y : β), f (g y) = y ⊓ f ⊤

/-- Grandis upper modularity law (RM0). -/
def GrandisRM0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (x : α), g (f x) = x ⊔ g ⊥

/-- Grandis LM2 condition (Theorem 3). -/
def GrandisLM2 {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (c d : β), c ≤ d → f (g c) = c ⊓ f (g d)

/-- Grandis LM3 condition (Theorem 3). -/
def GrandisLM3 {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (c d : β), f (g (c ⊓ d)) = c ⊓ f (g d)

/-- Grandis RM2 condition (Theorem 4). -/
def GrandisRM2 {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (a b : α), a ≤ b → g (f b) = b ⊔ g (f a)

/-- Grandis RM3 condition (Theorem 4). -/
def GrandisRM3 {α : Type u} {β : Type v} [Lattice α] [Lattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (a b : α), g (f (a ⊔ b)) = a ⊔ g (f b)

/-- Grandis RM4 condition (Theorem 5). -/
def GrandisRM4 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (a b : α), f a = f b → a ⊔ g ⊥ = b ⊔ g ⊥

/-- Grandis RM5 condition (Theorem 5). -/
def GrandisRM5 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (a b : α), f a ≤ f b → a ≤ b ⊔ g ⊥

/-- Grandis LM4 condition (Theorem 6). -/
def GrandisLM4 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (c d : β), g c = g d → c ⊓ f ⊤ = d ⊓ f ⊤

/-- Grandis LM5 condition (Theorem 6). -/
def GrandisLM5 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] (f : α → β) (g : β → α) : Prop :=
  ∀ (c d : β), g c ≤ g d → c ⊓ f ⊤ ≤ d

/-- Theorem 7 (Goswami-Janelidze-Manuell): Equivalence of Frobenius Reciprocity and Down-Closed Direct Image. -/
theorem frobenius_iff_down_closed {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : FrobeniusReciprocity f g ↔ DownClosedImage f := by
  constructor
  · intro hFrob c b hc
    have heq : f (b ⊓ g c) = f b ⊓ c := hFrob b c
    have hcinf : f b ⊓ c = c := by
      rw [Lattice.meet_comm]
      exact hc
    rw [hcinf] at heq
    refine ⟨b ⊓ g c, meet_le_left b (g c), heq.symm⟩
  · intro hDown a b
    apply le_antisymm
    · exact gc_frobenius_le gc a b
    · have h_le : f a ⊓ b ≤ f a := meet_le_left (f a) b
      rcases hDown (f a ⊓ b) a h_le with ⟨x, hx_le_a, hx_eq⟩
      have hx_le_b : f x ≤ b := by
        rw [← hx_eq]
        exact meet_le_right (f a) b
      have hx_le_gb : x ≤ g b := (gc.adjunction x b).mp hx_le_b
      have hx_le_meet : x ≤ a ⊓ g b := le_meet hx_le_a hx_le_gb
      have hf_mono : f x ≤ f (a ⊓ g b) := gc_monotone_lower gc hx_le_meet
      rw [hx_eq]
      exact hf_mono

/-- Theorem 8 (Goswami-Janelidze-Manuell): Equivalence of Modular Connection and Up-Closed Direct Image. -/
theorem modular_connection_iff_up_closed {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) : ModularConnection f g ↔ UpClosedImage g := by
  constructor
  · intro hMod b c hbc
    have heq : g (f b ⊔ c) = b ⊔ g c := hMod b c
    have hbjoin : b ⊔ g c = b := by
      rw [Lattice.join_comm]
      rw [le_iff_join_eq] at hbc
      exact hbc
    rw [hbjoin] at heq
    refine ⟨f b ⊔ c, right_le_join (f b) c, heq.symm⟩
  · intro hUp a b
    apply le_antisymm
    · have h_ge : g b ≤ a ⊔ g b := right_le_join a (g b)
      rcases hUp (a ⊔ g b) b h_ge with ⟨d, hd_ge_b, hd_eq⟩
      have ha_le_gd : a ≤ g d := by
        rw [← hd_eq]
        exact left_le_join a (g b)
      have hfa_le_d : f a ≤ d := (gc.adjunction a d).mpr ha_le_gd
      have h_join_le : f a ⊔ b ≤ d := join_le hfa_le_d hd_ge_b
      have hg_mono : g (f a ⊔ b) ≤ g d := gc_monotone_upper gc h_join_le
      rw [hd_eq]
      exact hg_mono
    · exact gc_modular_le gc a b

/-- Frobenius reciprocity specializes to Grandis LM0 on bounded lattices when b = ⊤. -/
theorem frobenius_implies_lm0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (hFrob : FrobeniusReciprocity f g) : GrandisLM0 f g := by
  intro y
  have h := hFrob ⊤ y
  rw [top_meet (g y)] at h
  rw [h, Lattice.meet_comm]

/-- Modular connection specializes to Grandis RM0 on bounded lattices when a = ⊥. -/
theorem modular_connection_implies_rm0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (hMod : ModularConnection f g) : GrandisRM0 f g := by
  intro x
  have h := hMod x ⊥
  rw [join_bot (f x)] at h
  exact h

/-! ### 5. Theorem 3, 4, 5, 6 Equivalences for Grandis Modularity -/

/-- Theorem 3: LM3 implies LM2. -/
theorem lm3_implies_lm2 {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (hLM3 : GrandisLM3 f g) : GrandisLM2 f g := by
  intro c d hcd
  have h : c ⊓ d = c := hcd
  have h3 := hLM3 c d
  rw [h] at h3
  exact h3

/-- Theorem 3: LM2 implies LM0 on bounded lattices. -/
theorem lm2_implies_lm0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (hLM2 : GrandisLM2 f g) : GrandisLM0 f g := by
  intro y
  have htop : y ≤ ⊤ := le_top y
  have h2 := hLM2 y ⊤ htop
  rw [gc_preserves_top gc] at h2
  exact h2

/-- Theorem 3: LM0 implies LM3 on bounded lattices. -/
theorem lm0_implies_lm3 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (hLM0 : GrandisLM0 f g) : GrandisLM3 f g := by
  intro c d
  have hc := hLM0 (c ⊓ d)
  have hd := hLM0 d
  rw [hc, hd, Lattice.meet_assoc]

/-- Theorem 4: RM3 implies RM2. -/
theorem rm3_implies_rm2 {α : Type u} {β : Type v} [Lattice α] [Lattice β] {f : α → β} {g : β → α}
    (hRM3 : GrandisRM3 f g) : GrandisRM2 f g := by
  intro a b hab
  have h : b ⊔ a = b := by
    rw [Lattice.join_comm]
    rw [le_iff_join_eq] at hab
    exact hab
  have h3 := hRM3 b a
  rw [h] at h3
  exact h3

/-- Theorem 4: RM2 implies RM0 on bounded lattices. -/
theorem rm2_implies_rm0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (hRM2 : GrandisRM2 f g) : GrandisRM0 f g := by
  intro x
  have hbot : ⊥ ≤ x := bot_le x
  have h2 := hRM2 ⊥ x hbot
  rw [gc_preserves_bot gc] at h2
  exact h2

/-- Theorem 4: RM0 implies RM3 on bounded lattices. -/
theorem rm0_implies_rm3 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (hRM0 : GrandisRM0 f g) : GrandisRM3 f g := by
  intro a b
  have hab := hRM0 (a ⊔ b)
  have hb := hRM0 b
  rw [hab, hb, Lattice.join_assoc]

/-- Theorem 5: RM0 implies RM5. -/
theorem rm0_implies_rm5 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (hRM0 : GrandisRM0 f g) : GrandisRM5 f g := by
  intro a b hfab
  have h1 : a ≤ g (f a) := gc_unit gc a
  have h2 : g (f a) ≤ g (f b) := gc_monotone_upper gc hfab
  have h3 : g (f b) = b ⊔ g ⊥ := hRM0 b
  rw [h3] at h2
  exact le_trans h1 h2

/-- Theorem 5: RM5 implies RM4. -/
theorem rm5_implies_rm4 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (hRM5 : GrandisRM5 f g) : GrandisRM4 f g := by
  intro a b hfab
  have h_fab_le : f a ≤ f b := by rw [hfab]; exact le_refl (f b)
  have h_fba_le : f b ≤ f a := by rw [hfab]; exact le_refl (f b)
  have h1 : a ≤ b ⊔ g ⊥ := hRM5 a b h_fab_le
  have h2 : b ≤ a ⊔ g ⊥ := hRM5 b a h_fba_le
  apply le_antisymm
  · apply join_le h1 (right_le_join b (g ⊥))
  · apply join_le h2 (right_le_join a (g ⊥))

/-- Theorem 5: RM4 implies RM0. -/
theorem rm4_implies_rm0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (hRM4 : GrandisRM4 f g) : GrandisRM0 f g := by
  intro x
  have h_idem : f (g (f x)) = f x := gc_closure_idempotent_lower gc x
  have h_eq : g (f x) ⊔ g ⊥ = x ⊔ g ⊥ := hRM4 (g (f x)) x h_idem
  have h_absorb : g (f x) ⊔ g ⊥ = g (f x) := by
    have h_bot_le : ⊥ ≤ f x := bot_le (f x)
    have h_g_bot_le : g ⊥ ≤ g (f x) := gc_monotone_upper gc h_bot_le
    rw [Lattice.join_comm]
    rw [le_iff_join_eq] at h_g_bot_le
    exact h_g_bot_le
  rw [h_absorb] at h_eq
  exact h_eq

/-- Theorem 6: LM0 implies LM5. -/
theorem lm0_implies_lm5 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (hLM0 : GrandisLM0 f g) : GrandisLM5 f g := by
  intro c d hgcd
  have h1 : c ⊓ f ⊤ = f (g c) := (hLM0 c).symm
  have h2 : f (g c) ≤ f (g d) := gc_monotone_lower gc hgcd
  have h3 : f (g d) ≤ d := gc_counit gc d
  rw [h1]
  exact le_trans h2 h3

/-- Theorem 6: LM5 implies LM4. -/
theorem lm5_implies_lm4 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (hLM5 : GrandisLM5 f g) : GrandisLM4 f g := by
  intro c d hgcd
  have h_cd_le : g c ≤ g d := by rw [hgcd]; exact le_refl (g d)
  have h_dc_le : g d ≤ g c := by rw [hgcd]; exact le_refl (g d)
  have h1 : c ⊓ f ⊤ ≤ d := hLM5 c d h_cd_le
  have h2 : d ⊓ f ⊤ ≤ c := hLM5 d c h_dc_le
  apply le_antisymm
  · apply le_meet h1 (meet_le_right c (f ⊤))
  · apply le_meet h2 (meet_le_right d (f ⊤))

/-- Theorem 6: LM4 implies LM0. -/
theorem lm4_implies_lm0 {α : Type u} {β : Type v} [BoundedLattice α] [BoundedLattice β] {f : α → β} {g : β → α}
    (gc : GaloisConnection f g) (hLM4 : GrandisLM4 f g) : GrandisLM0 f g := by
  intro y
  have h_idem : g (f (g y)) = g y := gc_closure_idempotent_upper gc y
  have h_eq : f (g y) ⊓ f ⊤ = y ⊓ f ⊤ := hLM4 (f (g y)) y h_idem
  have h_absorb : f (g y) ⊓ f ⊤ = f (g y) := by
    have h_top : g y ≤ ⊤ := le_top (g y)
    have h_f_top : f (g y) ≤ f ⊤ := gc_monotone_lower gc h_top
    exact h_f_top
  rw [h_absorb] at h_eq
  exact h_eq

/-! ### 6. Interval Sublattices -/

/-- The interval sublattice [l, u] = { x // l ≤ x ∧ x ≤ u }. -/
structure Interval {α : Type u} [Lattice α] (l u : α) where
  val : α
  lower_le : l ≤ val
  le_upper : val ≤ u

theorem interval_ext {α : Type u} [Lattice α] {l u : α} (x y : Interval l u) (h : x.val = y.val) : x = y := by
  rcases x with ⟨xv, xl, xu⟩
  rcases y with ⟨yv, yl, yu⟩
  subst h
  rfl

namespace Interval

def meet {α : Type u} [Lattice α] {l u : α} (x y : Interval l u) : Interval l u :=
  ⟨x.val ⊓ y.val,
   le_meet x.lower_le y.lower_le,
   le_trans (meet_le_left x.val y.val) x.le_upper⟩

def join {α : Type u} [Lattice α] {l u : α} (x y : Interval l u) : Interval l u :=
  ⟨x.val ⊔ y.val,
   le_trans x.lower_le (left_le_join x.val y.val),
   join_le x.le_upper y.le_upper⟩

instance {α : Type u} [Lattice α] {l u : α} : Lattice (Interval l u) where
  meet := meet
  join := join
  meet_assoc := fun a b c => interval_ext _ _ (Lattice.meet_assoc a.val b.val c.val)
  meet_comm := fun a b => interval_ext _ _ (Lattice.meet_comm a.val b.val)
  meet_idem := fun a => interval_ext _ _ (Lattice.meet_idem a.val)
  join_assoc := fun a b c => interval_ext _ _ (Lattice.join_assoc a.val b.val c.val)
  join_comm := fun a b => interval_ext _ _ (Lattice.join_comm a.val b.val)
  join_idem := fun a => interval_ext _ _ (Lattice.join_idem a.val)
  meet_join_absorb := fun a b => interval_ext _ _ (Lattice.meet_join_absorb a.val b.val)
  join_meet_absorb := fun a b => interval_ext _ _ (Lattice.join_meet_absorb a.val b.val)

theorem interval_le_iff {α : Type u} [Lattice α] {l u : α} (x y : Interval l u) : x ≤ y ↔ x.val ≤ y.val := by
  constructor
  · intro h
    have h_val : (x ⊓ y).val = x.val := congrArg Interval.val h
    exact h_val
  · intro h
    apply interval_ext
    exact h

instance {α : Type u} [ModularLattice α] {l u : α} : ModularLattice (Interval l u) where
  modular := fun a b c hac => by
    apply interval_ext
    have hac_val : a.val ≤ c.val := by
      rw [← interval_le_iff]
      exact hac
    exact ModularLattice.modular a.val b.val c.val hac_val

@[instance_reducible]
def bounded {α : Type u} [Lattice α] {l u : α} (hlu : l ≤ u) : BoundedLattice (Interval l u) where
  bot := ⟨l, le_refl l, hlu⟩
  top := ⟨u, hlu, le_refl u⟩
  bot_le := fun a => by
    rw [interval_le_iff]
    exact a.lower_le
  le_top := fun a => by
    rw [interval_le_iff]
    exact a.le_upper

end Interval

/-! ### 7. Order Isomorphisms & Lattice Isomorphism Theorems -/

/-- An order isomorphism between two lattices. -/
structure OrderIso (α : Type u) (β : Type v) [Lattice α] [Lattice β] where
  toFun : α → β
  invFun : β → α
  left_inv : ∀ x : α, invFun (toFun x) = x
  right_inv : ∀ y : β, toFun (invFun y) = y
  map_le_iff : ∀ x y : α, toFun x ≤ toFun y ↔ x ≤ y

namespace OrderIso

variable {α : Type u} {β : Type v} [Lattice α] [Lattice β]

theorem toFun_mono (iso : OrderIso α β) {x y : α} (h : x ≤ y) : iso.toFun x ≤ iso.toFun y :=
  (iso.map_le_iff x y).mpr h

theorem invFun_mono (iso : OrderIso α β) {x y : β} (h : x ≤ y) : iso.invFun x ≤ iso.invFun y := by
  rw [← iso.map_le_iff (iso.invFun x) (iso.invFun y)]
  rw [iso.right_inv x, iso.right_inv y]
  exact h

theorem map_meet (iso : OrderIso α β) (x y : α) : iso.toFun (x ⊓ y) = iso.toFun x ⊓ iso.toFun y := by
  apply le_antisymm
  · apply le_meet
    · exact iso.toFun_mono (meet_le_left x y)
    · exact iso.toFun_mono (meet_le_right x y)
  · let z := iso.toFun x ⊓ iso.toFun y
    have hz_le_x : iso.invFun z ≤ x := by
      have h1 : z ≤ iso.toFun x := meet_le_left (iso.toFun x) (iso.toFun y)
      have h2 := iso.invFun_mono h1
      rw [iso.left_inv x] at h2
      exact h2
    have hz_le_y : iso.invFun z ≤ y := by
      have h1 : z ≤ iso.toFun y := meet_le_right (iso.toFun x) (iso.toFun y)
      have h2 := iso.invFun_mono h1
      rw [iso.left_inv y] at h2
      exact h2
    have hz_le_meet : iso.invFun z ≤ x ⊓ y := le_meet hz_le_x hz_le_y
    have h_to := iso.toFun_mono hz_le_meet
    rw [iso.right_inv z] at h_to
    exact h_to

theorem map_join (iso : OrderIso α β) (x y : α) : iso.toFun (x ⊔ y) = iso.toFun x ⊔ iso.toFun y := by
  apply le_antisymm
  · let w := iso.toFun x ⊔ iso.toFun y
    have hx_le_w : x ≤ iso.invFun w := by
      have h1 : iso.toFun x ≤ w := left_le_join (iso.toFun x) (iso.toFun y)
      have h2 := iso.invFun_mono h1
      rw [iso.left_inv x] at h2
      exact h2
    have hy_le_w : y ≤ iso.invFun w := by
      have h1 : iso.toFun y ≤ w := right_le_join (iso.toFun x) (iso.toFun y)
      have h2 := iso.invFun_mono h1
      rw [iso.left_inv y] at h2
      exact h2
    have h_join_le : x ⊔ y ≤ iso.invFun w := join_le hx_le_w hy_le_w
    have h_to := iso.toFun_mono h_join_le
    rw [iso.right_inv w] at h_to
    exact h_to
  · apply join_le
    · exact iso.toFun_mono (left_le_join x y)
    · exact iso.toFun_mono (right_le_join x y)

def symm (iso : OrderIso α β) : OrderIso β α where
  toFun := iso.invFun
  invFun := iso.toFun
  left_inv := iso.right_inv
  right_inv := iso.left_inv
  map_le_iff := fun x y => by
    constructor
    · intro h
      have h2 := iso.toFun_mono h
      rw [iso.right_inv x, iso.right_inv y] at h2
      exact h2
    · intro h
      exact iso.invFun_mono h

def refl (α : Type u) [Lattice α] : OrderIso α α where
  toFun := id
  invFun := id
  left_inv := fun _ => rfl
  right_inv := fun _ => rfl
  map_le_iff := fun _ _ => Iff.rfl

def trans {γ : Type w} [Lattice γ] (iso1 : OrderIso α β) (iso2 : OrderIso β γ) : OrderIso α γ where
  toFun := iso2.toFun ∘ iso1.toFun
  invFun := iso1.invFun ∘ iso2.invFun
  left_inv := fun x => by simp [iso1.left_inv, iso2.left_inv]
  right_inv := fun y => by simp [iso1.right_inv, iso2.right_inv]
  map_le_iff := fun x y => by
    simp [iso2.map_le_iff, iso1.map_le_iff]

end OrderIso

/-! ### 8. Dedekind's Diamond Isomorphism Theorem for Modular Lattices -/

/-- Dedekind's Second Isomorphism Theorem (Diamond Isomorphism Theorem) for modular lattices:
    The interval [a ⊓ b, b] is isomorphic to [a, a ⊔ b] via x ↦ x ⊔ a and y ↦ y ⊓ b. -/
def dedekind_diamond_isomorphism {α : Type u} [ModularLattice α] (a b : α) :
    OrderIso (Interval (a ⊓ b) b) (Interval a (a ⊔ b)) := by
  let to_f (x : Interval (a ⊓ b) b) : Interval a (a ⊔ b) :=
    ⟨x.val ⊔ a,
     right_le_join x.val a,
     join_le (le_trans x.le_upper (right_le_join a b)) (left_le_join a b)⟩
  let inv_f (y : Interval a (a ⊔ b)) : Interval (a ⊓ b) b :=
    ⟨y.val ⊓ b,
     le_meet (le_trans (meet_le_left a b) y.lower_le) (meet_le_right a b),
     meet_le_right y.val b⟩
  refine {
    toFun := to_f
    invFun := inv_f
    left_inv := ?_
    right_inv := ?_
    map_le_iff := ?_
  }
  · intro x
    apply interval_ext
    dsimp [to_f, inv_f]
    have h_xb : x.val ≤ b := x.le_upper
    have h_mod := ModularLattice.modular x.val a b h_xb
    rw [h_mod]
    have h_ax : a ⊓ b ≤ x.val := x.lower_le
    rw [le_iff_join_eq] at h_ax
    rw [Lattice.join_comm, h_ax]
  · intro y
    apply interval_ext
    dsimp [to_f, inv_f]
    have h_ay : a ≤ y.val := y.lower_le
    have h_mod := ModularLattice.modular a b y.val h_ay
    rw [Lattice.join_comm (y.val ⊓ b) a]
    rw [Lattice.meet_comm y.val b]
    rw [← h_mod]
    rw [Lattice.meet_comm (a ⊔ b) y.val]
    exact y.le_upper
  · intro x1 x2
    constructor
    · intro h
      rw [Interval.interval_le_iff] at h ⊢
      dsimp [to_f] at h
      have h_meet : (x1.val ⊔ a) ⊓ b ≤ (x2.val ⊔ a) ⊓ b := meet_mono h (le_refl b)
      have h_xb1 : x1.val ≤ b := x1.le_upper
      have h_mod1 := ModularLattice.modular x1.val a b h_xb1
      have h_ax1 : a ⊓ b ≤ x1.val := x1.lower_le
      rw [le_iff_join_eq] at h_ax1
      have h_eq1 : (x1.val ⊔ a) ⊓ b = x1.val := by
        rw [h_mod1, Lattice.join_comm, h_ax1]
      have h_xb2 : x2.val ≤ b := x2.le_upper
      have h_mod2 := ModularLattice.modular x2.val a b h_xb2
      have h_ax2 : a ⊓ b ≤ x2.val := x2.lower_le
      rw [le_iff_join_eq] at h_ax2
      have h_eq2 : (x2.val ⊔ a) ⊓ b = x2.val := by
        rw [h_mod2, Lattice.join_comm, h_ax2]
      rw [h_eq1, h_eq2] at h_meet
      exact h_meet
    · intro h
      rw [Interval.interval_le_iff] at h ⊢
      dsimp [to_f]
      exact join_mono h (le_refl a)

/-! ### 9. Galois Interval Isomorphism Theorem (Goswami-Janelidze-Manuell 2025) -/

/-- For a modular Galois connection satisfying Frobenius reciprocity and mutual retraction
    on intervals, the restrictions of f and g establish a canonical order isomorphism
    between interval sublattices [a ⊓ g b, g b] and [f a ⊓ b, b]. -/
def galois_interval_isomorphism {α : Type u} {β : Type v} [Lattice α] [Lattice β]
    {f : α → β} {g : β → α} (gc : GaloisConnection f g) (hFrob : FrobeniusReciprocity f g)
    (a : α) (b : β)
    (h_retract_lower : ∀ x : Interval (a ⊓ g b) (g b), g (f x.val) = x.val)
    (h_retract_upper : ∀ y : Interval (f a ⊓ b) b, f (g y.val) = y.val) :
    OrderIso (Interval (a ⊓ g b) (g b)) (Interval (f a ⊓ b) b) := by
  let to_f (x : Interval (a ⊓ g b) (g b)) : Interval (f a ⊓ b) b :=
    ⟨f x.val,
     by
       have h_low : a ⊓ g b ≤ x.val := x.lower_le
       have hf := gc_monotone_lower gc h_low
       rw [hFrob a b] at hf
       exact hf,
     by
       have h_up : x.val ≤ g b := x.le_upper
       have hf := gc_monotone_lower gc h_up
       exact le_trans hf (gc_counit gc b)⟩
  let inv_g (y : Interval (f a ⊓ b) b) : Interval (a ⊓ g b) (g b) :=
    ⟨g y.val,
     by
       have h_low : f a ⊓ b ≤ y.val := y.lower_le
       have hg := gc_monotone_upper gc h_low
       rw [gc_preserves_meet gc] at hg
       have h_a_le : a ≤ g (f a) := gc_unit gc a
       have h_meet_le : a ⊓ g b ≤ g (f a) ⊓ g b := meet_mono h_a_le (le_refl (g b))
       exact le_trans h_meet_le hg,
     by
       have h_up : y.val ≤ b := y.le_upper
       exact gc_monotone_upper gc h_up⟩
  refine {
    toFun := to_f
    invFun := inv_g
    left_inv := ?_
    right_inv := ?_
    map_le_iff := ?_
  }
  · intro x
    apply interval_ext
    dsimp [to_f, inv_g]
    exact h_retract_lower x
  · intro y
    apply interval_ext
    dsimp [to_f, inv_g]
    exact h_retract_upper y
  · intro x1 x2
    constructor
    · intro h
      rw [Interval.interval_le_iff] at h ⊢
      dsimp [to_f] at h
      have hg := gc_monotone_upper gc h
      have h1 := h_retract_lower x1
      have h2 := h_retract_lower x2
      rw [h1, h2] at hg
      exact hg
    · intro h
      rw [Interval.interval_le_iff] at h ⊢
      dsimp [to_f]
      exact gc_monotone_lower gc h

end FrobeniusModularLattice
