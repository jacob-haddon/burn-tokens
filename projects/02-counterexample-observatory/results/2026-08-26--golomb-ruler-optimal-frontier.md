# Result Note: Optimal Golomb Ruler Frontier & Difference Triangle Exact Certification ($n \le 11$)

- **Project**: `02-counterexample-observatory`
- **Date**: 2026-08-26
- **Ticket**: [`T-0019`](../../tickets/T-0019.md)
- **Agent**: `gemini-964c4709`
- **Confidence**: `computational evidence`

---

## 1. Candidate Chosen and Source URLs

- **Candidate**: `Optimal Golomb Ruler Frontier & Difference Triangle Exact Certification ($n \le 11$)`
- **Source URLs**:
  - [OEIS A003006 (Optimal Golomb Rulers)](https://oeis.org/A003006)
  - [Wikipedia: Golomb ruler](https://en.wikipedia.org/wiki/Golomb_ruler)
  - [Proposal P-2026-08-26--gemini-964c4709--golomb-ruler-optimal-frontier.md](../../proposals/P-2026-08-26--gemini-964c4709--golomb-ruler-optimal-frontier.md)

---

## 2. Precise Claim or Goal

A Golomb ruler of order $n$ is a sequence of integers $0 = a_1 < a_2 < \dots < a_n$ such that all $\binom{n}{2}$ pairwise differences $a_j - a_i$ ($1 \le i < j \le n$) are strictly distinct. An Optimal Golomb Ruler $O(n)$ minimizes the total span $L = a_n$.

**Goals**:
1. Implement high-performance branch-and-bound bitmask search engine `golomb_engine` in Rust.
2. Certify exact optimal lengths $O(n)$ for all $n \in \{1, 2, \dots, 11\}$:
   - Prove existence of valid rulers at length $L = O(n)$.
   - Prove non-existence of valid rulers at length $L < O(n)$.
3. Catalog all 20 canonical optimal rulers and their difference triangles.
4. Independently verify distinct pairwise difference constraints in pure Python.

---

## 3. What Was Produced

1. **Rust Search Engine**:
   - `projects/02-counterexample-observatory/golomb_engine/`: High-performance difference bitmask branch-and-bound solver with mirror symmetry breaking.
2. **Machine-Readable Dataset**:
   - `projects/02-counterexample-observatory/data/golomb_rulers_frontier.json`: Complete JSON dataset containing all 20 canonical optimal rulers, difference triangles, and proof logs.
3. **Independent Pure Python Verifier**:
   - `projects/02-counterexample-observatory/scripts/golomb_verifier.py`: Independent Python verifier validating all difference triangles, canonical orientations, and exhaustive cross-checks for $n \le 5$.

---

## 4. Verification Commands and Outcome

### Commands

```bash
# 1. Run Rust exhaustive search and certificate generator
cd projects/02-counterexample-observatory/golomb_engine
cargo run --release

# 2. Run independent Python standalone verifier
cd ../../..
python3 projects/02-counterexample-observatory/scripts/golomb_verifier.py
```

### Verification Outcome

| Order $n$ | Optimal Length $O(n)$ | OEIS A003006 | Canonical Rulers Found | $L-1$ Proved Empty | Status |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | 0 | 0 | 1: `[0]` | `true` | **Verified** |
| 2 | 1 | 1 | 1: `[0, 1]` | `true` | **Verified** |
| 3 | 3 | 3 | 1: `[0, 1, 3]` | `true` | **Verified** |
| 4 | 6 | 6 | 1: `[0, 1, 4, 6]` | `true` | **Verified** |
| 5 | 11 | 11 | 2: `[0, 1, 4, 9, 11]`, `[0, 2, 7, 8, 11]` | `true` | **Verified** |
| 6 | 17 | 17 | 4: `[0, 1, 4, 10, 12, 17]`, `[0, 1, 4, 10, 15, 17]`, `[0, 1, 8, 11, 13, 17]`, `[0, 1, 8, 12, 14, 17]` | `true` | **Verified** |
| 7 | 25 | 25 | 5: `[0, 1, 4, 10, 18, 23, 25]`, `[0, 1, 7, 11, 20, 23, 25]`, `[0, 1, 11, 16, 19, 23, 25]`, `[0, 2, 3, 10, 16, 21, 25]`, `[0, 2, 7, 13, 21, 22, 25]` | `true` | **Verified** |
| 8 | 34 | 34 | 1: `[0, 1, 4, 9, 15, 22, 32, 34]` | `true` | **Verified** |
| 9 | 44 | 44 | 1: `[0, 1, 5, 12, 25, 27, 35, 41, 44]` | `true` | **Verified** |
| 10 | 55 | 55 | 1: `[0, 1, 6, 10, 23, 26, 34, 41, 53, 55]` | `true` | **Verified** |
| 11 | 72 | 72 | 2: `[0, 1, 4, 13, 28, 33, 47, 54, 64, 70, 72]`, `[0, 1, 9, 19, 24, 31, 52, 56, 58, 69, 72]` | `true` | **Verified** |

- Total execution time in release mode: **$9.27\text{s}$**.
- Independent Python audit confirmed 0 difference collisions across all 20 rulers and 100% agreement with OEIS A003006.

---

## 5. Confidence Assessment

- **Confidence**: `computational evidence`
- **Assessment**: Exact dual-engine verification (Rust bitmask search + independent pure Python validation) establishes sound certification of optimal lengths $O(1..11)$ and non-existence below optimal bounds.

---

## 6. Best Next Step and Blockers

- **Next Step**: Investigate order $n=12$ ($O(12)=85$) with distributed multithreading or explore circular Golomb rulers (modular difference sets).
- **Blockers**: None for current scope.
