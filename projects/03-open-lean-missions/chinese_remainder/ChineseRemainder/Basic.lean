/-
  Constructive Chinese Remainder Theorem & Modular Congruence Solvability in Lean 4
  Standalone formalization from first principles (Zero external Mathlib dependencies).
-/

namespace ChineseRemainder

/-- Modular congruence on integers: a ≡ b [MOD m] iff m divides (a - b). -/
def ModEq (m : Nat) (a b : Int) : Prop :=
  ∃ k : Int, a - b = (m : Int) * k

theorem modEq_refl (m : Nat) (a : Int) : ModEq m a a := by
  refine ⟨0, ?_⟩
  rw [Int.sub_self, Int.mul_zero]

theorem modEq_symm {m : Nat} {a b : Int} (h : ModEq m a b) : ModEq m b a := by
  rcases h with ⟨k, hk⟩
  refine ⟨-k, ?_⟩
  have : b - a = -(a - b) := by omega
  rw [this, hk, Int.mul_neg]

theorem modEq_trans {m : Nat} {a b c : Int} (h1 : ModEq m a b) (h2 : ModEq m b c) : ModEq m a c := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  refine ⟨k1 + k2, ?_⟩
  have : a - c = (a - b) + (b - c) := by omega
  rw [this, hk1, hk2, Int.mul_add]

theorem modEq_add {m : Nat} {a1 a2 b1 b2 : Int} (h1 : ModEq m a1 b1) (h2 : ModEq m a2 b2) :
    ModEq m (a1 + a2) (b1 + b2) := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  refine ⟨k1 + k2, ?_⟩
  have : (a1 + a2) - (b1 + b2) = (a1 - b1) + (a2 - b2) := by omega
  rw [this, hk1, hk2, Int.mul_add]

theorem modEq_sub {m : Nat} {a1 a2 b1 b2 : Int} (h1 : ModEq m a1 b1) (h2 : ModEq m a2 b2) :
    ModEq m (a1 - a2) (b1 - b2) := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  refine ⟨k1 - k2, ?_⟩
  have : (a1 - a2) - (b1 - b2) = (a1 - b1) - (a2 - b2) := by omega
  rw [this, hk1, hk2, Int.mul_sub]

-- 1. Bézout Structure for Coprime Moduli
structure BezoutCoprime (m1 m2 : Nat) where
  u : Int
  v : Int
  bezout : (m1 : Int) * u + (m2 : Int) * v = 1

-- 2. Raw CRT Combination
def crtRaw {m1 m2 : Nat} (B : BezoutCoprime m1 m2) (a1 a2 : Int) : Int :=
  a1 * ((m2 : Int) * B.v) + a2 * ((m1 : Int) * B.u)

-- 3. Soundness of Raw CRT
theorem crtRaw_mod_left {m1 m2 : Nat} (B : BezoutCoprime m1 m2) (a1 a2 : Int) :
    ModEq m1 (crtRaw B a1 a2) a1 := by
  unfold ModEq crtRaw
  refine ⟨(a2 - a1) * B.u, ?_⟩
  have h_v : (m2 : Int) * B.v = 1 - (m1 : Int) * B.u := by
    have hB := B.bezout; omega
  rw [h_v, Int.mul_sub, Int.mul_one]
  have h_alg : a1 - a1 * ((m1 : Int) * B.u) + a2 * ((m1 : Int) * B.u) - a1 =
               (a2 - a1) * ((m1 : Int) * B.u) := by
    have : a1 - a1 * ((m1 : Int) * B.u) + a2 * ((m1 : Int) * B.u) - a1 =
           a2 * ((m1 : Int) * B.u) - a1 * ((m1 : Int) * B.u) := by omega
    rw [this, ← Int.sub_mul]
  rw [h_alg]
  rw [← Int.mul_assoc (a2 - a1) (m1 : Int) B.u]
  rw [Int.mul_comm (a2 - a1) (m1 : Int)]
  rw [Int.mul_assoc (m1 : Int) (a2 - a1) B.u]

