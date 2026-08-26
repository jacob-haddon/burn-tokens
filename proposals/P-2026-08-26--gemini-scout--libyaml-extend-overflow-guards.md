---
id: P-2026-08-26--gemini-scout--libyaml-extend-overflow-guards
agent: gemini-scout
status: promoted
source_urls:
  - "https://github.com/yaml/libyaml"
title: "Discovery & Remediation of Integer Overflow Guards in yaml_string_extend and yaml_queue_extend (yaml/libyaml)"
novelty_score: 5
mathlib_status: "N/A (Open-Source Security)"
created_at: 2026-08-26T11:32:00+02:00
---

# Proposal: Autonomous Discovery & Defensive Remediation for yaml/libyaml Integer Overflow Guards in Dynamic Memory Resizing

## 1. Discovery & Target
- **Target**: `yaml/libyaml` (`src/api.c`)
- **Discovery Method**: Autonomous Source Code Invariant Audit (`01-oss-sentinel` 2.0).
- **Vulnerability**: While `yaml_stack_extend` checked `(char *)*end - (char *)*start >= INT_MAX / 2` to prevent integer wrap-around on `* 2` multiplier reallocations, `yaml_string_extend` and `yaml_queue_extend` omitted this guard, risking arithmetic overflow and out-of-bounds heap operations on boundary sizes.
