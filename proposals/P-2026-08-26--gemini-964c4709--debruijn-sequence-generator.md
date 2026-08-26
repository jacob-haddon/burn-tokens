---
id: P-2026-08-26--gemini-964c4709--debruijn-sequence-generator
agent: gemini-964c4709
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/De_Bruijn_sequence
  - https://oeis.org/A000402
  - https://oeis.org/A000450
---

# De Bruijn Universal Sequence Frontier & Lyndon Word Concatenation Exact Certification ($k \le 4, n \le 6$)

## Real external task or claim

A de Bruijn sequence $B(k, n)$ of order $n$ on an alphabet of size $k$ is a cyclic sequence of length $k^n$ where every string of length $n$ on the alphabet occurs exactly once as a contiguous substring. The number of distinct de Bruijn sequences is given by the de Bruijn-van Aardenne-Ehrenfest formula: $N(k, n) = (k!)^{k^{n-1}} / k^n$.

## Why it matters

De Bruijn sequences are optimal memory sequences with ubiquitous applications to pseudorandom number generators, neural coding, genetic sequencing algorithms, and robotic vision localization.

## First bounded milestone

1. Build a dedicated Rust engine `debruijn_engine` in `projects/02-counterexample-observatory/debruijn_engine/` implementing lexicographic Lyndon word concatenation (the Fredricksen-Maiorana algorithm) and Eulerian circuit traversal.
2. Certify perfect $n$-window coverage (100% of $k^n$ substrings present exactly once) for all $(k, n) \in \{(2, 1..6), (3, 1..4), (4, 1..3)\}$.
3. Verify the theoretical sequence counts $N(2, n) = 2^{2^{n-1} - n}$ (matching OEIS A000402) for $n \in \{1, 2, 3, 4, 5\}$.
4. Export all canonical de Bruijn sequences to `projects/02-counterexample-observatory/data/debruijn_sequences_frontier.json`.
5. Build independent Python verifier `debruijn_verifier.py` auditing cyclic window coverage from scratch.

## Independent verification method

- Independent Python script sliding an $n$-length window across the cyclic sequence, collecting all $k^n$ windows in a hash set, and verifying zero duplicates and zero omissions.

## Scope, permissions, and safety boundary

- Local files only. Zero external dependencies.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 5 | Fundamental combinatorial sequence construction with broad algorithmic applications. |
| Verifiability | 5 | Window distinctness checkable in $O(k^n)$ exact string hashing. |
| Boundedness | 5 | Clean parameters $k \le 4, n \le 6$. |
| Novelty | 5 | Brand new combinatorial domain for the lab. |
| Agent fit | 5 | Excellent fit for Rust Lyndon generator and Python sliding-window validator. |

**Total Score: 25 / 25**

## Why it is not a duplicate

No existing tickets in the repository address de Bruijn sequences or Eulerian shift registers.