theorem crtRaw_mod_right {m1 m2 : Nat} (B : BezoutCoprime m1 m2) (a1 a2 : Int) :
    ModEq m2 (crtRaw B a1 a2) a2 := by
  unfold ModEq crtRaw
  refine ⟨(a1 - a2) * B.v, ?_⟩
  have h_u : (m1 : Int) * B.u = 1 - (m2 : Int) * B.v := by
    have hB := B.bezout; omega
  rw [h_u, Int.mul_sub, Int.mul_one]
  have h_alg : a1 * ((m2 : Int) * B.v) + (a2 - a2 * ((m2 : Int) * B.v)) - a2 =
               (a1 - a2) * ((m2 : Int) * B.v) := by
    have : a1 * ((m2 : Int) * B.v) + (a2 - a2 * ((m2 : Int) * B.v)) - a2 =
           a1 * ((m2 : Int) * B.v) - a2 * ((m2 : Int) * B.v) := by omega
    rw [this, ← Int.sub_mul]
  rw [h_alg]
  rw [← Int.mul_assoc (a1 - a2) (m2 : Int) B.v]
  rw [Int.mul_comm (a1 - a2) (m2 : Int)]
  rw [Int.mul_assoc (m2 : Int) (a1 - a2) B.v]

-- 4. Simultaneous Congruence Divisibility (Product Modulus Lemma)
theorem simultaneous_modEq_product {m1 m2 : Nat} (B : BezoutCoprime m1 m2) {x y : Int}
    (h1 : ModEq m1 x y) (h2 : ModEq m2 x y) :
    ModEq (m1 * m2) x y := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  unfold ModEq
  refine ⟨k2 * B.u + k1 * B.v, ?_⟩
  have hB := B.bezout
  have H1 : x - y = (x - y) * 1 := by rw [Int.mul_one]
  have H2 : (x - y) * ((m1 : Int) * B.u + (m2 : Int) * B.v) =
            (x - y) * ((m1 : Int) * B.u) + (x - y) * ((m2 : Int) * B.v) := by
    rw [Int.mul_add]
  have h_prod1 : (m2 : Int) * k2 * ((m1 : Int) * B.u) = (m1 * m2 : Int) * (k2 * B.u) := by
    have h_eq : (m2 : Int) * k2 * ((m1 : Int) * B.u) = ((m1 : Int) * (m2 : Int)) * (k2 * B.u) := by
      rw [Int.mul_assoc, ← Int.mul_assoc k2 (m1 : Int) B.u, Int.mul_comm k2 (m1 : Int),
          Int.mul_assoc (m1 : Int) k2 B.u, ← Int.mul_assoc (m2 : Int) (m1 : Int) (k2 * B.u),
          Int.mul_comm (m2 : Int) (m1 : Int)]
    have h_nat : (m1 * m2 : Int) = (m1 : Int) * (m2 : Int) := by omega
    rw [h_nat, h_eq]
  have h_prod2 : (m1 : Int) * k1 * ((m2 : Int) * B.v) = (m1 * m2 : Int) * (k1 * B.v) := by
    have h_eq : (m1 : Int) * k1 * ((m2 : Int) * B.v) = ((m1 : Int) * (m2 : Int)) * (k1 * B.v) := by
      rw [Int.mul_assoc, ← Int.mul_assoc k1 (m2 : Int) B.v, Int.mul_comm k1 (m2 : Int),
          Int.mul_assoc (m2 : Int) k1 B.v, ← Int.mul_assoc (m1 : Int) (m2 : Int) (k1 * B.v)]
    have h_nat : (m1 * m2 : Int) = (m1 : Int) * (m2 : Int) := by omega
    rw [h_nat, h_eq]
  have H3 : (x - y) * ((m1 : Int) * B.u) = (m2 : Int) * k2 * ((m1 : Int) * B.u) := by rw [hk2]
  have H4 : (x - y) * ((m2 : Int) * B.v) = (m1 : Int) * k1 * ((m2 : Int) * B.v) := by rw [hk1]
  calc
    x - y = (x - y) * 1 := H1
    _ = (x - y) * ((m1 : Int) * B.u + (m2 : Int) * B.v) := by rw [hB]
    _ = (x - y) * ((m1 : Int) * B.u) + (x - y) * ((m2 : Int) * B.v) := H2
    _ = (m2 : Int) * k2 * ((m1 : Int) * B.u) + (m1 : Int) * k1 * ((m2 : Int) * B.v) := by rw [H3, H4]
    _ = (m1 * m2 : Int) * (k2 * B.u) + (m1 * m2 : Int) * (k1 * B.v) := by rw [h_prod1, h_prod2]
    _ = (m1 * m2 : Int) * (k2 * B.u + k1 * B.v) := by rw [← Int.mul_add]

