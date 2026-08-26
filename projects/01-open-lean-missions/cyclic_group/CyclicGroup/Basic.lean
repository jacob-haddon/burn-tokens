/-
  Formalization of Cyclic Groups, Element Orders, and Power Congruence in Lean 4
  Standalone formalization from first principles (Zero external Mathlib dependencies).
-/

namespace CyclicGroup

universe u v

-- 1. Algebraic Group Structure
class MyGroup (G : Type u) where
  mul : G → G → G
  one : G
  inv : G → G
  mul_assoc : ∀ a b c : G, mul (mul a b) c = mul a (mul b c)
  one_mul : ∀ a : G, mul one a = a
  mul_one : ∀ a : G, mul a one = a
  mul_left_inv : ∀ a : G, mul (inv a) a = one
  mul_right_inv : ∀ a : G, mul a (inv a) = one

variable {G : Type u} [MyGroup G]

instance : Mul G where mul := MyGroup.mul
instance : One G where one := MyGroup.one
instance : Inv G where inv := MyGroup.inv

theorem mul_assoc (a b c : G) : (a * b) * c = a * (b * c) := MyGroup.mul_assoc a b c
theorem one_mul (a : G) : (1 : G) * a = a := MyGroup.one_mul a
theorem mul_one (a : G) : a * (1 : G) = a := MyGroup.mul_one a
theorem mul_left_inv (a : G) : a⁻¹ * a = 1 := MyGroup.mul_left_inv a
theorem mul_right_inv (a : G) : a * a⁻¹ = 1 := MyGroup.mul_right_inv a

theorem mul_right_cancel (a b c : G) (h : a * c = b * c) : a = b := by
  calc a = a * 1 := (mul_one a).symm
  _ = a * (c * c⁻¹) := by rw [mul_right_inv]
  _ = (a * c) * c⁻¹ := by rw [mul_assoc]
  _ = (b * c) * c⁻¹ := by rw [h]
  _ = b * (c * c⁻¹) := by rw [← mul_assoc]
  _ = b * 1 := by rw [mul_right_inv]
  _ = b := mul_one b

theorem mul_left_cancel (a b c : G) (h : a * b = a * c) : b = c := by
  calc b = 1 * b := (one_mul b).symm
  _ = (a⁻¹ * a) * b := by rw [mul_left_inv]
  _ = a⁻¹ * (a * b) := by rw [← mul_assoc]
  _ = a⁻¹ * (a * c) := by rw [h]
  _ = (a⁻¹ * a) * c := by rw [mul_assoc]
  _ = 1 * c := by rw [mul_left_inv]
  _ = c := one_mul c

-- 2. Natural Exponentiation
def npow (n : Nat) (g : G) : G :=
  match n with
  | 0 => 1
  | n + 1 => g * npow n g

instance : HPow G Nat G where
  hPow g n := npow n g

@[simp] theorem npow_zero (g : G) : g ^ 0 = 1 := rfl
@[simp] theorem npow_succ (g : G) (n : Nat) : g ^ (n + 1) = g * (g ^ n) := rfl

theorem npow_one (g : G) : g ^ 1 = g := by
  dsimp [HPow.hPow, npow]
  rw [mul_one]

theorem npow_mul_g (g : G) (n : Nat) : g ^ n * g = g * (g ^ n) := by
  induction n with
  | zero =>
    rw [npow_zero, one_mul, mul_one]
  | succ n ih =>
    rw [npow_succ, mul_assoc, ih, ← mul_assoc]

theorem npow_add (g : G) (m n : Nat) : g ^ (m + n) = g ^ m * g ^ n := by
  induction m with
  | zero =>
    rw [Nat.zero_add, npow_zero, one_mul]
  | succ m ih =>
    rw [Nat.succ_add, npow_succ, npow_succ, ih, mul_assoc]

theorem npow_comm (g : G) (m n : Nat) : g ^ m * g ^ n = g ^ n * g ^ m := by
  rw [← npow_add, Nat.add_comm, npow_add]

theorem npow_mul (g : G) (m n : Nat) : g ^ (m * n) = (g ^ m) ^ n := by
  induction n with
  | zero =>
    rw [Nat.mul_zero, npow_zero, npow_zero]
  | succ n ih =>
    rw [Nat.mul_succ, npow_add, npow_succ, ih, npow_mul_g]

theorem npow_one_eq_one (q : Nat) : (1 : G) ^ q = 1 := by
  induction q with
  | zero => rfl
  | succ q ih =>
    rw [npow_succ, one_mul, ih]

-- 3. Cyclic Subgroup & Commutativity
def InCyclicSubgroup (g x : G) : Prop :=
  ∃ n : Nat, x = g ^ n

theorem cyclic_comm (g : G) (x y : G) (hx : InCyclicSubgroup g x) (hy : InCyclicSubgroup g y) :
    x * y = y * x := by
  cases hx with
  | intro m hm =>
    cases hy with
    | intro n hn =>
      rw [hm, hn]
      exact npow_comm g m n

-- 4. Element Order & Power Divisibility
structure IsFiniteOrder (g : G) (n : Nat) : Prop where
  pos : n > 0
  pow_eq_one : g ^ n = 1
  min_order : ∀ k : Nat, 0 < k → k < n → g ^ k ≠ 1

theorem pow_eq_one_of_dvd (g : G) (n : Nat) (hn : g ^ n = 1) {k : Nat} (h : ∃ q : Nat, k = n * q) :
    g ^ k = 1 := by
  cases h with
  | intro q hq =>
    rw [hq, npow_mul, hn, npow_one_eq_one]

