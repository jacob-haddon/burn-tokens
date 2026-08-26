# Autonomous Research Lab: Agent Coordination Protocol

This document defines the decentralized file-based coordination protocol for multiple agents working independently or across scheduled shifts in this repository.

---

## 1. Agent Identity & Registration

1. **Derive Stable ID**:
   - Format: `gemini-<first 8 characters of your Antigravity conversation ID>`
   - Example: `gemini-9dec4453`
   - If conversation ID is unavailable, generate a random 8-character lowercase hex string (e.g. `gemini-a1b2c3d4`).

2. **Register Profile**:
   - Create or update `agents/<your-id>.md`:
     ```markdown
     # Agent Profile: <your-id>

     - **Agent ID**: <your-id>
     - **Status**: active | idle | finished
     - **Registered At**: YYYY-MM-DD HH:MM:SS UTC
     - **Current Ticket**: tickets/T-XXXX.md (or none)
     - **Platform / Model**: Gemini / Antigravity
     ```

---

## 2. Ticket Lifecycle & Claiming Protocol

All tasks live as markdown files in `tickets/`.

### Ticket States
- `ready`: Available for any agent to claim.
- `in_progress`: Actively being worked on by the assigned `owner`.
- `review`: Finished attempt requiring human review or secondary replication.
- `reviewing`: A secondary agent is independently checking a `review` ticket.
- `needs_changes`: Review found specific, documented corrections required.
- `done`: Verified result produced and archived.
- `blocked` / `dead_end`: Infeasible, blocked on external deps, or disproved.

### Claiming Procedure (Optimistic Locking)
1. Scan `tickets/` for a file where `status: ready`.
2. Edit the ticket file:
   - Set `status: in_progress`
   - Set `owner: <your-id>`
   - Set `claimed_at: YYYY-MM-DDTHH:MM:SSZ`
3. **Re-read the ticket**:
   - Read the file content again.
   - If `owner` is NOT `<your-id>`, another agent claimed it concurrently. Yield immediately and select a different `ready` ticket.
4. Mark the ticket under "In Progress" in `BOARD.md`.

---

## 3. During Execution

- Work within the 2.5-hour budget / 3 major attempts limit.
- Run only local commands and tests.
- Maintain pinned toolchains (`~/.elan/bin/lean`, `.venv/bin/python`, etc.).

---

## 4. Completion & Handoff Protocol

When the run finishes (either successfully, partially, or as a dead end):

1. **Result Note**:
   - Write `projects/<project-id>/results/YYYY-MM-DD--<short-title>.md` adhering to `AGENTS.md`.

2. **Telemetry Log**:
   - Append a single JSON record to `runs.jsonl`.

3. **Detailed Handoff**:
   - Create `handoffs/<ticket-id>.md` explaining:
     - What exact hypothesis was tested.
     - What code was executed and exact outputs.
     - Known pitfalls, remaining gaps, and next suggested steps.

4. **Inbox Completion Notice**:
   - Create an immutable notice in `inbox/completed/<ticket-id>-notice.md` for the human:
     - 1-page executive summary of findings.
     - Confidence score (`machine-checked`, `computational evidence`, `source-checked`, `speculative`).
     - Links to code artifacts and verification commands.

5. **Update Ticket & Board**:
   - Update `tickets/<ticket-id>.md`: set `status: done` (or `review` / `blocked`).
   - Update `BOARD.md`: move ticket from *In Progress* to *Completed* or *Dead Ends*, and increment summary counters.
   - Update `agents/<your-id>.md`: set `status: idle` or `finished`.

---

## 5. Automatic Role Selection

An idle agent selects one role, in this order:

1. **Reviewer**: claim one `review` ticket according to `TICKET_REVIEW.md`.
2. **Executor**: claim one `ready` ticket according to the normal claim protocol.
3. **Task scout**: if neither exists, follow `TASK_DISCOVERY.md`.

An agent must never review a ticket it executed. Re-read a ticket immediately after claiming any role; if its owner or reviewer field changed, release it and choose another task.

---

## 6. Continuous Heartbeat Loop (Zero Manual Interventions)

Agents in this lab operate on an autonomous heartbeat cycle without requiring human prompts between steps:

1. **Self-Scheduled Sleep**: When awaiting reviewer response or when queues are briefly empty, agents set a 60–120s timer using the `schedule` tool or recurring cron.
2. **Reactive Wakeup**: On every tick, the agent re-reads the filesystem (`tickets/`, `inbox/requests/`, `BOARD.md`) to find active duties.
3. **Automatic Handoff to Next Ticket**: When an active ticket is finalized, the agent immediately claims the next `ready` ticket without halting.
4. **Time Gate**: Agents shut down only when the designated clock deadline is reached or platform quota is exhausted.
