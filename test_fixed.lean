class MyAddCommMonoid (M : Type _) where
  add : M → M → M
  zero : M
  add_assoc : ∀ a b c : M, add (add a b) c = add a (add b c)
  zero_add : ∀ a : M, add zero a = a
  add_zero : ∀ a : M, add a zero = a
  add_comm : ∀ a b : M, add a b = add b a

instance (M : Type _) [MyAddCommMonoid M] : Add M := ⟨MyAddCommMonoid.add⟩
instance (M : Type _) [MyAddCommMonoid M] : Zero M := ⟨MyAddCommMonoid.zero⟩

theorem add_assoc_thm {M : Type _} [MyAddCommMonoid M] (a b c : M) :
    a + b + c = a + (b + c) := MyAddCommMonoid.add_assoc a b c

theorem zero_add_thm {M : Type _} [MyAddCommMonoid M] (a : M) :
    0 + a = a := MyAddCommMonoid.zero_add a

theorem add_zero_thm {M : Type _} [MyAddCommMonoid M] (a : M) :
    a + 0 = a := MyAddCommMonoid.add_zero a

theorem add_comm_thm {M : Type _} [MyAddCommMonoid M] (a b : M) :
    a + b = b + a := MyAddCommMonoid.add_comm a b

theorem add_left_comm_thm {M : Type _} [MyAddCommMonoid M] (a b c : M) :
    a + (b + c) = b + (a + c) := by
  rw [← add_assoc_thm, add_comm_thm a b, add_assoc_thm]

theorem add_add_add_comm {M : Type _} [MyAddCommMonoid M] (a b c d : M) :
    (a + b) + (c + d) = (a + c) + (b + d) := by
  calc
    (a + b) + (c + d) = a + (b + (c + d)) := add_assoc_thm a b (c + d)
    _ = a + (c + (b + d)) := by rw [add_left_comm_thm b c d]
    _ = (a + c) + (b + d) := (add_assoc_thm a c (b + d)).symm

theorem add_add_add_comm3 {M : Type _} [MyAddCommMonoid M] (a b c d e f : M) :
    (a + b + c) + (d + e + f) = (a + d) + (b + e) + (c + f) := by
  calc
    (a + b + c) + (d + e + f) = ((a + b) + c) + ((d + e) + f) := rfl
    _ = ((a + b) + (d + e)) + (c + f) := add_add_add_comm (a + b) c (d + e) f
    _ = ((a + d) + (b + e)) + (c + f) := by rw [add_add_add_comm a b d e]

class MyAddCommGroup (G : Type _) extends MyAddCommMonoid G where
  neg : G → G
  add_left_neg : ∀ a : G, neg a + a = 0

instance (G : Type _) [MyAddCommGroup G] : Neg G := ⟨MyAddCommGroup.neg⟩

theorem add_left_neg_thm {G : Type _} [MyAddCommGroup G] (a : G) :
    -a + a = 0 := MyAddCommGroup.add_left_neg a

theorem add_right_neg_thm {G : Type _} [MyAddCommGroup G] (a : G) :
    a + -a = 0 := by
  rw [add_comm_thm, add_left_neg_thm]

theorem sub_cancel_same {G : Type _} [MyAddCommGroup G] (a b k : G) (h : a + k = b + k) : a = b := by
  calc
    a = a + 0 := (add_zero_thm a).symm
    _ = a + (k + -k) := by rw [add_right_neg_thm]
    _ = (a + k) + -k := (add_assoc_thm a k (-k)).symm
    _ = (b + k) + -k := by rw [h]
    _ = b + (k + -k) := add_assoc_thm b k (-k)
    _ = b + 0 := by rw [add_right_neg_thm]
    _ = b := add_zero_thm b

structure MyAddMonoidHom (M N : Type _) [MyAddCommMonoid M] [MyAddCommMonoid N] where
  toFun : M → N
  map_zero' : toFun 0 = 0
  map_add' : ∀ x y : M, toFun (x + y) = toFun x + toFun y

