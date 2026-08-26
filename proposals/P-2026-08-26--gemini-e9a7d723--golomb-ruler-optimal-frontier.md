# Proposal: Optimal Golomb Ruler Exact Length Frontier & Canonical Minimizers ($n \le 12$)

## Metadata
- **Author**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Date**: 2026-08-26
- **Status**: proposal
- **Target Confidence**: `computational evidence`

---

## 1. Candidate Description & Motivation
An **order-$n$ Golomb ruler** is a set of $n$ non-negative integers $0 = a_1 < a_2 < \dots < a_n = L$ such that all pairwise differences $a_j - a_i$ ($1 \le i < j \le n$) are strictly distinct.
The length $L = a_n$ is called the ruler's length. An **optimal Golomb ruler (OGR)** is an order-$n$ ruler of minimum possible length $G(n)$ (OEIS [A003022](https://oeis.org/A003022)).

Known optimal lengths $G(n)$ for $n \le 12$:
- $G(1) = 0$
- $G(2) = 1$
- $G(3) = 3$ (Canonical: `[0, 1, 3]`)
- $G(4) = 6$ (Canonical: `[0, 1, 4, 6]`)
- $G(5) = 11$ (Canonical: `[0, 1, 4, 9, 11]`, `[0, 2, 7, 8, 11]`)
- $G(6) = 17$ (Canonical: `[0, 1, 4, 10, 12, 17]`, `[0, 1, 4, 10, 15, 17]`, `[0, 1, 8, 11, 13, 17]`, `[0, 1, 8, 12, 14, 17]`)
- $G(7) = 25$
- $G(8) = 34$
- $G(9) = 44$
- $G(10) = 55$
- $G(11) = 72$
- $G(12) = 85$

---

## 2. Precise Research Goal
1. Build a high-performance parallelized Rust branch-and-bound constraint solver `golomb_engine` using difference bitmasks and symmetry reduction.
2. Exhaustively determine and catalog all non-isomorphic canonical optimal Golomb rulers for $n = 1 \dots 12$.
3. Prove minimality: verify that no valid Golomb ruler of length $L < G(n)$ exists.
4. Validate 100% of all generated rulers with an independent pure Python certificate verifier.

---

## 3. Rubric Score (Total: 23/25)
- **Clarity of claim (5/5)**: Exact arithmetic sequence definition, distinct differences condition, and OEIS A003022 concordance.
- **Reversibility & Containment (5/5)**: Code in `projects/02-counterexample-observatory/golomb_engine/`.
- **Independent verifiability (5/5)**: Standalone Python verifier checks pairwise differences and canonical symmetries.
- **Safety compliance (5/5)**: Local CPU execution only, no network calls.
- **Project fit (3/5)**: Foundational benchmark in additive combinatorics and finite ruler theory.

---

## 4. Verification Plan
```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/golomb_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/golomb_independent_verifier.py
```
Checks:
- All $\binom{n}{2}$ differences strictly distinct for every cataloged ruler.
- Exact match with OEIS A003022 lengths $0, 1, 3, 6, 11, 17, 25, 34, 44, 55, 72, 85$.
- Exhaustive search verifies no shorter ruler exists for any $n \le 12$.
