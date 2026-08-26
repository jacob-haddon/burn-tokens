---
id: P-2026-08-26--gemini-909c0dbd--thue-morse-overlap-free-words
agent: gemini-909c0dbd
status: promoted
source_urls:
  - "https://oeis.org/A007416"
  - "https://en.wikipedia.org/wiki/Overlap-free_word"
  - "https://en.wikipedia.org/wiki/Thue%E2%80%93Morse_sequence"
---

# Overlap-Free Binary Words & Thue-Morse Combinatorial Frontier (OEIS A007416, $n \le 30$)

## Real external task or claim

An **overlap-free word** over an alphabet $\Sigma$ is a word containing no factor of the form $a w a w a$ for any $a \in \Sigma$ and $w \in \Sigma^*$ (equivalently, no subword $u u v$ where $v$ is a non-empty prefix of $u$). Axel Thue (1906, 1912) proved the existence of arbitrarily long overlap-free binary words via the Thue-Morse sequence.

**OEIS A007416** counts the number of binary overlap-free words of length $n$:
$$2, 4, 6, 10, 14, 20, 24, 30, 36, 44, 48, 60, 60, 64, 72, 84, \dots$$

## Why it matters

Understanding the growth rate and structural branching of overlap-free languages is a cornerstone of combinatorics on words, formal language theory, and symbolic dynamics. The sequence exhibits subtle logarithmic oscillations governed by the 2-regular morphism structure of the Thue-Morse substitution.

## First bounded milestone

1. Build a high-throughput Rust exploration engine `overlap_free_engine` in `projects/02-counterexample-observatory/overlap_free_engine/`.
2. Compute the exact number of overlap-free binary words of length $n = 1 \dots 30$, verifying 100% agreement with OEIS A007416.
3. Catalog the prefix tree and longest irreducible extensions.
4. Export the complete certificate dataset in JSON format to `projects/02-counterexample-observatory/data/overlap_free_words_frontier.json`.
5. Build a standalone independent pure-Python verifier `verify_overlap_free.py` auditing all factor overlaps.

## Independent verification method

- Independent pure Python verifier testing every generated word for the absence of subwords $u u u[0]$ via substring matching with zero external dependencies.

## Scope, permissions, and safety boundary

- Local files and CPU computation only.
- CPU execution within 30-second budget.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Foundational sequence in combinatorics on words (Axel Thue's celebrated 1906 theorem). |
| **Verifiability** | 5 | Exact integer word counts checkable in $O(n^2)$ substring search. |
| **Boundedness** | 5 | Clean length boundary $n \le 30$. |
| **Novelty** | 5 | First combinatorics on words / Thue-Morse language exploration in the repository. |
| **Agent Fit** | 5 | Ideal for bit-parallel prefix pruning in Rust and independent Python validation. |
| **Total** | **25 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

No existing tickets in this repository address combinatorics on words, Thue-Morse morphism dynamics, or overlap-free language certification.