theorem pow_rem_eq_one (g : G) (n : Nat) (hn : g ^ n = 1) (k : Nat) (hk : g ^ k = 1) :
    g ^ (k % n) = 1 := by
  have h_div : k = n * (k / n) + k % n := (Nat.div_add_mod k n).symm
  have h_mult : g ^ (n * (k / n)) = 1 := pow_eq_one_of_dvd g n hn ⟨k / n, rfl⟩
  have h_split : g ^ k = g ^ (n * (k / n)) * g ^ (k % n) := by
    have h1 : g ^ k = g ^ (n * (k / n) + k % n) := by rw [← h_div]
    rw [h1, npow_add]
  have h_split2 : (1 : G) = (1 : G) * g ^ (k % n) := by
    calc (1 : G) = g ^ k := hk.symm
    _ = g ^ (n * (k / n)) * g ^ (k % n) := h_split
    _ = (1 : G) * g ^ (k % n) := by rw [h_mult]
  rw [one_mul] at h_split2
  exact h_split2.symm

theorem order_dvd_of_pow_eq_one {g : G} {n : Nat} (ho : IsFiniteOrder g n) {k : Nat} (hk : g ^ k = 1) :
    n ∣ k := by
  have h_rem_one := pow_rem_eq_one g n ho.pow_eq_one k hk
  have h_rem_lt := Nat.mod_lt k ho.pos
  have h_rem_zero : k % n = 0 := by
    cases h_eq : k % n with
    | zero => rfl
    | succ r =>
      have h_pos : r + 1 > 0 := Nat.succ_pos r
      have h_lt : r + 1 < n := by
        have : r + 1 = k % n := h_eq.symm
        rw [this]
        exact h_rem_lt
      have h_rem_one' : g ^ (r + 1) = 1 := by
        have : r + 1 = k % n := h_eq.symm
        rw [this]
        exact h_rem_one
      have h_contra := ho.min_order (r + 1) h_pos h_lt
      exact False.elim (h_contra h_rem_one')
  exact Nat.dvd_of_mod_eq_zero h_rem_zero

theorem pow_eq_one_iff_dvd {g : G} {n : Nat} (ho : IsFiniteOrder g n) (k : Nat) :
    g ^ k = 1 ↔ n ∣ k := by
  constructor
  · exact order_dvd_of_pow_eq_one ho
  · intro ⟨q, hq⟩
    exact pow_eq_one_of_dvd g n ho.pow_eq_one ⟨q, hq⟩

theorem pow_eq_pow_iff_dvd_sub {g : G} {n : Nat} (ho : IsFiniteOrder g n) {a b : Nat} (hab : a ≥ b) :
    g ^ a = g ^ b ↔ n ∣ (a - b) := by
  have h_dec : a = (a - b) + b := (Nat.sub_add_cancel hab).symm
  have h_split : g ^ a = g ^ (a - b) * g ^ b := by
    have h1 : g ^ a = g ^ ((a - b) + b) := by rw [← h_dec]
    rw [h1, npow_add]
  constructor
  · intro h
    have h_eq : g ^ (a - b) * g ^ b = 1 * g ^ b := by
      rw [← h_split, h, one_mul]
    have h_one : g ^ (a - b) = 1 := mul_right_cancel (g ^ (a - b)) 1 (g ^ b) h_eq
    exact (pow_eq_one_iff_dvd ho (a - b)).mp h_one
  · intro h_dvd
    have h_one : g ^ (a - b) = 1 := (pow_eq_one_iff_dvd ho (a - b)).mpr h_dvd
    rw [h_split, h_one, one_mul]

-- 5. Power Cancellation & Inverse Power Equational Lemmas
theorem npow_inv (g : G) (n : Nat) : (g ^ n)⁻¹ = (g⁻¹)^n := by
  induction n with
  | zero =>
    dsimp [HPow.hPow, npow]
    have h := mul_left_inv (1 : G)
    rw [mul_one] at h
    exact h
  | succ n ih =>
    rw [npow_succ, npow_succ]
    have h_inv_mul : ∀ a b : G, (a * b)⁻¹ = b⁻¹ * a⁻¹ := by
      intro a b
      have h1 : (a * b) * (b⁻¹ * a⁻¹) = 1 := by
        rw [mul_assoc, ← mul_assoc b, mul_right_inv, one_mul, mul_right_inv]
      have h2 : (a * b)⁻¹ = (a * b)⁻¹ * ((a * b) * (b⁻¹ * a⁻¹)) := by rw [h1, mul_one]
      rw [← mul_assoc, mul_left_inv, one_mul] at h2
      exact h2
    rw [h_inv_mul, ih, npow_mul_g]

-- 6. Group Homomorphisms & Cyclic Functoriality
structure MyGroupHom (G : Type u) (H : Type v) [MyGroup G] [MyGroup H] where
  toFun : G → H
  map_one : toFun 1 = 1
  map_mul : ∀ a b : G, toFun (a * b) = toFun a * toFun b

variable {H : Type v} [MyGroup H]

theorem map_npow (f : MyGroupHom G H) (g : G) (n : Nat) :
    f.toFun (g ^ n) = (f.toFun g) ^ n := by
  induction n with
  | zero =>
    rw [npow_zero, npow_zero, f.map_one]
  | succ n ih =>
    rw [npow_succ, npow_succ, f.map_mul, ih]

theorem image_cyclic_is_cyclic (f : MyGroupHom G H) (g : G) (y : H)
    (hy : ∃ x : G, InCyclicSubgroup g x ∧ y = f.toFun x) :
    InCyclicSubgroup (f.toFun g) y := by
  cases hy with
  | intro x hx =>
    cases hx.1 with
    | intro n hn =>
      refine ⟨n, ?_⟩
      rw [hx.2, hn, map_npow]

end CyclicGroup
