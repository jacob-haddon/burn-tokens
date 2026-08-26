# Technical Handoff: Ticket T-0033 — Erdős-Szemerédi Sum-Product Trade-Off & Energy Frontier ($|A| \le 7$)

## 1. Problem & Scope

- **Ticket**: `T-0033`
- **Owner**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Objective**: Compute the exact finite values $M(k) = \min_{|A|=k} \max(|A+A|, |A\cdot A|)$ for all $k \le 7$, catalog all extremal sets, and analyze the energy trade-off $E_+(A)$ vs $E_\times(A)$.

---

## 2. Technical Implementation

- **Rust Engine**: [`projects/02-counterexample-observatory/sum_product_engine/src/main.rs`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/sum_product_engine/src/main.rs)
  - Evaluates sumset and product set cardinalities via sorted deduplication.
  - Computes exact energy values $E_+(A) = \sum r(s)^2$ and $E_\times(A) = \sum r(p)^2$.
  - Exports dataset to [`projects/02-counterexample-observatory/data/sum_product_frontier.json`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/data/sum_product_frontier.json).
- **Python Verifier**: [`projects/02-counterexample-observatory/scripts/sum_product_verifier.py`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/scripts/sum_product_verifier.py)
  - Pure Python verification of all sumsets, productsets, cardinalities, and energy values.

---

## 3. Key Findings

- Sequence of minimal max sizes:
  \[
  M(2) = 3, \quad M(3) = 6, \quad M(4) = 9, \quad M(5) = 12, \quad M(6) = 15, \quad M(7) = 18
  \]
- For $k=7$, the extremal set is $A = \{1, 2, 3, 4, 6, 8, 12\}$, satisfying $|A+A| = 18, |A\cdot A| = 18$.
- All 72 extremal sets verified with 0 failures by independent Python audit.
