#!/usr/bin/env python3
"""
Autonomous Repository Sanitation & Structure Guardian (Caretaker)
Maintains zero-garbage policy, permanently purges scratch files, and audits structural sanity.
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
    "ROLES.md", "TASK_DISCOVERY.md", "TICKET_REVIEW.md", "runs.jsonl"
}

ALLOWED_ROOT_DIRS = {
    ".git", ".github", ".venv", "projects", "tickets", "proposals",
    "handoffs", "reviews", "docs", "scripts", "roles", "inbox", "agents", "prompts", "notes"
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
        if "/." in root or root.startswith(".") or ".git" in root or "build" in root or ".lake" in root or "target" in root or ".venv" in root:
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
    stray_binaries = audit_stray_binaries()
    
    score = 100
    if clutter:
        score -= min(40, len(clutter) * 10)
    if structure_issues:
        score -= min(40, len(structure_issues) * 15)
    if stray_binaries:
        score -= min(20, len(stray_binaries) * 5)
        
    score = max(0, score)
    
    print("=================================================================")
    print(f"  REPOSITORY SANITATION AUDIT REPORT (Health Score: {score}/100)")
    print("=================================================================")
    if not clutter:
        print("[*] ROOT DIRECTORY : 🟢 Clean (Zero root clutter)")
    else:
        print(f"[*] ROOT DIRECTORY : 🔴 Cluttered ({len(clutter)} illegal items):")
        for item in clutter:
            print(f"    - {item.name}")
            
    if not stray_binaries:
        print("[*] BINARIES & ARTIFACTS : 🟢 Clean (No stray binaries)")
    else:
        print(f"[*] BINARIES & ARTIFACTS : 🔴 Dirty ({len(stray_binaries)} stray binaries):")
        for b in stray_binaries:
            print(f"    - {b.relative_to(WORKSPACE_ROOT)}")
            
    if not structure_issues:
        print("[*] PILLAR STRUCTURE : 🟢 Symmetrical & Healthy (All 4 pillars aligned)")
    else:
        print(f"[*] PILLAR STRUCTURE : 🔴 Broken ({len(structure_issues)} issues):")
        for iss in structure_issues:
            print(f"    - {iss}")
            
    print("-----------------------------------------------------------------")
    return score, clutter, stray_binaries

def clean_scratch_files():
    print("[*] Executing Caretaker Automated Garbage Collection (Permanent Purge)...")
    clutter = audit_root_clutter()
    cleaned = 0
    for item in clutter:
        if item.is_file() or item.is_symlink():
            item.unlink()
            cleaned += 1
        elif item.is_dir():
            shutil.rmtree(item)
            cleaned += 1
            
    stray_binaries = audit_stray_binaries()
    for b in stray_binaries:
        b.unlink()
        cleaned += 1
        
    print(f"[✓] Caretaker Garbage Collection complete. Purged {cleaned} items.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Repository Sanitation Guardian")
    parser.add_argument("--clean", action="store_true", help="Automatically purge root clutter and stray files")
    args = parser.parse_args()
    
    if args.clean:
        clean_scratch_files()
        
    score, clutter, strays = perform_sanitation_check()
    sys.exit(0 if score == 100 else 1)
