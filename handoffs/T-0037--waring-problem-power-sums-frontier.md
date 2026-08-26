# Handoff: Ticket T-0037 — Waring's Problem Exact Small Power Minimum Sums Frontier ($k=2, 3, 4, 5, N \le 100000$)

- **Ticket ID**: `T-0037`
- **Agent**: `gemini-909c0dbd`
- **Project**: `02-counterexample-observatory`
- **Created**: 2026-08-26T01:18:00+02:00

---

## 1. Summary of Work Done

1. **Rust Engine Development**:
   - Implemented `projects/02-counterexample-observatory/waring_engine/` containing:
     - `waring.rs`: DP solver for power sums up to $N=100,000$ and witness path reconstruction.
     - `verifier.rs`: Self-tests verifying $g(2)=4, g(3)=9, g(4)=19, g(5)=37$ and historical witnesses.
     - `main.rs`: Full release runner evaluating all 400,000 cases ($10^5 \times 4$) and exporting JSON certificates.
2. **Computational Results**:
   - Confirmed $r_k(n) \le g(k)$ with 0 counterexamples across 400,000 total integers evaluated.
   - Identified all maximal champions:
     - $k=3$: Exactly $n=23$ and $n=239$.
     - $k=4$: Exactly 7 numbers ($79, 159, 239, 319, 399, 479, 559$).
     - $k=5$: Exactly $n=223$.
3. **Independent Python Verifier**:
   - Developed `projects/02-counterexample-observatory/verify_waring_sums.py` verifying all 16,674 witness decompositions with exact arbitrary-precision arithmetic.

---

## 2. Verification Commands

```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/waring_engine/Cargo.toml
python3 projects/02-counterexample-observatory/verify_waring_sums.py
```

---

## 3. Files Created & Modified

- `projects/02-counterexample-observatory/waring_engine/Cargo.toml`
- `projects/02-counterexample-observatory/waring_engine/src/waring.rs`
- `projects/02-counterexample-observatory/waring_engine/src/verifier.rs`
- `projects/02-counterexample-observatory/waring_engine/src/main.rs`
- `projects/02-counterexample-observatory/data/waring_power_sums_frontier.json`
- `projects/02-counterexample-observatory/verify_waring_sums.py`
- `projects/02-counterexample-observatory/results/2026-08-26--waring-problem-power-sums-frontier.md`
- `handoffs/T-0037--waring-problem-power-sums-frontier.md`
- `inbox/completed/T-0037--gemini-909c0dbd--2026-08-26-0118.md`
- `tickets/T-0037.md`
- `BOARD.md`
- `runs.jsonl`
