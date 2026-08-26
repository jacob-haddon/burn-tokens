# Beyond mathematics: useful unattended-agent work

## Honest ranking of the current projects

The famous-conjecture cards are **real**, but their expected value differs:

| Project type | Chance of a dramatic discovery | Expected ordinary output | Practical usefulness |
| --- | --- | --- | --- |
| Famous open-conjecture search | Very low | Search infrastructure and finite evidence | Medium; excellent as a hobby lab |
| Fresh-claim stress testing | Moderate | A minimal counterexample, correction, or precise covered range | High |
| Formal proof reproduction | Moderate | Compiling artifact or a reproducible failure | High |
| Open-data validation | Moderate | A curated issue list with evidence | High after human review |

The best sleep-on-it projects are those where an ordinary run is already useful. Do not measure success only by “solved an open problem.”

## Strong non-maths directions

### 1. Protocol model checking

Model a finite-state system — a voting rule, auction, turn-based game, rate limiter, queue, sync protocol, or access-control policy — in TLA+ / PlusCal. Ask the agent to search for a violation of a stated invariant: lost item, double spend, deadlock, unfair outcome, or privilege escalation. A model checker returns a replayable trace.

This is not production programming. The deliverable is a small mathematical model and a counterexample trace, both reviewable by a human.

Source: [TLA+ and TLC](https://docs.tlapl.us/).

### 2. Computational-reproducibility audits

Pick an open paper with code and data. The agent attempts a clean-room rerun, pins the environment, checks whether the advertised figure/table appears, and records every discrepancy. The result can be: reproduced, partially reproduced, or a minimal failure recipe.

This has real value across science because computational supplements often lack sufficient environment documentation.

Source: [computational reproducibility research](https://arxiv.org/abs/2505.21590).

### 3. Public-data quality watchdog

Create *suggestions*, never automatic edits, for a bounded public dataset: duplicate entities, impossible dates, contradictory identifiers, broken references, missing provenance, or inconsistent taxonomy. Every flagged item must have source URLs and a deterministic validation rule.

Good candidates: a narrow Wikidata topic, local OpenStreetMap data, museum collections, public bibliographic metadata, or government open data.

For OpenStreetMap in particular, treat the agent as a first-pass finder only: community workflows expect independent validation before data is accepted.

Source: [OpenStreetMap validation workflow](https://wiki.openstreetmap.org/wiki/OSM_Tasking_Manager/Validating_data).

### 4. Digital preservation and source alignment

Work only with public-domain or openly licensed material. The agent can transcribe scans, align two editions or translations, extract structured metadata, and flag uncertain readings. Require source-image references and a second independent pass for every final transcription.

The morning artifact is a searchable mini-corpus, not a claim that the transcription is perfect.

### 5. Citizen-science data analysis, not automatic classification

Platforms such as Zooniverse contribute real research data, but unattended agents should **not** submit classifications as if they were people. A safer project is analysing already-open aggregate/export data: disagreement patterns, unclear instructions, unusual examples, or quality-control reports for human project teams.

Source: [Zooniverse data exports](https://help.zooniverse.org/next-steps/data-exports/).

### 6. Formal policy and ruleset audits

Turn an explicit rulebook into executable checks: board-game rules, grant eligibility criteria, election rules, platform moderation policies, or organisational approval flows. Then search for contradictory rules, unreachable states, unfair tie-breaks, or loopholes. Keep it in a toy/public setting; do not use it to make high-stakes decisions.

## Good “agent chooses itself” feeds

- open papers with code/data and a clear claimed figure or table;
- new public formal-proof packages;
- open datasets with documented schemas and validation constraints;
- public-domain archives with scan images;
- finite rulebooks or protocol specifications.

The agent should choose only items that have: a stable source, explicit licence/permission, bounded scope, and an independent validation method.

## Avoid unattended automation in these areas

- medical, legal, financial, or safety-critical conclusions;
- security scanning or vulnerability disclosure;
- automatic edits to public knowledge bases or maps;
- scraping services that do not explicitly permit it;
- scientific claims that need wet-lab validation.
