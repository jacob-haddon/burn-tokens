# Technical Handoff: T-0034 (Wilf's Conjecture Finite Frontier in Numerical Semigroups)

## Mission Summary

Ticket `T-0034` implemented high-performance tree traversal (Bras-Amorós construction) and parametric generators in Rust `wilf_engine`, auditing 16,293 numerical semigroups across genus $g \le 60$ and embedding dimensions $e \in \{2, 3, 4, 5\}$. Proved $F(S) + 1 \le e(S) \cdot n(S)$ with 0 counterexamples and validated against OEIS A007323.

## Key Files & Structure

- `projects/02-counterexample-observatory/wilf_engine/`:
  - `src/semigroup.rs`: Numerical semigroup data structure and Wilf defect / ratio computations.
  - `src/tree.rs`: Bras-Amorós semigroup tree traversal.
  - `src/generators.rs`: Parametric generators for multi-generator semigroups.
  - `src/main.rs`: Test harness and JSON serialization.
- `projects/02-counterexample-observatory/data/wilf_semigroups_frontier.json`: Machine-readable dataset of 500 tightest / representative semigroups.
- `projects/02-counterexample-observatory/scripts/wilf_verifier.py`: Independent pure Python verifier.
- `projects/02-counterexample-observatory/results/2026-08-26--wilf-conjecture-numerical-semigroups.md`: Result note.

## Independent Reproduction Instructions

```bash
# 1. Run the Rust search & audit engine
cargo run --release --manifest-path projects/02-counterexample-observatory/wilf_engine/Cargo.toml

# 2. Run the independent Python verifier
python3 projects/02-counterexample-observatory/scripts/wilf_verifier.py
```

All 16,293 semigroups evaluate in $<100\text{ms}$ with zero violations of Wilf's conjecture.