-- 5. Canonical Uniqueness in Range [0, m1 * m2)
theorem crt_unique {m1 m2 : Nat} (B : BezoutCoprime m1 m2) {x y : Int}
    (hx_ge : 0 ≤ x) (hx_lt : x < (m1 * m2 : Int))
    (hy_ge : 0 ≤ y) (hy_lt : y < (m1 * m2 : Int))
    (h1 : ModEq m1 x y) (h2 : ModEq m2 x y) :
    x = y := by
  have hprod := simultaneous_modEq_product B h1 h2
  rcases hprod with ⟨k, hk⟩
  have h_nat : ((m1 * m2 : Nat) : Int) = (m1 : Int) * (m2 : Int) := rfl
  have hk_zero : k = 0 := by
    by_cases hk_pos : k > 0
    · have : (m1 : Int) * (m2 : Int) * k ≥ (m1 : Int) * (m2 : Int) * 1 := by
        apply Int.mul_le_mul_of_nonneg_left hk_pos (by omega)
      rw [Int.mul_one] at this
      have hk' : x - y = (m1 : Int) * (m2 : Int) * k := by rw [← h_nat]; exact hk
      rw [← hk'] at this
      omega
    · by_cases hk_neg : k < 0
      · have hk_le : k ≤ -1 := by omega
        have : (m1 : Int) * (m2 : Int) * k ≤ (m1 : Int) * (m2 : Int) * (-1) := by
          apply Int.mul_le_mul_of_nonneg_left hk_le (by omega)
        rw [Int.mul_neg, Int.mul_one] at this
        have hk' : x - y = (m1 : Int) * (m2 : Int) * k := by rw [← h_nat]; exact hk
        rw [← hk'] at this
        omega
      · omega
  rw [hk_zero, Int.mul_zero] at hk
  omega

-- 6. Constructive Fuel-Bounded Euclidean Algorithm for CRT
def extGcdFuel : Nat → Nat → Nat → Int × Int × Nat
  | 0, a, _ => (1, 0, a)
  | _, a, 0 => (1, 0, a)
  | fuel + 1, a, b =>
    let q := a / b
    let r := a % b
    let (s, t, g) := extGcdFuel fuel b r
    (t, s - (q : Int) * t, g)

def crtSolve (m1 m2 a1 a2 : Nat) : Option Nat :=
  let fuel := m1 + m2 + 10
  let (u, v, g) := extGcdFuel fuel m1 m2
  if g == 1 then
    let m := (m1 * m2 : Int)
    if m > 0 then
      let raw := (a1 : Int) * ((m2 : Int) * v) + (a2 : Int) * ((m1 : Int) * u)
      let rem := raw % m
      let can := (rem + m) % m
      some can.toNat
    else
      none
  else
    none

-- 7. Executable Verified Computations (rfl)
-- Example 1: x ≡ 2 [MOD 3], x ≡ 3 [MOD 5] => x = 8 in [0, 15)
theorem crt_test_3_5 : crtSolve 3 5 2 3 = some 8 := by rfl

-- Example 2: x ≡ 3 [MOD 7], x ≡ 4 [MOD 11] => x = 59 in [0, 77)
theorem crt_test_7_11 : crtSolve 7 11 3 4 = some 59 := by rfl

-- Example 3: x ≡ 1 [MOD 2], x ≡ 2 [MOD 3] => x = 5 in [0, 6)
theorem crt_test_2_3 : crtSolve 2 3 1 2 = some 5 := by rfl

-- Example 4: x ≡ 0 [MOD 5], x ≡ 0 [MOD 7] => x = 0 in [0, 35)
theorem crt_test_5_7 : crtSolve 5 7 0 0 = some 0 := by rfl

end ChineseRemainder
