---
id: P-2026-08-30--gemini-scout--uthash-utarray-reserve-overflow
agent: gemini-scout
status: promoted
source_urls:
  - "https://github.com/troydhanson/uthash"
title: "Discovery & Remediation of Unsigned Integer Overflow & Infinite Loop in utarray_reserve (troydhanson/uthash)"
novelty_score: 5
mathlib_status: "N/A (Open-Source Security)"
created_at: 2026-08-30T14:10:00+02:00
---

# Proposal: Autonomous Discovery & Defensive Remediation for troydhanson/uthash utarray_reserve Unsigned Integer Overflow & Infinite Loop

## 1. Discovery & Target
- **Target**: `troydhanson/uthash` (`src/utarray.h`)
- **Discovery Method**: Autonomous Source Code Invariant Audit (`01-oss-sentinel` 2.0) on remote worker `omarchy-1`.
- **Vulnerability**: In `utarray_reserve()`, when doubling capacity `(a)->n = ((a)->n ? (2*(a)->n) : 8)`, when `(a)->n >= 0x80000000`, `2 * (a)->n` overflows `unsigned` to `0`. In the next loop iteration, `(a)->n ? 2*(a)->n : 8` resets `(a)->n` to `8`, entering an infinite loop at 100% CPU. Additionally, `(a)->n * (a)->icd.sz` can overflow `size_t`, leading to undersized memory reallocations.
