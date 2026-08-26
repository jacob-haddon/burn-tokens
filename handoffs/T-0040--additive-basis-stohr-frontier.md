# Technical Handoff: Ticket T-0040 — Additive Basis of Order 2 and Extremal Stöhr Range Frontier ($k \le 10$)

## 1. Problem & Scope

- **Ticket**: `T-0040`
- **Owner**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Objective**: Compute and certify the exact values of the extremal Rohrbach-Stöhr function $n(2, k)$ (OEIS A001212) for all basis sizes $k \in \{2, 3, 4, 5, 6, 7, 8, 9, 10\}$ and catalog all extremal basis configurations.

---

## 2. Technical Implementation

- **Rust Engine**: [`projects/02-counterexample-observatory/additive_basis_engine/src/main.rs`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/additive_basis_engine/src/main.rs)
  - Uses bitmask operations (`u128`) to compute the 2-fold sumset $2A$.
  - Continuous run length of 1s from bit 0 computed via `(!mask).trailing_zeros() - 1`.
  - Backtracking with branch-and-bound pruning.
  - Dataset: [`projects/02-counterexample-observatory/data/additive_basis_frontier.json`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/data/additive_basis_frontier.json).
- **Python Verifier**: [`projects/02-counterexample-observatory/scripts/additive_basis_verifier.py`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/scripts/additive_basis_verifier.py)
  - Verifies exact containment $[0, n(2, k)] \subseteq 2A$ with 0 gaps.

---

## 3. Verification Transcript

```text
k = 2 | n(2, 2) = 2  | OEIS: 2  | Match: true  | Extremal: [0, 1]
k = 3 | n(2, 3) = 4  | OEIS: 4  | Match: true  | Extremal: [0, 1, 2]
k = 4 | n(2, 4) = 8  | OEIS: 8  | Match: true  | Extremal: [0, 1, 3, 4]
k = 5 | n(2, 5) = 12 | OEIS: 12 | Match: true  | Extremal: [0, 1, 3, 5, 6]
k = 6 | n(2, 6) = 16 | OEIS: 16 | Match: true  | Extremal: [0, 1, 3, 5, 7, 8]
k = 7 | n(2, 7) = 20 | OEIS: 20 | Match: true  | Extremal: [0, 1, 2, 5, 8, 9, 10]
k = 8 | n(2, 8) = 26 | OEIS: 26 | Match: true  | Extremal: [0, 1, 2, 5, 8, 11, 12, 13]
k = 9 | n(2, 9) = 32 | OEIS: 32 | Match: true  | Extremal: [0, 1, 2, 5, 8, 11, 14, 15, 16]
k = 10| n(2, 10)= 40 | OEIS: 40 | Match: true  | Extremal: [0, 1, 3, 4, 9, 11, 16, 17, 19, 20]
```
All checks passed cleanly with 100% agreement.
