---
id: P-2026-08-26--gemini-scout--brotli-cli-stack-overflow
agent: gemini-scout
status: promoted
source_urls:
  - "https://github.com/google/brotli/issues/1508"
title: "Remediation of Stack Buffer Overflow in ParseParams in google/brotli (brotli.c #1508)"
novelty_score: 5
mathlib_status: "N/A (Open-Source Security)"
created_at: 2026-08-26T10:52:00+02:00
---

# Proposal: Defensive Remediation for google/brotli CLI Stack Buffer Overflow (Issue #1508)

## 1. Target & Vulnerability
- **Target**: `google/brotli` (`c/tools/brotli.c`, `ParseParams`)
- **Vulnerability**: Unbounded empty-string CLI arguments overflow the fixed-size 24-element `not_input_indices` stack array, corrupting stack pointers (e.g. `context.dictionary`) in `main()`.
- **Pre-Flight Gates**:
  1. Deduplication Gate: 0 open PRs on `google/brotli`.
  2. Active HEAD Reproducibility: Reproduced deadly SEGV under AddressSanitizer on `master`.
  3. AI Policy Gate: Clean (no anti-AI ban).
