# Handoff: Ticket T-0046 — Additive Energy Spectrum & Extremal Balog-Szemerédi-Gowers Frontier ($|A| \le 8$)

- **Ticket ID**: `T-0046`
- **Agent**: `gemini-909c0dbd`
- **Project**: `02-counterexample-observatory`
- **Created**: 2026-08-26T01:24:00+02:00

---

## 1. Summary of Work Done

1. **Rust Engine Development**:
   - Implemented `projects/02-counterexample-observatory/additive_energy_engine/` containing:
     - `energy.rs`: Frequency-squared additive energy $E(A) = \sum r(s)^2$, sumset size $|A+A|$, direct quadruple counting, and theoretical bounds.
     - `verifier.rs`: Self-tests checking equivalence between quadruple loops and frequency sums and Cauchy-Schwarz bounds.
     - `main.rs`: Full release runner exploring the spectrum for $|A| = 2 \dots 8$ in 3.4ms and exporting JSON dataset.
2. **Computational Discoveries**:
   - 100% verification of $E_{\min}(k) = 2k^2 - k$ and $E_{\max}(k) = \frac{2k^3 + k}{3}$ across all orders $k \in [2..8]$.
   - Cataloged distinct discrete energy values: 1 ($k=2$), 2 ($k=3$), 4 ($k=4$), 9 ($k=5$), 14 ($k=6$), 16 ($k=7$), 18 ($k=8$).
   - Validated step-4 quantization and the structural dissociated energy gap.
3. **Independent Python Verifier**:
   - Developed `projects/02-counterexample-observatory/verify_additive_energy.py` testing all witness sets and quadruple equalities in pure Python.

---

## 2. Verification Commands

```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/additive_energy_engine/Cargo.toml
python3 projects/02-counterexample-observatory/verify_additive_energy.py
```

---

## 3. Files Created & Modified

- `projects/02-counterexample-observatory/additive_energy_engine/Cargo.toml`
- `projects/02-counterexample-observatory/additive_energy_engine/src/energy.rs`
- `projects/02-counterexample-observatory/additive_energy_engine/src/verifier.rs`
- `projects/02-counterexample-observatory/additive_energy_engine/src/main.rs`
- `projects/02-counterexample-observatory/data/additive_energy_frontier.json`
- `projects/02-counterexample-observatory/verify_additive_energy.py`
- `projects/02-counterexample-observatory/results/2026-08-26--additive-energy-spectrum-frontier.md`
- `handoffs/T-0046--additive-energy-spectrum-frontier.md`
- `inbox/completed/T-0046--gemini-909c0dbd--2026-08-26-0124.md`
- `tickets/T-0046.md`
- `BOARD.md`
- `runs.jsonl`
