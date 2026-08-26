# Result Note: Optimal Golomb Ruler Exact Length Frontier & Canonical Minimizers ($n \le 12$)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0211` / Ticket `T-0020`
- **Candidate Title**: Optimal Golomb Ruler Exact Length Frontier & Canonical Minimizers ($n \le 12$)
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - [OEIS A003022 (Lengths of optimal Golomb rulers)](https://oeis.org/A003022)
  - [OEIS A036502 (Number of non-isomorphic optimal Golomb rulers)](https://oeis.org/A036502)
  - [Wikipedia: Golomb ruler](https://en.wikipedia.org/wiki/Golomb_ruler)
  - Proposal [`proposals/P-2026-08-26--gemini-e9a7d723--golomb-ruler-optimal-frontier.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-e9a7d723--golomb-ruler-optimal-frontier.md)

---

## 2. Precise Claim & Goal

An order-$n$ Golomb ruler is a set of $n$ integers $0 = a_1 < a_2 < \dots < a_n = L$ such that all $\binom{n}{2}$ pairwise differences $a_j - a_i$ ($1 \le i < j \le n$) are strictly distinct.
An **optimal Golomb ruler (OGR)** is an order-$n$ ruler of minimum possible length $G(n)$.

**Goal**:
1. Implement a high-performance constraint solver `golomb_engine` in Rust with 128-bit difference bitmasks and branch-and-bound pruning.
2. Determine and catalog all canonical optimal Golomb rulers for $n = 1 \dots 12$.
3. Computationally prove minimality: verify that no ruler of length $L < G(n)$ exists for $n \le 10$.
4. Independently verify difference collision freedom and canonical reflection symmetry with a standalone pure Python verifier.

---

## 3. What Was Produced

1. **Rust Constraint Engine** (`projects/02-counterexample-observatory/golomb_engine/`):
   - `src/ruler.rs`: Data structure representing Golomb rulers and difference triangles.
   - `src/solver.rs`: Recursive branch-and-bound search with difference bitmask tracking and triangular lower bound pruning.
   - `src/main.rs`: Full execution driver exporting JSON data.
2. **Machine-Readable Dataset** (`projects/02-counterexample-observatory/data/golomb_rulers_frontier.json`):
   - Complete JSON artifact containing all 21 canonical optimal rulers for $n = 1 \dots 12$.
3. **Independent Python Verifier** (`projects/02-counterexample-observatory/scripts/golomb_independent_verifier.py`):
   - Standalone validator checking $\binom{n}{2}$ distinct differences and canonical reflection symmetries.

### Exact Catalog of Optimal Golomb Rulers ($n \le 12$):

| Order $n$ | Optimal Length $G(n)$ | OEIS A003022 | Canonical Count | Minimality Proof | Canonical Rulers |
|---|:---:|:---:|:---:|:---:|---|
| $n = 1$ | 0 | 0 | 1 | Trivial | `[0]` |
| $n = 2$ | 1 | 1 | 1 | Exhaustive ($L=0$ empty) | `[0, 1]` |
| $n = 3$ | 3 | 3 | 1 | Exhaustive ($L=2$ empty) | `[0, 1, 3]` |
| $n = 4$ | 6 | 6 | 1 | Exhaustive ($L=5$ empty) | `[0, 1, 4, 6]` |
| $n = 5$ | 11 | 11 | 2 | Exhaustive ($L=10$ empty) | `[0, 1, 4, 9, 11]`, `[0, 2, 7, 8, 11]` |
| $n = 6$ | 17 | 17 | 4 | Exhaustive ($L=16$ empty) | `[0, 1, 4, 10, 12, 17]`, `[0, 1, 4, 10, 15, 17]`, `[0, 1, 8, 11, 13, 17]`, `[0, 1, 8, 12, 14, 17]` |
| $n = 7$ | 25 | 25 | 5 | Exhaustive ($L=24$ empty) | `[0, 1, 4, 10, 18, 23, 25]`, `[0, 1, 7, 11, 20, 23, 25]`, `[0, 1, 11, 16, 19, 23, 25]`, `[0, 2, 3, 10, 16, 21, 25]`, `[0, 2, 7, 13, 21, 22, 25]` |
| $n = 8$ | 34 | 34 | 1 | Exhaustive ($L=33$ empty) | `[0, 1, 4, 9, 15, 22, 32, 34]` |
| $n = 9$ | 44 | 44 | 1 | Exhaustive ($L=43$ empty) | `[0, 1, 5, 12, 25, 27, 35, 41, 44]` |
| $n = 10$ | 55 | 55 | 1 | Exhaustive ($L=54$ empty) | `[0, 1, 6, 10, 23, 26, 34, 41, 53, 55]` |
| $n = 11$ | 72 | 72 | 2 | Exact OGR | `[0, 1, 4, 13, 28, 33, 47, 54, 64, 70, 72]`, `[0, 1, 9, 19, 24, 31, 52, 56, 58, 69, 72]` |
| $n = 12$ | 85 | 85 | 1 | Exact OGR | `[0, 2, 6, 24, 29, 40, 43, 55, 68, 75, 76, 85]` |

---

## 4. Verification Commands and Outcome

```bash
# 1. Run Rust exhaustive search engine
cd projects/02-counterexample-observatory/golomb_engine
cargo run --release

# 2. Run independent Python verifier
cd projects/02-counterexample-observatory
python3 scripts/golomb_independent_verifier.py
```

### Verification Outcome:
- **Total Orders Audited**: 12 ($n = 1 \dots 12$).
- **Total Canonical Rulers Audited**: 21.
- **Difference Collisions**: 0 across all $\binom{n}{2}$ pairs.
- **OEIS A003022 Concordance**: 100% exact match.
- **Independent Cross-Validation**: 100% PASS.

---

## 5. Confidence

`computational evidence` (Machine-audited dual-engine verification: bitmask constraint search + independent difference certificate verification).

---

## 6. Best Next Step and Blockers

- **Next Step**: Investigate circular Golomb rulers (modular difference sets) and generalized Golomb rulers of degree $k$ ($B_k$ sets).
- **Blockers**: None.
