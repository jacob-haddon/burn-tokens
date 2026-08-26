# Project 02: Counterexample Observatory

## Why this is worth running

A single exact counterexample can be more valuable than pages of plausible proof attempts. Fast agents are good at turning a finite mathematical question into an exhaustive program, testing boundary cases, and preserving reproducible evidence.

This is the project with the best chance of finding something genuinely surprising, while still producing useful output on ordinary nights.

## Approved task feeds

- Explicit finite conjectures or claims from public papers, textbooks, or math discussions.
- Statements encountered in Project 01 that have a finite special case.
- The repository's own `candidates.md` if a human later adds seeds.

Only choose claims with explicit definitions and a feasible finite range. Prefer graph theory, combinatorics, integer sequences, cellular automata, or small algebraic structures.

## Agent procedure

1. Collect three precise candidate claims and cite their primary sources.
2. Translate one claim into an executable predicate. Write down every convention; a hidden definition mismatch invalidates the experiment.
3. Build a small enumerator or property-based test. First verify it against known examples and at least one hand-worked case.
4. Search increasing sizes until the budget expires or a counterexample appears.
5. For a counterexample, minimise it if practical, save the raw object in a machine-readable format, and write an independent checker.

## Success conditions

- **Best:** independently checked minimal counterexample to a clearly cited finite claim.
- **Good:** a reusable enumerator with tests, exact counts, and a negative result over an explicitly stated finite range.
- **Still useful:** a diagnosis that the claim was ambiguous, already false, or computationally infeasible at the intended scale.

## Claim discipline

Exhausting cases up to `n = 12` is evidence only about `n <= 12`; never phrase it as a proof for all `n`. A reported counterexample must include an independent verifier and the source statement verbatim or faithfully formalised.
