# Proposal: Waring's Problem Exact Small Power Minimum Sums Frontier ($k=3, 4, 5$)

## Metadata
- **Author**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Date**: 2026-08-26
- **Status**: promoted
- **Target Confidence**: `computational evidence`

---

## 1. Candidate Description & Motivation
Waring's problem asserts that for every integer $k \ge 2$, there exists an integer $g(k)$ such that every non-negative integer is the sum of at most $g(k)$ $k$-th powers of non-negative integers:
\[
n = x_1^k + x_2^k + \dots + x_{g(k)}^k, \quad x_i \ge 0
\]
Exact classical values of $g(k)$:
- $k=2$: $g(2) = 4$ (Lagrange 1770; witness: 7 requires 4 squares: $7 = 2^2 + 1^2 + 1^2 + 1^2$)
- $k=3$: $g(3) = 9$ (Wieferich 1909; witnesses requiring 9 cubes: exactly two integers: $n = 23 = 2\cdot 2^3 + 7\cdot 1^3$ and $n = 239 = 4^3 + 4\cdot 3^3 + 3\cdot 2^3 + 1^3$)
- $k=4$: $g(4) = 19$ (Balasubramanian, Deshouillers, Dress 1986; witness requiring 19 fourth powers: $n = 79 = 4\cdot 2^4 + 15\cdot 1^4$)
- $k=5$: $g(5) = 37$ (Chen 1964; witness requiring 37 fifth powers: $n = 61 = 2^5 + 29\cdot 1^5$)

---

## 2. Precise Research Goal
1. Build a high-throughput dynamic programming search engine in Rust `waring_engine`.
2. Compute the exact minimum power decomposition length $r_k(n)$ for all integers $n \le 10^5$ for $k=2, 3, 4, 5$.
3. Verify that $r_k(n) \le g(k)$ holds for all $n \le 10^5$ with 0 counterexamples.
4. Catalog all historical extremal integers achieving the theoretical maximum $r_k(n) = g(k)$.
5. Certify all witness decompositions with a standalone independent pure Python arithmetic verifier.

---

## 3. Rubric Score (Total: 24/25)
- **Clarity of claim (5/5)**: Unambiguous arithmetic power decomposition problem.
- **Reversibility & Containment (5/5)**: Isolated in `projects/02-counterexample-observatory/waring_engine/`.
- **Independent verifiability (5/5)**: Standalone Python verifier tests $\sum x_i^k = n$ and count $\le g(k)$.
- **Safety compliance (5/5)**: Local CPU execution only, no network calls.
- **Project fit (4/5)**: Fundamental number theory benchmark in additive combinatorics.

---

## 4. Verification Plan
```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/waring_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/waring_verifier.py
```
Checks:
- $r_k(n) \le g(k)$ for 100% of numbers tested ($N \le 10^5$).
- Exact confirmation of extremal witnesses (23, 239 for $k=3$; 79 for $k=4$; 61 for $k=5$).
- Independent pure Python step-by-step verification.
