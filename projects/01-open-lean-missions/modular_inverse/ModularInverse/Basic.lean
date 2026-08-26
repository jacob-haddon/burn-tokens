/-
  Autonomous Research Lab: Project 01 (Open Lean Missions)
  Mission: Formalisation of Modular Multiplicative Inverse Existence & Uniqueness
  Target: Standalone machine-checked Lean 4 formalization with 0 sorry and no extra axioms.
-/

namespace ModularInverse

/-- Modular congruence on integers: a ≡ b [MOD m] iff m divides (a - b). -/
def ModEq (m a b : Int) : Prop := ∃ k : Int, a - b = m * k

theorem modEq_refl (m a : Int) : ModEq m a a := by
  refine ⟨0, ?_⟩
  rw [Int.sub_self, Int.mul_zero]

theorem modEq_symm {m a b : Int} (h : ModEq m a b) : ModEq m b a := by
  rcases h with ⟨k, hk⟩
  refine ⟨-k, ?_⟩
  have : b - a = -(a - b) := by omega
  rw [this, hk, Int.mul_neg]

theorem modEq_trans {m a b c : Int} (h1 : ModEq m a b) (h2 : ModEq m b c) : ModEq m a c := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  refine ⟨k1 + k2, ?_⟩
  have : a - c = (a - b) + (b - c) := by omega
  rw [this, hk1, hk2, Int.mul_add]

/-- Congruence preserves addition. -/
theorem modEq_add {m a1 a2 b1 b2 : Int} (h1 : ModEq m a1 b1) (h2 : ModEq m a2 b2) :
    ModEq m (a1 + a2) (b1 + b2) := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  refine ⟨k1 + k2, ?_⟩
  have : (a1 + a2) - (b1 + b2) = (a1 - b1) + (a2 - b2) := by omega
  rw [this, hk1, hk2, Int.mul_add]

/-- Congruence preserves multiplication. -/
theorem modEq_mul {m a1 a2 b1 b2 : Int} (h1 : ModEq m a1 b1) (h2 : ModEq m a2 b2) :
    ModEq m (a1 * a2) (b1 * b2) := by
  rcases h1 with ⟨k1, hk1⟩
  rcases h2 with ⟨k2, hk2⟩
  refine ⟨k1 * a2 + b1 * k2, ?_⟩
  have h_split : a1 * a2 - b1 * b2 = (a1 - b1) * a2 + b1 * (a2 - b2) := by
    have : (a1 - b1) * a2 = a1 * a2 - b1 * a2 := by rw [Int.sub_mul]
    have : b1 * (a2 - b2) = b1 * a2 - b1 * b2 := by rw [Int.mul_sub]
    omega
  rw [h_split, hk1, hk2]
  rw [Int.mul_assoc m k1 a2, Int.mul_comm b1 (m * k2), Int.mul_assoc m k2 b1, ← Int.mul_add]
  congr 1
  rw [Int.mul_comm k2 b1]

/-- Definition: b is a modular multiplicative inverse of a modulo m. -/
def IsModInverse (a b m : Int) : Prop :=
  ModEq m (a * b) 1

/-- Bezout implies existence of modular inverse: if a*x + m*y = 1, then x is a modular inverse of a modulo m. -/
theorem mod_inverse_of_bezout (a m x y : Int) (hxy : a * x + m * y = 1) :
    IsModInverse a x m := by
  unfold IsModInverse ModEq
  refine ⟨-y, ?_⟩
  have : a * x - 1 = -(m * y) := by omega
  rw [this, Int.mul_neg]

