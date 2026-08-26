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

theorem relL_refl {M : Type _} [MyMonoid M] (a : M) : relL a a := by
  refine ⟨⟨1, one_mul_thm a⟩, ⟨1, one_mul_thm a⟩⟩

theorem relL_symm {M : Type _} [MyMonoid M] {a b : M} (h : relL a b) : relL b a :=
  ⟨h.2, h.1⟩

theorem relL_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relL a b) (h2 : relL b c) : relL a c := by
  obtain ⟨⟨x1, hx1⟩, ⟨y1, hy1⟩⟩ := h1
  obtain ⟨⟨x2, hx2⟩, ⟨y2, hy2⟩⟩ := h2
  refine ⟨⟨x2 * x1, ?_⟩, ⟨y1 * y2, ?_⟩⟩
  · rw [mul_assoc_thm, hx1, hx2]
  · rw [mul_assoc_thm, hy2, hy1]

theorem relR_refl {M : Type _} [MyMonoid M] (a : M) : relR a a := by
  refine ⟨⟨1, mul_one_thm a⟩, ⟨1, mul_one_thm a⟩⟩

theorem relR_symm {M : Type _} [MyMonoid M] {a b : M} (h : relR a b) : relR b a :=
  ⟨h.2, h.1⟩

theorem relR_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relR a b) (h2 : relR b c) : relR a c := by
  obtain ⟨⟨u1, hu1⟩, ⟨v1, hv1⟩⟩ := h1
  obtain ⟨⟨u2, hu2⟩, ⟨v2, hv2⟩⟩ := h2
  refine ⟨⟨u1 * u2, ?_⟩, ⟨v2 * v1, ?_⟩⟩
  · rw [← mul_assoc_thm, hu1, hu2]
  · rw [← mul_assoc_thm, hv2, hv1]

theorem relH_refl {M : Type _} [MyMonoid M] (a : M) : relH a a :=
  ⟨relL_refl a, relR_refl a⟩

theorem relH_symm {M : Type _} [MyMonoid M] {a b : M} (h : relH a b) : relH b a :=
  ⟨relL_symm h.1, relR_symm h.2⟩

theorem relH_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relH a b) (h2 : relH b c) : relH a c :=
  ⟨relL_trans h1.1 h2.1, relR_trans h1.2 h2.2⟩

theorem relJ_refl {M : Type _} [MyMonoid M] (a : M) : relJ a a := by
  have h1 : 1 * a * 1 = a := by rw [one_mul_thm, mul_one_thm]
  refine ⟨⟨1, 1, h1⟩, ⟨1, 1, h1⟩⟩

theorem relJ_symm {M : Type _} [MyMonoid M] {a b : M} (h : relJ a b) : relJ b a :=
  ⟨h.2, h.1⟩

theorem relJ_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relJ a b) (h2 : relJ b c) : relJ a c := by
  obtain ⟨⟨x1, y1, h1_fwd⟩, ⟨z1, w1, h1_rev⟩⟩ := h1
  obtain ⟨⟨x2, y2, h2_fwd⟩, ⟨z2, w2, h2_rev⟩⟩ := h2
  refine ⟨⟨x2 * x1, y1 * y2, ?_⟩, ⟨z1 * z2, w2 * w1, ?_⟩⟩
  · calc
      (x2 * x1) * a * (y1 * y2) = x2 * (x1 * a) * (y1 * y2) := by rw [mul_assoc_thm x2 x1 a]
      _ = (x2 * (x1 * a)) * (y1 * y2) := rfl
      _ = x2 * (x1 * a * y1) * y2 := by
          rw [mul_assoc_thm x2 (x1 * a) (y1 * y2)]
          rw [← mul_assoc_thm (x1 * a) y1 y2]
          rw [mul_assoc_thm x2 (x1 * a * y1) y2]
      _ = x2 * b * y2 := by rw [h1_fwd]
      _ = c := h2_fwd
  · calc
      (z1 * z2) * c * (w2 * w1) = z1 * (z2 * c) * (w2 * w1) := by rw [mul_assoc_thm z1 z2 c]
      _ = (z1 * (z2 * c)) * (w2 * w1) := rfl
      _ = z1 * (z2 * c * w2) * w1 := by
          rw [mul_assoc_thm z1 (z2 * c) (w2 * w1)]
          rw [← mul_assoc_thm (z2 * c) w2 w1]
          rw [mul_assoc_thm z1 (z2 * c * w2) w1]
      _ = z1 * b * w1 := by rw [h2_rev]
      _ = a := h1_rev

