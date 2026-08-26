# Result Note: Davenport Constant and Minimal Zero-Sum Sequences in Small Non-Abelian Groups

- **Project**: `02-counterexample-observatory`
- **Date**: 2026-08-26
- **Ticket**: [`T-0011`](../../tickets/T-0011.md)
- **Agent**: `gemini-964c4709`
- **Confidence**: `computational evidence`

---

## 1. Candidate Chosen and Source URLs

- **Candidate**: `Davenport Constants and Zero-Sum Sequences in Non-Abelian Groups ($|G| \le 32$)`
- **Source URLs**:
  - [arXiv:1409.8054 (Davenport Constant of Non-Abelian Groups)](https://arxiv.org/abs/1409.8054)
  - [Wikipedia: Davenport constant](https://en.wikipedia.org/wiki/Davenport_constant)
  - [Geroldinger, Grynkiewicz, Schmid (2014) Zero-Sum Invariants](https://link.springer.com/chapter/10.1007/978-3-642-41400-8_2)

---

## 2. Precise Claim or Goal

For a finite group $G$ (written multiplicatively with identity $1_G$):
1. **Ordered Small Davenport constant $d_{seq}(G)$**: Smallest integer $d$ such that every sequence $S = (g_1, \dots, g_d)$ contains a non-empty subsequence whose elements multiply to $1_G$ in sequence order:
   $$\exists 1 \le i_1 < i_2 < \dots < i_m \le d \quad \text{such that} \quad g_{i_1} g_{i_2} \cdots g_{i_m} = 1_G$$
2. **Unordered Large Davenport constant $\mathsf{D}_{perm}(G)$**: Smallest integer $\mathsf{D}$ such that every sequence $S$ of length $\mathsf{D}$ contains a sub-multiset whose elements can be ordered to multiply to $1_G$.
3. **Universal Bound**: $\mathsf{D}_{perm}(G) \le d_{seq}(G) \le |G|$, with equality $\mathsf{D}_{perm}(G) = d_{seq}(G)$ for all abelian groups, and exact values $d(D_{2n}) = n + 1$ for dihedral groups.

**Computational Goals**:
- Build explicit Cayley multiplication tables and verify group axioms from first principles for all 32 test groups ($|G| \le 32$, including 25 non-abelian groups).
- Search and compute exact values of $d_{seq}(G)$ and $\mathsf{D}_{perm}(G)$ and catalog maximal zero-sum free sequences.
- Verify that $100\%$ of groups satisfy theoretical bounds and catalog non-abelian phenomena (such as $A_4$ where $\mathsf{D}_{perm}(A_4) = 5 < d_{seq}(A_4) = 6$).

---

## 3. What Was Produced

1. **Rust Search & Algebra Engine**:
   - `projects/02-counterexample-observatory/davenport_engine/`: Fast finite group representation, Cayley associativity verification, DP reachable product evaluation, and branch-and-bound sequence solver.
2. **Comprehensive Dataset**:
   - `projects/02-counterexample-observatory/data/davenport_results_g32.json`: Machine-readable JSON containing 32 group records with exact $d_{seq}(G)$, $\mathsf{D}_{perm}(G)$, element orders, and maximal witness sequences.
3. **Independent Pure Python Verifier**:
   - `projects/02-counterexample-observatory/scripts/davenport_independent_verifier.py`: Independent Python verifier reconstructing groups from scratch, auditing Cayley table axioms, validating zero-sum free witness sequences, and asserting theoretical bounds.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
# 1. Execute Rust Davenport engine
cd projects/02-counterexample-observatory/davenport_engine
cargo run --release

# 2. Run independent Python zero-sum verifier
cd ../../..
python3 projects/02-counterexample-observatory/scripts/davenport_independent_verifier.py
```

### Verification Outcome

- **Total Groups Audited**: 32 (25 Non-Abelian, 7 Abelian controls).
- **Group Axioms**: 100% of Cayley tables verified associative, with unique two-sided inverses and identity element 0.
- **Dihedral Series $D_{2n}$**:
  - $D_6$: $d=4, \mathsf{D}=4$
  - $D_8$: $d=5, \mathsf{D}=5$
  - $D_{10}$: $d=6, \mathsf{D}=6$
  - $D_{12}$: $d=7, \mathsf{D}=7$
  - $D_{14}$: $d=8, \mathsf{D}=8$
  - $D_{16}$: $d=9, \mathsf{D}=9$
  - $D_{18}$: $d=10, \mathsf{D}=10$
  - $D_{20}$: $d=11, \mathsf{D}=11$
  - $D_{24}$: $d=13, \mathsf{D}=13$
  - $D_{32}$: $d=17, \mathsf{D}=17$
  *(All exactly match Olson-White Theorem $d(D_{2n}) = n + 1$)*.
- **Dicyclic / Quaternion Series $Dic_n$**:
  - $Q_8$: $d=5, \mathsf{D}=5$
  - $Dic_3$: $d=7, \mathsf{D}=7$
  - $Q_{16}$: $d=9, \mathsf{D}=9$
  - $Dic_5$: $d=11, \mathsf{D}=11$
  - $Dic_6$: $d=13, \mathsf{D}=13$
  - $Q_{32}$: $d=17, \mathsf{D}=17$
  *(All match $d(Dic_n) = 2n + 1$)*.
- **Alternating Group $A_4$**:
  - $d_{seq}(A_4) = 6$
  - $\mathsf{D}_{perm}(A_4) = 5$
  *(Strict inequality $\mathsf{D}_{perm} < d_{seq}$ confirms order-sensitivity in non-abelian zero-sum theory)*.
- **Frobenius Groups**:
  - $F_{20} = \mathbb{Z}_5 \rtimes \mathbb{Z}_4$: $d=8, \mathsf{D}=8$
  - $F_{21} = \mathbb{Z}_7 \rtimes \mathbb{Z}_3$: $d=9, \mathsf{D}=9$
- **Direct Products**:
  - $D_8 \times \mathbb{Z}_2$: $d=6, \mathsf{D}=6$
  - $Q_8 \times \mathbb{Z}_2$: $d=6, \mathsf{D}=6$
  - $D_8 \times \mathbb{Z}_4$: $d=8, \mathsf{D}=8$
  - $Q_8 \times \mathbb{Z}_4$: $d=8, \mathsf{D}=8$
- **Independent Verification**: $0$ errors. 100% of witness sequences confirmed zero-sum free.

---

## 5. Confidence Assessment

- **Confidence**: `computational evidence`
- **Assessment**: The computation is machine-verified by dual independent engines (Rust bitmask DP and pure Python combinatorial subset permutation evaluator). Exact values and explicit witness sequences provide sound mathematical certificates.

---

## 6. Best Next Step and Blockers

- **Next Step**: Investigate large symmetric groups $S_n$ for $n \ge 4$ and simple groups $PSL(2, q)$ using subgroup lattice decomposition.
- **Blockers**: None for current scope.
