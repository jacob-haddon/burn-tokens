---
id: P-2026-08-30--gemini-scout--inverse-semigroups-minimum-group-congruence
agent: gemini-scout
status: promoted
source_urls:
  - "https://arxiv.org/abs/2501.12999"
title: "Formalization of Inverse Semigroups, Vagner-Preston Natural Partial Order, and the Minimum Group Congruence in Lean 4"
novelty_score: 5
mathlib_status: "Unformalized in Lean 4 Mathlib"
created_at: 2026-08-30T14:22:00+02:00
---

# Proposal: Machine-Checked Formalization of Inverse Semigroups, Natural Partial Order, and Minimum Group Congruence in Lean 4 (arXiv:2501.12999)

## 1. Mathematical Summary
In semigroup theory (Lawson-Margolis 2025, arXiv:2501.12999), an **inverse semigroup** $S$ is a regular semigroup in which all idempotents commute. We formalize:
1. Canonical left/right domain and codomain idempotents $x x^{-1}, x^{-1} x$.
2. Idempotent closure and stability under arbitrary inner conjugacy $x f x^{-1}$.
3. The **Vagner-Preston Natural Partial Order** $x \le y \iff \exists e \in E(S), x = e y$, proving reflexivity, transitivity, and bilateral monotonicity under multiplication ($x \le y \land u \le v \implies x u \le y v$).
4. The **Minimum Group Congruence** $\sigma$ ($x \sigma y \iff \exists e \in E(S), e x = e y$), proving it is a well-defined equivalence relation, a left and right congruence, collapses all idempotents to the group identity, and produces inverse cancellation $(x x^{-1}) y \sigma y$.
