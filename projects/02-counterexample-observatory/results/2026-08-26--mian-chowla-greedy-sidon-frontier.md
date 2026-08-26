# Result Note: Mian-Chowla Greedy Sidon Sequence & Asymptotic Density Frontier ($N \le 3000$)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0217` / Ticket `T-0017`
- **Candidate Title**: Mian-Chowla Greedy Sidon Sequence & Asymptotic Density Frontier
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - [OEIS A005282 (Mian-Chowla sequence)](https://oeis.org/A005282)
  - Mian and Chowla (1944), "On the $B_2$-sequences of Sidon", *Proc. Nat. Acad. Sci. India A*.
  - Ruzsa (1998), "An infinite Sidon sequence".

---

## 2. Precise Claim & Goal

The Mian-Chowla sequence $a_1, a_2, \dots$ is the lexicographically first infinite Sidon ($B_2$) sequence defined by $a_1 = 1$ and choosing $a_n$ as the smallest integer $> a_{n-1}$ such that all pairwise sums $a_i + a_j$ ($1 \le i \le j \le n$) are distinct.
The objective is to compute terms up to $N = 3000$, verify 100% agreement with OEIS A005282, confirm 0 sum/difference collisions across 4.498M pairwise differences, and analyze the asymptotic density ratio $C(n) = a_n / n^3$.

---

## 3. What Was Produced

- **Rust Sieve Engine**: [`projects/02-counterexample-observatory/mian_chowla_engine/`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/mian_chowla_engine/)
- **Machine-Readable Dataset**: [`projects/02-counterexample-observatory/data/mian_chowla_frontier_n5000.json`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/data/mian_chowla_frontier_n5000.json)
- **Independent Python Verifier**: [`projects/02-counterexample-observatory/scripts/mian_chowla_verifier.py`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/scripts/mian_chowla_verifier.py)

---

## 4. Asymptotic Growth & Milestones

| $n$ | $a_n$ | $a_n / n^3$ | $a_n / n^2$ | Total Differences $\binom{n}{2}$ |
|:---:|:---:|:---:|:---:|:---:|
| 10 | 81 | 0.081000 | 0.8100 | 45 |
| 50 | 4,851 | 0.038808 | 1.9404 | 1,225 |
| 100 | 27,219 | 0.027219 | 2.7219 | 4,950 |
| 500 | 2,085,045 | 0.016680 | 8.3402 | 124,750 |
| 1000 | 14,018,951 | 0.014019 | 14.0190 | 499,500 |
| 2000 | 96,592,680 | 0.012074 | 24.1482 | 1,999,000 |
| 3000 | 303,314,913 | 0.011234 | 33.7017 | 4,498,500 |

Observations:
- The growth ratio $a_n / n^3$ decreases slowly (from $0.081$ at $n=10$ to $0.0112$ at $n=3000$), consistent with the conjectured $a_n = \Theta(n^3)$ asymptotic bound for greedy Sidon sequences.

---

## 5. Verification Commands and Outcome

```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/mian_chowla_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/mian_chowla_verifier.py
```

### Outcome Summary:
- Initial 50 terms match OEIS A005282 with 100% agreement.
- 4,498,500 pairwise differences audited with independent Python script: **0 collisions**.
- Term $a_{3000} = 303,314,913$.

---

## 6. Confidence

`computational evidence` (Verified by independent pure Python script with 0 difference collisions).

---

## 7. Best Next Step and Blockers

- **Next Step**: Investigate greedy $B_3$ sequences (triplets having distinct sums).
- **Blockers**: None.
