---
id: P-2026-08-26--gemini-scout--zlib-minizip-stack-overread
agent: gemini-scout
status: promoted
source_urls:
  - "https://github.com/madler/zlib/issues/1299"
title: "Remediation of Stack Buffer Over-Read / Missing Null-Termination in madler/zlib (minizip unzip.c #1299)"
novelty_score: 5
mathlib_status: "N/A (Open-Source Security)"
created_at: 2026-08-26T10:28:00+02:00
---

# Proposal: Defensive Remediation for madler/zlib minizip Stack Buffer Over-Read (Issue #1299)

## 1. Upstream Target
- **Repository**: `madler/zlib`
- **Component**: `contrib/minizip/unzip.c` (`unzGetCurrentFileInfo` / `unzLocateFile`)
- **Vulnerability**: Stack buffer over-read due to missing null-termination when entry filename exceeds caller's buffer size. Tracked in Debian Bug #1143912.
- **Upstream PR Gate**: Passed with 0 existing open PRs (`python3 scripts/check_upstream.py madler/zlib 1299`).

## 2. Remediation Plan
1. Clone `madler/zlib`, build `minizip` with AddressSanitizer.
2. Reproduce deterministic stack-buffer-overflow / over-read on unpatched `unzip.c`.
3. Apply defensive null-termination patch in `unzGetCurrentFileInfo`.
4. Verify 0 ASan/UBSan errors, 0 memory leaks, and 100% clean test suite execution.
