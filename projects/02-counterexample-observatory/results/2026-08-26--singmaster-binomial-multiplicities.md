# Result Note: Singmaster Binomial Multiplicities and Repeated Binomial Coefficients Frontier ($N \le 10^{14}$)

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0208` / Ticket `T-0012`
- **Candidate Title**: Singmaster Binomial Multiplicities Frontier ($N \le 10^{14}$)
- **Project**: `02-counterexample-observatory`
- **Source URLs**:
  - [Singmaster's Conjecture (Wikipedia)](https://en.wikipedia.org/wiki/Singmaster%27s_conjecture)
  - [OEIS A003015: Repeated Binomial Coefficients](https://oeis.org/A003015)
  - [OEIS A003016: Multiplicities in Pascal's Triangle](https://oeis.org/A003016)
  - [OEIS A046980: Number of Times n Appears in Pascal's Triangle](https://oeis.org/A046980)

---

## 2. Precise Claim & Goal

Singmaster's Conjecture (1971) states that the multiplicity $N(x) = |\{(n, k) : 0 \le k \le n, \binom{n}{k} = x\}|$ of any integer $x > 1$ in Pascal's triangle is universally bounded by a constant $M$.

The purpose of this mission is to:
1. Exhaustively enumerate all binomial representations $\binom{n}{k} \le 10^{14}$ for $3 \le k \le n/2$.
2. Invert triangular numbers $\binom{m}{2} = m(m-1)/2 = x$ via Diophantine square roots $(2m-1)^2 = 8x + 1$.
3. Completely catalog all integers $x \le 10^{14}$ with multiplicity $\ge 6$ and determine whether any integer exceeds multiplicity 8.

---

## 3. What Was Produced

- **High-Performance Rust Search Engine**: `projects/02-counterexample-observatory/singmaster_engine/` (128-bit exact integer arithmetic without overflow).
- **Standalone Independent Python Verifier**: `projects/02-counterexample-observatory/scripts/singmaster_independent_verifier.py` (arbitrary-precision integer validation and independent parameter space recomputation).
- **Certified Machine-Readable Dataset**: `projects/02-counterexample-observatory/data/singmaster_frontier_n1e14.json`.

---

## 4. Verification Commands and Outcome

### Commands

```bash
cargo run --release --manifest-path projects/02-counterexample-observatory/singmaster_engine/Cargo.toml
python3 projects/02-counterexample-observatory/scripts/singmaster_independent_verifier.py
```

### Outcome

1. **Parameter Space Enumeration**:
   - Total $(n, k)$ pairs with $k \ge 3$ evaluated: $94,742$.
   - Total distinct values generated for $k \ge 3$: $94,741$.
2. **Multiplicity Spectrum up to $N = 10^{14}$**:
   - Maximum multiplicity found: **8** (Unique champion: **$3003$**).
   - Total integers with multiplicity $\ge 8$: **1** ($3003$).
   - Total integers with multiplicity $\ge 6$: **7** integers:
     - $120 = \binom{120}{1} = \binom{16}{2} = \binom{10}{3}$ (Multiplicity 6)
     - $210 = \binom{210}{1} = \binom{21}{2} = \binom{10}{4}$ (Multiplicity 6)
     - $1540 = \binom{1540}{1} = \binom{56}{2} = \binom{22}{3}$ (Multiplicity 6)
     - $3003 = \binom{3003}{1} = \binom{78}{2} = \binom{15}{5} = \binom{14}{6}$ (Multiplicity 8)
     - $7140 = \binom{7140}{1} = \binom{120}{2} = \binom{36}{3}$ (Multiplicity 6)
     - $11628 = \binom{11628}{1} = \binom{153}{2} = \binom{19}{5}$ (Multiplicity 6)
     - $24310 = \binom{24310}{1} = \binom{221}{2} = \binom{17}{8}$ (Multiplicity 6)
3. **Independent Verification**:
   - Dual-engine verification confirmed 100% agreement between Rust and pure Python.
   - All certificates verified with 0 errors.

---

## 5. Confidence

**`computational evidence`** (Exhaustive discrete search up to $10^{14}$ with exact 128-bit and arbitrary-precision integer verification).

---

## 6. Best Next Step & Blockers

- **Next Step**: Search the $k \ge 4$ sub-frontier up to $N = 10^{18}$ using 128-bit modular filtering.
- **Blockers**: None.
