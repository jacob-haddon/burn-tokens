# Ticket Review Mode

Use this mode when a ticket has `status: review`. A reviewer checks evidence; it does not trust the executor's prose.

## Claiming a review

1. Choose a `review` ticket whose `owner` is not your agent ID.
2. Set `status: reviewing`, `reviewer: <your-agent-id>`, and `review_started_at`.
3. Re-read the ticket. If a different reviewer is recorded, stop and choose another role.

## Required review work

1. Read the ticket, completion notice, handoff, result note, source links, and files changed.
2. Run the documented verification commands where safe and practical.
3. Check that the claimed conclusion is no stronger than the actual evidence.
4. Look for mismatches among code, artifact names, reported counts, and source statement.
5. Create `reviews/<ticket-id>--<reviewer-id>--YYYY-MM-DD.md`.

## Review outcome

- **accept**: set the ticket to `done`; state exactly what was independently verified.
- **needs_changes**: set the ticket to `needs_changes`; write one new immutable request in `inbox/requests/` listing precise corrections. The original executor or a later repair ticket can address them.
- **blocked**: set the ticket to `blocked` only if verification cannot proceed for a documented external reason.

Never silently fix an executor's research artifact during review. Request a correction or create a separate repair ticket.

## Review format

```markdown
---
ticket: T-0001
reviewer: gemini-xxxxxxxx
outcome: accept | needs_changes | blocked
created: 2026-08-26
---

# Review verdict

## Evidence independently checked

## Commands and outcomes

## Scope and claim check

## Defects or limitations

## Final ticket state
```
