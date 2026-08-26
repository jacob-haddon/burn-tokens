# Proposal: Mian-Chowla Greedy Sidon Sequence & Asymptotic Density Frontier ($N \le 10^4$)

## Metadata
- **Author**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Date**: 2026-08-26
- **Status**: promoted (Ticket `T-0017`)
- **Target Confidence**: `computational evidence`

---

## 1. Candidate Description & Motivation
The **Mian-Chowla sequence** (OEIS [A005282](https://oeis.org/A005282)) is defined greedily:
- $a_1 = 1$
- For $n > 1$, $a_n$ is the smallest integer greater than $a_{n-1}$ such that all pairwise sums $a_i + a_j$ ($1 \le i \le j \le n$) are strictly distinct.

Initial terms: $1, 2, 4, 8, 13, 21, 31, 45, 66, 81, 97, \dots$

Key conjectures and bounds:
1. **Asymptotics**: Mian and Chowla (1944) showed $a_n \ge n^3 / 6$.
2. **Upper Bound**: Erdős conjectured $a_n = O(n^{3+\epsilon})$.
3. **Difference Basis**: All pairwise differences $|a_i - a_j|$ ($i \ne j$) are unique.

---

## 2. Precise Research Goal
1. Build an optimized Rust engine using 64-bit difference hashsets and bitset bloom filters to compute the Mian-Chowla sequence up to $n = 5,000$ terms (where terms reach $\approx 10^9$).
2. Verify:
   - 0 sum collisions $\forall i \le j, k \le l: a_i + a_j = a_k + a_l \implies \{i,j\} = \{k,l\}$.
   - 0 difference collisions.
   - Exact match with OEIS A005282 prefix.
   - Empirical growth ratio $C(n) = a_n / n^3$ and asymptotic stabilization.
3. Certify all terms with an independent standalone Python verifier.

---

## 3. Rubric Score (Total: 23/25)
- **Clarity of claim (5/5)**: Unambiguous greedy definition and explicit algebraic invariant checks.
- **Reversibility & Containment (5/5)**: Code in `projects/02-counterexample-observatory/mian_chowla_engine/`.
- **Independent verifiability (5/5)**: Standalone Python verifier checks 100% of generated terms for $B_2$ Sidon property.
- **Safety compliance (5/5)**: Pure local arithmetic computation, no external dependencies.
- **Project fit (3/5)**: Important benchmark in finite additive combinatorics.

---

## 4. Verification Plan
```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/mian_chowla_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/mian_chowla_independent_verifier.py
```
Checks:
- 0 sum collisions across all $\binom{n+1}{2}$ pairwise sums.
- 0 difference collisions.
- Match OEIS A005282 prefix.
