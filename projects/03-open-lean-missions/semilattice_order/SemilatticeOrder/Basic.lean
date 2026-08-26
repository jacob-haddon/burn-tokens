/-
  Autonomous Research Lab: Project 01 (Open Lean Missions)
  Mission: Formalisation of Semilattice Endomorphisms, Induced Monotone Orders, and Sub-semilattice Images
  Target: Standalone machine-checked Lean 4 formalization with 0 sorry and no extra axioms.
-/

namespace SemilatticeFormalization

universe u v w

/-- A Semigroup is a type equipped with an associative binary operation. -/
class MySemigroup (S : Type u) extends Mul S where
  mul_assoc : ∀ a b c : S, (a * b) * c = a * (b * c)

/-- A Semilattice is a commutative, idempotent semigroup.
    Algebraically, it models the meet-semilattice operation (x * y = x ⊓ y). -/
class MySemilattice (S : Type u) extends MySemigroup S where
  mul_comm : ∀ a b : S, a * b = b * a
  mul_idem : ∀ a : S, a * a = a

/-- A Semigroup Homomorphism is a map between semigroups preserving multiplication. -/
structure MySemigroupHom (S : Type u) (T : Type v) [MySemigroup S] [MySemigroup T] where
  toFun : S → T
  map_mul' : ∀ a b : S, toFun (a * b) = toFun a * toFun b

instance (S : Type u) (T : Type v) [MySemigroup S] [MySemigroup T] :
    CoeFun (MySemigroupHom S T) (fun _ => S → T) where
  coe := MySemigroupHom.toFun

theorem MySemigroupHom.map_mul {S : Type u} {T : Type v} [MySemigroup S] [MySemigroup T]
    (f : MySemigroupHom S T) (a b : S) :
    f (a * b) = f a * f b :=
  f.map_mul' a b

/-- Identity semigroup homomorphism. -/
def MySemigroupHom.id (S : Type u) [MySemigroup S] : MySemigroupHom S S where
  toFun x := x
  map_mul' _ _ := rfl

/-- Composition of semigroup homomorphisms. -/
def MySemigroupHom.comp {S : Type u} {T : Type v} {P : Type w}
    [MySemigroup S] [MySemigroup T] [MySemigroup P]
    (g : MySemigroupHom T P) (f : MySemigroupHom S T) : MySemigroupHom S P where
  toFun x := g (f x)
  map_mul' a b := by
    change g (f (a * b)) = g (f a) * g (f b)
    rw [f.map_mul, g.map_mul]

/-- The induced canonical partial order on a semilattice: x ≤ y ↔ x * y = x. -/
def semilatticeLe {S : Type u} [MySemilattice S] (x y : S) : Prop :=
  x * y = x

instance (S : Type u) [MySemilattice S] : LE S where
  le := semilatticeLe

theorem le_def {S : Type u} [MySemilattice S] (x y : S) :
    x ≤ y ↔ x * y = x :=
  Iff.rfl

/-- Reflexivity of the induced semilattice order: x ≤ x. -/
theorem le_refl {S : Type u} [MySemilattice S] (x : S) : x ≤ x := by
  rw [le_def]
  exact MySemilattice.mul_idem x

/-- Antisymmetry of the induced semilattice order: x ≤ y → y ≤ x → x = y. -/
theorem le_antisymm {S : Type u} [MySemilattice S] {x y : S}
    (h1 : x ≤ y) (h2 : y ≤ x) : x = y := by
  rw [le_def] at h1 h2
  have h_comm : x * y = y * x := MySemilattice.mul_comm x y
  rw [h1] at h_comm
  rw [h2] at h_comm
  exact h_comm

/-- Transitivity of the induced semilattice order: x ≤ y → y ≤ z → x ≤ z. -/
theorem le_trans {S : Type u} [MySemilattice S] {x y z : S}
    (h1 : x ≤ y) (h2 : y ≤ z) : x ≤ z := by
  rw [le_def] at h1 h2 ⊢
  calc
    x * z = (x * y) * z := by rw [h1]
    _     = x * (y * z) := MySemigroup.mul_assoc x y z
    _     = x * y       := by rw [h2]
    _     = x           := h1

/-- Multiplication is the greatest lower bound (meet): x * y ≤ x. -/
theorem mul_le_left {S : Type u} [MySemilattice S] (x y : S) : x * y ≤ x := by
  rw [le_def]
  calc
    (x * y) * x = (y * x) * x := by rw [MySemilattice.mul_comm x y]
    _           = y * (x * x) := MySemigroup.mul_assoc y x x
    _           = y * x       := by rw [MySemilattice.mul_idem x]
    _           = x * y       := MySemilattice.mul_comm y x

/-- Multiplication is the greatest lower bound (meet): x * y ≤ y. -/
theorem mul_le_right {S : Type u} [MySemilattice S] (x y : S) : x * y ≤ y := by
  rw [le_def]
  calc
    (x * y) * y = x * (y * y) := MySemigroup.mul_assoc x y y
    _           = x * y       := by rw [MySemilattice.mul_idem y]

/-- Characterization of lower bounds: z ≤ x * y ↔ z ≤ x ∧ z ≤ y. -/
theorem le_mul_iff {S : Type u} [MySemilattice S] (x y z : S) :
    z ≤ x * y ↔ z ≤ x ∧ z ≤ y := by
  constructor
  · intro hz
    constructor
    · exact le_trans hz (mul_le_left x y)
    · exact le_trans hz (mul_le_right x y)
  · rintro ⟨hzx, hzy⟩
    rw [le_def] at hzx hzy ⊢
    calc
      z * (x * y) = (z * x) * y := (MySemigroup.mul_assoc z x y).symm
      _           = z * y       := by rw [hzx]
      _           = z           := hzy