/-- Uniqueness of modular inverse: any two modular inverses are congruent modulo m. -/
theorem mod_inverse_congr {a b1 b2 m : Int} (h1 : IsModInverse a b1 m) (h2 : IsModInverse a b2 m) :
    ModEq m b1 b2 := by
  have h_mul : ModEq m (b1 * (a * b2)) (b1 * 1) := by
    apply modEq_mul (modEq_refl m b1) h2
  have h_comm : ModEq m (b1 * (a * b2)) (a * b1 * b2) := by
    refine ⟨0, ?_⟩
    have : b1 * (a * b2) = a * b1 * b2 := by
      rw [← Int.mul_assoc b1 a b2, Int.mul_comm b1 a]
    rw [this, Int.sub_self, Int.mul_zero]
  have h_left : ModEq m (a * b1 * b2) (1 * b2) := by
    apply modEq_mul h1 (modEq_refl m b2)
  have h_step1 : ModEq m (b1 * 1) (b1 * (a * b2)) := modEq_symm h_mul
  have h_step2 : ModEq m (b1 * 1) (a * b1 * b2) := modEq_trans h_step1 h_comm
  have h_step3 : ModEq m (b1 * 1) (1 * b2) := modEq_trans h_step2 h_left
  have h_b1_one : ModEq m b1 (b1 * 1) := by
    refine ⟨0, ?_⟩; rw [Int.mul_one, Int.sub_self, Int.mul_zero]
  have h_one_b2 : ModEq m (1 * b2) b2 := by
    refine ⟨0, ?_⟩; rw [Int.one_mul, Int.sub_self, Int.mul_zero]
  exact modEq_trans (modEq_trans h_b1_one h_step3) h_one_b2

/-- Uniqueness in the standard residue interval [0, m): two congruent residues are equal. -/
theorem unique_residue {b1 b2 m : Int} (hm : m > 0)
    (hb1_lo : 0 ≤ b1) (hb1_hi : b1 < m)
    (hb2_lo : 0 ≤ b2) (hb2_hi : b2 < m)
    (h_cong : ModEq m b1 b2) :
    b1 = b2 := by
  rcases h_cong with ⟨k, hk⟩
  have h_diff_hi : b1 - b2 < m := by omega
  have h_diff_lo : b1 - b2 > -m := by omega
  have hk_zero : k = 0 := by
    by_cases hk_z : k = 0
    · exact hk_z
    · by_cases hk_pos : k > 0
      · have hk_ge : 1 ≤ k := by omega
        have hm_nonneg : 0 ≤ m := by omega
        have h_prod : m * 1 ≤ m * k := Int.mul_le_mul_of_nonneg_left hk_ge hm_nonneg
        rw [Int.mul_one] at h_prod
        rw [hk] at h_diff_hi
        omega
      · have hk_le : k ≤ -1 := by omega
        have hm_nonneg : 0 ≤ m := by omega
        have h_prod : m * k ≤ m * (-1) := Int.mul_le_mul_of_nonneg_left hk_le hm_nonneg
        have hm_neg : m * (-1) = -m := by omega
        rw [hm_neg] at h_prod
        rw [hk] at h_diff_lo
        omega
  subst hk_zero
  rw [Int.mul_zero] at hk
  omega

/-- Full Uniqueness Theorem: The modular multiplicative inverse in {0, ..., m-1} is unique. -/
theorem mod_inverse_unique {a b1 b2 m : Int} (hm : m > 1)
    (hb1_lo : 0 ≤ b1) (hb1_hi : b1 < m)
    (hb2_lo : 0 ≤ b2) (hb2_hi : b2 < m)
    (h1 : IsModInverse a b1 m) (h2 : IsModInverse a b2 m) :
    b1 = b2 := by
  have hm_pos : m > 0 := by omega
  have h_cong := mod_inverse_congr h1 h2
  exact unique_residue hm_pos hb1_lo hb1_hi hb2_lo hb2_hi h_cong

