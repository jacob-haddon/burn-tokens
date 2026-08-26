# Proposal: Additive Basis of Order 2 and Extremal Stöhr Range Frontier ($k \le 10$)

## Metadata
- **Author**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Date**: 2026-08-26
- **Status**: proposal
- **Target Confidence**: `computational evidence`

---

## 1. Candidate Description & Motivation
A finite subset $A \subseteq \mathbb{N}$ with $0 \in A$ and $|A| = k$ is an **additive basis of order $h$** for $\{0, 1, \dots, n\}$ if every integer $m \in [0, n]$ can be written as a sum of at most $h$ elements of $A$ ($[0, n] \subseteq hA$).
The classical extremal function $n(h, k)$ (Rohrbach 1937, Stöhr 1955, OEIS A001212) denotes the maximum value of $n$ for which a $k$-element basis of order $h$ exists.
Exact values of $n(2, k)$ from OEIS A001212:
\[
n(2, 1) = 0, \; n(2, 2) = 2, \; n(2, 3) = 4, \; n(2, 4) = 8, \; n(2, 5) = 12, \; n(2, 6) = 16, \; n(2, 7) = 20, \; n(2, 8) = 26, \; n(2, 9) = 32, \; n(2, 10) = 40
\]

---

## 2. Precise Research Goal
1. Build a high-performance Rust search engine `additive_basis_engine` utilizing bitsets and branch-and-bound pruning.
2. Certify the exact extremal ranges $n(2, k)$ for $k \in \{2, 3, 4, 5, 6, 7, 8, 9, 10\}$.
3. Catalog all canonical extremal bases $A$ achieving the maximal range $n(2, k)$.
4. Export the complete certificate database to `projects/02-counterexample-observatory/data/additive_basis_frontier.json`.
5. Verify 100% agreement with OEIS A001212 and validate all sumset coverings $[0, n(2, k)] \subseteq 2A$ with an independent pure Python verifier.

---

## 3. Rubric Score (Total: 25/25)
- **Clarity of claim (5/5)**: Exact correspondence with OEIS A001212.
- **Reversibility & Containment (5/5)**: Isolated in `projects/02-counterexample-observatory/additive_basis_engine/`.
- **Independent verifiability (5/5)**: Standalone Python verifier tests full interval coverage.
- **Safety compliance (5/5)**: Local CPU execution only, no network calls.
- **Project fit (5/5)**: Pillar 1 OEIS extremal sequence discovery.

---

## 4. Verification Plan
```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/additive_basis_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/additive_basis_verifier.py
```
Checks:
- Exact confirmation of $n(2, k)$ for $k=2..10$ matching OEIS A001212.
- Zero gap violations in $[0, n(2, k)]$.
