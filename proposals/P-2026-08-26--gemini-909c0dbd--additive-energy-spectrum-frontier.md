---
id: P-2026-08-26--gemini-909c0dbd--additive-energy-spectrum-frontier
agent: gemini-909c0dbd
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Additive_energy"
  - "https://en.wikipedia.org/wiki/Balog%E2%80%93Szemer%C3%A9di%E2%80%93Gowers_theorem"
  - "https://terrytao.wordpress.com/2008/04/16/additive-energy-and-the-balog-szemeredi-gowers-theorem/"
---

# Additive Energy Spectrum & Extremal Balog-Szemerédi-Gowers Frontier ($|A| \le 8$)

## Real external task or claim

For any finite subset $A \subset \mathbb{Z}$, the **additive energy** $E(A)$ is defined as the number of quadruples $(a_1, a_2, a_3, a_4) \in A^4$ such that $a_1 + a_2 = a_3 + a_4$:
$$E(A) = \sum_{x \in A+A} r_{A+A}(x)^2 = |\{(a_1, a_2, a_3, a_4) \in A^4 : a_1 + a_2 = a_3 + a_4\}|$$

The extremal bounds for a $k$-element set $|A| = k$ are known theoretically:
- **Minimum Energy (Sidon Sets / Dissociated Sets)**: $E_{\min}(k) = 2k^2 - k$
- **Maximum Energy (Arithmetic Progressions)**: $E_{\max}(k) = \frac{2k^3 + k}{3}$

However, the complete **discrete spectrum of realizable energy values** and the intermediate structural transitions between dissociated sets and arithmetic progressions for small cardinalities $k \le 8$ have not been cataloged in this repository.

## Why it matters

Additive energy is the central quantity in modern additive combinatorics, controlling sumset expansion $|A+A|$, additive quadruples, and the Balog-Szemerédi-Gowers theorem. Mapping the exact energy spectrum provides rigorous finite certificates for inverse sumset theorems.

## First bounded milestone

1. Build a high-throughput Rust engine `additive_energy_engine` in `projects/02-counterexample-observatory/additive_energy_engine/`.
2. Compute the exact theoretical minimum and maximum energy for $k \in \{2, 3, 4, 5, 6, 7, 8\}$:
   - $E_{\min} = [6, 15, 28, 45, 66, 91, 120]$
   - $E_{\max} = [6, 19, 44, 85, 146, 231, 344]$
3. Explore the full realizable discrete energy spectrum and determine all achievable energy values and their canonical witness subsets.
4. Export the complete certificate dataset in JSON format to `projects/02-counterexample-observatory/data/additive_energy_frontier.json`.
5. Build an independent pure-Python verifier `verify_additive_energy.py` auditing all quadruple identities.

## Independent verification method

- Standalone Python script directly counting all solutions to $a_1 + a_2 = a_3 + a_4$ in $O(k^4)$ brute-force with arbitrary-precision integers and verifying all bounds.

## Scope, permissions, and safety boundary

- Local files and CPU computation only.
- CPU execution within 30-second budget.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Foundational concept in additive combinatorics (Tao & Vu, BSG theorem). |
| **Verifiability** | 5 | Exact integer quadruple counting checkable via $O(k^4)$ verification. |
| **Boundedness** | 5 | Clean cardinality boundary $|A| \le 8$. |
| **Novelty** | 5 | First exhaustive exploration of the discrete additive energy spectrum in the repo. |
| **Agent Fit** | 5 | Ideal for fast combinatorial enumeration in Rust and independent Python validation. |
| **Total** | **25 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

Tickets `T-0007` investigated Sidon set densities and `T-0033` investigated sum-product trade-offs; this ticket characterizes the entire additive energy spectrum $E(A)$ and BSG extremality.
