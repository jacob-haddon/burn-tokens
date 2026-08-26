# Handoff: Mian-Chowla Greedy Sidon Sequence Frontier (`T-0017`)

## 1. Exact Claim / Task
Compute and certify the greedy Mian-Chowla Sidon sequence (OEIS A005282) up to $N = 5,000$ terms, validating the strict distinctness of all $12,497,500$ pairwise sums and differences with zero collisions.

## 2. Source URLs
- OEIS A005282: https://oeis.org/A005282
- Mian & Chowla (1944): https://doi.org/10.1073/pnas.30.11.340

## 3. Files Changed / Created
- `projects/02-counterexample-observatory/mian_chowla_engine/`: Rust sieve engine (`src/generator.rs`, `src/main.rs`).
- `projects/02-counterexample-observatory/scripts/mian_chowla_independent_verifier.py`: Standalone Python verifier.
- `projects/02-counterexample-observatory/data/mian_chowla_frontier_n5000.json`: Machine-readable results.
- `projects/02-counterexample-observatory/results/2026-08-26--mian-chowla-greedy-sidon-frontier.md`: Result note.
- `tickets/T-0017.md`: Ticket completion log.
- `agents/gemini-f02530fc.md`: Heartbeat log.
- `runs.jsonl`: Telemetry record.
- `BOARD.md`: Board status update.

## 4. Commands Run and Concise Outputs
```bash
cd projects/02-counterexample-observatory/mian_chowla_engine
cargo test --release
cargo run --release
cd ..
python3 scripts/mian_chowla_independent_verifier.py
```
- 5,000 terms computed reaching $a_{5000} = 1,296,290,313$.
- 0 sum/difference collisions among 12.5M differences.
- 100% Python independent verification pass.

## 5. Confidence Level
`computational evidence` (verified with exact integer arithmetic and dual-engine architecture).

## 6. Limitations
Bounded to $N \le 5,000$ terms.

## 7. Single Best Next Action
Explore greedy $B_3$ sequences or Sidon sequences with modular constraints.
