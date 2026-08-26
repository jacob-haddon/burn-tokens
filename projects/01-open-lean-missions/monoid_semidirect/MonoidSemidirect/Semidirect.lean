import MonoidSemidirect.Basic

namespace MonoidSemidirectFormalization

variable {M N : Type _} [MyMonoid M] [MyMonoid N] (act : MyMonoidAction N M)

/-- Carrier type for the semidirect product M ⋊_act N. -/
def SemidirectProduct (M N : Type _) [MyMonoid M] [MyMonoid N] (_ : MyMonoidAction N M) : Type _ :=
  M × N

namespace SemidirectProduct

/-- Constructor for elements of the semidirect product. -/
def mk (m : M) (n : N) : SemidirectProduct M N act := (m, n)

/-- Multiplication on the semidirect product: (m1, n1) · (m2, n2) = (m1 · act(n1)(m2), n1 · n2). -/
def mul (p1 p2 : SemidirectProduct M N act) : SemidirectProduct M N act :=
  (p1.1 * act.act p1.2 p2.1, p1.2 * p2.2)

/-- Identity element: (1, 1). -/
def one : SemidirectProduct M N act :=
  (1, 1)

/-- Main Theorem 1: The semidirect product forms a valid monoid. -/
instance instMyMonoidSemidirectProduct : MyMonoid (SemidirectProduct M N act) where
  mul := mul act
  one := one act
  mul_assoc p1 p2 p3 := by
    show ((p1.1 * act.act p1.2 p2.1) * act.act (p1.2 * p2.2) p3.1, (p1.2 * p2.2) * p3.2) =
         (p1.1 * act.act p1.2 (p2.1 * act.act p2.2 p3.1), p1.2 * (p2.2 * p3.2))
    have h_snd : (p1.2 * p2.2) * p3.2 = p1.2 * (p2.2 * p3.2) := mul_assoc_thm p1.2 p2.2 p3.2
    have h_act_comp : act.act (p1.2 * p2.2) p3.1 = act.act p1.2 (act.act p2.2 p3.1) :=
      act.act_comp p1.2 p2.2 p3.1
    have h_act_mul : act.act p1.2 (p2.1 * act.act p2.2 p3.1) =
                     act.act p1.2 p2.1 * act.act p1.2 (act.act p2.2 p3.1) :=
      act.act_mul p1.2 p2.1 (act.act p2.2 p3.1)
    have h_fst : (p1.1 * act.act p1.2 p2.1) * act.act (p1.2 * p2.2) p3.1 =
                 p1.1 * act.act p1.2 (p2.1 * act.act p2.2 p3.1) := by
      calc
        (p1.1 * act.act p1.2 p2.1) * act.act (p1.2 * p2.2) p3.1
          = (p1.1 * act.act p1.2 p2.1) * act.act p1.2 (act.act p2.2 p3.1) := by rw [h_act_comp]
        _ = p1.1 * (act.act p1.2 p2.1 * act.act p1.2 (act.act p2.2 p3.1)) := mul_assoc_thm _ _ _
        _ = p1.1 * act.act p1.2 (p2.1 * act.act p2.2 p3.1) := by rw [← h_act_mul]
    exact Prod.ext h_fst h_snd
  one_mul p := by
    show (1 * act.act 1 p.1, 1 * p.2) = (p.1, p.2)
    rw [act.act_id p.1, one_mul_thm p.1, one_mul_thm p.2]
  mul_one p := by
    show (p.1 * act.act p.2 1, p.2 * 1) = (p.1, p.2)
    rw [act.act_one p.2, mul_one_thm p.1, mul_one_thm p.2]

end SemidirectProduct

end MonoidSemidirectFormalization
