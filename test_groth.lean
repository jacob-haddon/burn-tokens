class MyAddCommMonoid (M : Type _) where
  add : M → M → M
  zero : M
  add_assoc : ∀ a b c : M, add (add a b) c = add a (add b c)
  zero_add : ∀ a : M, add zero a = a
  add_zero : ∀ a : M, add a zero = a
  add_comm : ∀ a b : M, add a b = add b a

instance (M : Type _) [MyAddCommMonoid M] : Add M := ⟨MyAddCommMonoid.add⟩
instance (M : Type _) [MyAddCommMonoid M] : Zero M := ⟨MyAddCommMonoid.zero⟩

theorem add_assoc_thm {M : Type _} [MyAddCommMonoid M] (a b c : M) :
    a + b + c = a + (b + c) := MyAddCommMonoid.add_assoc a b c

theorem zero_add_thm {M : Type _} [MyAddCommMonoid M] (a : M) :
    0 + a = a := MyAddCommMonoid.zero_add a

theorem add_zero_thm {M : Type _} [MyAddCommMonoid M] (a : M) :
    a + 0 = a := MyAddCommMonoid.add_zero a

theorem add_comm_thm {M : Type _} [MyAddCommMonoid M] (a b : M) :
    a + b = b + a := MyAddCommMonoid.add_comm a b

class MyAddCommGroup (G : Type _) extends MyAddCommMonoid G where
  neg : G → G
  add_left_neg : ∀ a : G, neg a + a = 0

instance (G : Type _) [MyAddCommGroup G] : Neg G := ⟨MyAddCommGroup.neg⟩

theorem add_left_neg_thm {G : Type _} [MyAddCommGroup G] (a : G) :
    -a + a = 0 := MyAddCommGroup.add_left_neg a

theorem add_right_neg_thm {G : Type _} [MyAddCommGroup G] (a : G) :
    a + -a = 0 := by
  rw [add_comm_thm, add_left_neg_thm]

def grothendieckRel {M : Type _} [MyAddCommMonoid M] (p1 p2 : M × M) : Prop :=
  ∃ k : M, p1.1 + p2.2 + k = p2.1 + p1.2 + k

theorem grothendieckRel_refl {M : Type _} [MyAddCommMonoid M] (p : M × M) :
    grothendieckRel p p := by
  use 0

theorem grothendieckRel_symm {M : Type _} [MyAddCommMonoid M] {p1 p2 : M × M}
    (h : grothendieckRel p1 p2) : grothendieckRel p2 p1 := by
  rcases h with ⟨k, hk⟩
  use k
  exact hk.symm

theorem grothendieckRel_trans {M : Type _} [MyAddCommMonoid M] {p1 p2 p3 : M × M}
    (h12 : grothendieckRel p1 p2) (h23 : grothendieckRel p2 p3) :
    grothendieckRel p1 p3 := by
  rcases h12 with ⟨k1, hk1⟩
  rcases h23 with ⟨k2, hk2⟩
  use (p2.1 + p2.2 + k1 + k2)
  have h_sum : (p1.1 + p2.2 + k1) + (p2.1 + p3.2 + k2) = (p2.1 + p1.2 + k1) + (p3.1 + p2.2 + k2) := by
    rw [hk1, hk2]
  calc
    p1.1 + p3.2 + (p2.1 + p2.2 + k1 + k2)
      = (p1.1 + p2.2 + k1) + (p2.1 + p3.2 + k2) := by
        -- Rearrangement
        simp [add_assoc_thm, add_comm_thm]
    _ = (p2.1 + p1.2 + k1) + (p3.1 + p2.2 + k2) := h_sum
    _ = p3.1 + p1.2 + (p2.1 + p2.2 + k1 + k2) := by
        simp [add_assoc_thm, add_comm_thm]

