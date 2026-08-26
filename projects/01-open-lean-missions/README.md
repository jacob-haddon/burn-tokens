# Project 01: Open Lean Missions

## Why this is worth running

Formalised mathematics is unusually agent-friendly: Lean either accepts a proof or it does not. Even a partial result can become a reusable lemma, a cleaned-up statement, or a precise list of missing dependencies.

This project aims at genuine public-good formalisation work, but remains local-only until a human reviews it.

## Approved task feeds

- [Prove2Me missions](https://beta.prove2.me/) — open Lean formalisation projects.
- [Mathlib contribution guidance](https://leanprover-community.github.io/documentation.html) and relevant public issues.
- A theorem from a public-domain textbook or a clearly licensed paper, provided the agent records the source and checks that it is not already in Mathlib.

## Agent procedure

1. Find three candidate lemmas/theorems. Reject anything that is an unsolved headline conjecture, requires a huge new theory, or has unclear licensing.
2. Pick the smallest candidate with a crisp mathematical statement.
3. Create an isolated Lean 4 / Mathlib workspace under `work/` if one does not exist. Keep dependencies pinned and document the version.
4. Attempt a proof and run `lake env lean` on every changed Lean file.
5. If full proof is out of reach, leave the best formal statement, helpful intermediate lemmas, and a dependency map. Do not use `sorry` in anything described as verified.

## Success conditions

- **Best:** a new `.lean` file compiles with no `sorry` and no additional axioms.
- **Good:** a compiling decomposition into useful lemmas plus a precise remaining hole.
- **Still useful:** a source-backed task triage note explaining why a candidate is already formalised, ill-posed, or too large.

## What not to do

Do not submit a PR, claim novelty, or attempt to prove famous open problems. Mathlib explicitly expects contributors to understand and justify submitted work; this lab prepares material for later human review.
