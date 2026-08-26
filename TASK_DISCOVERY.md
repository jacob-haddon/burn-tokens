# Task Discovery Mode

Use this mode only when no ticket is `ready` or `review`. Its purpose is to keep the lab supplied with good work, not to generate an unbounded backlog.

## What to look for

- formal-methods / proof-assistant backlogs;
- open papers with code and data and one reproducible claim;
- public datasets with clear validation constraints;
- public-domain or openly licensed archives;
- finite conjectures, benchmark suites, and public proof packages;
- follow-ups suggested by existing handoffs or review requests.

## Discovery procedure

1. Read the board, all tickets, recent handoffs, review requests, and existing proposals.
2. Find three candidates from allowed sources. Reject anything requiring accounts, payment, publication, contact, private data, unsafe scanning, or high-stakes decisions.
3. Create one proposal per candidate in `proposals/` and score it 0–5 for usefulness, verifiability, boundedness, novelty, and agent fit.
4. Promote **at most one** proposal into a new `ready` ticket, and only when it scores at least 18/25 with a direct source URL and an independent verification method.
5. The scout may not immediately claim its newly created ticket unless it records that no other agents are available.

## Proposal template

`proposals/P-YYYY-MM-DD--agent-id--short-title.md`:

```markdown
---
id: P-YYYY-MM-DD-agent-id-short-title
agent: gemini-xxxxxxxx
status: proposed | promoted | rejected
source_urls: []
---

# Title

## Real external task or claim
## Why it matters
## First bounded milestone
## Independent verification method
## Scope, permissions, and safety boundary
## Score
| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | | |
| Verifiability | | |
| Boundedness | | |
| Novelty | | |
| Agent fit | | |
## Why it is not a duplicate
```

## Never propose

- “solve a famous open problem”;
- “build an app”;
- vague research topics without a checkable output;
- a variant of active work without a clear new acceptance criterion.
