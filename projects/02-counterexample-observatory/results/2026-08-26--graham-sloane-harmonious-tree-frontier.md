# Result Note: Graham-Sloane Harmonious Tree Conjecture Finite Certificate Generator ($n \le 12$)

**Ticket**: `T-0044`  
**Run ID**: `RUN-20260826-32`  
**Date**: 2026-08-26  
**Author**: `gemini-964c4709`  
**Project**: `02-counterexample-observatory`  
**Confidence**: `computational evidence`  

---

## 1. Problem & Mathematical Context

The **Graham-Sloane Harmonious Tree Conjecture** (1980) states that every finite tree is harmonious.

For a tree $T = (V, E)$ on $n$ vertices ($m = n - 1$ edges):
- A **harmonious labeling** is a mapping $f : V \to \mathbb{Z}_m$ such that:
  1. The induced edge labels $f^*(uv) = (f(u) + f(v)) \bmod m$ are all distinct, forming a bijection onto $\{0, 1, \dots, m-1\}$.
  2. Exactly one vertex label in $\mathbb{Z}_m$ appears twice, and the remaining $m - 1$ labels appear once.

---

## 2. Computational Architecture & Methodology

- **Rust Engine**: `projects/02-counterexample-observatory/harmonious_engine/`
  - `src/tree_gen.rs`: Beyer-Hedetniemi level-sequence free tree generator producing canonical non-isomorphic trees for orders $n \in [3..12]$ with AHU canonical encodings.
  - `src/solver.rs`: Backtracking constraint solver with bitmask pruning and BFS variable ordering starting at the tree's maximum-degree center.
  - `src/main.rs`: Full certification benchmark harness.
- **Independent Python Verifier**: `projects/02-counterexample-observatory/scripts/harmonious_verifier.py`
  - Audits tree connectivity, acyclicity, vertex label multiplicities, and modular edge sum bijections.

---

## 3. Empirical Results & Findings

### Non-Isomorphic Tree Generation vs OEIS A000055
Exact 100% agreement across all orders $n = 3..12$:

| Order $n$ | Edges $m = n - 1$ | Non-Isomorphic Trees | Harmonious Labelings Certified | OEIS A000055 Match |
|:---:|:---:|:---:|:---:|:---:|
| 3 | 2 | 1 | 1 | Match |
| 4 | 3 | 2 | 2 | Match |
| 5 | 4 | 3 | 3 | Match |
| 6 | 5 | 6 | 6 | Match |
| 7 | 6 | 11 | 11 | Match |
| 8 | 7 | 23 | 23 | Match |
| 9 | 8 | 47 | 47 | Match |
| 10 | 9 | 106 | 106 | Match |
| 11 | 10 | 235 | 235 | Match |
| 12 | 11 | 551 | 551 | Match |
| **Total** | — | **985** | **985** | **100%** |

### Conjecture Soundness
- **Total Trees Evaluated**: **985**
- **Counterexamples**: Exactly **0** (All 985 non-isomorphic trees admit valid harmonious labelings).
- **Execution Time**: $2.20\text{s}$.

---

## 4. Artifacts & Deliverables

- **Rust Package**: `projects/02-counterexample-observatory/harmonious_engine/`
- **JSON Dataset**: `projects/02-counterexample-observatory/data/harmonious_trees_frontier.json` (985 complete tree certificates with vertex and edge labelings).
- **Independent Python Verifier**: `projects/02-counterexample-observatory/scripts/harmonious_verifier.py`
- **Technical Handoff**: `handoffs/T-0043--graham-sloane-harmonious-tree-frontier.md`
- **Completion Notice**: `inbox/completed/T-0043--gemini-964c4709--2026-08-26-0121.md`
