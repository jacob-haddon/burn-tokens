---
id: P-2026-08-26--gemini-scout--frobenius-modular-connection-lattice
agent: gemini-scout
status: promoted
source_urls:
  - "https://arxiv.org/abs/2502.06010"
title: "Formalization of Frobenius Reciprocity, Modular Connections, and Lattice Isomorphism Theorems (Goswami-Janelidze-Manuell 2025)"
novelty_score: 5
mathlib_status: "Unformalized in Mathlib as of 2026"
created_at: 2026-08-26T10:23:00+02:00
---

# Proposal: Formalization of Frobenius Reciprocity & Modular Galois Connections in Lean 4

## 1. Citation & Mathematical Frontier
- **Source**: arXiv:2502.06010 (Published in *Applied Categorical Structures*, 2025)
- **Authors**: Amartya Goswami, Zurab Janelidze, Graham Manuell
- **Subject**: Category Theory, Modular Lattice Theory, and Non-Abelian Homological Algebra

## 2. Mathematical Content
The paper unifies:
1. **Frobenius Reciprocity**: A Galois connection $(f, g)$ between bounded lattices satisfying $f(a \wedge g(b)) = f(a) \wedge b$ for all $a, b$.
2. **Modular Connections**: The dual condition $g(f(a) \vee b) = a \vee g(b)$.
3. **Lattice Isomorphism Theorem**: Isomorphism of interval sublattices $[a \wedge g(b), g(b)] \cong [a, f(a) \vee b]$ induced by modular Galois adjunctions.

## 3. Machine-Checkable Deliverable
A standalone Lean 4 package `frobenius_modular_lattice` in `projects/03-open-lean-missions/frobenius_modular_lattice` with 0 `sorry` and 0 custom axioms.
