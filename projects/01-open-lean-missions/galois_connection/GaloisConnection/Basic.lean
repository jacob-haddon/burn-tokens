/-
  Autonomous Research Lab: Project 01 (Open Lean Missions)
  Mission: Formalisation of Galois Connections, Closure Operators, and Subposet Adjunctions in Lean 4
  Target: Standalone machine-checked Lean 4 formalization with 0 sorry and no extra axioms.
-/

namespace GaloisFormalization

universe u v

/-- A Preorder is a type equipped with a reflexive and transitive binary relation `≤`. -/
class MyPreorder (α : Type u) extends LE α where
  le_refl : ∀ a : α, a ≤ a
  le_trans : ∀ a b c : α, a ≤ b → b ≤ c → a ≤ c

theorem my_le_refl {α : Type u} [MyPreorder α] (a : α) : a ≤ a :=
  MyPreorder.le_refl a

theorem my_le_trans {α : Type u} [MyPreorder α] {a b c : α} (h1 : a ≤ b) (h2 : b ≤ c) : a ≤ c :=
  MyPreorder.le_trans a b c h1 h2

/-- A Partial Order is a preorder where `≤` is also antisymmetric. -/
class MyPartialOrder (α : Type u) extends MyPreorder α where
  le_antisymm : ∀ a b : α, a ≤ b → b ≤ a → a = b

theorem my_le_antisymm {α : Type u} [MyPartialOrder α] {a b : α} (h1 : a ≤ b) (h2 : b ≤ a) : a = b :=
  MyPartialOrder.le_antisymm a b h1 h2

/-- A Galois connection between two preorders `α` and `β` is a pair of functions
`f : α → β` (lower adjoint) and `g : β → α` (upper adjoint) satisfying
`f a ≤ b ↔ a ≤ g b` for all `a : α` and `b : β`. -/
def GaloisConnection {α : Type u} {β : Type v} [MyPreorder α] [MyPreorder β]
    (f : α → β) (g : β → α) : Prop :=
  ∀ a b, f a ≤ b ↔ a ≤ g b

section PreorderTheorems

variable {α : Type u} {β : Type v} [MyPreorder α] [MyPreorder β]
variable {f : α → β} {g : β → α}

/-- Adjoint unit inequality: `a ≤ g (f a)` for all `a`. -/
theorem gc_le_g_f (gc : GaloisConnection f g) (a : α) : a ≤ g (f a) := by
  have h : f a ≤ f a := my_le_refl (f a)
  exact (gc a (f a)).mp h

/-- Adjoint counit inequality: `f (g b) ≤ b` for all `b`. -/
theorem gc_f_g_le (gc : GaloisConnection f g) (b : β) : f (g b) ≤ b := by
  have h : g b ≤ g b := my_le_refl (g b)
  exact (gc (g b) b).mpr h

/-- The lower adjoint `f` preserves order (is monotone). -/
theorem gc_monotone_l (gc : GaloisConnection f g) ⦃a₁ a₂ : α⦄ (h : a₁ ≤ a₂) : f a₁ ≤ f a₂ := by
  have h2 : a₁ ≤ g (f a₂) := my_le_trans h (gc_le_g_f gc a₂)
  exact (gc a₁ (f a₂)).mpr h2

/-- The upper adjoint `g` preserves order (is monotone). -/
theorem gc_monotone_u (gc : GaloisConnection f g) ⦃b₁ b₂ : β⦄ (h : b₁ ≤ b₂) : g b₁ ≤ g b₂ := by
  have h2 : f (g b₁) ≤ b₂ := my_le_trans (gc_f_g_le gc b₁) h
  exact (gc (g b₁) b₂).mp h2

/-- Composition `g ∘ f` is monotone on `α`. -/
theorem gc_monotone_gf (gc : GaloisConnection f g) ⦃a₁ a₂ : α⦄ (h : a₁ ≤ a₂) :
    g (f a₁) ≤ g (f a₂) :=
  gc_monotone_u gc (gc_monotone_l gc h)

/-- Composition `f ∘ g` is monotone on `β`. -/
theorem gc_monotone_fg (gc : GaloisConnection f g) ⦃b₁ b₂ : β⦄ (h : b₁ ≤ b₂) :
    f (g b₁) ≤ f (g b₂) :=
  gc_monotone_l gc (gc_monotone_u gc h)

end PreorderTheorems

section PartialOrderTheorems

variable {α : Type u} {β : Type v} [MyPartialOrder α] [MyPartialOrder β]
variable {f : α → β} {g : β → α}

/-- First triangular cancellation identity: `f (g (f a)) = f a`. -/
theorem gc_f_g_f (gc : GaloisConnection f g) (a : α) : f (g (f a)) = f a := by
  apply my_le_antisymm
  · exact gc_f_g_le gc (f a)
  · exact gc_monotone_l gc (gc_le_g_f gc a)

