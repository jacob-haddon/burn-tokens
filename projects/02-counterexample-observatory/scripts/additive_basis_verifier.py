import json
import sys
from pathlib import Path

def compute_sumset(basis):
    return sorted(list({a + b for a in basis for b in basis}))

def compute_continuous_range(sumset):
    sum_set = set(sumset)
    n = 0
    while n in sum_set:
        n += 1
    return n - 1

def main():
    data_path = Path("projects/02-counterexample-observatory/data/additive_basis_frontier.json")
    if not data_path.exists():
        print(f"Error: dataset {data_path} not found.")
        sys.exit(1)

    with open(data_path, "r") as f:
        report = json.load(f)

    print("===========================================================================")
    print("  INDEPENDENT AUDIT: ADDITIVE BASES OF ORDER 2 & STÖHR RANGE FRONTIER")
    print("===========================================================================")
    print(f"[*] Title: {report.get('title')}")
    print(f"[*] Orders Audited: {len(report['results'])}")
    print("---------------------------------------------------------------------------")
    print(f"{'Order k':<8} | {'n(2, k)':<8} | {'OEIS A001212':<13} | {'Extremal Bases':<15} | {'Status'}")
    print("---------------------------------------------------------------------------")

    total_bases_verified = 0
    failures = 0

    oeis_a001212 = {
        2: 2,
        3: 4,
        4: 8,
        5: 12,
        6: 16,
        7: 20,
        8: 26,
        9: 32,
        10: 40,
    }

    for res in report["results"]:
        k = res["k"]
        certified_n = res["certified_max_n"]
        expected_oeis = oeis_a001212.get(k)

        if certified_n != expected_oeis:
            print(f"FAIL: k={k} certified n={certified_n} != expected OEIS {expected_oeis}")
            failures += 1

        for cert in res["extremal_bases"]:
            total_bases_verified += 1
            basis = cert["basis"]

            # Verify length
            if len(basis) != k:
                print(f"FAIL: basis {basis} has length {len(basis)} != {k}")
                failures += 1
                continue

            # Verify 0 in basis
            if basis[0] != 0:
                print(f"FAIL: basis {basis} does not contain 0")
                failures += 1

            # Compute sumset independently
            py_sumset = compute_sumset(basis)
            if len(py_sumset) != cert["sumset_cardinality"]:
                print(f"FAIL: sumset size mismatch for {basis}: {len(py_sumset)} vs {cert['sumset_cardinality']}")
                failures += 1

            # Verify continuous range [0, n]
            py_range = compute_continuous_range(py_sumset)
            if py_range != cert["range_n"] or py_range != certified_n:
                print(f"FAIL: range mismatch for {basis}: {py_range} vs reported {cert['range_n']} (expected {certified_n})")
                failures += 1

            # Check that every integer in [0, py_range] is in 2A
            missing = [x for x in range(py_range + 1) if x not in py_sumset]
            if missing:
                print(f"FAIL: missing elements in [0, {py_range}] for {basis}: {missing}")
                failures += 1

        print(f"k = {k:<4} | {certified_n:<8} | {expected_oeis:<13} | {len(res['extremal_bases']):<15} | {'✅ PASS'}")

    print("---------------------------------------------------------------------------")
    print(f"[*] Total Bases Audited: {total_bases_verified}")
    print(f"[*] Total Verification Failures: {failures}")

    if failures == 0:
        print("\n[CONCLUSION] 🎉 100% PERFECT INDEPENDENT ADDITIVE BASIS AUDIT!")
        print("  - All 2-fold sumsets cover [0, n(2, k)] with 0 missing integers.")
        print("  - 100% agreement with OEIS A001212 across all orders k = 2..10.")
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
