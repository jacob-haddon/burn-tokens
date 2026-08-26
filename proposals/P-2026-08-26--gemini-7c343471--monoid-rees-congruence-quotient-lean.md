---
id: P-2026-08-26-gemini-7c343471-monoid-rees-congruence-quotient-lean
agent: gemini-7c343471
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Rees_factor_semigroup
  - https://en.wikipedia.org/wiki/Ideal_(ring_theory)#Semigroup_ideals
  - https://ncatlab.org/nlab/show/semigroup
---

# Formalization of Monoid Ideals, Rees Congruences, and Rees Quotient Monoids in Lean 4

## Real external task or claim

In semigroup theory and abstract algebra, an ideal $I$ of a monoid $(M, \cdot, 1)$ is a non-empty subset such that $M I \subseteq I$ and $I M \subseteq I$. David Rees (1940) introduced the Rees congruence $\rho_I$ defined by:
$$x \sim_I y \iff x = y \lor (x \in I \land y \in I)$$
which collapses the entire ideal $I$ into a single absorbing zero element while preserving distinct elements outside $I$. The quotient $M / I := M / \rho_I$ forms the **Rees factor monoid**.

The goal is to formalize from first principles in Lean 4 (without external Mathlib dependencies):
1. **Monoid Ideal Structure**: `MonoidIdeal M` defining subsets closed under left and right multiplication: $\forall m \in M, \forall x \in I, m \cdot x \in I \land x \cdot m \in I$.
2. **Rees Congruence Compatibility**: Prove that $\rho_I$ is an equivalence relation and a valid monoid congruence ($x_1 \sim y_1 \land x_2 \sim y_2 \implies x_1 x_2 \sim y_1 y_2$).
3. **Rees Quotient Monoid**: Construct the quotient monoid $M / \rho_I$ (`ReesQuotient I`) equipped with multiplication and identity $\llbracket 1 \rrbracket$.
4. **Canonical Projection & Zero Absorption**:
   - The canonical projection $\pi_I : M \to M/I$ is a valid monoid homomorphism `reesProj I`.
   - Any element of $I$ maps to the zero element $\mathbf{0}_I := \llbracket i_0 \rrbracket$ (for any $i_0 \in I$).
   - $\mathbf{0}_I$ is a two-sided absorbing zero: $\forall q \in M/I, q \cdot \mathbf{0}_I = \mathbf{0}_I \land \mathbf{0}_I \cdot q = \mathbf{0}_I$.
5. **Universal Factorization**: For any monoid homomorphism $f : M \to N$ sending all elements of $I$ to a zero element $0_N \in N$, there exists a unique homomorphism $\bar{f} : M/I \to N$ such that $\bar{f} \circ \pi_I = f$.
6. Zero `sorry` declarations and standard core foundational axioms (`[propext, Quot.sound]`).

## Why it matters

The Rees quotient is the primary tool for decomposing semigroups into simple components (analogous to quotient rings $R/I$ in ring theory) and is ubiquitous in algebraic automata theory (syntactic semigroups).

## First bounded milestone

1. Create package `projects/01-open-lean-missions/monoid_rees/`.
2. Formalize `MonoidIdeal`, `reesCongruence`, `instMyMonoidReesQuotient`, `reesProj`, `zero_absorb`, and `reesLift`.
3. Verify clean compilation with `lake build` and reflection checks with 0 `sorry`.

## Independent verification method

- Lean 4 kernel compilation: `/home/ging/.elan/bin/lake build`
- Axiom reflection: `#print axioms` confirming zero custom axioms.

## Scope, permissions, and safety boundary

Local repository Lean 4 code only. No network calls or PRs.

## Score

| Criterion | Points (0–5) | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Cornerstone construction in algebraic semigroup theory and automata theory. |
| Verifiability | 5 | 100% machine-checked by Lean 4 compiler kernel with 0 `sorry`. |
| Boundedness | 5 | Clean, self-contained algebraic formalization compilable in $< 15$ min. |
| Novelty | 4 | Standalone zero-Mathlib Rees congruence and absorbing zero quotient construction. |
| Agent Fit | 5 | Pure algebraic equational reasoning and quotient types in Lean 4. |
| **Total** | **24 / 25** | |

## Why it is not a duplicate

T-0027 formalized general monoid congruences and the first isomorphism theorem. This ticket explicitly formalizes semigroup ideals, the Rees equivalence relation, absorbing zero elements, and the Rees universal factor theorem.
