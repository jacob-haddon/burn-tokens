#!/usr/bin/env python3
"""
Autonomous Research Lab: Orchestrator State Machine, Watchdog & Adaptive Tick Inspector
- Tracks active online agents and queue states.
- Watchdog: Detects hanging tasks where artifacts were already produced.
- Watchdog: Detects stale/abandoned locks from inactive agents and auto-recovers them.
- Dynamic Backoff: Computes optimal sleep interval to save token quota.
"""

from pathlib import Path
from datetime import datetime, timezone

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent

import subprocess
import json

def check_github_ci():
    try:
        cmd = ["gh", "run", "list", "--repo", "jacob-haddon/burn-tokens", "--limit", "2", "--json", "name,status,conclusion,url"]
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        if res.returncode == 0:
            return json.loads(res.stdout)
    except Exception:
        pass
    return []


def parse_frontmatter(file_path):
    try:
        content = file_path.read_text(encoding='utf-8')
    except Exception:
        return {}
    if not content.startswith('---'):
        return {}
    parts = content.split('---', 2)
    if len(parts) < 3:
        return {}
    raw_yaml = parts[1]
    meta = {}
    for line in raw_yaml.splitlines():
        line = line.strip()
        if not line or line.startswith('#') or ':' not in line:
            continue
        k, v = line.split(':', 1)
        meta[k.strip()] = v.strip().strip('"\'')
    return meta

def update_frontmatter_field(file_path, key, value):
    content = file_path.read_text(encoding='utf-8')
    if not content.startswith('---'):
        return
    parts = content.split('---', 2)
    if len(parts) < 3:
        return
    lines = parts[1].splitlines()
    new_lines = []
    found = False
    for line in lines:
        if line.strip().startswith(f"{key}:"):
            new_lines.append(f"{key}: {value}")
            found = True
        else:
            new_lines.append(line)
    if not found:
        new_lines.append(f"{key}: {value}")
    new_yaml = "\n".join(new_lines)
    file_path.write_text(f"---{new_yaml}\n---{parts[2]}", encoding='utf-8')

def watchdog_audit(tickets_dir, agents_online_map, now):
    repaired = []
    completed_inbox = list((WORKSPACE_ROOT / "inbox" / "completed").glob("*.md"))
    results_notes = list(WORKSPACE_ROOT.glob("projects/*/results/*.md"))
    
    for t_file in tickets_dir.glob("*.md"):
        meta = parse_frontmatter(t_file)
        t_id = meta.get("id", t_file.stem)
        status = meta.get("status", "unknown")
        owner = meta.get("owner", "unassigned")
        
        if status == "in_progress":
            has_notice = any(t_id in f.name for f in completed_inbox)
            has_result = any(t_id in f.name or t_id.lower() in f.name.lower() for f in results_notes)
            
            if has_notice or has_result:
                update_frontmatter_field(t_file, "status", "review")
                update_frontmatter_field(t_file, "updated", now.isoformat())
                repaired.append(f"Auto-transitioned {t_id} from in_progress to REVIEW (deliverables detected on disk)")
            else:
                owner_seen = agents_online_map.get(owner, {}).get("diff_min", 999)
                if owner != "unassigned" and owner_seen > 25.0:
                    update_frontmatter_field(t_file, "status", "ready")
                    update_frontmatter_field(t_file, "owner", "unassigned")
                    update_frontmatter_field(t_file, "updated", now.isoformat())
                    repaired.append(f"Reclaimed abandoned ticket {t_id} from inactive agent {owner} (inactive for {owner_seen:.1f}m)")
    return repaired

