/-
  Autonomous Research Lab: Project 01 (Open Lean Missions)
  Mission: Formalisation of the Image of a Submonoid under a Monoid Homomorphism
  Target: Standalone machine-checked Lean 4 formalization with 0 sorry and no extra axioms.
-/

namespace MonoidFormalization

universe u v w

/-- A Monoid is a type equipped with an associative binary operation and a two-sided neutral element. -/
class MyMonoid (M : Type u) extends Mul M, One M where
  mul_assoc : ∀ a b c : M, (a * b) * c = a * (b * c)
  one_mul : ∀ a : M, 1 * a = a
  mul_one : ∀ a : M, a * 1 = a

/-- A Monoid Homomorphism is a map between monoids preserving 1 and multiplication. -/
structure MyMonoidHom (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] where
  toFun : M → N
  map_one' : toFun 1 = 1
  map_mul' : ∀ a b : M, toFun (a * b) = toFun a * toFun b

instance (M : Type u) (N : Type v) [MyMonoid M] [MyMonoid N] :
    CoeFun (MyMonoidHom M N) (fun _ => M → N) where
  coe := MyMonoidHom.toFun

theorem MyMonoidHom.map_one {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N) :
    f 1 = 1 :=
  f.map_one'

theorem MyMonoidHom.map_mul {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N] (f : MyMonoidHom M N) (a b : M) :
    f (a * b) = f a * f b :=
  f.map_mul' a b

/-- Identity monoid homomorphism. -/
def MyMonoidHom.id (M : Type u) [MyMonoid M] : MyMonoidHom M M where
  toFun x := x
  map_one' := rfl
  map_mul' _ _ := rfl

/-- Composition of monoid homomorphisms. -/
def MyMonoidHom.comp {M : Type u} {N : Type v} {P : Type w} [MyMonoid M] [MyMonoid N] [MyMonoid P]
    (g : MyMonoidHom N P) (f : MyMonoidHom M N) : MyMonoidHom M P where
  toFun x := g (f x)
  map_one' := by
    change g (f 1) = 1
    rw [f.map_one, g.map_one]
  map_mul' a b := by
    change g (f (a * b)) = g (f a) * g (f b)
    rw [f.map_mul, g.map_mul]

/-- A Submonoid of M is a subset containing 1 and closed under multiplication. -/
structure MySubmonoid (M : Type u) [MyMonoid M] where
  carrier : M → Prop
  one_mem' : carrier 1
  mul_mem' : ∀ {a b : M}, carrier a → carrier b → carrier (a * b)

instance (M : Type u) [MyMonoid M] : Membership M (MySubmonoid M) where
  mem S x := S.carrier x

instance (M : Type u) [MyMonoid M] : LE (MySubmonoid M) where
  le S T := ∀ ⦃x : M⦄, x ∈ S → x ∈ T

@[ext]
theorem MySubmonoid.ext {M : Type u} [MyMonoid M] {S T : MySubmonoid M}
    (h : ∀ x : M, x ∈ S ↔ x ∈ T) : S = T := by
  have h_carrier : S.carrier = T.carrier := funext (fun x => propext (h x))
  cases S
  cases T
  congr

theorem MySubmonoid.one_mem {M : Type u} [MyMonoid M] (S : MySubmonoid M) : (1 : M) ∈ S :=
  S.one_mem'

theorem MySubmonoid.mul_mem {M : Type u} [MyMonoid M] (S : MySubmonoid M) {a b : M}
    (ha : a ∈ S) (hb : b ∈ S) : a * b ∈ S :=
  S.mul_mem' ha hb

/-- The top submonoid (the entire monoid M). -/
def MySubmonoid.top (M : Type u) [MyMonoid M] : MySubmonoid M where
  carrier _ := True
  one_mem' := True.intro
  mul_mem' _ _ := True.intro

/-- The forward image of a submonoid under a monoid homomorphism.
    This establishes that f(S) = { y ∈ N | ∃ x ∈ S, f x = y } is a submonoid of N. -/
def MySubmonoid.map {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (S : MySubmonoid M) : MySubmonoid N where
  carrier y := ∃ x : M, x ∈ S ∧ f x = y
  one_mem' := by
    exact ⟨1, S.one_mem, f.map_one⟩
  mul_mem' := by
    intro y1 y2 h1 h2
    rcases h1 with ⟨x1, hx1, rfl⟩
    rcases h2 with ⟨x2, hx2, rfl⟩
    refine ⟨x1 * x2, S.mul_mem hx1 hx2, ?_⟩
    exact f.map_mul x1 x2

@[simp]
theorem MySubmonoid.mem_map {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (S : MySubmonoid M) (y : N) :
    y ∈ S.map f ↔ ∃ x : M, x ∈ S ∧ f x = y :=
  Iff.rfl

/-- The preimage (inverse image) of a submonoid under a monoid homomorphism. -/
def MySubmonoid.comap {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (T : MySubmonoid N) : MySubmonoid M where
  carrier x := f x ∈ T
  one_mem' := by
    change f 1 ∈ T
    rw [f.map_one]
    exact T.one_mem
  mul_mem' := by
    intro a b ha hb
    change f (a * b) ∈ T
    rw [f.map_mul]
    exact T.mul_mem ha hb

@[simp]
theorem MySubmonoid.mem_comap {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (T : MySubmonoid N) (x : M) :
    x ∈ T.comap f ↔ f x ∈ T :=
  Iff.rfl

/-- The image of the identity homomorphism on S is S itself. -/
theorem MySubmonoid.map_id {M : Type u} [MyMonoid M] (S : MySubmonoid M) :
    S.map (MyMonoidHom.id M) = S := by
  ext x
  constructor
  · rintro ⟨y, hy, rfl⟩
    exact hy
  · intro hx
    exact ⟨x, hx, rfl⟩

/-- Functoriality of map: image under composition is the composition of images. -/
theorem MySubmonoid.map_comp {M : Type u} {N : Type v} {P : Type w}
    [MyMonoid M] [MyMonoid N] [MyMonoid P]
    (f : MyMonoidHom M N) (g : MyMonoidHom N P) (S : MySubmonoid M) :
    S.map (g.comp f) = (S.map f).map g := by
  ext z
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact ⟨f x, ⟨x, hx, rfl⟩, rfl⟩
  · rintro ⟨y, ⟨x, hx, rfl⟩, rfl⟩
    exact ⟨x, hx, rfl⟩

/-- Galois connection / Adjunction between map and comap:
    f(S) ≤ T ↔ S ≤ f⁻¹(T). -/
theorem MySubmonoid.gc_map_comap {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (S : MySubmonoid M) (T : MySubmonoid N) :
    S.map f ≤ T ↔ S ≤ T.comap f := by
  constructor
  · intro hLE x hx
    show f x ∈ T
    apply hLE
    exact ⟨x, hx, rfl⟩
  · intro hLE y hy
    rcases hy with ⟨x, hx, rfl⟩
    exact hLE hx

/-- The range of a monoid homomorphism as a submonoid of the codomain. -/
def MyMonoidHom.range {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) : MySubmonoid N :=
  (MySubmonoid.top M).map f

theorem MyMonoidHom.mem_range {M : Type u} {N : Type v} [MyMonoid M] [MyMonoid N]
    (f : MyMonoidHom M N) (y : N) :
    y ∈ f.range ↔ ∃ x : M, f x = y := by
  constructor
  · rintro ⟨x, _, rfl⟩
    exact ⟨x, rfl⟩
  · rintro ⟨x, rfl⟩
    exact ⟨x, True.intro, rfl⟩

end MonoidFormalization
