/-
  Autonomous Research Lab: Project 01 (Open Lean Missions)
  Mission: Constructive Extended Euclidean Algorithm & Bézout Soundness in Lean 4
  Target: Standalone machine-checked Lean 4 formalization with 0 sorry and 0 custom axioms.
-/

namespace EuclideanAlgorithmFormalization

/-- Divisibility relation on natural numbers. -/
def NatDiv (d a : Nat) : Prop := ∃ k : Nat, a = d * k

/-- Common divisor of two natural numbers. -/
def IsCommonDivisor (d a b : Nat) : Prop := NatDiv d a ∧ NatDiv d b

/-- Greatest Common Divisor predicate. -/
def IsGcd (g a b : Nat) : Prop :=
  IsCommonDivisor g a b ∧ ∀ d : Nat, IsCommonDivisor d a b → NatDiv d g

/-- Extended Euclidean Algorithm (computable recursive function).
    Given natural numbers a and b, computes (x, y, g) such that:
    - a * x + b * y = g
    - g = Nat.gcd a b -/
def xgcd : Nat → Nat → Int × Int × Nat
  | a, 0 => (1, 0, a)
  | a, b + 1 =>
    have : (a % (b + 1)) < b + 1 := Nat.mod_lt a (Nat.succ_pos b)
    let (x', y', g) := xgcd (b + 1) (a % (b + 1))
    let q : Int := (a / (b + 1) : Nat)
    (y', x' - q * y', g)
termination_by _ b => b

/-- Linear arithmetic helper converting natural division with remainder into integers. -/
theorem nat_mul_add_to_int (b q r a : Nat) (h : b * q + r = a) :
    (a : Int) = (b : Int) * (q : Int) + (r : Int) := by
  have : (a : Int) = ((b * q + r : Nat) : Int) := by rw [h]
  omega

theorem nat_div_mod_to_int (a b : Nat) :
    (a : Int) = (b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int) := by
  apply nat_mul_add_to_int (b + 1) (a / (b + 1)) (a % (b + 1)) a
  exact Nat.div_add_mod a (b + 1)

/-- Main Theorem 1: Bézout identity for the Extended Euclidean Algorithm.
    (a : Int) * x + (b : Int) * y = (g : Int). -/
theorem xgcd_bezout (a b : Nat) :
    (a : Int) * (xgcd a b).1 + (b : Int) * (xgcd a b).2.1 = ((xgcd a b).2.2 : Int) := by
  induction a, b using xgcd.induct with
  | case1 a =>
    unfold xgcd
    dsimp
    omega
  | case2 a b h_lt x' y' g h_xgcd ih =>
    rw [xgcd]
    dsimp
    rw [h_xgcd]
    dsimp
    have h_div := nat_div_mod_to_int a b
    rw [h_xgcd] at ih
    dsimp at ih
    calc
      (a : Int) * y' + (b + 1 : Int) * (x' - ((a / (b + 1) : Nat) : Int) * y')
        = ((b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int)) * y'
          + (b + 1 : Int) * (x' - ((a / (b + 1) : Nat) : Int) * y') := by rw [h_div]
      _ = (b + 1 : Int) * x' + ((a % (b + 1) : Nat) : Int) * y' := by
        rw [Int.add_mul]
        have : (b + 1 : Int) * (x' - ((a / (b + 1) : Nat) : Int) * y') =
               (b + 1 : Int) * x' - (b + 1 : Int) * (((a / (b + 1) : Nat) : Int) * y') := by
          rw [Int.mul_sub]
        rw [this]
        have h_comm1 : (b + 1 : Int) * ((a / (b + 1) : Nat) : Int) * y' =
                       (b + 1 : Int) * (((a / (b + 1) : Nat) : Int) * y') := by
          rw [Int.mul_assoc]
        rw [h_comm1]
        omega
      _ = (g : Int) := ih

/-- GCD recursion step identity for natural numbers. -/
theorem gcd_step (a b : Nat) : Nat.gcd (b + 1) (a % (b + 1)) = Nat.gcd a (b + 1) := by
  have : Nat.gcd a (b + 1) = Nat.gcd (b + 1) (a % (b + 1)) := by
    calc
      Nat.gcd a (b + 1) = Nat.gcd (b + 1) a := Nat.gcd_comm a (b + 1)
      _                 = Nat.gcd (a % (b + 1)) (b + 1) := Nat.gcd_rec (b + 1) a
      _                 = Nat.gcd (b + 1) (a % (b + 1)) := Nat.gcd_comm (a % (b + 1)) (b + 1)
  exact this.symm

/-- Main Theorem 2: The output value g of xgcd equals the true mathematical gcd(a, b). -/
theorem xgcd_gcd (a b : Nat) : (xgcd a b).2.2 = Nat.gcd a b := by
  induction a, b using xgcd.induct with
  | case1 a =>
    unfold xgcd
    dsimp
    exact (Nat.gcd_zero_right a).symm
  | case2 a b h_lt x' y' g h_xgcd ih =>
    rw [xgcd]
    dsimp
    rw [h_xgcd]
    dsimp
    rw [h_xgcd] at ih
    dsimp at ih
    rw [ih]
    exact gcd_step a b

/-- Theorem 3: g divides a. -/
theorem xgcd_dvd_left (a b : Nat) : NatDiv (xgcd a b).2.2 a := by
  rw [xgcd_gcd]
  have := Nat.gcd_dvd_left a b
  rcases this with ⟨k, hk⟩
  exact ⟨k, hk⟩

/-- Theorem 4: g divides b. -/
theorem xgcd_dvd_right (a b : Nat) : NatDiv (xgcd a b).2.2 b := by
  rw [xgcd_gcd]
  have := Nat.gcd_dvd_right a b
  rcases this with ⟨k, hk⟩
  exact ⟨k, hk⟩

/-- Theorem 5: g is the greatest common divisor. -/
theorem xgcd_is_gcd (a b : Nat) : IsGcd (xgcd a b).2.2 a b := by
  constructor
  · exact ⟨xgcd_dvd_left a b, xgcd_dvd_right a b⟩
  · intro d ⟨⟨ka, hka⟩, ⟨kb, hkb⟩⟩
    rw [xgcd_gcd]
    have hd_a : d ∣ a := ⟨ka, hka⟩
    have hd_b : d ∣ b := ⟨kb, hkb⟩
    have hd_gcd := Nat.dvd_gcd hd_a hd_b
    rcases hd_gcd with ⟨k, hk⟩
    exact ⟨k, hk⟩

/-- Constructive Modular Inverse Witness Extraction:
    If a and m are coprime (gcd(a, m) = 1), then xgcd computes an integer x such that
    (a : Int) * x ≡ 1 (mod m). -/
theorem xgcd_mod_inverse (a m : Nat) (h_coprime : Nat.gcd a m = 1) :
    ∃ k : Int, (a : Int) * (xgcd a m).1 - 1 = (m : Int) * k := by
  have h_bezout := xgcd_bezout a m
  have h_gcd := xgcd_gcd a m
  rw [h_gcd, h_coprime] at h_bezout
  refine ⟨-(xgcd a m).2.1, ?_⟩
  calc
    (a : Int) * (xgcd a m).1 - 1 = -((m : Int) * (xgcd a m).2.1) := by omega
    _                            = (m : Int) * (-(xgcd a m).2.1)  := by
      rw [Int.mul_neg]

end EuclideanAlgorithmFormalization