instance (M N : Type _) [MyAddCommMonoid M] [MyAddCommMonoid N] :
    CoeFun (MyAddMonoidHom M N) (fun _ => M → N) where
  coe f := f.toFun

@[ext]
theorem MyAddMonoidHom.ext {M N : Type _} [MyAddCommMonoid M] [MyAddCommMonoid N]
    {f g : MyAddMonoidHom M N} (h : ∀ x : M, f x = g x) : f = g := by
  cases f
  cases g
  congr
  funext x
  exact h x

def grothendieckRel {M : Type _} [MyAddCommMonoid M] (p1 p2 : M × M) : Prop :=
  ∃ k : M, p1.1 + p2.2 + k = p2.1 + p1.2 + k

theorem grothendieckRel_refl {M : Type _} [MyAddCommMonoid M] (p : M × M) :
    grothendieckRel p p :=
  ⟨0, rfl⟩

theorem grothendieckRel_symm {M : Type _} [MyAddCommMonoid M] {p1 p2 : M × M}
    (h : grothendieckRel p1 p2) : grothendieckRel p2 p1 := by
  obtain ⟨k, hk⟩ := h
  exact ⟨k, hk.symm⟩

theorem grothendieckRel_trans {M : Type _} [MyAddCommMonoid M] {p1 p2 p3 : M × M}
    (h12 : grothendieckRel p1 p2) (h23 : grothendieckRel p2 p3) :
    grothendieckRel p1 p3 := by
  obtain ⟨k1, hk1⟩ := h12
  obtain ⟨k2, hk2⟩ := h23
  refine ⟨p2.1 + p2.2 + (k1 + k2), ?_⟩
  have h_sum : (p1.1 + p2.2 + k1) + (p2.1 + p3.2 + k2) = (p2.1 + p1.2 + k1) + (p3.1 + p2.2 + k2) := by
    rw [hk1, hk2]
  have L : (p1.1 + p2.2 + k1) + (p2.1 + p3.2 + k2) = (p1.1 + p3.2) + (p2.2 + p2.1) + (k1 + k2) := by
    rw [add_comm_thm p2.1 p3.2]
    exact add_add_add_comm3 p1.1 p2.2 k1 p3.2 p2.1 k2
  have R : (p2.1 + p1.2 + k1) + (p3.1 + p2.2 + k2) = (p3.1 + p1.2) + (p2.1 + p2.2) + (k1 + k2) := by
    calc
      (p2.1 + p1.2 + k1) + (p3.1 + p2.2 + k2) = (p3.1 + p2.2 + k2) + (p2.1 + p1.2 + k1) := add_comm_thm _ _
      _ = (p3.1 + p2.2 + k2) + (p1.2 + p2.1 + k1) := by rw [add_comm_thm p2.1 p1.2]
      _ = (p3.1 + p1.2) + (p2.2 + p2.1) + (k2 + k1) := add_add_add_comm3 p3.1 p2.2 k2 p1.2 p2.1 k1
      _ = (p3.1 + p1.2) + (p2.1 + p2.2) + (k1 + k2) := by rw [add_comm_thm p2.2 p2.1, add_comm_thm k2 k1]
  rw [add_comm_thm p2.2 p2.1] at L
  rw [L, R] at h_sum
  calc
    p1.1 + p3.2 + (p2.1 + p2.2 + (k1 + k2)) = (p1.1 + p3.2) + (p2.1 + p2.2) + (k1 + k2) :=
      (add_assoc_thm (p1.1 + p3.2) (p2.1 + p2.2) (k1 + k2)).symm
    _ = (p3.1 + p1.2) + (p2.1 + p2.2) + (k1 + k2) := h_sum
    _ = p3.1 + p1.2 + (p2.1 + p2.2 + (k1 + k2)) :=
      add_assoc_thm (p3.1 + p1.2) (p2.1 + p2.2) (k1 + k2)

