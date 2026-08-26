def xgcd : Nat → Nat → Int × Int × Nat
  | a, 0 => (1, 0, a)
  | a, b + 1 =>
    have : (a % (b + 1)) < b + 1 := Nat.mod_lt a (Nat.succ_pos b)
    let (x', y', g) := xgcd (b + 1) (a % (b + 1))
    let q : Int := (a / (b + 1) : Nat)
    (y', x' - q * y', g)
termination_by _ b => b

theorem nat_mul_add_to_int (b q r a : Nat) (h : b * q + r = a) :
    (a : Int) = (b : Int) * (q : Int) + (r : Int) := by
  have : (a : Int) = ((b * q + r : Nat) : Int) := by rw [h]
  omega

theorem nat_div_mod_to_int (a b : Nat) :
    (a : Int) = (b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int) := by
  apply nat_mul_add_to_int (b + 1) (a / (b + 1)) (a % (b + 1)) a
  exact Nat.div_add_mod a (b + 1)

theorem xgcd_bezout (a b : Nat) :
    (a : Int) * (xgcd a b).1 + (b : Int) * (xgcd a b).2.1 = ((xgcd a b).2.2 : Int) := by
  induction a, b using xgcd.induct with
  | case1 a =>
    unfold xgcd
    dsimp
    omega
  | case2 a b _ ih =>
    rw [xgcd]
    dsimp
    have h_div := nat_div_mod_to_int a b
    generalize h_res : xgcd (b + 1) (a % (b + 1)) = res at ih ⊢
    rcases res with ⟨x', y', g⟩
    dsimp at ih ⊢
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

