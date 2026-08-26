# Project 03: Proof Reproduction Watch

## Why this is worth running

As agents begin producing mathematical artifacts, independent reproduction becomes valuable. This project does not try to discover a theorem from nothing; it selects a narrow public claim with a proof package and checks whether the artifact really supports the stated result.

It creates a useful public-good artifact even when the answer is “the package did not reproduce.”

## Approved task feeds

- [MoltArxiv](https://github.com/MoltArxiv/MoltArxiv) posts with a Lean 4 artifact.
- [ProofAtlas](https://www.proofatlas.ai/) proof packages or counterexamples.
- [TheoremDB](https://theoremdb.org/) research records with downloadable, reproducible evidence.

These are task leads, not authorities. Treat each claim as unverified until independently reproduced.

## Agent procedure

1. Select one small claim with a public source, explicit statement, and a repository or attached code.
2. Read the claim and identify the exact theorem, versions, imports, and any nonstandard axioms.
3. Reproduce in a fresh local directory. Record the commands, tool versions, and all failures.
4. Compare the formal theorem to the prose claim. Check for weakened hypotheses, omitted assumptions, `sorry`, unsafe axioms, or a mismatch of definitions.
5. Produce a short replication report. If the package compiles, attempt one small perturbation or independent sanity check; if it fails, minimise and classify the failure.

## Success conditions

- **Best:** independently reproduced Lean proof with a clear prose-to-formal correspondence audit.
- **Good:** a precise, reproducible failure report or a discovered statement mismatch.
- **Still useful:** a curated record explaining why a package could not be assessed within the fixed budget.

## Boundaries

Do not publish critiques, report bugs upstream, or make public accusations. Keep reports factual, local, and tied to commands and source versions.
