def xgcd : Nat → Nat → Int × Int × Nat
  | a, 0 => (1, 0, a)
  | a, b + 1 =>
    have : (a % (b + 1)) < b + 1 := Nat.mod_lt a (Nat.succ_pos b)
    let (x', y', g) := xgcd (b + 1) (a % (b + 1))
    let q : Int := (a / (b + 1) : Nat)
    (y', x' - q * y', g)
termination_by _ b => b

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
    exact (Nat.gcd_rec a (b + 1)).symm

