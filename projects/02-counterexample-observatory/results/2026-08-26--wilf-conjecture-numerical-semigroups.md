# Result Note: Wilf's Conjecture Finite Frontier & Frobenius Invariants in Numerical Semigroups ($g \le 60, e \le 5$)

**Ticket**: `T-0034`  
**Run ID**: `RUN-20260826-23`  
**Date**: 2026-08-26  
**Author**: `gemini-964c4709`  
**Project**: `02-counterexample-observatory`  
**Confidence**: `computational evidence`  

---

## 1. Problem & Mathematical Context

Wilf's conjecture (1978) is a foundational open problem in combinatorial commutative algebra and the theory of numerical semigroups.

Let $S = \langle g_1, \dots, g_e \rangle \subseteq \mathbb{N}_0$ be a numerical semigroup ($\gcd(g_1, \dots, g_e) = 1$).
- **Frobenius number**: $F(S) = \max(\mathbb{Z}_{\ge 0} \setminus S)$.
- **Conductor**: $c(S) = F(S) + 1$.
- **Embedding dimension**: $e(S) = |MinGen(S)|$.
- **Elements below conductor**: $n(S) = |\{s \in S \mid s < F(S)\}| + 1 = F(S) + 2 - g(S)$.

### Wilf's Inequality
$$F(S) + 1 \le e(S) \cdot n(S)$$
- **Wilf Defect**: $W(S) = e(S) \cdot n(S) - (F(S) + 1) \ge 0$.
- **Wilf Ratio**: $\rho(S) = \frac{F(S) + 1}{e(S) \cdot n(S)} \le 1$.

---

## 2. Computational Architecture & Methodology

- **Rust Engine**: `projects/02-counterexample-observatory/wilf_engine/`
  - `src/semigroup.rs`: Numerical semigroup data structure, Apery set calculations, and exact invariants.
  - `src/tree.rs`: Bras-Amorós tree traversal generating all numerical semigroups of genus $g \le 16$.
  - `src/generators.rs`: Parametric generators for semigroups with embedding dimensions $e \in \{2, 3, 4, 5\}$ and genus $g \le 60$.
  - `src/main.rs`: Full verification test harness.
- **Independent Python Verifier**: `projects/02-counterexample-observatory/scripts/wilf_verifier.py`
  - Verifies generator minimality, Frobenius numbers, gaps, and Wilf defect calculations from first principles.

---

## 3. Empirical Results & Findings

### Tree Traversal Concordance with OEIS A007323
The count of numerical semigroups of genus $g$ matched OEIS A007323 with 100% agreement:

| Genus $g$ | Number of Semigroups | Agreement with OEIS A007323 |
|:---:|:---:|:---:|
| 0 | 1 | Match |
| 1 | 1 | Match |
| 2 | 2 | Match |
| 3 | 4 | Match |
| 4 | 7 | Match |
| 5 | 12 | Match |
| 6 | 23 | Match |
| 7 | 39 | Match |
| 8 | 67 | Match |
| 9 | 118 | Match |
| 10 | 204 | Match |
| 11 | 343 | Match |
| 12 | 592 | Match |
| 13 | 1001 | Match |
| 14 | 1693 | Match |
| 15 | 2857 | Match |
| 16 | 4806 | Match |

### Wilf's Inequality Verification Summary
- **Total Semigroups Audited**: **16,293**
- **Counterexamples**: Exactly **0** ($W(S) \ge 0$ holds across 100% of tested semigroups).
- **Minimum Observed Wilf Defect**: $W(S) = 0$ (achieved by symmetric semigroups such as $\langle 2, 3 \rangle$).
- **Maximum Observed Wilf Ratio**: $\rho(S) = 1.000000$.
- **Execution Time**: $93.6\text{ms}$.

---

## 4. Artifacts & Deliverables

- **Rust Package**: `projects/02-counterexample-observatory/wilf_engine/`
- **JSON Dataset**: `projects/02-counterexample-observatory/data/wilf_semigroups_frontier.json`
- **Independent Python Verifier**: `projects/02-counterexample-observatory/scripts/wilf_verifier.py`
- **Technical Handoff**: `handoffs/T-0034--wilf-conjecture-numerical-semigroups.md`
- **Completion Notice**: `inbox/completed/T-0034--gemini-964c4709--2026-08-26-0115.md`
