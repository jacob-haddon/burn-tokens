# Result: Erdős-Szemerédi Sum-Product Trade-Off & Additive-Multiplicative Energy Frontier ($|A| \le 7$)

- **Date**: 2026-08-26
- **Run ID**: `RUN-20260826-26`
- **Project**: `02-counterexample-observatory`
- **Ticket ID**: `T-0033`
- **Candidate ID**: `C-0215`
- **Primary Source**: Erdős-Szemerédi Sum-Product Conjecture (1983) / Terence Tao (2009)

---

## 1. Mathematical Background & Objectives

The celebrated **Erdős-Szemerédi Sum-Product Conjecture (1983)** states that for every finite subset $A \subset \mathbb{Z}$ (or $\mathbb{R}$):
$$\max(|A+A|, |A \cdot A|) \ge c_\epsilon |A|^{2 - \epsilon}$$

While pure arithmetic progressions minimize the sumset ($|A+A| = 2k-1$) and pure geometric progressions minimize the product set ($|A \cdot A| = 2k-1$), any non-trivial set is subject to a strict trade-off where both operations cannot be simultaneously compressed.

This run establishes the exact finite frontier $\min_{|A|=k} \max(|A+A|, |A \cdot A|)$ for all subset sizes $k \in \{2, 3, 4, 5, 6, 7\}$ and analyzes the additive/multiplicative energy duality:
$$E_+(A) = \sum_{s \in A+A} r_{A+A}(s)^2, \quad E_\times(A) = \sum_{m \in A \cdot A} r_{A \cdot A}(m)^2$$

---

## 2. Exact Finite Trade-Off Results ($k = 2 \dots 7$)

| Subset Size $k$ | Exact $\min \max(\|A+A\|, \|A \cdot A\|)$ | Lower Bound $2k-1$ | Upper Bound $\binom{k+1}{2}$ | Optimal Minimizing Set $A$ | Optimal $\|A+A\|$ | Optimal $\|A \cdot A\|$ | $E_+(A)$ | $E_\times(A)$ |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **2** | **3** | 3 | 3 | $\{1, 2\}$ | 3 | 3 | 6 | 6 |
| **3** | **6** | 5 | 6 | $\{1, 2, 3\}$ | 5 | 6 | 19 | 15 |
| **4** | **9** | 7 | 10 | $\{1, 2, 3, 4\}$ | 7 | 9 | 44 | 32 |
| **5** | **12** | 9 | 15 | $\{1, 2, 3, 4, 6\}$ | 10 | 12 | 73 | 65 |
| **6** | **15** | 11 | 21 | $\{1, 2, 3, 4, 6, 8\}$ | 13 | 15 | 114 | 106 |
| **7** | **18** | 13 | 28 | $\{1, 2, 3, 4, 6, 8, 12\}$ | 18 | 18 | 151 | 175 |

### Key Structural Discoveries:
1. **Linear Minimum Envelope**: For $k \le 7$, the exact minimum follows $\min \max(|A+A|, |A \cdot A|) = 3k - 3$.
2. **Transition to Smooth / Divisor Lattices**:
   - For $k \le 4$, standard arithmetic progressions achieve the minimum.
   - For $k = 5, 6, 7$, the optimal configurations break away from pure APs and shift toward **2-3-smooth divisor subsets** of highly composite numbers (e.g. $\{1, 2, 3, 4, 6, 8, 12\}$ which are the proper divisors of 24).
3. **Cauchy-Schwarz Energy Concordance**: In all optimal configurations, both additive and multiplicative energies strictly respect the Cauchy-Schwarz bounds $E_+(A) \ge |A|^4 / |A+A|$ and $E_\times(A) \ge |A|^4 / |A \cdot A|$.

---

## 3. Verification & Reproduction

```bash
# Execute Rust release engine
cargo run --release --manifest-path projects/02-counterexample-observatory/sum_product_engine/Cargo.toml

# Execute Independent Python Verifier
python3 projects/02-counterexample-observatory/verify_sum_product.py
```

**Verification Output**:
```text
Loading sum-product report from: projects/02-counterexample-observatory/data/sum_product_frontier.json
Report covers subset sizes up to k = 7
...
  [ALL INDEPENDENT CHECKS PASSED] SUM-PRODUCT FRONTIER VERIFIED
```

---

## 4. Confidence Assessment

- **Confidence**: `computational evidence` (exact finite optimization).
- **Data Artifact**: [`projects/02-counterexample-observatory/data/sum_product_frontier.json`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/data/sum_product_frontier.json).
