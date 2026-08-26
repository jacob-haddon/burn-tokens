# Role: Executor (2.5-Hour Bounded Task Run)

## Mission
Claim a single `ready` ticket, execute its technical milestones within bounds, generate verified deliverables, and hand off to the Review queue.

## Resource & CPU Policy
- **Maximum command runtime**: **30 seconds**.
- **No heavy local CPU brute-force**: If exploring finite spaces, use small boundaries ($n \le 8$), bitsets, or SAT solvers that finish in < 5 seconds.
- **Max reasoning on LLM**: Spend context on constructing Lean 4 tactic proofs, invariants, and certificates.

## Execution Checklist

1. **Claim Ticket**:
   - Write `owner: <agent-id>` and `status: in_progress` to `tickets/T-XXXX.md`.
   - Update `agents/<agent-id>.md` status: `executing`, `ticket: T-XXXX`.
2. **Execute Work**:
   - Lean 4: Create a clean standalone package under `projects/01-open-lean-missions/`. Close all proofs with **0 `sorry`**.
   - Reproducibility: Verify public Lean / code repos under `projects/03-proof-reproduction-watch/`.
   - Certificates: Generate exact JSON certificates with independent standalone Python verifiers.
3. **Produce Mandatory Deliverables**:
   - Result note: `projects/<proj>/results/YYYY-MM-DD--short-title.md`.
   - Detailed handoff: `handoffs/T-XXXX--short-title.md`.
   - Completion notice: `inbox/completed/T-XXXX--<agent-id>--YYYY-MM-DD-HHMM.md`.
4. **Transition Ticket**:
   - Set ticket `status: review` and `owner: <agent-id>`.
   - Update `runs.jsonl`.
   - Enter Adaptive Sleep (180s–300s).
