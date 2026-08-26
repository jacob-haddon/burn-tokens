# Result: Waring's Problem Exact Small Power Minimum Sums Frontier ($k=2, 3, 4, 5, N \le 100000$)

- **Date**: 2026-08-26
- **Run ID**: `RUN-20260826-27`
- **Project**: `02-counterexample-observatory`
- **Ticket ID**: `T-0037`
- **Candidate ID**: `C-0216`
- **OEIS References**: [A002804 ($g(k)$ sequence)](https://oeis.org/A002804), [A002828 (Least number of squares to sum to $n$)](https://oeis.org/A002828), [A002376 (Least number of cubes to sum to $n$)](https://oeis.org/A002376)
- **Primary Source**: Waring's Problem (Lagrange 1770, Wieferich 1909, Balasubramanian 1986, Chen 1964)

---

## 1. Mathematical Background & Objectives

Waring's problem asserts that for every integer $k \ge 2$, there exists a number $g(k)$ such that every non-negative integer is the sum of at most $g(k)$ non-negative $k$-th powers:
$$n = x_1^k + x_2^k + \dots + x_{r_k(n)}^k, \quad r_k(n) \le g(k)$$

The Euler-Waring theoretical formula gives:
$$g(k) = 2^k + \left\lfloor \left(\frac{3}{2}\right)^k \right\rfloor - 2$$
yielding $g(2) = 4, g(3) = 9, g(4) = 19, g(5) = 37$.

This run comprehensively audited the exact representation lengths $r_k(n)$ for all integers $n \le 100,000$ across powers $k \in \{2, 3, 4, 5\}$ and cataloged all extremal witness configurations.

---

## 2. Exhaustive Verification Results ($N \le 100,000$)

| Power $k$ | Theoretical Bound $g(k)$ | Max $r_k(n)$ Observed ($n \le 10^5$) | Bound Respected ($r_k \le g(k)$) | Total Extremal Integers with $r_k(n) = g(k)$ | Exact Historical Champions ($n \le 10^5$) | DP Runtime |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **$k=2$** (Squares) | **4** | **4** | **100%** (0 cex) | 16,664 | $n = 4^a(8b+7)$ ($7, 15, 23, 28, 31, \dots$) | 38.1 ms |
| **$k=3$** (Cubes) | **9** | **9** | **100%** (0 cex) | **2** | **Exactly $n = 23$ and $n = 239$** | 6.9 ms |
| **$k=4$** (4th Powers) | **19** | **19** | **100%** (0 cex) | **7** | $79, 159, 239, 319, 399, 479, 559$ | 2.4 ms |
| **$k=5$** (5th Powers) | **37** | **37** | **100%** (0 cex) | **1** | **Exactly $n = 223$** ($6 \cdot 2^5 + 31 \cdot 1^5$) | 1.3 ms |

### Key Historical & Structural Validations:
1. **Uniqueness of Wieferich Cube Champions**: Verified that within the entire range $n \le 100,000$, exactly **two integers** ($n=23$ and $n=239$) require 9 cubes, perfectly matching Wieferich's 1909 theorem.
2. **Fourth-Power Density**: Exactly 7 integers require 19 fourth powers ($79 + 80m$ for $m=0 \dots 6$).
3. **Fifth-Power Extreme**: The unique integer requiring 37 fifth powers is $n = 223$, constructed from the Euler-Waring extremal base $2^5 \cdot \lfloor (3/2)^5 \rfloor - 1 = 32 \cdot 7 - 1 = 223$.

---

## 3. Verification & Reproduction

```bash
# Execute Rust release DP engine
cargo run --release --manifest-path projects/02-counterexample-observatory/waring_engine/Cargo.toml

# Execute Independent Python Verifier
python3 projects/02-counterexample-observatory/verify_waring_sums.py
```

**Verification Output**:
```text
Loading Waring report from: projects/02-counterexample-observatory/data/waring_power_sums_frontier.json
Report evaluated all integers up to N = 100,000
...
  [ALL INDEPENDENT CHECKS PASSED] WARING'S PROBLEM FRONTIER OK
```

---

## 4. Confidence Assessment

- **Confidence**: `computational evidence` (exhaustive dynamic programming audit).
- **Data Artifact**: [`projects/02-counterexample-observatory/data/waring_power_sums_frontier.json`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/data/waring_power_sums_frontier.json).
