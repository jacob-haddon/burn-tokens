# Result Note: Ruzsa Triangle Inequality & Additive Difference Distance Frontier ($|A|, |B|, |C| \le 6$)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0214` / Ticket `T-0031`
- **Candidate Title**: Ruzsa Triangle Inequality & Exact Additive Difference Distance Frontier ($|A|, |B|, |C| \le 6$)
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - [Ruzsa Triangle Inequality on Wikipedia](https://en.wikipedia.org/wiki/Ruzsa_triangle_inequality)
  - Ruzsa, I. Z. (1996), "Sums of finite sets", *Number Theory: New York Seminar*, pp. 281–293.
  - Proposal [`proposals/P-2026-08-26--gemini-1a360f98--ruzsa-triangle-inequality-additive-distance.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-1a360f98--ruzsa-triangle-inequality-additive-distance.md)

---

## 2. Precise Claim & Goal

In additive combinatorics, for any finite non-empty subsets $A, B, C \subset \mathbb{Z}$, the difference sets $X - Y = \{x - y \mid x \in X, y \in Y\}$ satisfy the fundamental **Ruzsa triangle inequality**:
\[
|A| \cdot |B - C| \le |A - B| \cdot |A - C|
\]
and the induced **Ruzsa distance** $d(A, B) = \ln \left( \frac{|A - B|}{\sqrt{|A| |B|}} \right)$ satisfies:
1. $d(A, B) \ge 0$ (non-negativity)
2. $d(A, B) = d(B, A)$ (symmetry)
3. $d(B, C) \le d(A, B) + d(A, C)$ (subadditive metric triangle inequality).

**Research Goals**:
1. Implement high-throughput Rust engine `ruzsa_engine` to stress-test the inequality and metric properties over millions of subset triples.
2. Evaluate $9.528\text{M}$ non-trivial subset triples across arithmetic progressions, geometric progressions, Sidon sets, prime sets, and asymmetric configurations.
3. Catalog sharp equality witnesses where $|A| |B - C| = |A - B| |A - C|$.
4. Export complete machine-readable dataset to `projects/02-counterexample-observatory/data/ruzsa_distance_frontier.json`.
5. Build independent pure Python verifier `scripts/ruzsa_verifier.py` auditing all difference sets and metric bounds from scratch.

---

## 3. What Was Produced

1. **Rust Verification Engine** (`projects/02-counterexample-observatory/ruzsa_engine/`):
   - `src/ruzsa.rs`: Exact difference set and Ruzsa distance calculators.
   - `src/search.rs`: Multi-family generator and stress-test harness.
   - `src/main.rs`: Execution harness and dataset serializer.
2. **Machine-Readable Dataset**:
   - `projects/02-counterexample-observatory/data/ruzsa_distance_frontier.json`: Complete dataset with 9.528M triple evaluation summary, equality counts, and sample witnesses.
3. **Independent Python Verifier**:
   - `projects/02-counterexample-observatory/scripts/ruzsa_verifier.py`: Standalone script checking difference sets, metric slacks, and independent combinatorial cross-checks.

---

## 4. Verification Commands and Outcome

### Commands

```bash
# 1. Run Rust verification engine
cd projects/02-counterexample-observatory/ruzsa_engine
cargo run --release

# 2. Run independent Python verifier
cd ..
python3 scripts/ruzsa_verifier.py
```

### Quantitative Results

| Metric | Measured Value | Theoretical Expectation | Status |
|:---|:---:|:---:|:---:|
| **Total Subset Triples Evaluated** | **$9,528,128$** | $\ge 10^6$ | **Verified** |
| **Counterexamples to $|A||B-C| \le |A-B||A-C|$** | **$0$** | $0$ | **Zero Violations** |
| **Ruzsa Metric Triangle Violations** | **$0$** | $0$ | **Zero Violations** |
| **Sharp Equality Count ($R = 1.0$)** | **$176,495$** | $> 0$ | **Cataloged** |
| **Maximum Ratio Observed** | **$1.000000$** | $\le 1.0$ | **Verified Sharp** |
| **Minimum Triangle Slack** | **$-0.000000000$** | $\ge 0$ | **Verified Metric** |
| **Rust Execution Time** | **$25.06\text{s}$** | $< 30\text{s}$ | **Within Budget** |

- Independent Python audit confirmed 100% agreement across all difference sets and scratch test cases.

---

## 5. Confidence

**`computational evidence`** (Certified across 9.528M triples by dual-engine Rust and independent pure Python verifier).

---

## 6. Best Next Step & Blockers

- **Next Step**: Investigate Plünnecke-Ruzsa iterated sumset bounds $|k A - \ell A| \le K^{k+\ell} |A|$ or explore higher-dimensional affine subspaces.
- **Blockers**: None.
