# Proposal: Collatz Conjecture Trajectory Frontier & Stopping Time Record Champions ($N \le 10^8$)

## Metadata
- **Author**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Date**: 2026-08-26
- **Status**: proposal
- **Target Confidence**: `computational evidence`

---

## 1. Candidate Description & Motivation
The **Collatz $3n+1$ sequence** for an integer $n \ge 1$ is defined by:
\[
T(n) = \begin{cases} n/2 & \text{if } n \text{ is even} \\ 3n+1 & \text{if } n \text{ is odd} \end{cases}
\]
The **total stopping time** $\sigma_\infty(n)$ is the number of steps until $T^k(n) = 1$.
The **trajectory maximum** $M(n) = \max_{k \ge 0} T^k(n)$ is the peak height reached.

Integers setting new historical records for stopping time (OEIS [A006877](https://oeis.org/A006877)) and peak trajectory height (OEIS [A006884](https://oeis.org/A006884)) provide essential computational milestones.

---

## 2. Precise Research Goal
1. Implement a SIMD/bit-parallel Rust Collatz exploration engine testing all starting values up to $N = 10^8$.
2. Verify:
   - All $n \le 10^8$ converge to 1 (0 counterexamples / cycles).
   - Catalog all strictly extremal record champions for total stopping time matching OEIS A006877.
   - Catalog all strictly extremal peak height champions matching OEIS A006884.
3. Validate all record paths with an independent Python trajectory verifier.

---

## 3. Rubric Score (Total: 22/25)
- **Clarity of claim (5/5)**: Unambiguous arithmetic function and sequence specifications.
- **Reversibility & Containment (5/5)**: Fully contained in `projects/02-counterexample-observatory/collatz_engine/`.
- **Independent verifiability (5/5)**: Independent Python script recomputes every record trajectory step-by-step.
- **Safety compliance (5/5)**: Pure local arithmetic computation, no external dependencies.
- **Project fit (2/5)**: Classical number-theoretic benchmark with historical OEIS calibration.

---

## 4. Verification Plan
```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/collatz_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/collatz_independent_verifier.py
```
Checks:
- 0 trajectory failures or non-terminating loops for $n \le 10^8$.
- 100% agreement of record champion list with OEIS A006877 & A006884.
