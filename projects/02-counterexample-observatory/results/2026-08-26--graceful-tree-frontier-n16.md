# Result: Graceful Tree Conjecture Finite Certificate Generator ($n \le 16$)

- **Date**: 2026-08-26
- **Run ID**: `RUN-20260826-09`
- **Project**: `02-counterexample-observatory`
- **Ticket ID**: `T-0009`
- **Candidate ID**: `C-0206`
- **OEIS Reference**: [A000055 (Number of trees with $n$ unlabeled nodes)](https://oeis.org/A000055)
- **Primary Source**: Ringel-Kotzig-Rosa Graceful Tree Conjecture (1967)

---

## 1. Mathematical Objective & Background

**The Graceful Tree Conjecture (Ringel-Kotzig-Rosa, 1967)**:
Every finite tree $T = (V, E)$ on $n$ vertices with $n-1$ edges admits a **graceful labeling**: an injective vertex assignment $f: V \to \{0, 1, \dots, n-1\}$ such that the induced edge weight function:
$$\delta(\{u, v\}) = |f(u) - f(v)| \quad \forall \{u, v\} \in E$$
is a bijection onto $\{1, 2, \dots, n-1\}$.

This run aimed to:
1. Construct a verified canonical generator producing all non-isomorphic unrooted trees on $n \le 16$ vertices, matching OEIS A000055.
2. Formulate and solve the graceful tree constraint satisfaction problem (CSP) using tree-directed BFS search with difference-descending value ordering.
3. Emit an exact JSON certificate dataset with explicit tree structures, canonical AHU isomorphism codes, and bijective graceful vertex labelings.
4. Verify all certificates with an independent pure-Python verifier.

---

## 2. Exhaustive Tree Counts & Results ($n = 1 \dots 16$)

Across all levels from $n = 1$ to $n = 16$, exactly **32,508 non-isomorphic trees** were generated, analyzed, and successfully endowed with certified graceful labelings. **Zero counterexamples** were observed.

| Level $n$ | Total Non-Isomorphic Trees | OEIS A000055 Match | Gracefully Labeled | Counterexamples Found | Solver Time |
|:---:|:---:|:---:|:---:|:---:|:---:|
| **1** | 1 | Exact (1) | 1 | 0 | 10 µs |
| **2** | 1 | Exact (1) | 1 | 0 | 10 µs |
| **3** | 1 | Exact (1) | 1 | 0 | 56 µs |
| **4** | 2 | Exact (2) | 2 | 0 | 102 µs |
| **5** | 3 | Exact (3) | 3 | 0 | 77 µs |
| **6** | 6 | Exact (6) | 6 | 0 | 193 µs |
| **7** | 11 | Exact (11) | 11 | 0 | 255 µs |
| **8** | 23 | Exact (23) | 23 | 0 | 475 µs |
| **9** | 47 | Exact (47) | 47 | 0 | 951 µs |
| **10** | 106 | Exact (106) | 106 | 0 | 3.7 ms |
| **11** | 235 | Exact (235) | 235 | 0 | 4.9 ms |
| **12** | 551 | Exact (551) | 551 | 0 | 26.6 ms |
| **13** | 1,301 | Exact (1,301) | 1,301 | 0 | 55.2 ms |
| **14** | 3,159 | Exact (3,159) | 3,159 | 0 | 514.5 ms |
| **15** | 7,741 | Exact (7,741) | 7,741 | 0 | 1.43 s |
| **16** | 19,320 | Exact (19,320) | 19,320 | 0 | 22.62 s |
| **Total** | **32,508** | **Exact Concordance** | **32,508** | **0** | **24.67 s** |

---

## 3. Implementation & Computational Architecture

1. **Dual Engine**:
   - **Rust Engine (`graceful_tree_engine`)**: Parallel Rayon solver generating canonical Beyer-Hedetniemi rooted level sequences, AHU string isomorphism deduplication, and tree-directed BFS CSP propagation.
   - **Python Verifier (`verify_graceful_trees.py`)**: Standalone, independent script with zero external dependencies verifying tree connectivity, acyclicity, label injectivity, and difference covering.
2. **Data Artifact**:
   - Saved in `projects/02-counterexample-observatory/data/graceful_tree_certificates_n16.json` (contains level statistics, canonical AHU hashes, and explicit vertex labelings).

---

## 4. Verification Commands

```bash
# Execute Rust release engine
cargo run --release --manifest-path projects/02-counterexample-observatory/graceful_tree_engine/Cargo.toml -- 16

# Execute Independent Python Verifier
python3 projects/02-counterexample-observatory/verify_graceful_trees.py
```

---

## 5. Confidence Assessment

- **Confidence**: `computational evidence` (exhaustive machine check).
- **Status**: 100% verified across all 32,508 non-isomorphic trees up to $n = 16$.
