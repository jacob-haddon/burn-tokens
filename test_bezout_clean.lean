def xgcd : Nat → Nat → Int × Int × Nat
  | a, 0 => (1, 0, a)
  | a, b + 1 =>
    have : (a % (b + 1)) < b + 1 := Nat.mod_lt a (Nat.succ_pos b)
    let (x', y', g) := xgcd (b + 1) (a % (b + 1))
    let q : Int := (a / (b + 1) : Nat)
    (y', x' - q * y', g)
termination_by _ b => b

theorem nat_div_mod_to_int (a b : Nat) :
    (a : Int) = (b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int) := by
  have h_nat : (b + 1) * (a / (b + 1)) + (a % (b + 1)) = a := Nat.div_add_mod a (b + 1)
  have : (a : Int) = (((b + 1) * (a / (b + 1)) + (a % (b + 1)) : Nat) : Int) := by rw [h_nat]
  omega

theorem xgcd_bezout (a b : Nat) :
    (a : Int) * (xgcd a b).1 + (b : Int) * (xgcd a b).2.1 = ((xgcd a b).2.2 : Int) := by
  induction a, b using xgcd.induct with
  | case1 a =>
    unfold xgcd
    dsimp
    omega
  | case2 a b ih =>
    have h_unfold : xgcd a (b + 1) =
      let (x', y', g) := xgcd (b + 1) (a % (b + 1))
      let q : Int := (a / (b + 1) : Nat)
      (y', x' - q * y', g) := by
      unfold xgcd
      rfl
    have h_div : (a : Int) = (b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int) :=
      nat_div_mod_to_int a b
    generalize h_res : xgcd (b + 1) (a % (b + 1)) = res at ih ⊢
    rcases res with ⟨x', y', g⟩
    dsimp at ih ⊢
    rw [h_unfold, h_res]
    dsimp
    calc
      (a : Int) * y' + (b + 1 : Int) * (x' - ((a / (b + 1) : Nat) : Int) * y')
        = ((b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int)) * y'
          + (b + 1 : Int) * (x' - ((a / (b + 1) : Nat) : Int) * y') := by rw [h_div]
      _ = (b + 1 : Int) * x' + ((a % (b + 1) : Nat) : Int) * y' := by
        rw [Int.add_mul, Int.mul_assoc (b + 1 : Int), Int.mul_sub, Int.mul_assoc (b + 1 : Int)]
        omega
      _ = (g : Int) := ih

