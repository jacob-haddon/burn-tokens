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

theorem add_left_comm_thm {M : Type _} [MyAddCommMonoid M] (a b c : M) :
    a + (b + c) = b + (a + c) := by
  rw [← add_assoc_thm, add_comm_thm a b, add_assoc_thm]

theorem add_add_add_comm {M : Type _} [MyAddCommMonoid M] (a b c d : M) :
    (a + b) + (c + d) = (a + c) + (b + d) := by
  calc
    (a + b) + (c + d) = a + (b + (c + d)) := add_assoc_thm (a + b) c d ▸ rfl
    _ = a + (c + (b + d)) := by rw [add_left_comm_thm b c d]
    _ = (a + c) + (b + d) := (add_assoc_thm a c (b + d)).symm

theorem add_add_add_comm3 {M : Type _} [MyAddCommMonoid M] (a b c d e f : M) :
    (a + b + c) + (d + e + f) = (a + d) + (b + e) + (c + f) := by
  calc
    (a + b + c) + (d + e + f) = ((a + b) + c) + ((d + e) + f) := rfl
    _ = ((a + b) + (d + e)) + (c + f) := add_add_add_comm (a + b) c (d + e) f
    _ = ((a + d) + (b + e)) + (c + f) := by rw [add_add_add_comm a b d e]

theorem grothendieckRel_trans_prop {M : Type _} [MyAddCommMonoid M]
    (a b c d e f k1 k2 : M)
    (h1 : a + d + k1 = c + b + k1)
    (h2 : c + f + k2 = e + d + k2) :
    (a + f) + (c + d + (k1 + k2)) = (e + b) + (c + d + (k1 + k2)) := by
  have h_sum : (a + d + k1) + (c + f + k2) = (c + b + k1) + (e + d + k2) := by
    rw [h1, h2]
  have L : (a + d + k1) + (c + f + k2) = (a + f) + (d + c) + (k1 + k2) :=
    add_add_add_comm3 a d k1 f c k2
  have R : (c + b + k1) + (e + d + k2) = (e + b) + (c + d) + (k1 + k2) := by
    calc
      (c + b + k1) + (e + d + k2) = (e + d + k2) + (c + b + k1) := add_comm_thm _ _
      _ = (e + b) + (d + c) + (k2 + k1) := add_add_add_comm3 e d k2 b c k1
      _ = (e + b) + (c + d) + (k1 + k2) := by rw [add_comm_thm d c, add_comm_thm k2 k1]
  rw [add_comm_thm d c] at L
  rw [L, R] at h_sum
  calc
    (a + f) + (c + d + (k1 + k2)) = (a + f) + (c + d) + (k1 + k2) := (add_assoc_thm (a + f) (c + d) (k1 + k2)).symm
    _ = (e + b) + (c + d) + (k1 + k2) := h_sum
    _ = (e + b) + (c + d + (k1 + k2)) := add_assoc_thm (e + b) (c + d) (k1 + k2)

