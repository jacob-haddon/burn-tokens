# Technical Handoff: T-0047 (Semidirect Product of Monoids & Action Invariants in Lean 4)

## Mission Summary

Ticket `T-0047` formalized from first principles in Lean 4 the semidirect product of monoids $M \rtimes_\alpha N$, proving associativity, identity laws, canonical inclusions $\iota_M, \iota_N$, projection $\pi_N$, split exact retraction $\pi_N \circ \iota_N = \text{id}_N$, and the fundamental commutation intertwining identity $\iota_N(n) \cdot \iota_M(m) = \iota_M(\alpha(n)(m)) \cdot \iota_N(n)$ with 0 `sorry` and 0 axioms.

## Key Files & Structure

- `projects/01-open-lean-missions/monoid_semidirect/`:
  - `MonoidSemidirect/Basic.lean`: `MyMonoid`, `MyMonoidHom`, `MyMonoidAction`.
  - `MonoidSemidirect/Semidirect.lean`: `SemidirectProduct`, `SemidirectProduct.instMyMonoidSemidirectProduct`.
  - `MonoidSemidirect/Homomorphisms.lean`: `inlHom`, `inrHom`, `projN`, `projN_inrHom`, `projN_inlHom`, `intertwining_law`, `element_decomposition`.
  - `MonoidSemidirect.lean`: Axiom reflection check.
- `projects/01-open-lean-missions/results/2026-08-26--monoid-semidirect-product-lean4.md`: Result note.

## Independent Reproduction Instructions

```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_semidirect
lake build
lake env lean MonoidSemidirect.lean
```

Clean compilation in $<200\text{ms}$ with 0 `sorry` and 0 axioms.
