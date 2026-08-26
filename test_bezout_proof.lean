def xgcd : Nat → Nat → Int × Int × Nat
  | a, 0 => (1, 0, a)
  | a, b + 1 =>
    have : (a % (b + 1)) < b + 1 := Nat.mod_lt a (Nat.succ_pos b)
    let (x', y', g) := xgcd (b + 1) (a % (b + 1))
    let q : Int := (a / (b + 1) : Nat)
    (y', x' - q * y', g)
termination_by _ b => b

theorem xgcd_bezout (a b : Nat) :
    (a : Int) * (xgcd a b).1 + (b : Int) * (xgcd a b).2.1 = ((xgcd a b).2.2 : Int) := by
  induction a, b using xgcd.induct with
  | case1 a =>
    simp [xgcd]
  | case2 a b ih =>
    unfold xgcd
    dsimp
    have h_div : (a : Int) = (b + 1 : Int) * (a / (b + 1) : Nat) + (a % (b + 1) : Nat) := by
      have h_nat := Nat.div_add_mod a (b + 1)
      have : (a : Int) = (((b + 1) * (a / (b + 1)) + a % (b + 1) : Nat) : Int) := by rw [← h_nat]
      push_cast at this
      rw [this]
      ring
    -- ih says: (b + 1 : Int) * (xgcd (b + 1) (a % (b + 1))).1 + (a % (b + 1) : Int) * (xgcd (b + 1) (a % (b + 1))).2.1 = ...
    generalize h_res : xgcd (b + 1) (a % (b + 1)) = res
    rcases res with ⟨x', y', g⟩
    dsimp at ih h_res ⊢
    rw [h_res] at ih
    dsimp at ih
    calc
      (a : Int) * y' + (b + 1 : Int) * (x' - ((a / (b + 1) : Nat) : Int) * y')
        = ((b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + (a % (b + 1) : Nat)) * y' + (b + 1 : Int) * (x' - ((a / (b + 1) : Nat) : Int) * y') := by rw [h_div]
      _ = (b + 1 : Int) * x' + (a % (b + 1) : Nat : Int) * y' := by ring
      _ = (g : Int) := ih