/-- Monotonicity of semigroup homomorphisms with respect to the induced semilattice order. -/
theorem MySemigroupHom.monotone {S : Type u} {T : Type v}
    [MySemilattice S] [MySemilattice T]
    (f : MySemigroupHom S T) {x y : S} (h : x ≤ y) : f x ≤ f y := by
  rw [le_def] at h ⊢
  calc
    f x * f y = f (x * y) := (f.map_mul x y).symm
    _         = f x       := by rw [h]

/-- A Sub-semilattice is a subset closed under the semigroup multiplication. -/
structure MySubSemilattice (S : Type u) [MySemilattice S] where
  carrier : S → Prop
  mul_mem' : ∀ {a b : S}, carrier a → carrier b → carrier (a * b)

instance (S : Type u) [MySemilattice S] : Membership S (MySubSemilattice S) where
  mem U x := U.carrier x

instance (S : Type u) [MySemilattice S] : LE (MySubSemilattice S) where
  le U V := ∀ ⦃x : S⦄, x ∈ U → x ∈ V

@[ext]
theorem MySubSemilattice.ext {S : Type u} [MySemilattice S] {U V : MySubSemilattice S}
    (h : ∀ x : S, x ∈ U ↔ x ∈ V) : U = V := by
  have h_carrier : U.carrier = V.carrier := funext (fun x => propext (h x))
  cases U
  cases V
  congr

theorem MySubSemilattice.mul_mem {S : Type u} [MySemilattice S] (U : MySubSemilattice S)
    {a b : S} (ha : a ∈ U) (hb : b ∈ U) : a * b ∈ U :=
  U.mul_mem' ha hb

/-- The forward image of a sub-semilattice under a semigroup homomorphism is a sub-semilattice. -/
def MySubSemilattice.map {S : Type u} {T : Type v}
    [MySemilattice S] [MySemilattice T]
    (f : MySemigroupHom S T) (U : MySubSemilattice S) : MySubSemilattice T where
  carrier y := ∃ x : S, x ∈ U ∧ f x = y
  mul_mem' := by
    intro y1 y2 h1 h2
    rcases h1 with ⟨x1, hx1, rfl⟩
    rcases h2 with ⟨x2, hx2, rfl⟩
    refine ⟨x1 * x2, U.mul_mem hx1 hx2, ?_⟩
    exact f.map_mul x1 x2

@[simp]
theorem MySubSemilattice.mem_map {S : Type u} {T : Type v}
    [MySemilattice S] [MySemilattice T]
    (f : MySemigroupHom S T) (U : MySubSemilattice S) (y : T) :
    y ∈ U.map f ↔ ∃ x : S, x ∈ U ∧ f x = y :=
  Iff.rfl

/-- The preimage (inverse image) of a sub-semilattice under a semigroup homomorphism. -/
def MySubSemilattice.comap {S : Type u} {T : Type v}
    [MySemilattice S] [MySemilattice T]
    (f : MySemigroupHom S T) (V : MySubSemilattice T) : MySubSemilattice S where
  carrier x := f x ∈ V
  mul_mem' := by
    intro a b ha hb
    change f (a * b) ∈ V
    rw [f.map_mul]
    exact V.mul_mem ha hb

@[simp]
theorem MySubSemilattice.mem_comap {S : Type u} {T : Type v}
    [MySemilattice S] [MySemilattice T]
    (f : MySemigroupHom S T) (V : MySubSemilattice T) (x : S) :
    x ∈ V.comap f ↔ f x ∈ V :=
  Iff.rfl

/-- Galois connection / Adjunction between map and comap for sub-semilattices:
    f(U) ≤ V ↔ U ≤ f⁻¹(V). -/
theorem MySubSemilattice.gc_map_comap {S : Type u} {T : Type v}
    [MySemilattice S] [MySemilattice T]
    (f : MySemigroupHom S T) (U : MySubSemilattice S) (V : MySubSemilattice T) :
    U.map f ≤ V ↔ U ≤ V.comap f := by
  constructor
  · intro hLE x hx
    show f x ∈ V
    apply hLE
    exact ⟨x, hx, rfl⟩
  · intro hLE y hy
    rcases hy with ⟨x, hx, rfl⟩
    exact hLE hx

/-- The image under identity is the sub-semilattice itself. -/
theorem MySubSemilattice.map_id {S : Type u} [MySemilattice S] (U : MySubSemilattice S) :
    U.map (MySemigroupHom.id S) = U := by
  ext x
  constructor
  · rintro ⟨y, hy, rfl⟩
    exact hy
  · intro hx
    exact ⟨x, hx, rfl⟩

/-- Functoriality of map under composition of semigroup homomorphisms. -/
theorem MySubSemilattice.map_comp {S : Type u} {T : Type v} {P : Type w}
    [MySemilattice S] [MySemilattice T] [MySemilattice P]
    (f : MySemigroupHom S T) (g : MySemigroupHom T P) (U : MySubSemilattice S) :
    U.map (g.comp f) = (U.map f).map g := by
  ext z
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact ⟨f x, ⟨x, hx, rfl⟩, rfl⟩
  · rintro ⟨y, ⟨x, hx, rfl⟩, rfl⟩
    exact ⟨x, hx, rfl⟩

end SemilatticeFormalization
