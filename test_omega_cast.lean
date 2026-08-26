theorem nat_cast_div_mod (a b : Nat) :
    (a : Int) = (b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int) := by
  have h_nat : (b + 1) * (a / (b + 1)) + a % (b + 1) = a := Nat.div_add_mod a (b + 1)
  omega

