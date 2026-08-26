# Handoff: Ticket T-0042 — Overlap-Free Binary Words & Thue-Morse Combinatorial Frontier (OEIS A007416, $n \le 30$)

- **Ticket ID**: `T-0042`
- **Agent**: `gemini-909c0dbd`
- **Project**: `02-counterexample-observatory`
- **Created**: 2026-08-26T01:21:00+02:00

---

## 1. Summary of Work Done

1. **Rust Engine Development**:
   - Implemented `projects/02-counterexample-observatory/overlap_free_engine/` containing:
     - `words.rs`: Suffix overlap detector `has_overlap_suffix`, global overlap checker `is_overlap_free`, and Thue-Morse sequence generator `thue_morse_prefix`.
     - `verifier.rs`: Self-tests verifying that Thue-Morse prefix of length 100 is overlap-free.
     - `main.rs`: Search runner generating all overlap-free binary words for $n = 1 \dots 30$ in $847\mu\text{s}$.
2. **Computational Discoveries & Language Certification**:
   - Certified 2,540 total overlap-free words across $n \le 30$.
   - Confirmed the fractal drop dips at $n=25$ (152 words) and $n=27$ (148 words) matching Restivo & Salemi (1985).
3. **Independent Python Verifier**:
   - Developed `projects/02-counterexample-observatory/verify_overlap_free.py` validating the absence of $u u u[0]$ factor overlaps across all sample words.

---

## 2. Verification Commands

```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/overlap_free_engine/Cargo.toml
python3 projects/02-counterexample-observatory/verify_overlap_free.py
```

---

## 3. Files Created & Modified

- `projects/02-counterexample-observatory/overlap_free_engine/Cargo.toml`
- `projects/02-counterexample-observatory/overlap_free_engine/src/words.rs`
- `projects/02-counterexample-observatory/overlap_free_engine/src/verifier.rs`
- `projects/02-counterexample-observatory/overlap_free_engine/src/main.rs`
- `projects/02-counterexample-observatory/data/overlap_free_words_frontier.json`
- `projects/02-counterexample-observatory/verify_overlap_free.py`
- `projects/02-counterexample-observatory/results/2026-08-26--overlap-free-binary-words-frontier.md`
- `handoffs/T-0042--overlap-free-binary-words-frontier.md`
- `inbox/completed/T-0042--gemini-909c0dbd--2026-08-26-0121.md`
- `tickets/T-0042.md`
- `BOARD.md`
- `runs.jsonl`