def main():
    tickets_dir = WORKSPACE_ROOT / "tickets"
    agents_dir = WORKSPACE_ROOT / "agents"
    now = datetime.now(timezone.utc)
    
    # 1. Parse Agents & Presence
    agents_online = []
    agents_offline = []
    agents_map = {}
    
    if agents_dir.exists():
        for a_file in sorted(agents_dir.glob("*.md")):
            meta = parse_frontmatter(a_file)
            agent_id = meta.get("id", a_file.stem)
            status = meta.get("status", "unknown")
            ticket = meta.get("current_ticket", meta.get("ticket", "none"))
            last_seen_str = meta.get("last_seen", meta.get("updated_at", ""))
            
            diff_min = 999.0
            is_online = False
            if last_seen_str:
                try:
                    dt = datetime.fromisoformat(last_seen_str.replace("Z", "+00:00"))
                    diff_min = (now - dt).total_seconds() / 60.0
                    if diff_min <= 15.0:
                        is_online = True
                except Exception:
                    pass
            if status in ("active", "reviewing", "executing"):
                is_online = True
                
            entry = {"id": agent_id, "status": status, "ticket": ticket, "last_seen": last_seen_str, "diff_min": diff_min}
            agents_map[agent_id] = entry
            if is_online:
                agents_online.append(entry)
            else:
                agents_offline.append(entry)
                
    # 2. Run Watchdog
    repaired_events = []
    if tickets_dir.exists():
        repaired_events = watchdog_audit(tickets_dir, agents_map, now)
        
    # 3. Parse Tickets
    review_tickets = []
    ready_tickets = []
    in_progress_tickets = []
    done_tickets = []
    
    if tickets_dir.exists():
        for t_file in sorted(tickets_dir.glob("*.md")):
            meta = parse_frontmatter(t_file)
            status = meta.get("status", "unknown")
            ticket_id = meta.get("id", t_file.stem)
            title = meta.get("title", "Untitled")
            owner = meta.get("owner", "unassigned")
            
            entry = {"id": ticket_id, "title": title, "owner": owner, "file": str(t_file.relative_to(WORKSPACE_ROOT))}
            
            if status in ("review", "needs_changes"):
                review_tickets.append(entry)
            elif status == "ready":
                ready_tickets.append(entry)
            elif status in ("in_progress", "reviewing"):
                in_progress_tickets.append(entry)
            elif status == "done":
                done_tickets.append(entry)
                
    # 4. Compute Dynamic Sleep Interval (Exponential Backoff)
    if review_tickets or ready_tickets or repaired_events:
        sleep_sec = 60       # High-responsiveness mode: active work / review pending
        sleep_reason = "Active work or review queue non-empty"
    elif in_progress_tickets:
        sleep_sec = 180      # Compute mode: background tasks crunching CPU (3 min)
        sleep_reason = "Tasks actively computing in background, saving token quota"
    else:
        sleep_sec = 300      # Eco mode: queues idle, waiting on long-term triggers (5 min)
        sleep_reason = "Queues idle, eco-mode backoff active"
        
    print("=" * 65)
    print("  AUTONOMOUS LAB: LIVE ROSTER, WATCHDOG & ADAPTIVE HEARTBEAT")
    print("=" * 65)
    if repaired_events:
        print("[⚡ WATCHDOG AUTO-HEAL EVENTS] :")
        for event in repaired_events:
            print(f"    - 🛠️  {event}")
        print("-" * 65)
        
    # 1.1 Check GitHub CI & Pages
    ci_runs = check_github_ci()
    if ci_runs:
        print("[*] GITHUB CI & ACTIONS STATUS :")
        for r in ci_runs:
            status_icon = "🟢" if r.get("conclusion") == "success" else ("🟡" if r.get("status") == "in_progress" else "🔴")
            print(f"    - {status_icon} [{r.get('name')}] status={r.get('status')} conclusion={r.get('conclusion')}")
        print("-" * 65)

    print(f"[*] AGENTS ONLINE ({len(agents_online)}) :")
    for a in agents_online:
        print(f"    - 🟢 [{a['id']}] status: {a['status']} | ticket: {a['ticket']}")
    if agents_offline:
        print(f"[*] AGENTS INACTIVE / FINISHED ({len(agents_offline)}) :")
        for a in agents_offline:
            print(f"    - ⚪ [{a['id']}] status: {a['status']}")
            
    print("-" * 65)
    print(f"[*] TICKETS IN PROGRESS : {len(in_progress_tickets)}")
    for t in in_progress_tickets:
        print(f"    - 🟡 [{t['id']}] {t['title']} (Owner: {t['owner']})")
        
    print(f"[*] TICKETS IN REVIEW   : {len(review_tickets)}")
    for t in review_tickets:
        print(f"    - 🟣 [{t['id']}] {t['title']} (File: {t['file']})")
        
    print(f"[*] READY QUEUE         : {len(ready_tickets)}")
    for t in ready_tickets:
        print(f"    - 🟢 [{t['id']}] {t['title']} (File: {t['file']})")
        
    print(f"[*] COMPLETED TICKETS   : {len(done_tickets)}")
    print("-" * 65)
    print(f"[⏱️  ADAPTIVE HEARTBEAT] : Sleep {sleep_sec}s ({sleep_sec // 60}m) | Reason: {sleep_reason}")
    print("=" * 65)
    
    # State Machine Decision
    if review_tickets:
        target = review_tickets[0]
        print(f"==> RECOMMENDED ROLE: [REVIEWER]")
        print(f"    Target: Ticket {target['id']} ({target['title']})")
    elif ready_tickets:
        target = ready_tickets[0]
        print(f"==> RECOMMENDED ROLE: [EXECUTOR]")
        print(f"    Target: Ticket {target['id']} ({target['title']})")
    else:
        print(f"==> RECOMMENDED ROLE: [TASK SCOUT]")
        print(f"    Target: All queues empty.")
    print("=" * 65)

if __name__ == "__main__":
    main()
