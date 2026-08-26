import MonoidSemidirect.Basic
import MonoidSemidirect.Semidirect

namespace MonoidSemidirectFormalization

open SemidirectProduct

variable {M N : Type _} [MyMonoid M] [MyMonoid N] (act : MyMonoidAction N M)

/-- Main Theorem 2: Canonical left inclusion homomorphism ι_M : M → M ⋊_act N. -/
def inlHom : MyMonoidHom M (SemidirectProduct M N act) where
  toFun m := (m, 1)
  map_one' := rfl
  map_mul' m1 m2 := by
    show (m1 * m2, 1) = (m1 * act.act 1 m2, 1 * 1)
    rw [act.act_id, mul_one_thm 1]

/-- Main Theorem 3: Canonical right inclusion homomorphism ι_N : N → M ⋊_act N. -/
def inrHom : MyMonoidHom N (SemidirectProduct M N act) where
  toFun n := (1, n)
  map_one' := rfl
  map_mul' n1 n2 := by
    show (1, n1 * n2) = (1 * act.act n1 1, n1 * n2)
    rw [act.act_one, one_mul_thm 1]

/-- Main Theorem 4: Canonical projection homomorphism π_N : M ⋊_act N → N. -/
def projN : MyMonoidHom (SemidirectProduct M N act) N where
  toFun p := p.2
  map_one' := rfl
  map_mul' _ _ := rfl

/-- Split exact projection retraction: π_N ∘ ι_N = id_N. -/
theorem projN_inrHom (n : N) : projN act (inrHom act n) = n := rfl

/-- Kernel inclusion: π_N ∘ ι_M = 1. -/
theorem projN_inlHom (m : M) : projN act (inlHom act m) = 1 := rfl

/-- Main Theorem 5: Fundamental Commutation / Intertwining Identity in Semidirect Product:
    ι_N(n) · ι_M(m) = ι_M(act(n)(m)) · ι_N(n). -/
theorem intertwining_law (n : N) (m : M) :
    (inrHom act n) * (inlHom act m) = (inlHom act (act.act n m)) * (inrHom act n) := by
  show (1 * act.act n m, n * 1) = (act.act n m * act.act 1 1, 1 * n)
  have h_fst : 1 * act.act n m = act.act n m * act.act 1 1 := by
    rw [one_mul_thm, act.act_one, mul_one_thm]
  have h_snd : n * 1 = 1 * n := by
    rw [mul_one_thm, one_mul_thm]
  exact Prod.ext h_fst h_snd

/-- Reconstruction decomposition: every element (m, n) in the semidirect product decomposes as ι_M(m) · ι_N(n). -/
theorem element_decomposition (p : SemidirectProduct M N act) :
    p = (inlHom act p.1) * (inrHom act p.2) := by
  show (p.1, p.2) = (p.1 * act.act 1 1, 1 * p.2)
  rw [act.act_one, mul_one_thm, one_mul_thm]

end MonoidSemidirectFormalization
