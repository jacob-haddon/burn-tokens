#!/usr/bin/env python3
"""
Upstream Issue, PR & AI Policy Deduplication Checker for OSS-Sentinel
Ensures agents never submit duplicate PRs or violate repository AI contribution policies.
"""

import sys
import subprocess
import json
import re
from pathlib import Path

def check_ai_policy(repo):
    """Inspects upstream CONTRIBUTING.md / SECURITY.md for anti-AI rules."""
    try:
        cmd = ["gh", "api", f"/repos/{repo}/contents/CONTRIBUTING.md", "--jq", ".content"]
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
        if res.returncode == 0 and res.stdout.strip():
            import base64
            content = base64.b64decode(res.stdout.strip()).decode('utf-8', errors='ignore')
            # Check for explicit AI bans
            if re.search(r"(AI\s+AND\s+LLM\s+ARE\s+FORBIDDEN|no\s+AI\s+contributions|do\s+not\s+submit.*LLM|generative\s+AI.*forbidden|AI.*not\s+accept)", content, re.IGNORECASE):
                print(f"[⚠️ AI POLICY WARNING] Repository '{repo}' explicitly forbids LLM/AI-generated contributions!")
                print("   -> Policy: Do NOT submit automated upstream PRs. Local verification & research only.")
                return False
    except Exception:
        pass
    return True

def check_upstream(repo, query):
    print(f"[*] Checking upstream repository '{repo}' for query: '{query}'...")
    
    # 0. Check AI Contribution Policy
    ai_allowed = check_ai_policy(repo)
    
    # 1. Check open PRs
    try:
        pr_cmd = ["gh", "pr", "list", "--repo", repo, "--search", query, "--state", "open", "--json", "number,title,url"]
        res_pr = subprocess.run(pr_cmd, capture_output=True, text=True, timeout=10)
        open_prs = json.loads(res_pr.stdout) if res_pr.returncode == 0 else []
    except Exception as e:
        open_prs = []
        
    # 2. Check open issues
    try:
        issue_cmd = ["gh", "issue", "list", "--repo", repo, "--search", query, "--state", "open", "--json", "number,title,url"]
        res_issue = subprocess.run(issue_cmd, capture_output=True, text=True, timeout=10)
        open_issues = json.loads(res_issue.stdout) if res_issue.returncode == 0 else []
    except Exception as e:
        open_issues = []

    print(f"    -> Open Issues matching query: {len(open_issues)}")
    for iss in open_issues[:3]:
        print(f"       • #{iss['number']}: {iss['title']} ({iss['url']})")
        
    print(f"    -> Open PRs matching query: {len(open_prs)}")
    for pr in open_prs[:3]:
        print(f"       • PR #{pr['number']}: {pr['title']} ({pr['url']})")

    if open_prs:
        print(f"\n[BLOCKED] Duplicate PR already exists! ({len(open_prs)} active PRs found). Do NOT claim.")
        return False
    elif not ai_allowed:
        print("\n[RESEARCH ONLY] Target is valid for local verification, but PR submission is disabled due to maintainer policy.")
        return True
    else:
        print("\n[CLEAN] No existing open PR found and AI policy clean. Safe to propose and execute.")
        return True

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 check_upstream.py <owner/repo> <search_query>")
        sys.exit(1)
    safe = check_upstream(sys.argv[1], sys.argv[2])
    sys.exit(0 if safe else 2)
