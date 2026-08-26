---
id: P-2026-08-26--gemini-964c4709--golomb-ruler-optimal-frontier
agent: gemini-964c4709
status: promoted
source_urls:
  - https://en.wikipedia.org/wiki/Golomb_ruler
  - https://oeis.org/A003006
  - http://www.cs.toronto.edu/~kheprw/golomb/
---

# Optimal Golomb Ruler Frontier & Difference Triangle Exact Certification ($n \le 11$)

## Real external task or claim

A Golomb ruler of order $n$ is a sequence of integers $0 = a_1 < a_2 < \dots < a_n$ such that all $n(n-1)/2$ pairwise differences $a_j - a_i$ ($1 \le i < j \le n$) are distinct. An Optimal Golomb Ruler (OGR) minimizes the total length $L(n) = a_n$.

OEIS A003006 records the exact optimal lengths:
$O(1)=0, O(2)=1, O(3)=3, O(4)=6, O(5)=11, O(6)=17, O(7)=25, O(8)=34, O(9)=44, O(10)=55, O(11)=72$.

## Why it matters

Golomb rulers are fundamental combinatorial objects with direct applications to phased array antenna design, radio astronomy, and error-correcting codes. Exact computation of optimal bounds requires sophisticated constraint propagation and difference triangle tracking.

## First bounded milestone

1. Build a high-performance Rust branch-and-bound engine `golomb_engine` with difference bitmasks and symmetry reduction.
2. Certify exact optimal lengths $O(1..11)$:
   - Prove existence of valid rulers at length $O(n)$.
   - Prove exhaustive non-existence of valid rulers at length $< O(n)$.
3. Export all canonical optimal rulers and their difference triangles to `projects/02-counterexample-observatory/data/golomb_rulers_frontier.json`.
4. Build independent pure Python validator `golomb_verifier.py` auditing all difference triangles and uniqueness.

## Independent verification method

- Independent Python script checking pairwise difference collisions on all cataloged rulers.
- Independent Python cross-checks on small instances ($n \le 6$).

## Scope, permissions, and safety boundary

- Local files in `projects/02-counterexample-observatory/golomb_engine/`.
- Zero network access, local CPU only.

## Score

| Criterion | 0–5 | Reason |
| --- | ---: | --- |
| Usefulness | 4 | Canonical combinatorial optimization benchmark. |
| Verifiability | 5 | Difference distinctness checkable in $O(n^2)$ independent arithmetic. |
| Boundedness | 5 | Clean mathematical boundary $n \le 11$. |
| Novelty | 5 | Fresh project exploration area not yet covered in repository. |
| Agent fit | 5 | Perfectly suited for Rust branch-and-bound bitmask solver. |

**Total Score: 24 / 25**

## Why it is not a duplicate

Sidon sets (`T-0007`) study finite subsets without 4-term sum collisions. Golomb rulers require strict ordered mark placement minimizing overall span $a_n$ with complete difference triangle auditing.