theorem relD_comm_fwd {M : Type _} [MyMonoid M] {a b : M} (h : ∃ c : M, relL a c ∧ relR c b) :
    ∃ d : M, relR a d ∧ relL d b := by
  obtain ⟨c, ⟨⟨x, hx⟩, ⟨y, hy⟩⟩, ⟨⟨u, hu⟩, ⟨v, hv⟩⟩⟩ := h
  refine ⟨a * u, ?_⟩
  have h_R_ad : relR a (a * u) := by
    refine ⟨⟨u, rfl⟩, ⟨v, ?_⟩⟩
    calc
      (a * u) * v = a * (u * v) := mul_assoc_thm a u v
      _ = (y * c) * (u * v) := by rw [hy]
      _ = y * (c * (u * v)) := mul_assoc_thm y c (u * v)
      _ = y * (c * u * v) := by rw [← mul_assoc_thm c u v]
      _ = y * (b * v) := by rw [hu]
      _ = y * c := by rw [hv]
      _ = a := hy
  have h_L_db : relL (a * u) b := by
    refine ⟨⟨x, ?_⟩, ⟨y, ?_⟩⟩
    · calc
        x * (a * u) = (x * a) * u := (mul_assoc_thm x a u).symm
        _ = c * u := by rw [hx]
        _ = b := hu
    · calc
        y * b = y * (c * u) := by rw [hu]
        _ = (y * c) * u := (mul_assoc_thm y c u).symm
        _ = a * u := by rw [hy]
  exact ⟨h_R_ad, h_L_db⟩

theorem relD_comm {M : Type _} [MyMonoid M] (a b : M) :
    (∃ c : M, relL a c ∧ relR c b) ↔ (∃ d : M, relR a d ∧ relL d b) := by
  constructor
  · exact relD_comm_fwd
  · intro ⟨d, hd1, hd2⟩
    have hd_symm : ∃ c : M, relL b c ∧ relR c a := by
      refine ⟨d, relL_symm hd2, relR_symm hd1⟩
    obtain ⟨c, hc1, hc2⟩ := relD_comm_fwd hd_symm
    exact ⟨c, relL_symm hc2, relR_symm hc1⟩

theorem greens_lemma_fwd {M : Type _} [MyMonoid M] {a b : M} {s t : M}
    (h_as : a * s = b) (h_bt : b * t = a) {x : M} (hx : relL x a) :
    relL (x * s) b ∧ (x * s) * t = x := by
  obtain ⟨⟨x1, hx1⟩, ⟨x2, hx2⟩⟩ := hx
  have hL : relL (x * s) b := by
    refine ⟨⟨x2, ?_⟩, ⟨x1, ?_⟩⟩
    · calc
        x2 * (x * s) = (x2 * x) * s := (mul_assoc_thm x2 x s).symm
        _ = a * s := by rw [hx2]
        _ = b := h_as
    · calc
        x1 * b = x1 * (a * s) := by rw [h_as]
        _ = (x1 * a) * s := (mul_assoc_thm x1 a s).symm
        _ = x * s := by rw [hx1]
  have h_inv : (x * s) * t = x := by
    calc
      (x * s) * t = (x1 * a * s) * t := by rw [hx1]
      _ = (x1 * (a * s)) * t := by rw [mul_assoc_thm x1 a s]
      _ = (x1 * b) * t := by rw [h_as]
      _ = x1 * (b * t) := mul_assoc_thm x1 b t
      _ = x1 * a := by rw [h_bt]
      _ = x := hx1
  exact ⟨hL, h_inv⟩

