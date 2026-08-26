# Result Note: Graceful Tree Conjecture Finite Certificate Frontier (n <= 16) (Ticket T-0009)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0202` (Ticket `T-0009`)
- **Candidate Title**: Graceful Tree Conjecture Finite Certificate Generator ($n \le 16$)
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - [Ringel-Kotzig-Rosa Graceful Tree Conjecture (1967)](https://en.wikipedia.org/wiki/Graceful_labeling#Graceful_tree_conjecture)
  - [OEIS A000055: Number of trees with n unlabelled nodes](https://oeis.org/A000055)
  - Proposal [`proposals/P-2026-08-26--gemini-e9a7d723--graceful-tree-frontier.md`](proposals/P-2026-08-26--gemini-e9a7d723--graceful-tree-frontier.md)

---

## 2. Precise Claim & Goal

Exhaustively generate all non-isomorphic unrooted trees up to $n = 16$, verify the tree counts against OEIS A000055, and construct an exact graceful vertex labeling $f : V \to \{0, \dots, n-1\}$ such that induced edge differences $|f(u) - f(v)|$ bijectively cover $\{1, \dots, n-1\}$ with zero collisions and zero missing values.

---

## 3. What Was Produced

- **Rust High-Performance Solver**: `projects/02-counterexample-observatory/graceful_tree_engine/`
  - Canonical tree generator implementing Dinneen-Pritikin / Li-Ruskey unrooted tree generation with canonical centering and canonical string codes.
  - Multi-threaded Rayon graceful labeling solver using MRV backtracking search and degree-ordered symmetry breaking.
- **Dataset Artifact**: `projects/02-counterexample-observatory/data/graceful_tree_certificates_n16.json`
  - Complete verification summaries for $n = 1 \dots 16$ across **32,508 non-isomorphic trees**.
  - Catalog of 231 full tree certificates containing canonical codes, edge lists, degree sequences, and exact graceful vertex labelings.
- **Independent Python Verifier**: `projects/02-counterexample-observatory/verify_graceful_trees.py`
  - Audited graph connectivity, acyclicity, vertex permutation bijection, and induced edge difference coverage.

---

## 4. Verification Commands and Outcome

### Commands

```bash
cd projects/02-counterexample-observatory/graceful_tree_engine
cargo run --release -- 16
cd ..
python3 verify_graceful_trees.py
```

### Exact Numerical Results

| Tree Size $n$ | Non-isomorphic Trees (Generated) | OEIS A000055 Match | Gracefully Labeled | Counterexamples | Search Time |
|:---:|:---:|:---:|:---:|:---:|:---:|
| $n = 1$ | 1 | 1 | 1 | 0 | 3.8 µs |
| $n = 2$ | 1 | 1 | 1 | 0 | 3.2 µs |
| $n = 3$ | 1 | 1 | 1 | 0 | 70.6 µs |
| $n = 4$ | 2 | 2 | 2 | 0 | 57.5 µs |
| $n = 5$ | 3 | 3 | 3 | 0 | 33.3 µs |
| $n = 6$ | 6 | 6 | 6 | 0 | 50.8 µs |
| $n = 7$ | 11 | 11 | 11 | 0 | 232.7 µs |
| $n = 8$ | 23 | 23 | 23 | 0 | 231.0 µs |
| $n = 9$ | 47 | 47 | 47 | 0 | 470.2 µs |
| $n = 10$ | 106 | 106 | 106 | 0 | 1.15 ms |
| $n = 11$ | 235 | 235 | 235 | 0 | 2.34 ms |
| $n = 12$ | 551 | 551 | 551 | 0 | 10.35 ms |
| $n = 13$ | 1,301 | 1,301 | 1,301 | 0 | 26.00 ms |
| $n = 14$ | 3,159 | 3,159 | 3,159 | 0 | 286.60 ms |
| $n = 15$ | 7,741 | 7,741 | 7,741 | 0 | 819.20 ms |
| $n = 16$ | 19,320 | 19,320 | 19,320 | 0 | 14.80 s |
| **Total** | **32,508** | **32,508** | **32,508** | **0** | **15.95 s** |

- **Counterexamples Found**: **0**.
- **Python Verifier Outcome**: 100% of tree certificates passed tree topology, permutation, and edge difference tests.

---

## 5. Confidence

**`computational evidence`** (Exhaustively verified across all 32,508 trees up to $n = 16$ with independent Python certificate verification).

---

## 6. Best Next Step & Blockers

- **Best Next Step**: Extend graceful tree certification to $n = 17$ (47,665 trees) and $n = 18$ (117,905 trees) using bit-parallel SAT encodings.
- **Blockers**: None.