def grothendieckSetoid (M : Type _) [MyAddCommMonoid M] : Setoid (M × M) where
  r := grothendieckRel
  iseqv := ⟨grothendieckRel_refl, grothendieckRel_symm, grothendieckRel_trans⟩

def GrothendieckGroup (M : Type _) [MyAddCommMonoid M] : Type _ :=
  Quotient (grothendieckSetoid M)

theorem grothendieckRel_add_congr {M : Type _} [MyAddCommMonoid M]
    {a1 a2 b1 b2 : M × M} (ha : grothendieckRel a1 a2) (hb : grothendieckRel b1 b2) :
    grothendieckRel (a1.1 + b1.1, a1.2 + b1.2) (a2.1 + b2.1, a2.2 + b2.2) := by
  obtain ⟨ka, hka⟩ := ha
  obtain ⟨kb, hkb⟩ := hb
  refine ⟨ka + kb, ?_⟩
  dsimp
  have h_sum : (a1.1 + a2.2 + ka) + (b1.1 + b2.2 + kb) = (a2.1 + a1.2 + ka) + (b2.1 + b1.2 + kb) := by
    rw [hka, hkb]
  have L : (a1.1 + a2.2 + ka) + (b1.1 + b2.2 + kb) = (a1.1 + b1.1) + (a2.2 + b2.2) + (ka + kb) :=
    add_add_add_comm3 a1.1 a2.2 ka b1.1 b2.2 kb
  have R : (a2.1 + a1.2 + ka) + (b2.1 + b1.2 + kb) = (a2.1 + b2.1) + (a1.2 + b1.2) + (ka + kb) :=
    add_add_add_comm3 a2.1 a1.2 ka b2.1 b1.2 kb
  rw [L, R] at h_sum
  calc
    (a1.1 + b1.1) + (a2.2 + b2.2) + (ka + kb) = (a2.1 + b2.1) + (a1.2 + b1.2) + (ka + kb) := h_sum
    _ = (a2.1 + b2.1) + (a1.2 + b1.2) + (ka + kb) := rfl

def grothAdd {M : Type _} [MyAddCommMonoid M] : GrothendieckGroup M → GrothendieckGroup M → GrothendieckGroup M :=
  Quotient.lift₂ (fun p1 p2 => Quotient.mk (grothendieckSetoid M) (p1.1 + p2.1, p1.2 + p2.2)) (fun _ _ _ _ ha hb =>
    Quotient.sound (grothendieckRel_add_congr ha hb))

def grothZero {M : Type _} [MyAddCommMonoid M] : GrothendieckGroup M :=
  Quotient.mk (grothendieckSetoid M) (0, 0)

def grothNeg {M : Type _} [MyAddCommMonoid M] : GrothendieckGroup M → GrothendieckGroup M :=
  Quotient.lift (fun p => Quotient.mk (grothendieckSetoid M) (p.2, p.1)) (fun p1 p2 h => by
    obtain ⟨k, hk⟩ := h
    apply Quotient.sound
    refine ⟨k, ?_⟩
    dsimp
    calc
      p1.2 + p2.1 + k = p2.1 + p1.2 + k := by rw [add_comm_thm p1.2 p2.1]
      _ = p1.1 + p2.2 + k := hk.symm
      _ = p2.2 + p1.1 + k := by rw [add_comm_thm p1.1 p2.2])

