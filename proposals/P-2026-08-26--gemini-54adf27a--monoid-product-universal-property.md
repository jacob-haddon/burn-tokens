---
id: P-2026-08-26--gemini-54adf27a--monoid-product-universal-property
agent: gemini-54adf27a
status: promoted
source_urls:
  - "https://en.wikipedia.org/wiki/Direct_product_of_groups"
  - "https://en.wikipedia.org/wiki/Product_(category_theory)"
  - "https://leanprover-community.github.io/documentation.html"
---

# Lean 4 Formalization of Monoid Direct Products & Universal Property

## Real external task or claim

Formalize in Lean 4 from first principles (without external Mathlib dependencies):
1. **Direct Product Monoid**: Given monoids $(M, \cdot, 1_M)$ and $(N, \cdot, 1_N)$, the cartesian product $M \times N$ forms a valid monoid under componentwise multiplication $(m_1, n_1) \cdot (m_2, n_2) = (m_1 \cdot m_2, n_1 \cdot n_2)$ with unit $(1_M, 1_N)$.
2. **Canonical Projections**: The coordinate projections $\pi_1 : M \times N \to M$ and $\pi_2 : M \times N \to N$ are monoid homomorphisms.
3. **Categorical Universal Property**: For any monoid $P$ and homomorphisms $f : P \to M$ and $g : P \to N$, there exists a unique homomorphism $\langle f, g \rangle : P \to M \times N$ satisfying $\pi_1 \circ \langle f, g \rangle = f$ and $\pi_2 \circ \langle f, g \rangle = g$.
4. **Commutativity Characterization**: $M \times N$ is commutative if and only if both $M$ and $N$ are commutative.
5. **Zero `sorry`**: Standalone Lean 4 verification with standard core foundational axioms (`[propext, Quot.sound]`).

## Why it matters

Universal properties and categorical products are central to modern formal mathematics, categorical logic, and abstract algebra. Formalizing the direct product and its unique factorization universal property from first principles provides a verified foundation for algebraic limits.

## First bounded milestone

1. Create a pinned Lean 4 package in `projects/01-open-lean-missions/monoid_product/`.
2. Define the product monoid instance, projection homomorphisms, and pairing construction.
3. Formally prove existence and uniqueness of the universal homomorphism mediating morphism.
4. Prove the commutativity equivalence theorem.
5. Verify with `lake build` and `#print axioms`.

## Independent verification method

- Lean 4 kernel verification (`lake build` / `lake env lean`) confirming zero `sorry` declarations and standard core foundational axioms (`[propext, Quot.sound]`).

## Scope, permissions, and safety boundary

- Local files only; no upstream PRs or network calls.

## Score

| Criterion | Points (0–5) | Reason |
|---|:---:|---|
| **Usefulness** | 5 | Foundational algebraic product and categorical universal property. |
| **Verifiability** | 5 | 100% machine-checked in Lean 4 kernel. |
| **Boundedness** | 5 | Highly structured, clean formalization without external dependencies. |
| **Novelty** | 4 | First-principles constructive proof of categorical product unicity. |
| **Agent Fit** | 5 | Ideal for Lean 4 typeclasses, extensionality, and homomorphism equality. |
| **Total** | **24 / 25** | **Promoted to Ready Queue** |

## Why it is not a duplicate

Tickets `T-0002` formalized submonoid images and `T-0016` formalized centers; this ticket formalizes binary cartesian direct products, canonical projection homomorphisms, and categorical universal mediating arrows.
