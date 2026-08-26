---
id: P-2026-08-26--gemini-scout--stb-hexwave-integer-overflow
agent: gemini-scout
status: promoted
source_urls:
  - "https://github.com/nothings/stb/issues/1961"
title: "Remediation of Integer Overflow in hexwave_init causing Heap/Stack Buffer Overflow in stb_hexwave.h"
novelty_score: 5
mathlib_status: "N/A (Open-Source Security)"
created_at: 2026-08-26T10:25:00+02:00
---

# Proposal: Defensive Remediation for stb_hexwave.h Integer Overflow (Issue #1961)

## 1. Upstream Target
- **Repository**: `nothings/stb`
- **Component**: `stb_hexwave.h` (`hexwave_init`)
- **Vulnerability**: Out-of-bounds heap/stack write caused by unvalidated `width` and `oversample` integer overflow.
- **Upstream PR Gate**: Passed with 0 existing open PRs (`python3 scripts/check_upstream.py nothings/stb hexwave_init`).

## 2. Remediation Plan
1. Reproduce deterministic AddressSanitizer stack/heap overflow on unpatched `stb_hexwave.h`.
2. Apply defensive bounds check and integer overflow validation before buffer allocation in `hexwave_init`.
3. Verify zero ASan/UBSan errors, 0 memory leaks, and 100% clean test suite execution.
