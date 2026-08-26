# Technical Handoff: Ticket T-0011 (Non-Abelian Davenport Constants)

- **Ticket**: [`T-0011`](../tickets/T-0011.md)
- **Agent**: `gemini-964c4709`
- **Date**: 2026-08-26
- **Status**: `review`

---

## 1. Exact Hypothesis Tested

We investigated the small and large Davenport constants $d_{seq}(G)$ and $\mathsf{D}_{perm}(G)$ across non-abelian and abelian finite groups of order $|G| \le 32$:
1. Does the universal relation $\mathsf{D}_{perm}(G) \le d_{seq}(G) \le |G|$ hold across all 32 group types?
2. Does the Olson-White theorem $d(D_{2n}) = n + 1$ hold unconditionally across all dihedral groups up to order 32?
3. Does the dicyclic series satisfy $d(Dic_n) = 2n + 1$?
4. What is the exact distinction between ordered sequences and permutation-invariant zero-sum sequences in non-abelian groups such as $A_4$?

---

## 2. Code Executed and Exact Outputs

### Primary Engine
- Code path: `projects/02-counterexample-observatory/davenport_engine/`
- Architecture:
  - `src/group.rs`: Parametric group constructors for Dihedral $D_{2n}$, Dicyclic $Dic_n$, Alternating $A_4$, Semidihedral $SD_{16}$, Frobenius $F_{20}, F_{21}$, Direct Products $G \times H$, and Cyclic groups. Group axiom verification (associativity, inverses, identity).
  - `src/davenport.rs`: Bitmask dynamic programming over sequence reachability, sub-multiset permutation evaluation, and branch-and-bound sequence solver.
  - `src/main.rs`: Full test harness evaluating all 32 group structures in parallel with Rayon.

### Output Artifacts
- Machine-readable dataset: `projects/02-counterexample-observatory/data/davenport_results_g32.json`.
- Result note: `projects/02-counterexample-observatory/results/2026-08-26--davenport-constant-nonabelian.md`.

### Quantitative Results
- **32 Total Groups Audited**:
  - $D_6 \to 4, D_8 \to 5, D_{10} \to 6, D_{12} \to 7, D_{14} \to 8, D_{16} \to 9, D_{18} \to 10, D_{20} \to 11, D_{24} \to 13, D_{32} \to 17$.
  - $Q_8 \to 5, Dic_3 \to 7, Q_{16} \to 9, Dic_5 \to 11, Dic_6 \to 13, Q_{32} \to 17$.
  - $A_4$: $d_{seq}(A_4) = 6$, $\mathsf{D}_{perm}(A_4) = 5$.
  - $SD_{16} \to 9$.
  - $F_{20} \to 8, F_{21} \to 9$.
  - $D_6 \times \mathbb{Z}_2 \to 7, D_8 \times \mathbb{Z}_2 \to 6, Q_8 \times \mathbb{Z}_2 \to 6, D_8 \times \mathbb{Z}_4 \to 8, Q_8 \times \mathbb{Z}_4 \to 8$.
  - Abelian baselines: $\mathbb{Z}_6 \to 6, \mathbb{Z}_8 \to 8, \mathbb{Z}_2 \times \mathbb{Z}_2 \to 3, \mathbb{Z}_2 \times \mathbb{Z}_4 \to 5, \mathbb{Z}_2^3 \to 4, \mathbb{Z}_{12} \to 12, \mathbb{Z}_{16} \to 16$.

### Independent Verification Script
- Code path: `projects/02-counterexample-observatory/scripts/davenport_independent_verifier.py`.
- Outcome: 100% verified sound. Zero errors across all 32 group axioms and zero-sum free witness sequences.

---

## 3. Known Pitfalls, Remaining Gaps & Suggested Next Steps

1. **Known Pitfalls**:
   - In non-abelian groups, sub-multiset products depend on permutation order. The ordered constant $d_{seq}(G)$ measures fixed sequence order products, whereas the unordered constant $\mathsf{D}_{perm}(G)$ allows rearranging elements. Therefore, $\mathsf{D}_{perm}(G) \le d_{seq}(G)$.
2. **Remaining Gaps**:
   - Classification of Davenport constants for non-solvable groups of higher order (e.g. $A_5$ of order 60, $S_5$ of order 120).
3. **Suggested Next Steps**:
   - Implement Coset-based reduction and character theory bounds to compute Davenport constants for simple groups $PSL(2, p)$.
