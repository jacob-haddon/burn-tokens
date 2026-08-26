theorem nat_cast_div_mod (a b : Nat) :
    (a : Int) = (b + 1 : Int) * ((a / (b + 1) : Nat) : Int) + ((a % (b + 1) : Nat) : Int) := by
  have h_nat : (b + 1) * (a / (b + 1)) + a % (b + 1) = a := Nat.div_add_mod a (b + 1)
  have h_int : (( (b + 1) * (a / (b + 1)) + a % (b + 1) : Nat) : Int) = (a : Int) := by rw [h_nat]
  rw [← h_int]
  rw [Int.ofNat_add, Int.ofNat_mul]

