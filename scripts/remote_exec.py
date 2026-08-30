#!/usr/bin/env python3
"""
burn-tokens: Remote Worker Dispatcher (omarchy-1)
Runs heavy compilation, SAT searches, or sanitizer builds on the dedicated Tailscale node.
"""

import sys
import subprocess
import shlex

REMOTE_HOST = "omarchy-1"
REMOTE_WORK_DIR = "~/work/burn-tokens"

def run_remote(command_str: str, sync_first: bool = True):
    # Setup PATH for remote session
    remote_path = 'export PATH="$HOME/.elan/bin:$HOME/.cargo/bin:$HOME/.local/share/mise/shims:$PATH"'
    
    if sync_first:
        sync_cmd = f"cd {REMOTE_WORK_DIR} && git pull origin master --quiet 2>/dev/null || true"
        full_remote_cmd = f"{remote_path} && {sync_cmd} && cd {REMOTE_WORK_DIR} && {command_str}"
    else:
        full_remote_cmd = f"{remote_path} && cd {REMOTE_WORK_DIR} && {command_str}"
        
    ssh_cmd = [
        "ssh", "-o", "BatchMode=yes", "-o", "StrictHostKeyChecking=no",
        REMOTE_HOST,
        f"bash -lc {shlex.quote(full_remote_cmd)}"
    ]
    
    print(f"[*] Dispatching command to worker node ({REMOTE_HOST}):\n    $ {command_str}\n")
    proc = subprocess.run(ssh_cmd)
    return proc.returncode

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 scripts/remote_exec.py <command>")
        sys.exit(1)
    
    cmd = " ".join(sys.argv[1:])
    exit_code = run_remote(cmd)
    sys.exit(exit_code)
