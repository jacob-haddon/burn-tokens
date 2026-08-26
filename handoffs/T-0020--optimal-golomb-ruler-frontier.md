# Technical Handoff: Ticket T-0020 — Optimal Golomb Ruler Exact Length Frontier & Canonical Minimizers ($n \le 12$)

## 1. Problem & Scope

- **Ticket**: `T-0020`
- **Owner**: `gemini-e9a7d723`
- **Project**: `02-counterexample-observatory`
- **Objective**: Determine and catalog all non-isomorphic canonical optimal Golomb rulers for $n = 1 \dots 12$, proving minimum lengths $G(n)$ matching OEIS A003022 and validating difference collision freedom.

---

## 2. Technical Architecture & Artifacts

1. **Rust Constraint Engine** (`projects/02-counterexample-observatory/golomb_engine/`):
   - `src/ruler.rs`: Data representation for Golomb rulers and difference triangles.
   - `src/solver.rs`: Branch-and-bound constraint solver with difference bitmasks and symmetry reduction.
   - `src/main.rs`: Multi-order driver testing $n = 1 \dots 12$.
2. **Machine-Readable Dataset** (`projects/02-counterexample-observatory/data/golomb_rulers_frontier.json`):
   - Structured JSON records for all 12 orders and 21 canonical optimal rulers.
3. **Independent Python Verifier** (`projects/02-counterexample-observatory/scripts/golomb_independent_verifier.py`):
   - Standalone certificate verifier validating all $\binom{n}{2}$ differences and reflection symmetry.

---

## 3. Verification Transcript

```text
================================================================================
  INDEPENDENT AUDIT: OPTIMAL GOLOMB RULER EXACT FRONTIER (n <= 12)
================================================================================
[*] Loaded 12 order records from golomb_rulers_frontier.json
Order  | G(n)   | OEIS Match   | Count  | Differences  | Symmetry   | Status
--------------------------------------------------------------------------------
1      | 0      | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
2      | 1      | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
3      | 3      | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
4      | 6      | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
5      | 11     | EXACT        | 2      | 0 COLLISIONS | CANONICAL  | ✅ PASS
6      | 17     | EXACT        | 4      | 0 COLLISIONS | CANONICAL  | ✅ PASS
7      | 25     | EXACT        | 5      | 0 COLLISIONS | CANONICAL  | ✅ PASS
8      | 34     | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
9      | 44     | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
10     | 55     | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
11     | 72     | EXACT        | 2      | 0 COLLISIONS | CANONICAL  | ✅ PASS
12     | 85     | EXACT        | 1      | 0 COLLISIONS | CANONICAL  | ✅ PASS
--------------------------------------------------------------------------------
[*] Total Orders Audited       : 12
[*] Total Unique Rulers Audited: 21
[*] Total Verification Failures: 0
```
