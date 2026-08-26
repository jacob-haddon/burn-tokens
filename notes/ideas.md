# Burn Tokens: autonomous work worth coming back to

## The actual goal

Do not spend agent quota for its own sake. Build a setup where an agent can work unattended for a few hours and leave behind a surprising but inspectable artifact: a formal proof, a research map, a small tool, a dataset, a visualisation, or a well-supported negative result.

The useful model is not *"give the agent another task"*. It is a standing instruction:

> Find the next worthwhile item from an approved task feed, work on it within a fixed budget, verify it, and write a short hand-off for the human.

## There is no perfect torrent-for-agent-quota yet

The closest things today are fragmented by domain:

| Route | What agents can contribute | Caveat |
| --- | --- | --- |
| Lean / formal mathematics | Formalise theorems, repair proofs, explore conjectures | Verification is objective, but setup can be demanding. |
| Open-source | Fix documentation, tests, bugs, accessibility, developer tooling | Never publish or push automatically. |
| Open research platforms | Analyse evidence, propose/review proof routes, reproduce a result | Treat unreviewed claims as leads, not facts. |
| Task marketplaces | Do bounded research, data, docs, or automation work for someone | Usually needs an account, a contract, and human approval. |

For unused **Gemini / Antigravity quota**, the first three are practical. Account quotas are not a general-purpose pool of compute that can currently be donated to a network in the way idle GPU hardware can.

## The Liberman brothers: yes, but it is a different layer

David and Daniil Liberman's project is **Gonka**. It is a decentralised AI-compute network: GPU hosts supply hardware, serve model inference/training workloads, and earn its GNK token. That is genuinely close to the old torrent/mining intuition — spare hardware performs useful AI work — but it does **not** consume or distribute a person's Gemini-agent allowance.

It may be interesting if the resource you want to contribute is an idle GPU. It is not the direct answer for spare Antigravity limits.

Sources: [Gonka FAQ](https://gonka.ai/docs/FAQ/), [Gonka codebase](https://github.com/gonka-ai/gonka).

## Best direction: a small autonomous research lab

Create one repository that an agent revisits. It has a `QUEUE.md`, a strict budget, and an append-only `results/` folder. The agent chooses work itself from a few feeds, but it must leave evidence and never silently invent a success.

### Good task feeds

1. **Lean community / Mathlib backlog.** Formalise an accessible theorem, fill a missing lemma, improve a proof, or write a verified example. The output either compiles or it does not.
2. **MoltArxiv.** An agent-oriented mathematics-research platform where submissions include Lean 4 artifacts; useful as a source of narrow formalisation and review tasks.
3. **ProofAtlas and TheoremDB.** New public workspaces for machine-mathematics records, conjectures, proof packages, counterexamples, and research routes. Use them as a reading/triage feed; independently verify every claim.
4. **A personal curiosity feed.** A text file of topics you like: obscure games, cryptography, graph theory, languages, city history, visual patterns, economic mechanisms, etc. The agent can select one and make a mini research dossier.

Sources: [Lean community](https://leanprover-community.github.io/), [MoltArxiv](https://github.com/MoltArxiv/MoltArxiv), [ProofAtlas](https://www.proofatlas.ai/), [TheoremDB](https://theoremdb.org/).

## Overnight steward prompt

Use this as the project-level instruction or as a scheduled recurring task. It gives the agent agency without giving it unlimited authority.

```text
You are the overnight research steward for this repository.

Your job is to choose one small, high-signal item from the approved feeds in QUEUE.md,
or one clearly bounded improvement to an existing artifact. Do not ask the user to choose
unless every candidate is unsafe, paid, ambiguous, or requires credentials.

Budget: at most 3 hours and 3 substantial attempts. Prefer an artifact that can be checked
locally: a Lean proof, reproducible program, tested dataset transformation, or cited research note.

Rules:
- Never spend money, create accounts, contact people, publish, push, or change files outside this repo.
- Do not claim a theorem, experiment, or fact is established unless the checker or primary source supports it.
- Keep the change small and reversible.
- If stuck, turn the failure into a useful map of what was tried and what would unblock it.

Before stopping, create results/YYYY-MM-DD-short-title.md containing:
1. the question and why it was chosen;
2. sources or task link;
3. result, with confidence level;
4. verification commands and their output summary;
5. files changed;
6. the single best next step.

Then update QUEUE.md: mark the item done, blocked, or split it into smaller follow-ups.
```

## A more playful version

Make an "agent archaeology" lab: each run picks a niche from a curated list and must return one of:

- a map of an obscure intellectual lineage;
- a tiny interactive explainer or simulation;
- a formalised toy theorem or verified algorithm;
- a collection of primary sources with contradictions called out;
- a counterexample to a tempting claim;
- a "strange but true" note with reproducible code.

The trick is to curate **what kinds of surprises are welcome**, rather than to pre-write every task.

## Guardrails

- Use a disposable repository and a separate branch/worktree per run.
- Cap iterations and wall-clock time. Autonomous loops otherwise tend to burn quota while retrying the same dead end.
- Require a result note every run, including failed runs.
- Review before sharing results. A compiling Lean proof is strong evidence; a fluent prose proof is not.
- Start with one agent, then add independent reviewer/replicator agents only after the workflow produces useful artifacts.

## Immediate next experiment

Set up a `lean-night-shift` repository with the steward prompt, a 15-item source queue, and a scheduled nightly run. For the first week, accept only artifacts that compile or have primary-source citations. At the end of the week, keep the one direction that you were genuinely curious to open each morning.
