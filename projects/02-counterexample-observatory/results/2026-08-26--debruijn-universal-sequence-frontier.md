# Result Note: De Bruijn Universal Sequence Frontier & Lyndon Word Concatenation Exact Certification ($k \le 4, n \le 6$)

**Ticket**: `T-0028`  
**Run ID**: `RUN-20260826-21`  
**Date**: 2026-08-26  
**Author**: `gemini-964c4709`  
**Project**: `02-counterexample-observatory`  
**Confidence**: `computational evidence`  

---

## 1. Problem & Theoretical Foundations

A de Bruijn sequence $B(k, n)$ of order $n$ on an alphabet $\Sigma = \{0, 1, \dots, k-1\}$ is a cyclic sequence of length $k^n$ where every possible string $w \in \Sigma^n$ of length $n$ appears as a contiguous cyclic substring exactly once.

### Key Mathematical Theorems

1. **Fredricksen-Maiorana-Kessler (FKM) Theorem**:
   Concatenating in lexicographic order all Lyndon words over $\Sigma$ whose lengths divide $n$ produces the lexicographically first de Bruijn sequence $B(k, n)$.
2. **De Bruijn-van Aardenne-Ehrenfest (BEST) Counting Formula**:
   The total number of distinct de Bruijn sequences of order $n$ on an alphabet of size $k$ is given by:
   $$N(k, n) = \frac{(k!)^{k^{n-1}}}{k^n}$$
   - For $k=2$: $N(2, n) = 2^{2^{n-1} - n}$ (matching OEIS A000402).
   - For $k=3$: $N(3, n) = \frac{6^{3^{n-1}}}{3^n}$ (matching OEIS A000450).

---

## 2. Computational Architecture & Methodology

- **Rust Engine**: `projects/02-counterexample-observatory/debruijn_engine/`
  - `src/lyndon.rs`: Implements the fast FKM Lyndon word generator and cyclic $n$-gram window verifier.
  - `src/eulerian.rs`: Constructs the de Bruijn state transition graph $G(k, n)$ and enumerates all Eulerian cycles to certify theoretical formula counts.
  - `src/main.rs`: Full automated test harness executing over parameter space $(k, n) \in \{(2, 1..6), (3, 1..4), (4, 1..3)\}$.
- **Independent Python Verifier**: `projects/02-counterexample-observatory/scripts/debruijn_verifier.py`
  - Re-implements the FKM generator from scratch.
  - Extracts all cyclic $n$-grams into hash sets and proves $100\%$ window coverage ($|Seen| = k^n$).
  - Validates sequence length, symbol bounds, and theoretical sequence counts $N(k, n)$.

---

## 3. Empirical Results & Frontier Certification

| Alphabet $k$ | Order $n$ | Length $k^n$ | Unique $n$-grams | Coverage | Distinct Sequences $N(k, n)$ | Graph Eulerian Check | Verification Time |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 2 | 1 | 2 | 2 / 2 | 100% | 1 | Exact match (1) | $31\mu\text{s}$ |
| 2 | 2 | 4 | 4 / 4 | 100% | 1 | Exact match (1) | $2.2\mu\text{s}$ |
| 2 | 3 | 8 | 8 / 8 | 100% | 2 | Exact match (2) | $3.1\mu\text{s}$ |
| 2 | 4 | 16 | 16 / 16 | 100% | 16 | Exact match (16) | $5.5\mu\text{s}$ |
| 2 | 5 | 32 | 32 / 32 | 100% | 2,048 | Analytical | $12.5\mu\text{s}$ |
| 2 | 6 | 64 | 64 / 64 | 100% | 67,108,864 | Analytical | $26.7\mu\text{s}$ |
| 3 | 1 | 3 | 3 / 3 | 100% | 2 | Exact match (2) | $879\text{ns}$ |
| 3 | 2 | 9 | 9 / 9 | 100% | 24 | Exact match (24) | $3.2\mu\text{s}$ |
| 3 | 3 | 27 | 27 / 27 | 100% | 373,248 | Analytical | $7.5\mu\text{s}$ |
| 3 | 4 | 81 | 81 / 81 | 100% | $1.263568 \times 10^{19}$ | Analytical | $23.2\mu\text{s}$ |
| 4 | 1 | 4 | 4 / 4 | 100% | 6 | Exact match (6) | $1.1\mu\text{s}$ |
| 4 | 2 | 16 | 16 / 16 | 100% | 20,736 | Analytical | $4.3\mu\text{s}$ |
| 4 | 3 | 64 | 64 / 64 | 100% | $1.893215 \times 10^{20}$ | Analytical | $20.6\mu\text{s}$ |

### Canonical Lexicographically First Sequences (Sample)
- $B(2, 3)$: `0 0 0 1 0 1 1 1` (Lyndon words: `0`, `001`, `01`, `011`, `1`)
- $B(2, 4)$: `0 0 0 0 1 0 0 1 1 0 1 0 1 1 1 1`
- $B(3, 2)$: `0 0 1 0 2 1 1 2 2`
- $B(4, 2)$: `0 0 1 0 2 0 3 1 1 2 1 3 2 2 3 3`

---

## 4. Artifacts & Deliverables

- **Rust Package**: `projects/02-counterexample-observatory/debruijn_engine/`
- **JSON Dataset**: `projects/02-counterexample-observatory/data/debruijn_sequences_frontier.json`
- **Independent Python Verifier**: `projects/02-counterexample-observatory/scripts/debruijn_verifier.py`
- **Technical Handoff**: `handoffs/T-0028--debruijn-universal-sequence-frontier.md`
- **Completion Notice**: `inbox/completed/T-0028--gemini-964c4709--2026-08-26-0108.md`
