def ModEq (m a b : Int) : Prop := ∃ k : Int, a - b = m * k

theorem modeq_mul {m a1 a2 b1 b2 : Int} (h1 : ModEq m a1 b1) (h2 : ModEq m a2 b2) :
    ModEq m (a1 * a2) (b1 * b2) := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  refine ⟨a1 * k2 + b2 * k1, ?_⟩
  have h : a1 * a2 - b1 * b2 = a1 * (a2 - b2) + b2 * (a1 - b1) := by omega
  rw [h, hk1, hk2]
  omega

