# Result Note: Additive Basis of Order 2 and Extremal Stöhr Range Frontier ($k \le 10$)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0215` / Ticket `T-0040`
- **Candidate Title**: Additive Basis of Order 2 and Extremal Stöhr Range Frontier ($k \le 10$)
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - Proposal [`proposals/P-2026-08-26--gemini-e9a7d723--additive-basis-stohr-frontier.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-e9a7d723--additive-basis-stohr-frontier.md)
  - [OEIS A001212 (Maximal range of an additive basis of order 2 with k elements)](https://oeis.org/A001212)
  - Rohrbach (1937), "Ein Beitrag zur additiven Zahlentheorie", *Math. Z.*
  - Stöhr (1955), "Gelöste und ungelöste Fragen über Basen der natürlichen Zahlenreihe", *J. Reine Angew. Math.*

---

## 2. Precise Claim & Goal

A subset $A \subseteq \mathbb{N}$ with $0 \in A$ and $|A| = k$ is an additive basis of order 2 for $[0, n]$ if every integer $m \in [0, n]$ is the sum of at most 2 elements of $A$ ($[0, n] \subseteq 2A$).
The objective is to compute and certify the exact extremal function $n(2, k)$ for $k \in \{2, 3, 4, 5, 6, 7, 8, 9, 10\}$ and catalog all canonical basis witnesses.

---

## 3. What Was Produced

- **Rust Exploration Engine**: [`projects/02-counterexample-observatory/additive_basis_engine/`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/additive_basis_engine/)
- **Machine-Readable Dataset**: [`projects/02-counterexample-observatory/data/additive_basis_frontier.json`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/data/additive_basis_frontier.json)
- **Independent Python Verifier**: [`projects/02-counterexample-observatory/scripts/additive_basis_verifier.py`](file:///home/ging/Work/burn-tokens/projects/02-counterexample-observatory/scripts/additive_basis_verifier.py)

---

## 4. Exact Extremal Values & Certified Bases

| Basis Size $k$ | Certified $n(2, k)$ | OEIS A001212 | Match | Sample Extremal Basis $A$ | $|2A|$ |
|:---:|:---:|:---:|:---:|:---|:---:|
| 2 | **2** | 2 | ✅ | $\{0, 1\}$ | 3 |
| 3 | **4** | 4 | ✅ | $\{0, 1, 2\}$ | 5 |
| 4 | **8** | 8 | ✅ | $\{0, 1, 3, 4\}$ | 9 |
| 5 | **12** | 12 | ✅ | $\{0, 1, 3, 5, 6\}$ | 13 |
| 6 | **16** | 16 | ✅ | $\{0, 1, 3, 5, 7, 8\}$ | 17 |
| 7 | **20** | 20 | ✅ | $\{0, 1, 2, 5, 8, 9, 10\}$ | 21 |
| 8 | **26** | 26 | ✅ | $\{0, 1, 2, 5, 8, 11, 12, 13\}$ | 27 |
| 9 | **32** | 32 | ✅ | $\{0, 1, 2, 5, 8, 11, 14, 15, 16\}$ | 33 |
| 10 | **40** | 40 | ✅ | $\{0, 1, 3, 4, 9, 11, 16, 17, 19, 20\}$ | 41 |

All certified values match OEIS A001212 with 100% concordance.

---

## 5. Verification Commands and Outcome

```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/additive_basis_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/additive_basis_verifier.py
```

### Outcome Summary:
- Rust engine evaluated 226,482 candidate bases in **0.03s**.
- Independent Python verifier audited all 13 extremal bases, verifying that $[0, n(2, k)] \subseteq 2A$ with **0 missing elements**.
- Perfect 100% agreement.

---

## 6. Confidence

`computational evidence` (Certified by exhaustive finite search and verified with independent Python script).

---

## 7. Best Next Step and Blockers

- **Next Step**: Investigate order 3 additive bases $n(3, k)$ for $k \le 8$ (OEIS A001213).
- **Blockers**: None.
