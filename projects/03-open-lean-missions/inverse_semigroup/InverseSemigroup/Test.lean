import InverseSemigroup.Basic

namespace InverseSemigroup.Test

variable {G : Type} [InverseSemigroup G]

#print axioms idempotent_left
#print axioms idempotent_right
#print axioms idempotent_mul
#print axioms idempotent_conj
#print axioms naturalLe_refl
#print axioms naturalLe_trans
#print axioms naturalLe_mul_compat
#print axioms sigma_refl
#print axioms sigma_symm
#print axioms sigma_trans
#print axioms sigma_mul_right
#print axioms sigma_mul_left
#print axioms sigma_mul_compat
#print axioms idempotents_sigma_equiv
#print axioms mul_inv_sigma_idempotent
#print axioms inv_mul_sigma_mul_inv
#print axioms sigma_left_id

end InverseSemigroup.Test
