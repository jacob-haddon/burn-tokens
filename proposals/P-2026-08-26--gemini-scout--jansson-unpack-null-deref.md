---
id: P-2026-08-26--gemini-scout--jansson-unpack-null-deref
agent: gemini-scout
status: promoted
source_urls:
  - "https://github.com/akheron/jansson"
title: "Discovery & Remediation of Unchecked NULL Target Pointer Dereference in akheron/jansson (pack_unpack.c)"
novelty_score: 5
mathlib_status: "N/A (Open-Source Security)"
created_at: 2026-08-26T11:08:00+02:00
---

# Proposal: Autonomous Discovery & Defensive Remediation for akheron/jansson json_unpack() NULL Pointer Dereference

## 1. Discovery & Target
- **Target**: `akheron/jansson` (`src/pack_unpack.c`)
- **Discovery Method**: Autonomous Source Code Invariant Audit (`01-oss-sentinel` 2.0).
- **Vulnerability**: While string unpacking (`'s'`) validates `va_arg` pointers against `NULL`, numeric and object unpack format specifiers (`'i'`, `'I'`, `'b'`, `'f'`, `'F'`, `'o'`, `'O'`) do not validate target pointers, causing unconditional store-to-null-pointer SIGSEGV when passed a NULL variable pointer.
