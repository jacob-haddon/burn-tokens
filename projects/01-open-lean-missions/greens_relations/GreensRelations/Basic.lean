/-
  Autonomous Research Lab: Project 01 (Open Lean Missions)
  Mission: Formalization of Green's Relations, Commutation of D-Classes, and Green's Lemma in Lean 4
  Target: Standalone machine-checked Lean 4 formalization with 0 sorry and 0 custom axioms.
-/

namespace GreensRelationsFormalization

/-- Monoid typeclass with associativity and identity laws. -/
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

/-- Green's L-relation: principal left ideal equivalence (M a = M b). -/
def relL {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  (∃ x : M, x * a = b) ∧ (∃ y : M, y * b = a)

/-- Green's R-relation: principal right ideal equivalence (a M = b M). -/
def relR {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  (∃ u : M, a * u = b) ∧ (∃ v : M, b * v = a)

/-- Green's H-relation: intersection of L and R relations (H = L ∩ R). -/
def relH {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  relL a b ∧ relR a b

/-- Green's J-relation: principal two-sided ideal equivalence (M a M = M b M). -/
def relJ {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  (∃ x y : M, x * a * y = b) ∧ (∃ z w : M, z * b * w = a)

/-- Green's D-relation: relational composition of L and R (D = L ∘ R). -/
def relD {M : Type _} [MyMonoid M] (a b : M) : Prop :=
  ∃ c : M, relL a c ∧ relR c b

-- ============================================================================
-- Section 1: Equivalence Properties of L, R, H, J
-- ============================================================================

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
      (x2 * x1) * a * (y1 * y2) = (x2 * (x1 * a)) * (y1 * y2) := by rw [mul_assoc_thm x2 x1 a]
      _ = x2 * (x1 * a) * y1 * y2 := (mul_assoc_thm (x2 * (x1 * a)) y1 y2).symm
      _ = x2 * (x1 * a * y1) * y2 := by rw [← mul_assoc_thm x2 (x1 * a) y1]
      _ = x2 * b * y2 := by rw [h1_fwd]
      _ = c := h2_fwd
  · calc
      (z1 * z2) * c * (w2 * w1) = (z1 * (z2 * c)) * (w2 * w1) := by rw [mul_assoc_thm z1 z2 c]
      _ = z1 * (z2 * c) * w2 * w1 := (mul_assoc_thm (z1 * (z2 * c)) w2 w1).symm
      _ = z1 * (z2 * c * w2) * w1 := by rw [← mul_assoc_thm z1 (z2 * c) w2]
      _ = z1 * b * w1 := by rw [h2_rev]
      _ = a := h1_rev

-- ============================================================================
-- Section 2: Green's Commutation Theorem (L ∘ R = R ∘ L) & D Equivalence
-- ============================================================================

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

/-- Main Theorem 1: Green's Commutation of Relations (L ∘ R = R ∘ L). -/
theorem relD_comm {M : Type _} [MyMonoid M] (a b : M) :
    (∃ c : M, relL a c ∧ relR c b) ↔ (∃ d : M, relR a d ∧ relL d b) := by
  constructor
  · exact relD_comm_fwd
  · intro ⟨d, hd1, hd2⟩
    have hd_symm : ∃ c : M, relL b c ∧ relR c a := by
      refine ⟨d, relL_symm hd2, relR_symm hd1⟩
    obtain ⟨c, hc1, hc2⟩ := relD_comm_fwd hd_symm
    exact ⟨c, relL_symm hc2, relR_symm hc1⟩

theorem relD_refl {M : Type _} [MyMonoid M] (a : M) : relD a a :=
  ⟨a, relL_refl a, relR_refl a⟩

theorem relD_symm {M : Type _} [MyMonoid M] {a b : M} (h : relD a b) : relD b a := by
  obtain ⟨d, hd1, hd2⟩ := (relD_comm a b).mp h
  exact ⟨d, relL_symm hd2, relR_symm hd1⟩

theorem relD_trans {M : Type _} [MyMonoid M] {a b c : M} (h1 : relD a b) (h2 : relD b c) : relD a c := by
  obtain ⟨d1, hd1_L, hd1_R⟩ := h1
  obtain ⟨d2, hd2_L, hd2_R⟩ := h2
  have h_mid : ∃ mid, relL d1 mid ∧ relR mid d2 := (relD_comm d1 d2).mpr ⟨b, hd1_R, hd2_L⟩
  obtain ⟨mid, h_d1_mid, h_mid_d2⟩ := h_mid
  refine ⟨mid, relL_trans hd1_L h_d1_mid, relR_trans h_mid_d2 hd2_R⟩

-- ============================================================================
-- Section 3: Green's Lemma (Isomorphisms between L-classes and H-classes)
-- ============================================================================

/-- Main Theorem 2: Green's Lemma Forward Map (ρ_s maps L_a to L_b bijectively). -/
theorem greens_lemma_fwd {M : Type _} [MyMonoid M] {a b : M} {s t : M}
    (h_as : a * s = b) (h_bt : b * t = a) {x : M} (hx : relL x a) :
    relL (x * s) b ∧ (x * s) * t = x := by
  obtain ⟨⟨u, hu⟩, ⟨v, hv⟩⟩ := hx
  have hL : relL (x * s) b := by
    refine ⟨⟨u, ?_⟩, ⟨v, ?_⟩⟩
    · calc
        u * (x * s) = (u * x) * s := (mul_assoc_thm u x s).symm
        _ = a * s := by rw [hu]
        _ = b := h_as
    · calc
        v * b = v * (a * s) := by rw [h_as]
        _ = (v * a) * s := (mul_assoc_thm v a s).symm
        _ = x * s := by rw [hv]
  have h_inv : (x * s) * t = x := by
    calc
      (x * s) * t = ((v * a) * s) * t := by rw [hv]
      _ = (v * (a * s)) * t := by rw [mul_assoc_thm v a s]
      _ = (v * b) * t := by rw [h_as]
      _ = v * (b * t) := mul_assoc_thm v b t
      _ = v * a := by rw [h_bt]
      _ = x := hv
  exact ⟨hL, h_inv⟩

/-- Main Theorem 3: Green's Lemma Backward Map (ρ_t maps L_b to L_a bijectively). -/
theorem greens_lemma_bwd {M : Type _} [MyMonoid M] {a b : M} {s t : M}
    (h_as : a * s = b) (h_bt : b * t = a) {y : M} (hy : relL y b) :
    relL (y * t) a ∧ (y * t) * s = y :=
  greens_lemma_fwd h_bt h_as hy

/-- Main Theorem 4: Green's Lemma Preserves R-Relations. -/
theorem greens_lemma_r_preservation {M : Type _} [MyMonoid M] {a b : M} {s t : M}
    (h_as : a * s = b) (h_bt : b * t = a) {x : M} (hx : relL x a) :
    relR x (x * s) := by
  have h_inv := (greens_lemma_fwd h_as h_bt hx).2
  refine ⟨⟨s, rfl⟩, ⟨t, h_inv⟩⟩

/-- Main Theorem 5: Green's Lemma H-Class Isomorphism (ρ_s maps H_a onto H_b). -/
theorem greens_lemma_h_fwd {M : Type _} [MyMonoid M] {a b : M} {s t : M}
    (h_as : a * s = b) (h_bt : b * t = a) (h_R_ab : relR a b)
    {x : M} (hx : relH x a) :
    relH (x * s) b := by
  have hL := (greens_lemma_fwd h_as h_bt hx.1).1
  have h_R_x_xs := greens_lemma_r_preservation h_as h_bt hx.1
  have hR : relR (x * s) b :=
    relR_trans (relR_symm h_R_x_xs) (relR_trans hx.2 h_R_ab)
  exact ⟨hL, hR⟩

/-- Main Theorem 6: Green's Lemma H-Class Isomorphism Backward. -/
theorem greens_lemma_h_bwd {M : Type _} [MyMonoid M] {a b : M} {s t : M}
    (h_as : a * s = b) (h_bt : b * t = a) (h_R_ab : relR a b)
    {y : M} (hy : relH y b) :
    relH (y * t) a :=
  greens_lemma_h_fwd h_bt h_as (relR_symm h_R_ab) hy

end GreensRelationsFormalization
