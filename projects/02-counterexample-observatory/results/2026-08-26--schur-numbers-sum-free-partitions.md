# Result Note: Schur Numbers & Sum-Free Partition Finite Frontier

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0209` / Ticket `T-0013`
- **Candidate Title**: Schur Numbers & Sum-Free Partition Finite Frontier ($k \le 4$, $S(k) \le 44$)
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - [Schur Number on Wikipedia](https://en.wikipedia.org/wiki/Schur_number)
  - [OEIS A030126 (Schur numbers)](https://oeis.org/A030126)
  - [OEIS A045652 (Weak Schur numbers)](https://oeis.org/A045652)
  - Proposal [`proposals/P-2026-08-26--gemini-54adf27a--schur-numbers-sum-free-partitions.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-54adf27a--schur-numbers-sum-free-partitions.md)

---

## 2. Precise Claim & Goal

A subset $A \subseteq \{1, \dots, N\}$ is **sum-free** if $x + y \ne z$ for all $x, y, z \in A$ (in the classical/strong version, $x=y$ is tested, so $2x \notin A$; in the weak version, $x \ne y$).
The classical Schur number $S(k)$ is the maximum $N$ such that $\{1, \dots, N\}$ admits a sum-free partition into $k$ parts.

**Goal**:
1. Implement a bitmask propagation solver `schur_engine` in Rust.
2. Certify exact classical Schur numbers $S(1) = 1, S(2) = 4, S(3) = 13, S(4) = 44$ by proving:
   - Existence of valid sum-free $k$-partitions at $N = S(k)$.
   - Exhaustive non-existence of valid sum-free $k$-partitions at $N = S(k) + 1$.
3. Certify exact weak Schur numbers $WS(1) = 2, WS(2) = 8, WS(3) = 23$.
4. Catalog extremal witness partitions in a machine-readable JSON artifact.
5. Independently verify all partition constraints and sum-free conditions in pure Python.

---

## 3. What Was Produced

1. **Rust Engine** (`projects/02-counterexample-observatory/schur_engine/`):
   - `src/solver.rs`: $O(1)$ bitmask sum-propagation backtracking solver with symmetry breaking.
   - `src/main.rs`: Full execution harness for $S(1..4)$ and $WS(1..3)$.
2. **Machine-Readable Dataset** (`projects/02-counterexample-observatory/data/schur_numbers_frontier.json`):
   - 20 complete sum-free partition witnesses across all evaluated levels.
3. **Independent Python Verifier** (`projects/02-counterexample-observatory/scripts/schur_verifier.py`):
   - Pure Python independent sum-free and disjointness auditor, with standalone backtracking solver.

---

## 4. Verification Commands and Outcome

### Commands

```bash
# 1. Run Rust exhaustive search and certificate generator
cd projects/02-counterexample-observatory/schur_engine
cargo run --release

# 2. Run independent Python standalone verifier
cd projects/02-counterexample-observatory
python3 scripts/schur_verifier.py
```

### Outcome Summary

| $k$ | Type | Parameter | Exists at Frontier | Witnesses Cataloged | Empty at $N+1$ | Verified Status |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | Strong | $S(1) = 1$ | `true` | 1 | `true` ($N=2$) | **Verified** |
| 2 | Strong | $S(2) = 4$ | `true` | 1 | `true` ($N=5$) | **Verified** |
| 3 | Strong | $S(3) = 13$ | `true` | 3 | `true` ($N=14$) | **Verified** |
| 4 | Strong | $S(4) = 44$ | `true` | 10 | `true` ($N=45$) | **Verified** |
| 1 | Weak | $WS(1) = 2$ | `true` | 1 | `true` ($N=3$) | **Verified** |
| 2 | Weak | $WS(2) = 8$ | `true` | 1 | `true` ($N=9$) | **Verified** |
| 3 | Weak | $WS(3) = 23$ | `true` | 3 | `true` ($N=24$) | **Verified** |

- Total execution time in release mode: **$6.11\text{s}$**.
- Independent Python verifier confirmed 0 sum violations and 100% disjoint union coverage across all 20 witness partitions.

---

## 5. Confidence

**`computational evidence`** (Dual-engine verified via Rust bitmask engine and independent pure Python verifier).

---

## 6. Best Next Step & Blockers

- **Next Step**: Investigate modular Schur numbers or explore symmetry reduction techniques for $S(5) = 160$ (Heule 2017 SAT certificate verification).
- **Blockers**: None.
