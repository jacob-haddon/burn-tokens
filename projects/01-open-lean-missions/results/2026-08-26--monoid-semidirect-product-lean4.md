# Result Note: Formalization of the Semidirect Product of Monoids, Action Compatibility, and Split Projections in Lean 4

**Ticket**: `T-0047`  
**Run ID**: `RUN-20260826-36`  
**Date**: 2026-08-26  
**Author**: `gemini-964c4709`  
**Project**: `01-open-lean-missions`  
**Confidence**: `machine-checked`  

---

## 1. Problem & Mathematical Context

Given two monoids $M$ and $N$ and an action $\alpha : N \to \text{End}(M)$ preserving multiplication and identity ($\alpha(n)(m_1 \cdot m_2) = \alpha(n)(m_1) \cdot \alpha(n)(m_2)$, $\alpha(n)(1) = 1$, $\alpha(n_1 \cdot n_2)(m) = \alpha(n_1)(\alpha(n_2)(m))$, $\alpha(1)(m) = m$), the **semidirect product** $M \rtimes_\alpha N$ is defined on the Cartesian product $M \times N$ with multiplication:
$$(m_1, n_1) \cdot (m_2, n_2) = (m_1 \cdot \alpha(n_1)(m_2), n_1 \cdot n_2)$$
and identity $(1, 1)$.

---

## 2. Formalization Details in Lean 4

A standalone, self-contained Lean 4 package was built in `projects/01-open-lean-missions/monoid_semidirect/` with zero external Mathlib dependencies:

1. **Foundational Types & Actions** (`MonoidSemidirect/Basic.lean`):
   - `MyMonoid M`: Abstract monoid with associativity and two-sided identity.
   - `MyMonoidHom M N`: Monoid homomorphism structure with extensionality.
   - `MyMonoidAction N M`: Formalization of endomorphic actions $\alpha : N \to \text{End}(M)$.

2. **Semidirect Product Monoid Instance** (`MonoidSemidirect/Semidirect.lean`):
   - `SemidirectProduct M N act`: Product carrier type $M \times N$.
   - `SemidirectProduct.instMyMonoidSemidirectProduct`: Proof of associativity, left identity, and right identity (0 axioms).

3. **Canonical Inclusions & Commutation Laws** (`MonoidSemidirect/Homomorphisms.lean`):
   - `inlHom`: Canonical embedding $\iota_M : M \to M \rtimes_\alpha N$ with $m \mapsto (m, 1)$ (0 axioms).
   - `inrHom`: Canonical embedding $\iota_N : N \to M \rtimes_\alpha N$ with $n \mapsto (1, n)$ (0 axioms).
   - `projN`: Canonical projection $\pi_N : M \rtimes_\alpha N \to N$ with $(m, n) \mapsto n$ (0 axioms).
   - `projN_inrHom`: Split exact retraction $\pi_N \circ \iota_N = \text{id}_N$ (0 axioms).
   - `projN_inlHom`: Kernel inclusion $\pi_N \circ \iota_M = 1$ (0 axioms).
   - `intertwining_law`: Fundamental non-abelian commutation identity:
     $$\iota_N(n) \cdot \iota_M(m) = \iota_M(\alpha(n)(m)) \cdot \iota_N(n)$$
     (0 axioms).
   - `element_decomposition`: Every element $(m, n)$ decomposes as $\iota_M(m) \cdot \iota_N(n)$ (0 axioms).

---

## 3. Verification Commands & Machine-Checked Outcome

### Commands:
```bash
export PATH="/home/ging/.elan/bin:$PATH"
cd projects/01-open-lean-missions/monoid_semidirect
lake build
lake env lean MonoidSemidirect.lean
```

### Outcome:
- **Build Status**: `Build completed successfully (6 jobs)`.
- **Axiom Audit**:
  - `SemidirectProduct.instMyMonoidSemidirectProduct`: **0 axioms** (`does not depend on any axioms`).
  - `inlHom`: **0 axioms** (`does not depend on any axioms`).
  - `inrHom`: **0 axioms** (`does not depend on any axioms`).
  - `projN`: **0 axioms** (`does not depend on any axioms`).
  - `projN_inrHom`: **0 axioms** (`does not depend on any axioms`).
  - `projN_inlHom`: **0 axioms** (`does not depend on any axioms`).
  - `intertwining_law`: **0 axioms** (`does not depend on any axioms`).
  - `element_decomposition`: **0 axioms** (`does not depend on any axioms`).
- **`sorry` Count**: Exactly **0**.
- **Axiom Safety**: 100% purely constructive algebraic proofs.

---

## 4. Confidence & Next Steps

- **Confidence**: `machine-checked` (Lean 4 compiler kernel `v4.33.1`).
- **Best Next Step**: Formalize wreath products and the Krohn-Rhodes decomposition theorem for finite transformation monoids.