instance (M : Type _) [MyAddCommMonoid M] : MyAddCommGroup (GrothendieckGroup M) where
  add := grothAdd
  zero := grothZero
  neg := grothNeg
  add_assoc a b c := by
    induction a using Quotient.inductionOn with | h a =>
    induction b using Quotient.inductionOn with | h b =>
    induction c using Quotient.inductionOn with | h c =>
    apply Quotient.sound
    refine ⟨0, ?_⟩
    dsimp
    rw [add_assoc_thm a.1 b.1 c.1, add_assoc_thm a.2 b.2 c.2]
  zero_add a := by
    induction a using Quotient.inductionOn with | h a =>
    apply Quotient.sound
    refine ⟨0, ?_⟩
    dsimp
    rw [zero_add_thm a.1, zero_add_thm a.2]
  add_zero a := by
    induction a using Quotient.inductionOn with | h a =>
    apply Quotient.sound
    refine ⟨0, ?_⟩
    dsimp
    rw [add_zero_thm a.1, add_zero_thm a.2]
  add_comm a b := by
    induction a using Quotient.inductionOn with | h a =>
    induction b using Quotient.inductionOn with | h b =>
    apply Quotient.sound
    refine ⟨0, ?_⟩
    dsimp
    rw [add_comm_thm a.1 b.1, add_comm_thm a.2 b.2]
  add_left_neg a := by
    induction a using Quotient.inductionOn with | h a =>
    apply Quotient.sound
    refine ⟨0, ?_⟩
    dsimp
    calc
      (a.2 + a.1) + 0 + 0 = (a.1 + a.2) + 0 + 0 := by rw [add_comm_thm a.2 a.1]
      _ = 0 + (a.1 + a.2) + 0 := by rw [add_zero_thm, zero_add_thm]

def canonicalHom (M : Type _) [MyAddCommMonoid M] : MyAddMonoidHom M (GrothendieckGroup M) where
  toFun m := Quotient.mk (grothendieckSetoid M) (m, 0)
  map_zero' := rfl
  map_add' x y := by
    apply Quotient.sound
    refine ⟨0, ?_⟩
    dsimp
    rw [add_zero_thm 0]

def universalLift {M G : Type _} [MyAddCommMonoid M] [MyAddCommGroup G]
    (f : MyAddMonoidHom M G) : MyAddMonoidHom (GrothendieckGroup M) G where
  toFun := Quotient.lift (fun p => f p.1 + -f p.2) (fun p1 p2 h => by
    obtain ⟨k, hk⟩ := h
    have h_f : f (p1.1 + p2.2 + k) = f (p2.1 + p1.2 + k) := by rw [hk]
    rw [f.map_add', f.map_add', f.map_add', f.map_add'] at h_f
    have h_cancel : (f p1.1 + f p2.2) + f k = (f p2.1 + f p1.2) + f k := by
      calc
        (f p1.1 + f p2.2) + f k = (f p1.1 + f p2.2 + f k) := rfl
        _ = f p2.1 + f p1.2 + f k := h_f
        _ = (f p2.1 + f p1.2) + f k := rfl
    have h_main := sub_cancel_same (f p1.1 + f p2.2) (f p2.1 + f p1.2) (f k) h_cancel
    calc
      f p1.1 + -f p1.2 = (f p1.1 + -f p1.2) + 0 := (add_zero_thm _).symm
      _ = (f p1.1 + -f p1.2) + (f p2.2 + -f p2.2) := by rw [add_right_neg_thm]
      _ = (f p1.1 + f p2.2) + (-f p1.2 + -f p2.2) := add_add_add_comm (f p1.1) (-f p1.2) (f p2.2) (-f p2.2)
      _ = (f p2.1 + f p1.2) + (-f p1.2 + -f p2.2) := by rw [h_main]
      _ = f p2.1 + (f p1.2 + (-f p1.2 + -f p2.2)) := add_assoc_thm _ _ _
      _ = f p2.1 + ((f p1.2 + -f p1.2) + -f p2.2) := by rw [← add_assoc_thm (f p1.2) (-f p1.2) (-f p2.2)]
      _ = f p2.1 + (0 + -f p2.2) := by rw [add_right_neg_thm]
      _ = f p2.1 + -f p2.2 := by rw [zero_add_thm])
  map_zero' := by
    dsimp
    rw [f.map_zero', f.map_zero']
    calc
      0 + -0 = -0 + 0 := add_comm_thm 0 (-0)
      _ = 0 := add_left_neg_thm 0
  map_add' a b := by
    induction a using Quotient.inductionOn with | h a =>
    induction b using Quotient.inductionOn with | h b =>
    dsimp [grothAdd]
    rw [f.map_add', f.map_add']
    calc
      (f a.1 + f b.1) + -(f a.2 + f b.2)
        = (f a.1 + f b.1) + (-f a.2 + -f b.2) := by
          congr 1
          have h_inv : (f a.2 + f b.2) + (-f a.2 + -f b.2) = 0 := by
            calc
              (f a.2 + f b.2) + (-f a.2 + -f b.2)
                = (f a.2 + -f a.2) + (f b.2 + -f b.2) := add_add_add_comm (f a.2) (f b.2) (-f a.2) (-f b.2)
              _ = 0 + 0 := by rw [add_right_neg_thm, add_right_neg_thm]
              _ = 0 := add_zero_thm 0
          calc
            -(f a.2 + f b.2) = -(f a.2 + f b.2) + 0 := (add_zero_thm _).symm
            _ = -(f a.2 + f b.2) + ((f a.2 + f b.2) + (-f a.2 + -f b.2)) := by rw [h_inv]
            _ = (-(f a.2 + f b.2) + (f a.2 + f b.2)) + (-f a.2 + -f b.2) := (add_assoc_thm _ _ _).symm
            _ = 0 + (-f a.2 + -f b.2) := by rw [add_left_neg_thm]
            _ = -f a.2 + -f b.2 := zero_add_thm _
      _ = (f a.1 + -f a.2) + (f b.1 + -f b.2) := add_add_add_comm (f a.1) (f b.1) (-f a.2) (-f b.2)

