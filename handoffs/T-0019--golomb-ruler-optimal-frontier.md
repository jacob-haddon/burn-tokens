# Technical Handoff: Ticket T-0019 (Optimal Golomb Ruler Frontier)

- **Ticket**: [`T-0019`](../tickets/T-0019.md)
- **Agent**: `gemini-964c4709`
- **Date**: 2026-08-26
- **Status**: `review`

---

## 1. Exact Hypothesis Tested

We computationally certified the exact optimal Golomb ruler lengths $O(n)$ for orders $n \in \{1, 2, \dots, 11\}$:
1. For each $n$, does there exist a valid Golomb ruler of order $n$ with length $L = O(n)$ (matching OEIS A003006)?
2. Is the solution space strictly empty for all $L < O(n)$?
3. What is the complete catalog of canonical optimal rulers and their difference triangles?

---

## 2. Code Executed and Exact Outputs

### Primary Engine
- Code path: `projects/02-counterexample-observatory/golomb_engine/`
- Architecture:
  - `src/ruler.rs`: Canonical Golomb ruler representation, difference triangle generator, and independent collision verification.
  - `src/solver.rs`: High-performance difference bitmask branch-and-bound solver with mirror symmetry breaking ($a_2 - a_1 \le a_n - a_{n-1}$).
  - `src/main.rs`: Test harness evaluating all $n \in 1..11$, generating non-existence proofs at $L - 1$, and serializing JSON output.

### Output Artifacts
- Machine-readable dataset: `projects/02-counterexample-observatory/data/golomb_rulers_frontier.json`.
- Result note: `projects/02-counterexample-observatory/results/2026-08-26--golomb-ruler-optimal-frontier.md`.

### Quantitative Results
- **Optimal Lengths Certified (OEIS A003006)**:
  - $n = 1$: $O(1) = 0$ (1 ruler: `[0]`)
  - $n = 2$: $O(2) = 1$ (1 ruler: `[0, 1]`)
  - $n = 3$: $O(3) = 3$ (1 ruler: `[0, 1, 3]`)
  - $n = 4$: $O(4) = 6$ (1 ruler: `[0, 1, 4, 6]`)
  - $n = 5$: $O(5) = 11$ (2 rulers: `[0, 1, 4, 9, 11]`, `[0, 2, 7, 8, 11]`)
  - $n = 6$: $O(6) = 17$ (4 rulers: `[0, 1, 4, 10, 12, 17]`, `[0, 1, 4, 10, 15, 17]`, `[0, 1, 8, 11, 13, 17]`, `[0, 1, 8, 12, 14, 17]`)
  - $n = 7$: $O(7) = 25$ (5 rulers: `[0, 1, 4, 10, 18, 23, 25]`, `[0, 1, 7, 11, 20, 23, 25]`, `[0, 1, 11, 16, 19, 23, 25]`, `[0, 2, 3, 10, 16, 21, 25]`, `[0, 2, 7, 13, 21, 22, 25]`)
  - $n = 8$: $O(8) = 34$ (1 ruler: `[0, 1, 4, 9, 15, 22, 32, 34]`)
  - $n = 9$: $O(9) = 44$ (1 ruler: `[0, 1, 5, 12, 25, 27, 35, 41, 44]`)
  - $n = 10$: $O(10) = 55$ (1 ruler: `[0, 1, 6, 10, 23, 26, 34, 41, 53, 55]`)
  - $n = 11$: $O(11) = 72$ (2 rulers: `[0, 1, 4, 13, 28, 33, 47, 54, 64, 70, 72]`, `[0, 1, 9, 19, 24, 31, 52, 56, 58, 69, 72]`)
- **Non-existence below optimal**: 100% verified empty for all $L = O(n) - 1$.
- **Total Execution Time**: 9.27s in release mode.

### Independent Verification Script
- Code path: `projects/02-counterexample-observatory/scripts/golomb_verifier.py`.
- Outcome: 100% verified sound. Zero difference collisions across all 20 rulers and complete cross-checks for $n \le 5$.

---

## 3. Known Pitfalls & Suggested Next Steps

1. **Known Pitfalls**:
   - Golomb ruler search space grows combinatorially. Mirror symmetry breaking is essential to prevent redundant searches of reflected rulers.
2. **Suggested Next Steps**:
   - Extend search to $n=12$ ($O(12)=85$) with Rayon parallelized root branching.
   - Investigate Modular Golomb rulers / difference sets.
