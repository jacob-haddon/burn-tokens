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

theorem grothendieckRel_trans_calc {M : Type _} [MyAddCommMonoid M]
    (a b c d e f k1 k2 : M)
    (h1 : a + d + k1 = c + b + k1)
    (h2 : c + f + k2 = e + d + k2) :
    a + f + (c + d + k1 + k2) = e + b + (c + d + k1 + k2) := by
  have h_sum : (a + d + k1) + (c + f + k2) = (c + b + k1) + (e + d + k2) := by
    rw [h1, h2]
  have L : (a + d + k1) + (c + f + k2) = a + f + (c + d + k1 + k2) := by
    calc
      (a + d + k1) + (c + f + k2)
        = a + d + k1 + c + f + k2 := by rw [add_assoc_thm (a + d + k1) (c + f) k2, add_assoc_thm (a + d + k1) c f]
      _ = a + f + (c + d + k1 + k2) := by
        -- rearrange
        rw [add_assoc_thm (a + d + k1 + c) f k2]
        rw [add_assoc_thm (a + d + k1) c (f + k2)]
        rw [add_assoc_thm (a + d) k1 (c + (f + k2))]
        rw [add_assoc_thm a d (k1 + (c + (f + k2)))]
        rw [add_assoc_thm (a + f) (c + d + k1) k2]
        rw [add_assoc_thm (a + f) (c + d) (k1 + k2)]
        rw [add_assoc_thm (a + f) c (d + (k1 + k2))]
        rw [add_assoc_thm a f (c + (d + (k1 + k2)))]
        congr 1
        rw [add_left_comm_thm d k1]
        rw [add_left_comm_thm d c]
        rw [add_comm_thm f k2]
        rw [add_left_comm_thm f (c + (d + (k1 + k2)))]
        rw [add_left_comm_thm f (k1 + (c + (k2 + f)))]
        congr 1
        rw [add_left_comm_thm k1 c]
        rw [add_comm_thm k2 f]
        rw [add_left_comm_thm k2 f]
        rw [add_comm_thm c d]
        rw [add_left_comm_thm d (k1 + k2)]
        rw [add_comm_thm k1 k2]
        rw [add_left_comm_thm k2 k1]
        rw [add_comm_thm k2 k1]
        rw [add_left_comm_thm k1 k2]
  sorry

