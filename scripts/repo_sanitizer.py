#!/usr/bin/env python3
"""
Autonomous Repository Sanitation & Structure Guardian (Caretaker)
Maintains zero-garbage policy, sweeps scratch files, and audits structural sanity.
"""

import sys
import os
import shutil
import argparse
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

# Allowed root files and directories
ALLOWED_ROOT_FILES = {
    "AGENTS.md", "BOARD.md", "README.md", "LICENSE", ".gitignore",
    "WORKER_PROMPT.md", "LOOP_PROTOCOL.md", "COORDINATION.md",
    "ROLES.md", "TASK_DISCOVERY.md", "TICKET_REVIEW.md",
    "lakefile.toml", "lean-toolchain", "runs.jsonl"
}

ALLOWED_ROOT_DIRS = {
    ".git", ".github", ".venv", "projects", "tickets", "proposals",
    "handoffs", "reviews", "docs", "scripts", "roles", "inbox", "archive", "agents", "prompts", "notes"
}

def audit_root_clutter():
    clutter = []
    for item in WORKSPACE_ROOT.iterdir():
        if item.name.startswith(".") and item.name not in {".git", ".gitignore", ".github", ".venv"}:
            clutter.append(item)
        elif item.is_file():
            if item.name not in ALLOWED_ROOT_FILES:
                clutter.append(item)
        elif item.is_dir():
            if item.name not in ALLOWED_ROOT_DIRS:
                clutter.append(item)
    return clutter

def audit_structural_sanity():
    issues = []
    projects_dir = WORKSPACE_ROOT / "projects"
    if not projects_dir.exists():
        issues.append("Missing 'projects/' directory")
        return issues
        
    expected_pillars = [
        "01-oss-sentinel",
        "02-counterexample-observatory",
        "03-open-lean-missions",
        "04-proof-reproduction-watch"
    ]
    
    for pillar in expected_pillars:
        p_path = projects_dir / pillar
        if not p_path.exists():
            issues.append(f"Missing expected project pillar: projects/{pillar}")
        else:
            readme = p_path / "README.md"
            if not readme.exists():
                issues.append(f"Missing README.md in projects/{pillar}")
    return issues

def audit_stray_binaries():
    strays = []
    for root, dirs, files in os.walk(WORKSPACE_ROOT):
        # Skip hidden/virtualenv/git/lake/build directories
        if "/." in root or root.startswith(".") or ".git" in root or "build" in root or ".lake" in root or "target" in root or ".venv" in root or "archive" in root:
            continue
        for f in files:
            p = Path(root) / f
            if f.endswith((".o", ".so", ".dylib", ".a")) or (os.access(p, os.X_OK) and not f.endswith((".py", ".sh")) and p.is_file()):
                if p.parent == WORKSPACE_ROOT / "scripts":
                    continue
                strays.append(p)
    return strays

def perform_sanitation_check():
    clutter = audit_root_clutter()
    structure_issues = audit_structural_sanity()
    stray_bins = audit_stray_binaries()
    
    total_violations = len(clutter) + len(structure_issues) + len(stray_bins)
    health_score = max(0, 100 - (total_violations * 3))
    
    print("=" * 65)
    print(f"  REPOSITORY SANITATION AUDIT REPORT (Health Score: {health_score}/100)")
    print("=" * 65)
    
    if clutter:
        print(f"[*] ROOT DIRECTORY CLUTTER ({len(clutter)} items):")
        for item in clutter[:10]:
            print(f"    - 🗑️  {item.name} ({'file' if item.is_file() else 'dir'})")
        if len(clutter) > 10:
            print(f"    - ... and {len(clutter) - 10} more clutter items")
    else:
        print("[*] ROOT DIRECTORY : 🟢 Clean (Zero root clutter)")
        
    if stray_bins:
        print(f"\n[*] STRAY UNTRACKED BINARIES ({len(stray_bins)} items):")
        for b in stray_bins[:10]:
            print(f"    - ⚠️  {b.relative_to(WORKSPACE_ROOT)}")
    else:
        print("[*] BINARIES & ARTIFACTS : 🟢 Clean (No stray binaries)")
        
    if structure_issues:
        print(f"\n[*] STRUCTURAL SANITY ISSUES ({len(structure_issues)} items):")
        for iss in structure_issues:
            print(f"    - ❌ {iss}")
    else:
        print("[*] PILLAR STRUCTURE : 🟢 Symmetrical & Healthy (All 4 pillars aligned)")
        
    print("-" * 65)
    return health_score, clutter, stray_bins, structure_issues

def perform_garbage_collection():
    print("[*] Executing Caretaker Automated Garbage Collection...")
    clutter = audit_root_clutter()
    stray_bins = audit_stray_binaries()
    
    archive_dir = WORKSPACE_ROOT / "archive" / "scratch"
    archive_dir.mkdir(parents=True, exist_ok=True)
    
    cleaned_count = 0
    for item in clutter:
        if item.name.startswith("test_") or item.name.endswith((".lean", ".c", ".bin", ".py")):
            target = archive_dir / item.name
            shutil.move(str(item), str(target))
            print(f"    - Archived root scratch file: {item.name} -> archive/scratch/")
            cleaned_count += 1
        elif item.is_file():
            target = archive_dir / item.name
            shutil.move(str(item), str(target))
            print(f"    - Archived root file: {item.name} -> archive/scratch/")
            cleaned_count += 1
            
    for b in stray_bins:
        if b.exists() and not b.name.endswith((".py", ".sh")):
            b.unlink()
            print(f"    - Removed stray binary: {b.relative_to(WORKSPACE_ROOT)}")
            cleaned_count += 1
            
    print(f"[✓] Caretaker Garbage Collection complete. Cleaned {cleaned_count} items.\n")

def main():
    parser = argparse.ArgumentParser(description="Repository Sanitation & Caretaker Guardian")
    parser.add_argument("--check", action="store_true", help="Run hygiene audit without modifying files")
    parser.add_argument("--clean", action="store_true", help="Execute automated garbage collection")
    
    args = parser.parse_args()
    if args.clean:
        perform_garbage_collection()
        perform_sanitation_check()
    else:
        score, _, _, _ = perform_sanitation_check()
        sys.exit(0 if score >= 90 else 1)

if __name__ == "__main__":
    main()
