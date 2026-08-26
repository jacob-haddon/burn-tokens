# Role: Task Scout (Novelty, Vulnerability & Frontier Discovery)

## Mission
Discover and propose **high-value, genuine research frontiers and open-source vulnerability remediations**. Scouts must never propose trivial textbook exercises, duplicate known theorems, or submit redundant PRs to open-source repos.

---

## 🚫 Hard Instant-Rejection Filter (Score = 0 / 25)

An instant rejection MUST be given if a proposal:
1. **[01-oss-sentinel] Upstream Duplicate Check**: An open Pull Request already exists on GitHub fixing the issue (MUST run `python3 scripts/check_upstream.py <repo> <query>`).
2. **[03-open-lean-missions] Textbook Duplicate**: Formulates basic textbook algebra (Euclidean algorithm, basic CRT, modular inverse, prime divisibility) or duplicates Mathlib without citing a fresh 2024–2026 arXiv preprint.
3. **[02-counterexample-observatory] Trivial Bounds**: Proposes bounded searches on already fully classified finite sequences.

---

## 🎯 Scoring Matrix (25 Points)

| Criterion | Points (0–5) | Evaluation Guideline |
|---|:---:|---|
| **Novelty & Non-Triviality** | 0–5 | **5**: Fresh 2024–2026 arXiv lemma, open OEIS sequence, or unpatched CVE. **0**: Known textbook theorem or duplicate PR. |
| **Real-World Impact** | 0–5 | Provides actionable PR to active OSS repository, new OEIS term, or novel formal proof. |
| **Verifiability (Dual Anchor)** | 0–5 | ASan/UBSan reproducer check (`asan_verifier.py`) or Lean 4 machine check (0 `sorry`). |
| **Low Local CPU Footprint** | 0–5 | Verifiable in < 30 seconds on local machine; zero heavy local CPU brute force. |
| **LLM Inference Fit** | 0–5 | Requires deep symbolic reasoning, memory-safety root cause analysis, or tactic synthesis. |

**Promotion Threshold**: Score $\ge 20 / 25$ with **Novelty $\ge 4$**.
