# 🪐 Burn-Tokens: Autonomous Discovery, Memory Safety & Formal Verification Lab

[![Live Observatory](https://img.shields.io/badge/Live_Observatory-GitHub_Pages-blue?style=for-the-badge&logo=github)](https://jacob-haddon.github.io/burn-tokens/)
[![Lean 4](https://img.shields.io/badge/Lean_4-4.33.1-emerald?style=for-the-badge&logo=lean)](https://leanprover.github.io/)
[![ASan](https://img.shields.io/badge/Sanitizers-ASan%20%7C%20UBSan-red?style=for-the-badge&logo=cplusplus)](https://clang.llvm.org/docs/AddressSanitizer.html)
[![Model](https://img.shields.io/badge/Model-Gemini_3.7_Flash_High-purple?style=for-the-badge&logo=google)](https://deepmind.google/technologies/gemini/)

An unattended, decentralized multi-agent research laboratory designed to solve real-world open-source memory-safety vulnerabilities, formalize verified mathematics in **Lean 4**, and compute certified combinatorial datasets without human intervention.

🌐 **Live Research Observatory & Lab Notes**: **[jacob-haddon.github.io/burn-tokens](https://jacob-haddon.github.io/burn-tokens/)**

---

## 🏛️ Autonomous Swarm Architecture & Verification Lifecycle

The laboratory operates on a decentralized, amnesia-proof state machine with strict **Pre-Flight Gates** and **Zero-Trust Independent Auditing**:

```mermaid
flowchart TD
    subgraph Discovery["1. Scout & Pre-Flight Verification"]
        S[Task Scout] --> G1{Gate 1: Deduplication<br/>check_upstream.py}
        G1 -->|Duplicate PRs Found| REJ1[🚫 REJECT: Duplicate]
        G1 -->|0 Open PRs| G2{Gate 2: Active HEAD Reproducibility<br/>ASan / UBSan}
        G2 -->|Not Reproducible on master| REJ2[🚫 REJECT: Obsolete/Invalid]
        G2 -->|Reproducible Crash| G3{Gate 3: AI Policy Check<br/>CONTRIBUTING.md}
        G3 -->|AI Banned by Maintainer| HELD[⚠️ PR HELD: Research Only]
        G3 -->|Clean AI Policy| T[🟢 Ticket Created in tickets/]
    end

    subgraph Execution["2. Autonomous Synthesis"]
        T -->|Optimistic Lock| E[Executor Agent]
        E -->|Synthesize Defensive Patch / Lean Proof| D[projects/* Artifacts & Handoff]
    end

    subgraph Review["3. Zero-Trust Independent Audit"]
        D --> A[Zero-Trust Auditor]
        A -->|Verify ASan Exit 0 / Lean 0 sorry| V{Machine Verified?}
        V -->|Failed / Regressed| E
        V -->|100% Verified| OK[🟣 Immutable Done Archive]
    end

    subgraph Caretaker["4. Caretaker & Hygiene Guardian"]
        C[Caretaker Daemon<br/>repo_sanitizer.py] -->|Permanent Scratch Purge| CHK[100/100 Hygiene Enforced]
        HQ[HQ Heartbeat & CI Watchdog] -->|Monitor GitHub Actions & Pages| CHK
    end

    Discovery --> Execution
    Execution --> Review
```

---

## 🎯 The 4 High-Value Research Pillars

1. 🛡️ **Open-Source Security & Vulnerability Repair (`01-oss-sentinel`)**:
   - Repairing unpatched memory-safety bugs in C/C++/Rust open-source libraries (`zlib`, `brotli`, `stb`, `cJSON`).
   - **Verification Anchor**: Deterministic reproducer triggering ASan/UBSan on unpatched `HEAD`, followed by a defensive bounds patch (exit 0) and zero test suite regression.
   - **Deduplication & AI Policy Gates**: Must pass `scripts/check_upstream.py` (0 duplicate open PRs, maintainer AI policy respected).

2. 📜 **Novel arXiv Preprint Formalization in Lean 4 (`03-open-lean-missions`)**:
   - Formalizing unformalized key lemmas from fresh mathematical preprints (2024–2026).
   - **Verification Anchor**: 0 `sorry` machine check in Lean 4 and standard axioms.

3. 🥇 **Open Combinatorial Frontiers & Certified Extrema (`02-counterexample-observatory`)**:
   - Generating exact mathematical certificates and bounds for open OEIS sequences.
   - **Verification Anchor**: Dual-engine independent verifier scripts and exact JSON certificates (12.8 MB).

4. 🔍 **AI Research Reproducibility Audits (`04-proof-reproduction-watch`)**:
   - Auditing claimed mathematical proofs in recent AI/LLM literature.

---

## 📁 Repository Structure

```text
├── projects/
│   ├── 01-oss-sentinel/             # Real-world OSS security patches, reproducers & reports (zlib, brotli, stb, cjson)
│   ├── 02-counterexample-observatory/# 25 Certified combinatorial datasets (12.8 MB JSON) & engines
│   ├── 03-open-lean-missions/       # 22 Standalone Lean 4 machine-checked packages (0 sorry)
│   └── 04-proof-reproduction-watch/ # AI scientific proof reproducibility audits
├── tickets/                         # Atomic frontmatter task state records (51 verified)
├── proposals/                       # Scored discovery proposals (>=20/25 filter)
├── handoffs/                        # Detailed technical execution handoffs
├── reviews/                         # Independent adversarial reviewer verdict notes
├── docs/                            # GitHub Pages interactive observatory site
└── scripts/                         # Orchestrator, Caretaker & check_upstream engines
```

---

## 🔬 Quick Local Reproduction (1-Line Verifications)

```bash
# Clone the repository
git clone https://github.com/jacob-haddon/burn-tokens.git && cd burn-tokens

# 1. Verify Brotli CLI stack overflow fix under AddressSanitizer:
cd projects/01-oss-sentinel/targets/brotli && cmake -B build -DENABLE_SANITIZER=address . && cmake --build build --target brotli

# 2. Build and verify Frobenius Modular Lattice package in Lean 4 (arXiv:2502.06010):
cd projects/03-open-lean-missions/frobenius_modular_lattice && lake build

# 3. Verify Singmaster repeated binomial coefficients (10^14):
python3 projects/02-counterexample-observatory/scripts/singmaster_independent_verifier.py
```

---

## 📜 License

MIT License. Free and open-source scientific artifacts.
