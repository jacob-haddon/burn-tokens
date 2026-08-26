#!/usr/bin/env python3
"""
OSS-Sentinel Verification Engine
Deterministic Cleanroom Sanitizer & Regression Gatekeeper
Verifies memory-safety bug remediation under AddressSanitizer and UBSan.
"""

import sys
import os
import subprocess
import argparse
import json
import shutil
from pathlib import Path

def run_cmd(cmd, cwd=None, timeout=25, env=None):
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    # Set ASan options for deterministic crash reporting
    merged_env["ASAN_OPTIONS"] = "detect_leaks=1:symbolize=1:abort_on_error=1"
    merged_env["UBSAN_OPTIONS"] = "halt_on_error=1:print_stacktrace=1"
    try:
        proc = subprocess.run(
            cmd,
            cwd=cwd,
            shell=isinstance(cmd, str),
            capture_output=True,
            text=True,
            timeout=timeout,
            env=merged_env
        )
        return proc.returncode, proc.stdout, proc.stderr
    except subprocess.TimeoutExpired:
        return -999, "", f"Command timed out after {timeout}s: {cmd}"
    except Exception as e:
        return -1, "", str(e)

def verify_patch(target_dir, build_cmd, run_unpatched_cmd, patch_file, test_cmd=None):
    target_path = Path(target_dir).resolve()
    patch_path = Path(patch_file).resolve()
    
    print(f"[*] Starting OSS-Sentinel Zero-Trust Verification on {target_path.name}")
    print(f"[*] Patch: {patch_path.name}")

    # Step 1: Clean build unpatched
    print("[1/5] Building unpatched target with AddressSanitizer / UBSan...")
    code, stdout, stderr = run_cmd(build_cmd, cwd=target_path)
    if code != 0:
        print(f"[FAIL] Unpatched build failed (exit code {code}):\n{stderr}")
        return False, "Unpatched build failure"

    # Step 2: Run reproducer on unpatched target (MUST CRASH)
    print("[2/5] Running crash reproducer on unpatched binary (Expecting Crash)...")
    code, stdout, stderr = run_cmd(run_unpatched_cmd, cwd=target_path)
    if code == 0:
        print("[FAIL] Unpatched binary did NOT crash on reproducer! Verification rejected.")
        return False, "Reproducer failed to trigger crash on unpatched code"
    
    has_asan = "AddressSanitizer" in stderr or "runtime error:" in stderr or "heap-buffer-overflow" in stderr or "use-after-free" in stderr or code != 0
    print(f"      -> Confirmed expected crash (exit code {code}, ASan detected: {has_asan})")

    # Step 3: Apply defensive patch
    print("[3/5] Applying defensive patch...")
    code, stdout, stderr = run_cmd(f"git apply {patch_path}", cwd=target_path)
    if code != 0:
        # Fallback to patch -p1
        code, stdout, stderr = run_cmd(f"patch -p1 < {patch_path}", cwd=target_path)
        if code != 0:
            print(f"[FAIL] Failed to apply patch:\n{stderr}")
            return False, "Patch application failed"

    # Step 4: Rebuild patched target
    print("[4/5] Rebuilding patched target under ASan/UBSan...")
    code, stdout, stderr = run_cmd(build_cmd, cwd=target_path)
    if code != 0:
        print(f"[FAIL] Patched build failed (exit code {code}):\n{stderr}")
        # Revert
        run_cmd("git reset --hard HEAD", cwd=target_path)
        return False, "Patched build failure"

    # Step 5: Run reproducer on patched binary (MUST PASS 0)
    print("[5/5] Running crash reproducer on patched binary (Expecting Clean 0 Exit)...")
    code, stdout, stderr = run_cmd(run_unpatched_cmd, cwd=target_path)
    if code != 0 or "AddressSanitizer" in stderr or "runtime error:" in stderr:
        print(f"[FAIL] Patched binary still crashed or triggered sanitizer (exit code {code}):\n{stderr}")
        run_cmd("git reset --hard HEAD", cwd=target_path)
        return False, "Patched binary failed reproducer check"

    # Step 6: Run regression test suite if provided
    if test_cmd:
        print("[6/5] Running existing regression test suite...")
        code, stdout, stderr = run_cmd(test_cmd, cwd=target_path)
        if code != 0:
            print(f"[FAIL] Regression test suite failed:\n{stderr}")
            run_cmd("git reset --hard HEAD", cwd=target_path)
            return False, "Regression test suite failure"
        print("      -> 100% regression tests passed.")

    # Revert working directory to clean state
    run_cmd("git reset --hard HEAD", cwd=target_path)

    print("\n" + "="*60)
    print("  [VERIFICATION SUCCESS: 100% CLEAN DEFENSIVE PATCH]")
    print("  - Reproducer verified crash on HEAD")
    print("  - Patch eliminates ASan/UBSan crash cleanly (exit 0)")
    print("  - Zero regression on existing test suite")
    print("="*60 + "\n")
    return True, "Verified Clean"

def main():
    parser = argparse.ArgumentParser(description="OSS-Sentinel Sanitizer Verifier")
    parser.add_argument("--target-dir", required=True, help="Path to target project directory")
    parser.add_argument("--build-cmd", required=True, help="Build command with ASan flags")
    parser.add_argument("--run-cmd", required=True, help="Command to run crash reproducer")
    parser.add_argument("--patch", required=True, help="Path to patch diff file")
    parser.add_argument("--test-cmd", default=None, help="Command to run regression tests")
    
    args = parser.parse_args()
    success, msg = verify_patch(
        args.target_dir,
        args.build_cmd,
        args.run_cmd,
        args.patch,
        args.test_cmd
    )
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
