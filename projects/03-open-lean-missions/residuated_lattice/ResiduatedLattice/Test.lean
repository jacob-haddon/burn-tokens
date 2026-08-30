import ResiduatedLattice.Basic

namespace ResiduatedLattice.Test

variable {L : Type} [ResiduatedPoset L]

#print axioms ldiv_counit
#print axioms rdiv_counit
#print axioms ldiv_unit
#print axioms rdiv_unit
#print axioms ldiv_mono_right
#print axioms ldiv_anti_left
#print axioms rdiv_mono_left
#print axioms rdiv_anti_right
#print axioms ldiv_closure_idempotent
#print axioms rdiv_closure_idempotent
#print axioms residual_associativity
#print axioms one_ldiv
#print axioms rdiv_one
#print axioms invertible_ldiv
#print axioms invertible_rdiv

end ResiduatedLattice.Test
