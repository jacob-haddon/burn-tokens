# Technical Handoff: Ticket T-0006 (Caccetta-Häggkvist Frontier)

- **Ticket**: [`T-0006`](../tickets/T-0006.md)
- **Agent**: `gemini-964c4709`
- **Date**: 2026-08-26
- **Status**: `review`

---

## 1. Exact Hypothesis Tested

We tested the **Caccetta-Häggkvist Conjecture**:
For every simple directed graph $D = (V, E)$ on $n$ vertices with minimum out-degree $\delta^+(D) \ge k$, the directed girth satisfies:
$$\text{girth}(D) \le \left\lceil \frac{n}{k} \right\rceil$$

Specifically:
1. For all simple digraphs on $n \le 6$ vertices with $\delta^+ \ge k$, does every digraph satisfy $\text{girth}(D) \le \lceil n/k \rceil$?
2. For $n \le 9$, does there exist any simple directed graph with no 2-cycles and no directed triangles (i.e. $\text{girth} \ge 4$) that achieves $\delta^+(D) \ge \lceil n/3 \rceil$?
3. For circulant digraphs $C_n(S)$ up to $n=16$, does every circulant satisfy $\text{girth}(C_n(S)) \le \lceil n / |S| \rceil$?

---

## 2. Code Executed and Exact Outputs

### Primary Engine
- Code path: `projects/02-counterexample-observatory/caccetta_engine/`
- Architecture:
  - `src/digraph.rs`: 32-bit bitmask representation, bitwise out-degrees, 2-cycle / 3-cycle detection, BFS directed girth computation.
  - `src/exhaustive_search.rs`: Rayon-parallelized enumeration of all row combinations satisfying out-degree $\ge k$.
  - `src/triangle_free_search.rs`: Backtracking branch-and-bound with future degree constraint propagation and root symmetry breaking.
  - `src/circulant_search.rs`: Systematic audit of all regular circulant digraph topologies on $\mathbb{Z}_n$.

### Output Artifacts
- Machine-readable JSON: `projects/02-counterexample-observatory/data/caccetta_haggkvist_frontier.json` (10 MB).
- Result note: `projects/02-counterexample-observatory/results/2026-08-26--caccetta-haggkvist-frontier.md`.

### Quantitative Results
- **Total Digraphs Checked in Exhaustive Levels**: $326,619,229$
- **Total Counterexamples Found**: **0**
- **Level Breakdown**:
  - $n=3, k=1$: 27 digraphs checked, $\text{girth} \le 3$, 0 CEx
  - $n=3, k=2$: 1 digraph checked, $\text{girth} \le 2$, 0 CEx
  - $n=4, k=1$: 2,401 digraphs checked, $\text{girth} \le 4$, 0 CEx
  - $n=4, k=2$: 256 digraphs checked, $\text{girth} \le 2$, 0 CEx
  - $n=4, k=3$: 1 digraph checked, $\text{girth} \le 2$, 0 CEx
  - $n=5, k=1$: 759,375 digraphs checked, $\text{girth} \le 5$, 0 CEx
  - $n=5, k=2$: 161,051 digraphs checked, $\text{girth} \le 3$, 0 CEx
  - $n=5, k=3$: 3,125 digraphs checked, $\text{girth} \le 2$, 0 CEx
  - $n=6, k=2$: 308,915,776 digraphs checked, $\text{girth} \le 3$, 0 CEx
  - $n=6, k=3$: 16,777,216 digraphs checked, $\text{girth} \le 2$, 0 CEx
- **Triangle-Free Girth $\ge 4$ Boundary**:
  - $n=3$: Threshold $k=1$, max $\delta^+ = 0 < 1$
  - $n=4$: Threshold $k=2$, max $\delta^+ = 1 < 2$
  - $n=5$: Threshold $k=2$, max $\delta^+ = 1 < 2$
  - $n=6$: Threshold $k=2$, max $\delta^+ = 1 < 2$
  - $n=7$: Threshold $k=3$, max $\delta^+ = 2 < 3$
  - $n=8$: Threshold $k=3$, max $\delta^+ = 2 < 3$
  - $n=9$: Threshold $k=3$, max $\delta^+ = 2 < 3$
- **Circulant Digraphs Audited**: 43,892 configurations; 11,853 strictly extremal ($\text{girth} = \lceil n/k \rceil$); 0 CEx.

### Independent Verification Script
- Code path: `projects/02-counterexample-observatory/scripts/caccetta_independent_verifier.py`
- Outcome: 100% verified sound. Zero directed triangles ($\text{Tr}(A^3) = 0$) verified algebraically for all 56 cataloged extremal digraphs.

---

## 3. Known Pitfalls, Remaining Gaps & Suggested Next Steps

1. **Known Pitfalls**:
   - In simple directed graphs, 2-cycles $u \to v \to u$ have length 2. If 2-cycles are permitted, girth is immediately $\le 2$, satisfying $\lceil n/k \rceil \ge 2$ trivially for $k \le n/2$. Thus, the critical search domain for counterexamples is oriented graphs (no 2-cycles).
   - In algebraic cycle counting, $\text{Tr}(A^3) = 3 \times (\text{# directed triangles})$, but this holds strictly when $A$ has no 2-cycles or when irreflexive. The independent verifier checks both $A_{ii} = 0$ and $A_{ij} A_{ji} = 0$.
2. **Remaining Gaps**:
   - The general conjecture remains open for $n \ge 10$ and general $k \ge 6$.
3. **Suggested Next Steps**:
   - Encode the triangle-free digraph search as a Boolean Satisfiability (CNF) problem for SAT solvers to extend the search to $n=10..20$.
