# Beyond Lean: domains suitable for unattended agents

## Selection rule

Avoid tasks where success means "the code looks good." Prefer a result that can be checked independently by a small trusted tool, an exhaustive computation, a fixed dataset, or primary sources.

## Strong candidates

| Domain | What an agent does overnight | What checks the result | Useful artifact even on failure |
| --- | --- | --- | --- |
| Other proof assistants | Formalises a theorem in Rocq/Coq, Isabelle, Metamath, Agda, or HOL | The proof assistant kernel | A precise statement and dependency map |
| SAT / SMT / QBF certificates | Encodes a finite claim, solves it, and emits a proof certificate | Independent certificate checker | A benchmark instance and verified finite result |
| Combinatorial search | Searches graphs, codes, designs, tilings, automata, or integer sequences | Exhaustive enumerator plus independent verifier | Exact data, counts, bounds, or a counterexample |
| Model checking | Checks a finite-state protocol or game rule for safety/liveness properties | Model checker plus trace replay | Minimal failing trace or verified invariant |
| Symbolic algebra | Searches identities, recurrences, factorizations, or exact special cases | Computer-algebra verification and substitution tests | Candidate identity with an exact validation log |
| Reproducibility audits | Re-runs a published computational result or formal proof package | Pinned environment, tests, hashes, and source comparison | A replication report or a minimised failure |
| Data provenance and citation maps | Builds a structured, source-linked map of claims in a narrow topic | Primary-source quotations, identifiers, and consistency checks | An auditable mini-database, including disagreements |
| Historical / linguistic corpus work | Transcribes, aligns, annotates, or compares public-domain material | Double-entry comparison, dictionaries, and source scans | Searchable corpus and uncertainty annotations |

## The three best non-Lean directions

### 1. Certificate-first combinatorics

Ask the agent to find a clear finite conjecture, write a search, and preserve both a witness and a standalone verifier. Examples include a smallest graph with a property, a covering design, a colouring, a tiling, or a counterexample to a finite claim.

Why it is good:

- a fast model can make real progress by experimenting;
- output is deterministic and inspectable;
- a counterexample is a genuine result, while a failed search still gives a rigorous finite bound;
- it does not depend on trusting the agent's prose or its software-design taste.

This is Project 02 in this repository.

### 2. SAT/SMT proof-certificate work

Many finite questions can be reduced to Boolean satisfiability or satisfiability modulo theories. The solver itself can be untrusted if it emits a certificate that a separate checker accepts. Modern SAT competitions explicitly require proof certificates for UNSAT claims in their main track.

Useful agent missions:

- translate a small combinatorial question into SAT;
- generate new, well-documented benchmark instances;
- shrink a hard instance while preserving its property;
- compare two encodings and prove their equivalence on a finite domain;
- independently check a public solver claim.

This is not ordinary application programming: the program is disposable scaffolding around a checkable certificate.

Sources: [SAT Competition 2026](https://github.com/satcompetition/2026), [certificate requirements](https://satcompetition.github.io/2026/output.html).

### 3. Reproduction and adversarial verification

An agent can act as a skeptical lab assistant: reproduce a narrow public computation, compile a formal artifact from scratch, compare its formal claim with the prose claim, then run a small independent sanity check. This scales to agent-generated mathematics, scientific code, economic simulations, and data analysis.

The result is valuable precisely because the agent is not asked to be brilliant. It is asked to be systematic, record versions, and expose mismatches.

This is Project 03 in this repository.

## Interesting but weaker-certainty domains

### Scientific literature synthesis with a source graph

Pick a very narrow question, collect only primary papers/datasets, extract claims into a table, and force the agent to label each as `directly supported`, `inferred`, `contradicted`, or `unresolved`. This makes useful research dossiers, but it is not a mathematical proof.

### Digital humanities and language documentation

For public-domain scans or openly licensed corpora, agents can produce transcriptions, align translations, identify variants, and build searchable metadata. The right validation is redundancy: two independent passes, source-image links, uncertainty labels, and spot checks.

### Finite protocol and rule-system audits

Model a voting rule, auction, board game, smart-contract state machine, or access-control policy as a finite transition system. Then use a model checker to seek a violating trace. The model is small and verifiable even if no production code is trusted.

## Separate route: donating hardware, not quota

If the spare resource is an idle CPU/GPU rather than agent allowance, volunteer computing is already mature: BOINC distributes scientific jobs to background computers across dozens of projects. It is the closest real implementation of the old torrent analogy, but it does not consume Gemini/Antigravity credits.

Source: [BOINC](https://boinc.ssl.berkeley.edu/).

## What to avoid for unsupervised runs

- production application code;
- security-sensitive code or exploit research;
- medical, legal, or financial conclusions;
- web scraping that may violate site terms or overload services;
- any task requiring an agent to publish, spend money, create accounts, or contact people;
- broad "solve this famous open problem" prompts.

## A good meta-prompt

```text
Choose a task that produces an independently checkable artifact, not merely plausible prose.
Rank candidates by: public usefulness, feasibility within two hours, strength of verification,
and novelty of the resulting artifact. Select one. If it does not finish, preserve a minimal
reproduction, exact negative result, or dependency map rather than extending the loop.
```