theorem universalLift_canonical {M G : Type _} [MyAddCommMonoid M] [MyAddCommGroup G]
    (f : MyAddMonoidHom M G) (m : M) :
    universalLift f (canonicalHom M m) = f m := by
  dsimp [universalLift, canonicalHom]
  rw [f.map_zero']
  calc
    f m + -0 = f m + 0 := by
      congr 1
      calc
        -0 = -0 + 0 := (add_zero_thm (-0)).symm
        _ = 0 := add_left_neg_thm 0
    _ = f m := add_zero_thm (f m)

theorem universalLift_unique {M G : Type _} [MyAddCommMonoid M] [MyAddCommGroup G]
    (f : MyAddMonoidHom M G)
    (h : MyAddMonoidHom (GrothendieckGroup M) G)
    (h_comm : ∀ m : M, h (canonicalHom M m) = f m) :
    h = universalLift f := by
  ext q
  induction q using Quotient.inductionOn with | h p =>
  have h_split : Quotient.mk (grothendieckSetoid M) p =
      canonicalHom M p.1 + -canonicalHom M p.2 := by
    apply Quotient.sound
    refine ⟨0, ?_⟩
    dsimp [canonicalHom, grothAdd, grothNeg]
    rw [add_zero_thm, zero_add_thm]
  have h_map_neg (x : GrothendieckGroup M) : h (-x) = -h x := by
    have h0 : h (-x + x) = h 0 := by rw [add_left_neg_thm]
    rw [h.map_add', h.map_zero'] at h0
    calc
      h (-x) = h (-x) + 0 := (add_zero_thm _).symm
      _ = h (-x) + (h x + -h x) := by rw [add_right_neg_thm]
      _ = (h (-x) + h x) + -h x := (add_assoc_thm _ _ _).symm
      _ = 0 + -h x := by rw [h0]
      _ = -h x := zero_add_thm _
  calc
    h (Quotient.mk (grothendieckSetoid M) p)
      = h (canonicalHom M p.1 + -canonicalHom M p.2) := by rw [h_split]
    _ = h (canonicalHom M p.1) + h (-canonicalHom M p.2) := h.map_add' _ _
    _ = f p.1 + -h (canonicalHom M p.2) := by rw [h_comm p.1, h_map_neg]
    _ = f p.1 + -f p.2 := by rw [h_comm p.2]
    _ = universalLift f (Quotient.mk (grothendieckSetoid M) p) := rfl

