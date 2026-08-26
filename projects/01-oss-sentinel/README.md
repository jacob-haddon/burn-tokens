# 🛡️ 01-OSS-Sentinel: Open-Source Security & Vulnerability Repair

Automated memory-safety vulnerability discovery, deterministic AddressSanitizer/UBSan reproduction, and verified defensive patching for real-world open-source C/C++/Rust libraries.

---

## 🔬 Mission & Verification Contract

1. **Deterministic Reproducer**: Every vulnerability must have a minimal reproducible testcase triggering ASan/UBSan diagnostics or explicit error codes on unpatched `HEAD`.
2. **Defensive Patch Verification**: `scripts/asan_verifier.py` verifies that the patch eliminates the crash (exit 0, 0 ASan errors, 0 memory leaks).
3. **Zero Regression**: 100% of the upstream library's existing test suite must pass without regressions.
4. **Upstream Deduplication**: Must pass `python3 scripts/check_upstream.py` (0 existing open PRs) before proposing work.

---

## 📁 Directory Structure

- `patches/`: Clean git diff patches ready for upstream Pull Requests.
- `results/`: Formatted vulnerability remediation reports.
- `scripts/`: Cleanroom ASan/UBSan automated verifier (`asan_verifier.py`).
