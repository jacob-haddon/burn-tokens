# Result Note: Modular Multiplicative Inverse Existence & Uniqueness in Lean 4

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0103` / Ticket `T-0010`
- **Candidate Title**: Lean 4 Formalization of Modular Multiplicative Inverse Existence & Uniqueness
- **Project**: `01-open-lean-missions`
- **Source URLs**:
  - [Mathlib Number Theory / ZMod Library](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Data/ZMod/Basic.html)
  - [Modular Multiplicative Inverse on Wikipedia](https://en.wikipedia.org/wiki/Modular_multiplicative_inverse)
  - Proposal [`proposals/P-2026-08-26--gemini-f02530fc--lean-modular-inverse.md`](file:///home/ging/Work/burn-tokens/proposals/P-2026-08-26--gemini-f02530fc--lean-modular-inverse.md)

---

## 2. Precise Claim & Goal

For any integers $a, m \in \mathbb{Z}$ with $m > 1$:
1. If $a \cdot x + m \cdot y = 1$ (Bézout identity), then $x$ is a modular multiplicative inverse of $a$ modulo $m$ ($a \cdot x \equiv 1 \pmod m$).
2. Any two modular multiplicative inverses of $a$ modulo $m$ are congruent modulo $m$.
3. Within the standard non-negative residue range $\{0, \dots, m-1\}$, the modular multiplicative inverse is **strictly unique** ($b_1 = b_2$).
4. For $m > 1$, any inverse in $\{0, \dots, m-1\}$ is non-zero ($b \ge 1$).
5. Modular inversion satisfies algebraic involution ($b^{-1} = a$) and anti-homomorphism / product rule ($(a_1 a_2)^{-1} = a_2^{-1} a_1^{-1}$).
6. Constructive Extended Euclidean Algorithm (`extGcd`) computable and definitionally verified at compile-time via `rfl`.

---

## 3. What Was Produced

- **Lean 4 Package**: `projects/01-open-lean-missions/modular_inverse/`
  - `lakefile.toml` & `lean-toolchain` (pinned Lean 4.33.1).
  - `ModularInverse/Basic.lean`: Complete, standalone machine-checked formalization:
    - `ModEq`: Equivalence relation and congruence arithmetic on $\mathbb{Z}$.
    - `IsModInverse`: Definition of multiplicative inverse modulo $m$.
    - `mod_inverse_of_bezout`: Existence from Bézout identity.
    - `mod_inverse_congr`: Uniqueness up to congruence.
    - `unique_residue`: Distinctness of non-congruent residues in $[0, m)$.
    - `mod_inverse_unique`: Global uniqueness in $[0, m)$.
    - `mod_inverse_pos`: Strict positivity in $[0, m)$ for $m > 1$.
    - `mod_inv_symm` & `mod_inv_prod`: Algebraic properties of inverses.
    - `extGcd` & `modInverse`: Constructive algorithm with `rfl` proofs on concrete test instances ($3^{-1} \equiv 5 \pmod 7$, $5^{-1} \equiv 9 \pmod{11}$, $7^{-1} \equiv 2 \pmod{13}$, $\gcd(2, 6) \neq 1 \implies \text{none}$).
  - `ModularInverse.lean`: Axiom reflection suite confirming zero `sorry` and standard foundational axioms only (`propext`, `Quot.sound`).

---

## 4. Verification Commands and Outcome

### Commands

```bash
cd projects/01-open-lean-missions/modular_inverse
export PATH="/home/ging/.elan/bin:$PATH"
lake build
lake env lean ModularInverse/Basic.lean
```

### Outcome

- **Build**: 4 jobs built cleanly in 1.3s with 0 warnings and 0 errors.
- **Axiom Check**:
  - `mod_inverse_unique`: `[propext, Quot.sound]`
  - `mod_inverse_pos`: `[propext, Quot.sound]`
  - `mod_inv_prod`: `[propext, Quot.sound]`
  - `extGcd`, `modInverse`, `test_inv_3_7`: `[]` (0 axioms)
- **`sorry` Count**: 0.

---

## 5. Mathlib Duplication Assessment

In Mathlib 4, modular inverses are formalized within `ZMod.unit` and `Nat.gcdA`. Our implementation provides an isolated, dependency-free, machine-checked constructive algebraic development directly from integers and the Extended Euclidean algorithm.

---

## 6. Confidence

**`machine-checked`** (Compiled and verified by the Lean 4.33.1 kernel with zero `sorry`).

---

## 7. Best Next Step & Blockers

- **Next Step**: Formalize the Chinese Remainder Theorem using `modInverse` as the constructive basis.
- **Blockers**: None.
