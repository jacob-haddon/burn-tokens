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

def grothendieckRel {M : Type _} [MyAddCommMonoid M] (p1 p2 : M × M) : Prop :=
  ∃ k : M, p1.1 + p2.2 + k = p2.1 + p1.2 + k

theorem grothendieckRel_refl {M : Type _} [MyAddCommMonoid M] (p : M × M) :
    grothendieckRel p p :=
  ⟨0, rfl⟩

theorem grothendieckRel_symm {M : Type _} [MyAddCommMonoid M] {p1 p2 : M × M}
    (h : grothendieckRel p1 p2) : grothendieckRel p2 p1 := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k, hk.symm⟩

def add_assoc4 {M : Type _} [MyAddCommMonoid M] (a b c d : M) :
    (a + b) + (c + d) = (a + c) + (b + d) := by
  calc
    (a + b) + (c + d) = a + (b + (c + d)) := add_assoc_thm _ _ _
    _ = a + ((b + c) + d) := by rw [add_assoc_thm b c d]
    _ = a + ((c + b) + d) := by rw [add_comm_thm b c]
    _ = a + (c + (b + d)) := by rw [← add_assoc_thm c b d]
    _ = (a + c) + (b + d) := (add_assoc_thm a c (b + d)).symm

def add_assoc6 {M : Type _} [MyAddCommMonoid M] (a b c d e f : M) :
    (a + b + c) + (d + e + f) = (a + d) + (b + e) + (c + f) := by
  calc
    (a + b + c) + (d + e + f) = ((a + b) + c) + ((d + e) + f) := rfl
    _ = ((a + b) + (d + e)) + (c + f) := add_assoc4 (a + b) c (d + e) f
    _ = ((a + d) + (b + e)) + (c + f) := by rw [add_assoc4 a b d e]

theorem grothendieckRel_trans {M : Type _} [MyAddCommMonoid M] {p1 p2 p3 : M × M}
    (h12 : grothendieckRel p1 p2) (h23 : grothendieckRel p2 p3) :
    grothendieckRel p1 p3 := by
  obtain ⟨k1, hk1⟩ := h12
  obtain ⟨k2, hk2⟩ := h23
  refine ⟨p2.1 + p2.2 + k1 + k2, ?_⟩
  have h_sum : (p1.1 + p2.2 + k1) + (p2.1 + p3.2 + k2) = (p2.1 + p1.2 + k1) + (p3.1 + p2.2 + k2) := by
    rw [hk1, hk2]
  have h_left : (p1.1 + p2.2 + k1) + (p2.1 + p3.2 + k2) = (p1.1 + p3.2) + (p2.2 + p2.1) + (k1 + k2) :=
    add_assoc6 p1.1 p2.2 k1 p2.1 p3.2 k2
  have h_right : (p2.1 + p1.2 + k1) + (p3.1 + p2.2 + k2) = (p2.1 + p3.1) + (p1.2 + p2.2) + (k1 + k2) :=
    add_assoc6 p2.1 p1.2 k1 p3.1 p2.2 k2
  rw [h_left, h_right] at h_sum
  calc
    p1.1 + p3.2 + (p2.1 + p2.2 + k1 + k2)
      = (p1.1 + p3.2) + (p2.1 + p2.2) + (k1 + k2) := by
        rw [← add_assoc_thm (p1.1 + p3.2) (p2.1 + p2.2) (k1 + k2)]
        rw [← add_assoc_thm (p1.1 + p3.2 + (p2.1 + p2.2)) k1 k2]
    _ = (p1.1 + p3.2) + (p2.2 + p2.1) + (k1 + k2) := by
        rw [add_comm_thm p2.1 p2.2]
    _ = (p2.1 + p3.1) + (p1.2 + p2.2) + (k1 + k2) := h_sum
    _ = (p3.1 + p1.2) + (p2.1 + p2.2) + (k1 + k2) := by
        rw [add_comm_thm p2.1 p3.1, add_comm_thm p1.2 p2.2]
        calc
          (p3.1 + p2.1) + (p2.2 + p1.2) + (k1 + k2)
            = (p3.1 + p2.1 + (p2.2 + p1.2)) + (k1 + k2) := rfl
          _ = (p3.1 + (p2.1 + (p2.2 + p1.2))) + (k1 + k2) := by rw [add_assoc_thm p3.1 p2.1 _]
          _ = (p3.1 + ((p2.1 + p2.2) + p1.2)) + (k1 + k2) := by rw [add_assoc_thm p2.1 p2.2 p1.2]
          _ = (p3.1 + (p1.2 + (p2.1 + p2.2))) + (k1 + k2) := by rw [add_comm_thm (p2.1 + p2.2) p1.2]
          _ = ((p3.1 + p1.2) + (p2.1 + p2.2)) + (k1 + k2) := by rw [← add_assoc_thm p3.1 p1.2 _]
    _ = p3.1 + p1.2 + (p2.1 + p2.2 + k1 + k2) := by
        rw [← add_assoc_thm (p3.1 + p1.2) (p2.1 + p2.2) (k1 + k2)]
        rw [← add_assoc_thm (p3.1 + p1.2 + (p2.1 + p2.2)) k1 k2]

