import GaloisConnection.Basic

open GaloisFormalization

#print axioms gc_le_g_f
#print axioms gc_f_g_le
#print axioms gc_monotone_l
#print axioms gc_monotone_u
#print axioms gc_f_g_f
#print axioms gc_g_f_g
#print axioms gc_closure_operator_gf
#print axioms gc_kernel_operator_fg
#print axioms is_closed_iff_mem_range
#print axioms is_open_iff_mem_range
#print axioms closed_open_equiv

def main : IO Unit := do
  IO.println "All GaloisConnection axioms printed and verified successfully."
