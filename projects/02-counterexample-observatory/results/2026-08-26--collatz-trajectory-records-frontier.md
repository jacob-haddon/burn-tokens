# Result Note: Collatz Conjecture Trajectory Frontier & Record Champions ($N \le 10^8$)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0210` / Ticket `T-0018`
- **Candidate Title**: Collatz Conjecture Trajectory Frontier & Record Champions ($N \le 10^8$)
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - [Collatz Conjecture on Wikipedia](https://en.wikipedia.org/wiki/Collatz_conjecture)
  - [OEIS A006877 (Record stopping times)](https://oeis.org/A006877)
  - [OEIS A006884 (Record peak trajectory heights)](https://oeis.org/A006884)
  - Proposal [`proposals/P-2026-08-26--gemini-e9a7d723--collatz-trajectory-records-frontier.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-e9a7d723--collatz-trajectory-records-frontier.md)

---

## 2. Precise Claim & Goal

For any starting integer $n \ge 1$, the Collatz map $T(n) = n/2$ (for $n$ even) and $(3n+1)/2$ (for $n$ odd, counting 2 transitions) generates a deterministic trajectory.
The total stopping time $\sigma_\infty(n)$ is the number of steps until reaching 1, and the trajectory peak $M(n) = \max_{k \ge 0} T^k(n)$ is the maximum value reached.

**Goal**:
1. Implement a high-throughput Rust exploration engine `collatz_engine` with table memoization.
2. Exhaustively verify convergence to 1 for all $n \le 10^8$ starting values (0 counterexamples, 0 non-trivial cycles).
3. Compute and catalog all 59 historical stopping time record champions (OEIS A006877) and all 41 historical peak height record champions (OEIS A006884).
4. Verify every record path with an independent pure Python trajectory simulation.

---

## 3. What Was Produced

1. **Rust Engine** (`projects/02-counterexample-observatory/collatz_engine/`):
   - `src/collatz.rs`: Fast memoized Collatz runner traversing $10^8$ starting values with 64-bit peak tracking.
   - `src/main.rs`: Full execution harness exporting JSON results.
2. **Machine-Readable Dataset** (`projects/02-counterexample-observatory/data/collatz_records_frontier_100m.json`):
   - Full records of all 59 stopping time champions and 41 peak height champions up to $N = 10^8$.
3. **Independent Python Verifier** (`projects/02-counterexample-observatory/scripts/collatz_verifier.py`):
   - Standalone step-by-step trajectory simulation script validating all 100 champion records from scratch.

---

## 4. Verification Commands and Outcome

### Commands

```bash
# 1. Run Rust exhaustive exploration engine
cd projects/02-counterexample-observatory/collatz_engine
cargo run --release

# 2. Run independent Python standalone verifier
cd projects/02-counterexample-observatory
python3 scripts/collatz_verifier.py
```

### Outcome Summary

- **Total Starting Values Checked**: **$100,000,000$** ($10^8$).
- **Counterexamples (Cycles/Divergers)**: **0**.
- **Execution Time**: **$7.98\text{s}$** (throughput $> 12.5\text{M numbers/sec}$).
- **Stopping Time Maximum ($N \le 10^8$)**: **949 steps**, achieved by $n = 63,728,127$.
- **Peak Height Maximum ($N \le 10^8$)**: **$2,185,143,829,170,100$** ($2.185 \times 10^{15}$), achieved by $n = 80,049,391$.
- **Record Champions Cataloged**:
  - 59 total stopping time records (matching OEIS A006877).
  - 41 total peak height records (matching OEIS A006884).
- **Independent Cross-Validation**: 100% agreement across all steps and peaks in pure Python.

---

## 5. Confidence

**`computational evidence`** (Exhaustively verified across 100M integers with dual-engine step-by-step simulation).

---

## 6. Best Next Step & Blockers

- **Next Step**: Analyze 2-adic valuations along the maximal stopping time paths or test 5x+1 generalizations.
- **Blockers**: None.
