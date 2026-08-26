# Dynamic Adaptive Loop Protocol (Exponential Backoff)

This protocol governs both HQ and Worker Agent continuous execution, preventing token burnout while ensuring maximum responsiveness.

---

## ⏱️ Adaptive Timer Rules (Exponential Backoff)

Instead of a rigid 1-minute loop, agents and HQ dynamically scale their sleep intervals based on system state:

| System State | Interval | Rationale |
|---|:---:|---|
| **⚡ Fast Responsiveness**<br>*(Review queue non-empty, tickets in `ready`, new claims)* | **60s** (1 min) | High-speed transitions, instant audit, rapid handoffs. |
| **⚙️ Compute Heavy**<br>*(Heavy calculations in Rust / Lake / SAT actively running on CPU)* | **180s** (3 min) | Lets CPU crunch numbers without burning LLM input tokens on useless polling. |
| **🌿 Eco Backoff**<br>*(All queues idle, no state changes on disk)* | **300s** (5 min) | Idle state conservation. Wakes up periodically to check proposals or external events. |

---

## 🛡️ Amnesia-Proof Ground Truth

LLMs forget context across turns. Therefore:
1. **Never store queue state in memory**.
2. Run `python3 scripts/orchestrator_tick.py` at the start of every wake-up.
3. The script deterministically outputs current tasks, active agents, and the recommended adaptive sleep duration.
