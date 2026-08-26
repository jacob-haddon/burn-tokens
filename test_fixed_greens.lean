class MyMonoid (M : Type _) where
  mul : M → M → M
  one : M
  mul_assoc : ∀ a b c : M, mul (mul a b) c = mul a (mul b c)
  one_mul : ∀ a : M, mul one a = a
  mul_one : ∀ a : M, mul a one = a

instance (M : Type _) [MyMonoid M] : Mul M := ⟨MyMonoid.mul⟩
instance (M : Type _) [MyMonoid M] : One M := ⟨MyMonoid.one⟩

theorem mul_assoc_thm {M : Type _} [MyMonoid M] (a b c : M) :
    a * b * c = a * (b * c) := MyMonoid.mul_assoc a b c

theorem one_mul_thm {M : Type _} [MyMonoid M] (a : M) :
    1 * a = a := MyMonoid.one_mul a

theorem mul_one_thm {M : Type _} [MyMonoid M] (a : M) :
    a * 1 = a := MyMonoid.mul_one a

def relL {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  (∃ x : M, x * a = b) ∧ (∃ y : M, y * b = a)

def relR {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  (∃ u : M, a * u = b) ∧ (∃ v : M, b * v = a)

def relH {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  relL a b ∧ relR a b

def relJ {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  (∃ x y : M, x * a * y = b) ∧ (∃ z w : M, z * b * w = a)

def relD {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  ∃ c : M, relL a c ∧ relR c b

theorem relL_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relL a b) (h2 : relL b c) : relL a c := sorry
theorem relR_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relR a b) (h2 : relR b c) : relR a c := sorry
theorem relD_comm {M : Type _} [MyMonoid M] (a b : M) :
    (∃ c : M, relL a c ∧ relR c b) ↔ (∃ d : M, relR a d ∧ relL d b) := sorry

theorem relJ_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relJ a b) (h2 : relJ b c) : relJ a c := by
  obtain ⟨⟨x1, y1, h1_fwd⟩, ⟨z1, w1, h1_rev⟩⟩ := h1
  obtain ⟨⟨x2, y2, h2_fwd⟩, ⟨z2, w2, h2_rev⟩⟩ := h2
  refine ⟨⟨x2 * x1, y1 * y2, ?_⟩, ⟨z1 * z2, w2 * w1, ?_⟩⟩
  · calc
      (x2 * x1) * a * (y1 * y2) = (x2 * (x1 * a)) * (y1 * y2) := by rw [mul_assoc_thm x2 x1 a]
      _ = x2 * (x1 * a) * y1 * y2 := mul_assoc_thm (x2 * (x1 * a)) y1 y2
      _ = x2 * (x1 * a * y1) * y2 := by rw [← mul_assoc_thm x2 (x1 * a) y1]
      _ = x2 * b * y2 := by rw [h1_fwd]
      _ = c := h2_fwd
  · calc
      (z1 * z2) * c * (w2 * w1) = (z1 * (z2 * c)) * (w2 * w1) := by rw [mul_assoc_thm z1 z2 c]
      _ = z1 * (z2 * c) * w2 * w1 := mul_assoc_thm (z1 * (z2 * c)) w2 w1
      _ = z1 * (z2 * c * w2) * w1 := by rw [← mul_assoc_thm z1 (z2 * c) w2]
      _ = z1 * b * w1 := by rw [h2_rev]
      _ = a := h1_rev

theorem relD_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relD a b) (h2 : relD b c) : relD a c := by
  obtain ⟨d1, hd1_L, hd1_R⟩ := h1
  obtain ⟨d2, hd2_L, hd2_R⟩ := h2
  have h_mid : ∃ mid, relL d1 mid ∧ relR mid d2 := (relD_comm d1 d2).mpr ⟨b, hd1_R, hd2_L⟩
  obtain ⟨mid, h_d1_mid, h_mid_d2⟩ := h_mid
  refine ⟨mid, relL_trans hd1_L h_d1_mid, relR_trans h_mid_d2 hd2_R⟩

