# Autonomous Research Lab: Sentinel, Frontier Discovery & Architecture Contract

This repository is dedicated strictly to genuine scientific discoveries, open conjecture frontiers, and **real-world open-source vulnerability & memory-safety repair (`01-oss-sentinel`)**. Unattended agents must never spend compute on textbook exercises or duplicate solved theorems.

---

## 🎯 Mandatory High-Value Research Pillars

All tasks in `tickets/` and `proposals/` must belong strictly to one of four research pillars:

1. 🛡️ **Open-Source Security & Vulnerability Repair (`01-oss-sentinel`)**:
   - Repairing unpatched memory-safety bugs in C/C++/Rust open-source libraries.
   - **Verification Anchor**: `scripts/asan_verifier.py`. Must provide a deterministic reproducer triggering ASan/UBSan on unpatched `HEAD`, a clean defensive patch (exit 0), and zero test suite regression.
   - **Deduplication Gate**: Must pass `python3 scripts/check_upstream.py` (0 duplicate open PRs).

2. 🥇 **Open Combinatorial Frontiers & Certified Extrema (`02-counterexample-observatory`)**:
   - Generating exact mathematical certificates, extremal graphs, or bound improvements for open OEIS sequences.

3. 📜 **Novel arXiv Preprint Formalization (2024–2026) in Lean 4 (`03-open-lean-missions`)**:
   - Formalizing unformalized key lemmas from fresh mathematical papers published on arXiv between 2024 and 2026.
   - Must cite the specific arXiv preprint ID and provide 0 `sorry` machine check in Lean 4.

4. 🔍 **Independent AI Research Reproducibility Audits (`04-proof-reproduction-watch`)**:
   - Auditing claimed mathematical proofs in recent AI/LLM literature.

---

## 🧹 Repository Sanitation Guardian (Caretaker Role)

- **Sanitation Engine**: `scripts/repo_sanitizer.py`.
- **Zero Root Clutter**: No scratch scripts, stray binaries, or temporary tests in root.
- **Automated GC**: Automatically sweeps scratch files to `archive/scratch/` and enforces structural symmetry across all 4 pillars.

---

## ⚙️ Resource & Compute Policy (Zero Local Overload)

- **Local CPU Time**: Max **30 seconds** per command (only for Lean compilation, sanitizer checking via `asan_verifier.py`, or lightweight certificate checking).
- **Zero Heavy Brute Force**: Heavy searches must use algebraic pruning, SAT/SMT encodings, or tight analytical bounds.
- **LLM Reasoning First**: Heavy lifting is performed via Gemini 3.7 Flash High inference.

---

## 📋 Standard Ticket Lifecycle

1. **Scout Mode**: Propose genuine frontier tasks (with upstream deduplication check).
2. **Review First**: Review any pending tickets in `status: review` before executing new tasks.
3. **Execution**: Complete within 2.5 hours, generate result note, patch, and handoff.
4. **Independent Verification**: Transition to `status: review` for zero-trust adversarial auditing.
5. **Caretaker Sweep**: Caretaker verifies 100/100 repository hygiene on each heartbeat tick.
