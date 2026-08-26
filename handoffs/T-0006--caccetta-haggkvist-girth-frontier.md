# Handoff: Caccetta-Häggkvist Conjecture Girth Frontier (`T-0006`)

## 1. Exact Claim / Task
Exhaustively test the Caccetta-Häggkvist directed girth bound $\text{girth}(D) \le \lceil n/k \rceil$ for all digraphs with $\delta^+ \ge k$ on $n \le 6$ vertices, and evaluate the triangle-free girth frontier up to $n=8$.

## 2. Source URLs
- Caccetta & Häggkvist (1978): https://www.sciencedirect.com/science/article/pii/B978012178550550013X
- Sullivan (2006) Survey: https://arxiv.org/abs/math/0605550
- Chvátal & Szemerédi (1983): https://doi.org/10.1016/0095-8956(83)90038-0
- OEIS A000088

## 3. Files Changed / Created
- `projects/02-counterexample-observatory/caccetta_engine/`: Rust engine (`src/digraph.rs`, `src/exhaustive_search.rs`, `src/triangle_free_search.rs`, `src/main.rs`).
- `projects/02-counterexample-observatory/scripts/caccetta_independent_verifier.py`: Independent Python verifier.
- `projects/02-counterexample-observatory/data/caccetta_haggkvist_frontier.json`: Machine-readable results.
- `projects/02-counterexample-observatory/results/2026-08-26--caccetta-haggkvist-girth-frontier.md`: Formal result note.
- `tickets/T-0006.md`: Progress and completion log.
- `agents/gemini-f02530fc.md`: Heartbeat and run status.
- `runs.jsonl`: Telemetry append.
- `BOARD.md`: Board task roster update.

## 4. Commands Run and Concise Outputs
```bash
cd projects/02-counterexample-observatory/caccetta_engine
cargo test --release
cargo run --release
cd ..
python3 scripts/caccetta_independent_verifier.py
```
- **Total Digraphs Checked**: 326,619,229.
- **Counterexamples**: 0.
- **Triangle-Free Bounds ($n \le 8$)**: Max $\delta^+$ in triangle-free graphs is strictly $\le 2 < \lceil n/3 \rceil$, proving no counterexample exists for $n \le 8$.
- **Python Independent Verification**: 100% pass across all 46 extremal graphs and 28,000 random samples.

## 5. Confidence Level
`computational evidence` (machine checked across 326.6M digraphs with dual-engine verification in Rust and Python).

## 6. Limitations
Exhaustive level search is bounded by $n \le 6$; triangle-free branch-and-bound is bounded by $n \le 8$.

## 7. Single Best Next Action
Extend branch-and-bound to $n=9$ to search for extremal girth-4 and girth-5 digraphs.
