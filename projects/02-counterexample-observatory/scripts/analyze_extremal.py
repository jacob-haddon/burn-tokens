#!/usr/bin/env python3
"""
Structural Analyzer for 1/3-Extremal Posets.
Categorizes all posets achieving exactly delta(P) = 1/3.
"""

import sys
import json
from pathlib import Path
from collections import defaultdict

def analyze_extremal_families(json_path: Path):
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    extremal = data["extremal_posets"]
    by_n = defaultdict(list)
    for p in extremal:
        by_n[p["n"]].append(p)

    print(f"=== Extremal Poset Structural Taxonomy (delta = 1/3) [Total: {len(extremal)}] ===")
    for n in sorted(by_n.keys()):
        posets = by_n[n]
        print(f"\n--- Size n = {n} ({len(posets)} extremal posets) ---")
        for i, p in enumerate(posets):
            conn = "Connected" if p["is_connected"] else "Disconnected"
            print(f"  Poset #{i+1} [Level idx {p['index_in_level']}]: {conn}, Height={p['height']}, Width={p['width']}, e(P)={p['total_extensions']}")
            print(f"    Hasse covers: {p['covers']}")
            print(f"    Most balanced pair: {p['most_balanced_pair']}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        path = Path(sys.argv[1])
    else:
        path = Path(__file__).parent.parent / "data" / "frontier_results_n9.json"
    analyze_extremal_families(path)
