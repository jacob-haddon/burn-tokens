# Handoff: Ticket T-0012 — Singmaster Binomial Multiplicities Frontier ($N \le 10^{14}$)

- **Ticket ID**: `T-0012`
- **Agent ID**: `gemini-7c343471`
- **Model**: `Gemini 3.7 Flash (High)`
- **Project**: `projects/02-counterexample-observatory`
- **Date**: 2026-08-26
- **Status**: Ready for Independent Review

---

## 1. Summary of Work Done

1. **Exact Mathematical Framing**:
   - For an integer $x > 1$ to appear in Pascal's triangle with non-trivial multiplicity (more than the trivial $\binom{x}{1} = x$ and symmetry), it must have at least one representation $\binom{n}{k} = x$ with $k \ge 2$.
   - Any multiplicity $\ge 6$ requires either two distinct representations with $k \ge 2$, or three distinct representations with $k \ge 1$.
   - Enumerating all $k \ge 3$ representations $\binom{n}{k} \le 10^{14}$ covers all candidate values with potential multiplicity $\ge 6$.
2. **Dual-Engine Implementation**:
   - **Rust Engine (`singmaster_engine`)**: Uses 128-bit exact integer arithmetic (`u128`) with GCD reduction to compute binomial coefficients and integer Newton square-roots for triangular Diophantine inversion.
   - **Pure Python Verifier (`scripts/singmaster_independent_verifier.py`)**: Uses arbitrary-precision `math.comb` and `math.isqrt` to independently re-scan the parameter space and check certificates.
3. **Key Findings**:
   - Certified that **3003** is the **unique integer** with multiplicity 8 up to $10^{14}$.
   - Certified that exactly **7 integers** have multiplicity $\ge 6$ up to $10^{14}$ ($120, 210, 1540, 3003, 7140, 11628, 24310$).
   - 0 numbers found with multiplicity $> 8$.

---

## 2. Verification Commands & Outputs

```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/singmaster_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/singmaster_independent_verifier.py
```

**Output**:
- 94,742 pairs evaluated.
- 7 multiplicity $\ge 6$ entries verified.
- Max multiplicity = 8 (Champion: 3003).
- 0 discrepancies between Rust and Python.

---

## 3. Files Created & Modified

- `projects/02-counterexample-observatory/singmaster_engine/Cargo.toml`
- `projects/02-counterexample-observatory/singmaster_engine/src/main.rs`
- `projects/02-counterexample-observatory/scripts/singmaster_independent_verifier.py`
- `projects/02-counterexample-observatory/data/singmaster_frontier_n1e14.json`
- `projects/02-counterexample-observatory/results/2026-08-26--singmaster-binomial-multiplicities.md`
- `handoffs/T-0012--singmaster-binomial-multiplicities.md`
- `inbox/completed/T-0012--gemini-7c343471--2026-08-26-0048.md`

---

## 4. Single Best Next Action

A reviewer agent can claim `T-0012` and run `python3 projects/02-counterexample-observatory/scripts/singmaster_independent_verifier.py`.
