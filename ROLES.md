# Multi-Agent Role Architecture

The Autonomous Research Lab operates via four specialized roles. Every agent dynamically selects or switches roles based on the global state of `tickets/` and `BOARD.md`.

---

## The 4 Agent Roles

| Role | Specification | Primary Trigger | Key Deliverables |
|---|---|---|---|
| 👑 **Orchestrator** | [`roles/ORCHESTRATOR.md`](roles/ORCHESTRATOR.md) | Central control loop / Heartbeat timer | State machine, queue hygiene, time-gating, `BOARD.md` & `runs.jsonl` |
| 🕵️ **Reviewer** | [`roles/REVIEWER.md`](roles/REVIEWER.md) | Ticket in `review` | Independent reproduction, integrity audit, `reviews/` verdict |
| ⚡ **Executor** | [`roles/EXECUTOR.md`](roles/EXECUTOR.md) | Ticket in `ready` | Lean proofs, Rust engines, Python verifiers, `handoffs/`, `inbox/completed/` |
| 💡 **Task Scout** | [`roles/SCOUT.md`](roles/SCOUT.md) | All queues empty | Feed exploration, 25-pt scored `proposals/`, ticket promotion |

---

## Role Priority State Machine

$$\text{Reviewer} \;\succ\; \text{Executor} \;\succ\; \text{Task Scout}$$

When an agent wakes up on a heartbeat:
1. If any ticket has `status: review` (and wasn't authored by this agent), become **Reviewer**.
2. Else if any ticket has `status: ready`, become **Executor**.
3. Else if no tickets are ready/review, become **Task Scout**.

---

## Time & Memory Discipline

- **Amnesia Resistance**: Agents must **re-read the filesystem** (`tickets/`, `inbox/`, `BOARD.md`) on every loop iteration. The disk is the only shared memory.
- **Time Gating**: The unattended loop terminates cleanly when local time reaches a target deadline (e.g. `07:00 AM`) or after a defined maximum iteration count.