/-- Second triangular cancellation identity: `g (f (g b)) = g b`. -/
theorem gc_g_f_g (gc : GaloisConnection f g) (b : β) : g (f (g b)) = g b := by
  apply my_le_antisymm
  · exact gc_monotone_u gc (gc_f_g_le gc b)
  · exact gc_le_g_f gc (g b)

/-- A Closure Operator on `α` is a monotone, extensive, idempotent endomorphism. -/
structure IsClosureOperator (c : α → α) : Prop where
  monotone : ∀ ⦃a b : α⦄, a ≤ b → c a ≤ c b
  extensive : ∀ a : α, a ≤ c a
  idempotent : ∀ a : α, c (c a) = c a

/-- A Kernel (Interior) Operator on `β` is a monotone, intensive, idempotent endomorphism. -/
structure IsKernelOperator (k : β → β) : Prop where
  monotone : ∀ ⦃b₁ b₂ : β⦄, b₁ ≤ b₂ → k b₁ ≤ k b₂
  intensive : ∀ b : β, k b ≤ b
  idempotent : ∀ b : β, k (k b) = k b

/-- The composite endomorphism `g ∘ f` is a closure operator on `α`. -/
theorem gc_closure_operator_gf (gc : GaloisConnection f g) :
    IsClosureOperator (fun a => g (f a)) where
  monotone := fun _ _ h => gc_monotone_gf gc h
  extensive := fun a => gc_le_g_f gc a
  idempotent := fun a => by
    change g (f (g (f a))) = g (f a)
    rw [gc_f_g_f gc a]

/-- The composite endomorphism `f ∘ g` is a kernel operator on `β`. -/
theorem gc_kernel_operator_fg (gc : GaloisConnection f g) :
    IsKernelOperator (fun b => f (g b)) where
  monotone := fun _ _ h => gc_monotone_fg gc h
  intensive := fun b => gc_f_g_le gc b
  idempotent := fun b => by
    change f (g (f (g b))) = f (g b)
    rw [gc_g_f_g gc b]

/-- An element `a : α` is closed with respect to the Galois connection if `g (f a) = a`. -/
def IsClosed (_gc : GaloisConnection f g) (a : α) : Prop :=
  g (f a) = a

/-- An element `b : β` is open (or co-closed) with respect to the Galois connection if `f (g b) = b`. -/
def IsOpen (_gc : GaloisConnection f g) (b : β) : Prop :=
  f (g b) = b

/-- Characterization: `a` is closed iff `a` is in the range of `g`. -/
theorem is_closed_iff_mem_range (gc : GaloisConnection f g) (a : α) :
    IsClosed gc a ↔ ∃ b : β, g b = a := by
  constructor
  · intro h
    exact ⟨f a, h⟩
  · rintro ⟨b, rfl⟩
    exact gc_g_f_g gc b

/-- Characterization: `b` is open iff `b` is in the range of `f`. -/
theorem is_open_iff_mem_range (gc : GaloisConnection f g) (b : β) :
    IsOpen gc b ↔ ∃ a : α, f a = b := by
  constructor
  · intro h
    exact ⟨g b, h⟩
  · rintro ⟨a, rfl⟩
    exact gc_f_g_f gc a

/-- Applying `f` to any element `a` produces an open element `f a`. -/
theorem f_is_open (gc : GaloisConnection f g) (a : α) : IsOpen gc (f a) :=
  gc_f_g_f gc a

/-- Applying `g` to any element `b` produces a closed element `g b`. -/
theorem g_is_closed (gc : GaloisConnection f g) (b : β) : IsClosed gc (g b) :=
  gc_g_f_g gc b

/-- Mutual bijection and order preservation on closed and open elements:
    If `a` is closed, `g (f a) = a`.
    If `b` is open, `f (g b) = b`. -/
theorem closed_open_inverse_f (gc : GaloisConnection f g) {a : α} (ha : IsClosed gc a) :
    g (f a) = a :=
  ha

theorem closed_open_inverse_g (gc : GaloisConnection f g) {b : β} (hb : IsOpen gc b) :
    f (g b) = b :=
  hb

/-- On the subposets of closed and open elements, the adjunction restricts to an exact order isomorphism:
    `f a ≤ b ↔ a ≤ g b` with equality `f a = b ↔ a = g b`. -/
theorem closed_open_equiv (gc : GaloisConnection f g) {a : α} {b : β}
    (ha : IsClosed gc a) (hb : IsOpen gc b) :
    f a = b ↔ a = g b := by
  constructor
  · intro h
    rw [← h, ha]
  · intro h
    rw [h, hb]

end PartialOrderTheorems

end GaloisFormalization
