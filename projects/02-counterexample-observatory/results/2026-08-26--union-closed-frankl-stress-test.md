# Result Note: Union-Closed Families (Frankl's Conjecture) Exhaustive Frontier ($m \le 5$) & Stress Test

## 1. Candidate Chosen & Sources

- **Candidate ID**: `C-0202`
- **Candidate Title**: Union-Closed Families (Frankl) Stress Test
- **Project**: `02-counterexample-observatory`
- **Task Card**: [`TASK-CARDS.md` Card C-02](projects/02-counterexample-observatory/TASK-CARDS.md#card-c-02-union-closed-families-stress-test)
- **Source URLs**:
  - [Frankl (1979), Union-Closed Sets Conjecture Original Problem](https://www.sciencedirect.com/science/article/pii/0097316592900686)
  - [Gilmer (2022), A Constant Lower Bound for the Union-Closed Sets Conjecture](https://arxiv.org/abs/2211.09055)
  - [Chase & Lovett (2022), Approximate Frankl's Conjecture](https://arxiv.org/abs/2211.11689)
  - [OEIS A007412: Number of Closure Systems on $m$ Elements](https://oeis.org/A007412)
  - [OEIS A102896: Number of Non-Isomorphic Closure Systems on $m$ Elements](https://oeis.org/A102896)

---

## 2. Precise Claim & Goal

Let $X = [m] = \{0, 1, \dots, m-1\}$ be a finite ground set. A family $\mathcal{F} \subseteq 2^X$ is **union-closed** if $\forall A, B \in \mathcal{F}, A \cup B \in \mathcal{F}$.
A family is **nontrivial** if $|\mathcal{F}| \ge 2$ and $\bigcup_{A \in \mathcal{F}} A = X \ne \emptyset$.
For any element $x \in X$, its degree in $\mathcal{F}$ is $d(x) = |\{ A \in \mathcal{F} : x \in A \}|$, and its relative frequency is $p(x) = \frac{d(x)}{|\mathcal{F}|}$.
The **Frankl ratio** of $\mathcal{F}$ is:
$$\rho(\mathcal{F}) = \max_{x \in X} p(x) = \frac{\max_{x \in X} d(x)}{|\mathcal{F}|}$$

**Frankl's Union-Closed Sets Conjecture (1979)** states that for every nontrivial finite union-closed family $\mathcal{F}$:
$$\rho(\mathcal{F}) \ge \frac{1}{2}$$

### Duality Theorem & Moore Families
Under the complement bijection $A \mapsto X \setminus A$, a union-closed family $\mathcal{F}$ containing $\emptyset$ and $X$ is dual to an intersection-closed family $\mathcal{C} = \{ X \setminus A : A \in \mathcal{F} \}$ (a **closure system** or **Moore family**).
$$\max_{x \in X} \frac{d_{\mathcal{F}}(x)}{|\mathcal{F}|} \ge \frac{1}{2} \iff \min_{x \in X} \frac{d_{\mathcal{C}}(x)}{|\mathcal{C}|} \le \frac{1}{2}$$
Furthermore, any union-closed family $\mathcal{F}$ with $\emptyset \notin \mathcal{F}$ satisfies $\rho(\mathcal{F}) > \rho(\mathcal{F} \cup \{\emptyset\}) \ge 1/2$ strictly. Thus, all extremal families ($\rho = 1/2$) and any potential counterexamples MUST contain $\emptyset$.

**Goals of this Run**:
1. Implement a high-performance bitmask search engine in Rust for union-closed and Moore families.
2. Exhaustively enumerate all closure systems for $m \le 5$ ($1,385,552$ families for $m=5$) using Ganter's canonical search, validating against OEIS A007412.
3. Search for counterexamples ($\rho(\mathcal{F}) < 1/2$) across all $1,388,102$ families.
4. Extract and catalog all non-isomorphic strictly extremal families ($\rho(\mathcal{F}) = 1/2$) and classify their structural invariants.
5. Stress test $k$-generator families ($k=3..6$), graph neighborhood union closures ($n=3..8$, 392k+ graphs), and classical combinatorial designs ($PG(2,2)$, $AG(2,3)$, Petersen graph, $K_{3,3}$).
6. Build an independent, pure Python standalone verifier validating 100% of exported extremal records.

---

## 3. What Was Produced

1. **High-Performance Rust Search Engine** (`frankl_engine/`):
   - `src/family.rs`: Bitmask set and family operations, union closure, element degree calculation, canonical form under $S_m$, and minimal basis extraction.
   - `src/closure_generator.rs`: Ganter's canonical NextClosure search parallelized via Rayon, dualizing to union-closed families with hardware `popcnt`.
   - `src/extremal_collector.rs`: Deduplication and structural cataloger of extremal families under $S_m$ symmetry.
   - `src/generator_search.rs`: High-throughput stress tester for $k$-generated union-closed families ($k=3, 4, 5, 6$) on ground sets up to $m=12$.
   - `src/graph_closures.rs`: Open, closed, and clique neighborhood union closures for all connected graphs up to $n=8$.
   - `src/designs.rs`: Formal configurations and union closures for Fano plane $PG(2,2)$, Affine plane $AG(2,3)$, Petersen graph, and complete bipartite $K_{3,3}$.
   - `src/main.rs`: CLI orchestrator generating full telemetry and JSON artifacts.
2. **Machine-Readable Data Artifact** (`data/frankl_frontier_m5.json`):
   - Level-by-level exhaustive metrics ($m=1..5$), complete catalog of all 39 non-isomorphic extremal families (with member sets, minimal generating bases, and degrees), $k$-generator tests, and graph closure frontiers.
3. **Independent Python Verifier & Analyzer** (`scripts/frankl_independent_verifier.py`, `scripts/frankl_analysis.py`):
   - Standalone ground-up verification of union closure, degrees, extremal equality $\rho = 1/2$, and minimal basis generation.

---

## 4. Verification Commands and Outcome

### Verification Commands

```bash
# 1. Run Rust test suite
cd projects/02-counterexample-observatory/frankl_engine
cargo test --release

# 2. Execute full exhaustive search and stress test engine
cargo run --release

# 3. Run independent pure Python verifier
cd ..
python3 scripts/frankl_independent_verifier.py

# 4. Run structural taxonomy analysis of extremal families
python3 scripts/frankl_analysis.py
```

### Concise Outcome

#### A. Exhaustive Frontier ($m \le 5$)

| $m$ | Total Closure Systems (OEIS A007412) | Non-Trivial Families Tested | Counterexamples ($\rho < 1/2$) | Labeled Extremal ($\rho = 1/2$) | Non-Isomorphic Extremal Families | $\min \rho(\mathcal{F})$ | Compute Time |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **1** | 2 | 1 | **0** | 1 | 1 | $1/2 = 0.5000$ | 0.6 ms |
| **2** | 7 | 6 | **0** | 4 | 3 | $1/2 = 0.5000$ | 0.1 ms |
| **3** | 61 | 60 | **0** | 14 | 6 | $1/2 = 0.5000$ | 0.04 ms |
| **4** | 2,480 | 2,479 | **0** | 51 | 11 | $1/2 = 0.5000$ | 2.3 ms |
| **5** | 1,385,552 | 1,385,551 | **0** | 202 | 18 | $1/2 = 0.5000$ | 2.56 s |
| **Total** | **1,388,102** | **1,388,097** | **0** | **272** | **39** | **$1/2$** | **2.57 s** |

#### B. Structural Discovery on Extremal Families ($\rho = 1/2$)

1. **Power of Two Sizes**: Every single one of the 39 non-isomorphic extremal families has size strictly equal to a power of two: $|\mathcal{F}| = 2^k$ for $1 \le k \le m$.
2. **Boolean Lattice Quotients**: Every separating extremal family is isomorphic to a full Boolean lattice $\mathcal{P}([k])$ on its active support.
3. **No Non-Boolean Extremal Semilattices for $m \le 5$**: Every non-Boolean union-closed family on $m \le 5$ elements satisfies $\rho(\mathcal{F}) > 1/2$ strictly (e.g. triad family $\rho = 3/5 = 0.6000$).
4. **All Extremal Families Cataloged**:
   - $m=1$: 1 family ($|\mathcal{F}|=2, |\mathcal{B}|=1$)
   - $m=2$: 3 families ($|\mathcal{F}| \in \{2, 4\}$)
   - $m=3$: 6 families ($|\mathcal{F}| \in \{2, 4, 8\}$)
   - $m=4$: 11 families ($|\mathcal{F}| \in \{2, 4, 8, 16\}$)
   - $m=5$: 18 families ($|\mathcal{F}| \in \{2, 4, 8, 16, 32\}$)

#### C. $k$-Generator Stress Tests ($k=3..6$) on Larger Ground Sets ($m \le 12$)

- **$k=3$ ($m=6$)**: 49,999 families tested, $\min \rho = 0.5000$ ($2/4$), 0 counterexamples.
- **$k=4$ ($m=8$)**: 50,000 families tested, $\min \rho = 0.5000$ ($2/4$), 0 counterexamples.
- **$k=5$ ($m=10$)**: 50,000 families tested, $\min \rho = 0.6000$ ($12/20$), 0 counterexamples.
- **$k=6$ ($m=12$)**: 50,000 families tested, $\min \rho = 0.6667$ ($12/18$), 0 counterexamples.

#### D. Graph Neighborhood Closures ($n=3..8$)

- Tested 392,081 connected graphs across open, closed, and clique neighborhood union closures.
- 0 counterexamples across all graph families.
- Minimum Frankl ratios observed:
  - Open neighborhood closures: $\min \rho = 0.5000$ ($n=3..7$), $0.5882$ ($n=8$)
  - Closed neighborhood closures: $\min \rho = 0.5000$ ($n=3..6$), $0.6333$ ($n=7$), $0.6304$ ($n=8$)
  - Maximal clique closures: $\min \rho = 0.5000$ ($n=3..6$), $0.5600$ ($n=7$), $0.5595$ ($n=8$)

#### E. Classical Combinatorial Designs

- **Fano Plane $PG(2, 2)$ Lines**: $|X|=7$, $|\mathcal{B}|=7$, $|\mathcal{F}|=37$, $\max d(x)=25$, $\rho = 25/37 \approx 0.6757$ (Conjecture satisfied).
- **Affine Plane $AG(2, 3)$ Lines**: $|X|=9$, $|\mathcal{B}|=12$, $|\mathcal{F}|=197$, $\max d(x)=127$, $\rho = 127/197 \approx 0.6447$ (Conjecture satisfied).
- **Petersen Graph Open Neighborhoods**: $|X|=10$, $|\mathcal{B}|=10$, $|\mathcal{F}|=187$, $\max d(x)=125$, $\rho = 125/187 \approx 0.6684$ (Conjecture satisfied).
- **Complete Bipartite $K_{3, 3}$ Neighborhoods**: $|X|=6$, $|\mathcal{B}|=6$, $|\mathcal{F}|=4$, $\max d(x)=2$, $\rho = 2/4 = 0.5000$ (Extremal, satisfied).

---

## 5. Confidence

**`computational evidence`** (backed by full machine check over all $1,388,102$ closure systems up to $m=5$ matching OEIS A007412, dual-engine cross-validation in Rust and pure Python, and 392k+ graph neighborhood closures).

---

## 6. Best Next Step & Blockers

- **Next Step**: Target $m = 6$ closure systems using distributed cluster streaming (OEIS A007412 has $7.59 \times 10^{10}$ families), or explore restricted subclasses at $m=6..8$ (e.g. 3-uniform hypergraph transversals, chordal graph neighborhood closures, or rank-3 matroid flat union closures).
- **Blockers**: None. The pipeline is fully self-contained, reproducible, verified, and integrated into the repository.