/-- Positivity of inverse: if m > 1, any inverse in [0, m) satisfies b >= 1. -/
theorem mod_inverse_pos {a b m : Int} (hm : m > 1)
    (hb_lo : 0 ≤ b) (h : IsModInverse a b m) :
    b ≥ 1 := by
  by_cases hb_zero : b = 0
  · subst hb_zero
    rcases h with ⟨k, hk⟩
    have hk_eq : m * k = -1 := by
      have : a * 0 - 1 = -1 := by rw [Int.mul_zero, Int.zero_sub]
      rw [← this, hk]
    by_cases hk_neg : k ≤ -1
    · have h_prod : m * k ≤ m * (-1) := Int.mul_le_mul_of_nonneg_left hk_neg (by omega)
      have hm_neg : m * (-1) = -m := by omega
      rw [hm_neg] at h_prod
      have hm_bound : -m ≤ -2 := by omega
      omega
    · have hk_ge : 0 ≤ k := by omega
      have h_prod : 0 ≤ m * k := Int.mul_nonneg (by omega) hk_ge
      omega
  · omega

/-- Inverse symmetry: if a is invertible mod m with inverse b, then b is invertible mod m with inverse a. -/
theorem mod_inv_symm {a b m : Int} (h : IsModInverse a b m) : IsModInverse b a m := by
  rcases h with ⟨k, hk⟩
  refine ⟨k, ?_⟩
  rw [Int.mul_comm b a, hk]

/-- Product rule: (a1 * a2) has inverse (b2 * b1). -/
theorem mod_inv_prod {a1 a2 b1 b2 m : Int} (h1 : IsModInverse a1 b1 m) (h2 : IsModInverse a2 b2 m) :
    IsModInverse (a1 * a2) (b2 * b1) m := by
  have h_prod : ModEq m ((a1 * b1) * (a2 * b2)) (1 * 1) := modEq_mul h1 h2
  have h_assoc : ModEq m ((a1 * a2) * (b2 * b1)) ((a1 * b1) * (a2 * b2)) := by
    refine ⟨0, ?_⟩
    have : (a1 * a2) * (b2 * b1) = (a1 * b1) * (a2 * b2) := by
      rw [Int.mul_assoc a1 a2 (b2 * b1), ← Int.mul_assoc a2 b2 b1, Int.mul_comm a2 b2,
          Int.mul_comm (b2 * a2) b1, ← Int.mul_assoc a1 b1 (b2 * a2), Int.mul_comm b2 a2]
    rw [this, Int.sub_self, Int.mul_zero]
  have h_one : ModEq m (1 * 1) 1 := by
    refine ⟨0, ?_⟩; rw [Int.mul_one, Int.sub_self, Int.mul_zero]
  exact modEq_trans (modEq_trans h_assoc h_prod) h_one

/-- Fuel-bounded Extended Euclidean algorithm on natural numbers returning (x, y, g). -/
def extGcdFuel : Nat → Nat → Nat → Int × Int × Nat
  | 0, _, _ => (0, 0, 0)
  | _ + 1, 0, b => (0, 1, b)
  | fuel + 1, a + 1, b =>
    let (x1, y1, g) := extGcdFuel fuel (b % (a + 1)) (a + 1)
    let q : Int := (b / (a + 1) : Nat)
    (y1 - q * x1, x1, g)

/-- Extended Euclidean Algorithm on natural numbers. -/
def extGcd (a b : Nat) : Int × Int × Nat :=
  extGcdFuel (a + b + 1) a b

/-- Computable modular inverse constructor via Extended Euclidean Algorithm. -/
def modInverse (a m : Nat) : Option Nat :=
  if m ≤ 1 then none
  else
    let (x, _, g) := extGcd (a % m) m
    if g == 1 then
      let m_int : Int := m
      let inv := (x % m_int + m_int) % m_int
      some inv.toNat
    else
      none

/-- Verified concrete test instances at compile-time via definitional equality rfl. -/
theorem test_inv_3_7 : modInverse 3 7 = some 5 := rfl
theorem test_inv_5_11 : modInverse 5 11 = some 9 := rfl
theorem test_inv_7_13 : modInverse 7 13 = some 2 := rfl
theorem test_inv_2_6 : modInverse 2 6 = none := rfl

end ModularInverse
