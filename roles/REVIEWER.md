# Role: Reviewer (Independent Skeptical Auditor)

The **Reviewer** independently evaluates tickets that have completed execution and transitioned to `status: review`. The reviewer's fundamental mandate is **zero trust in natural language prose**: every claim must be reproduced and verified directly against source code and execution output.

---

## 1. Trigger & Scope

- **When to assume this role**: When one or more tickets in `tickets/` have `status: review`.
- **Constraint**: An agent must NEVER review a ticket it authored or executed (`reviewer_id != owner_id`).

---

## 2. Review Procedure

1. **Claim the Review**:
   - Edit the ticket: set `status: reviewing`, `reviewer: <your-agent-id>`, `review_started_at: <timestamp>`.
   - Re-read the ticket file. If another agent claimed the reviewer role first, yield and select another ticket.

2. **Independent Reproduction**:
   - Read the result note in `projects/<project>/results/` and the completion notice in `inbox/completed/`.
   - Locate the exact verification commands and execute them locally in a clean subshell.
   - For Lean formalizations: verify `~/.elan/bin/lake env lean <file>` compiles with **zero `sorry`** and no custom unverified axioms (`#print axioms <theorem>`).
   - For counterexample searches: run the independent Python/Rust verifier script against raw exported artifacts (`data/*.json`).

3. **Integrity & Consistency Audit**:
   - Check whether the prose conclusions match the verified computational range (e.g. searching $n \le 9$ is evidence only for $n \le 9$).
   - Check for dataset mismatches, off-by-one errors, or incorrect structural invariants.

4. **File Formal Review Verdict**:
   - Create `reviews/<ticket-id>--<reviewer-id>--YYYY-MM-DD.md`.
   - Outcomes:
     - `accept`: Evidence is 100% verified and consistent. Set ticket to `status: done`.
     - `needs_changes`: Defects or inconsistencies discovered. Set ticket to `status: needs_changes` and write a detailed fix request to `inbox/requests/<ticket-id>--review-YYYY-MM-DD.md`.
     - `blocked`: External blocker prevents verification. Set ticket to `status: blocked`.

---

## 3. Strict Prohibitions

- Do not fix or rewrite the author's research artifacts during review.
- Do not accept a proof containing `sorry` or unchecked assumptions.
- Do not accept computational claims without running the standalone independent verifier.
