---
id: R-2026-08-26-OSS-0004
target: google/brotli (c/tools/brotli.c)
type: vulnerability_remediation
upstream_issue: "https://github.com/google/brotli/issues/1508"
date: 2026-08-26
status: verified_clean
patch: projects/01-oss-sentinel/patches/brotli_fix_cli_stack_overflow.patch
---

# Vulnerability Remediation Report: Stack Buffer Overflow in ParseParams() via Unbounded Empty-String CLI Arguments in google/brotli (Issue #1508)

## 1. Executive Summary

A stack buffer overflow vulnerability exists in `google/brotli` command line tool (`c/tools/brotli.c`, Issue [#1508](https://github.com/google/brotli/issues/1508)). When more than 24 empty string arguments (`""`) are supplied to the `brotli` CLI utility, `ParseParams()` writes indices into the fixed-size `params->not_input_indices[MAX_OPTIONS]` array (where `MAX_OPTIONS = 24`) without checking `next_option_index`. This leads to sequential out-of-bounds stack writes in `main()`, corrupting adjacent stack pointers (such as `context.dictionary`) and causing an AddressSanitizer deadly signal / memory corruption.

## 2. Root Cause Analysis

In `c/tools/brotli.c`:
```c
for (i = 1; i < argc; ++i) {
    const char* arg = argv[i];
    size_t arg_len = arg ? strlen(arg) : 0;

    if (arg_len == 0) {
        params->not_input_indices[next_option_index++] = i; // BUG: No bounds check!
        continue;
    }

    if (next_option_index > (MAX_OPTIONS - 2)) {           // Bounds check only reached for non-empty args!
        fprintf(stderr, "too many options passed\n");
        return COMMAND_INVALID;
    }
    ...
```

## 3. Verified Defensive Patch

We move the `next_option_index > (MAX_OPTIONS - 2)` check to the beginning of the argument processing loop, ensuring that all argument paths (both empty and non-empty) are strictly bounded before writing to `params->not_input_indices`:

```diff
--- a/c/tools/brotli.c
+++ b/c/tools/brotli.c
@@ -301,20 +301,17 @@ static Command ParseParams(Context* params) {
        contain pointers to strings"; NULL and 0-length are not forbidden. */
     size_t arg_len = arg ? strlen(arg) : 0;
 
-    if (arg_len == 0) {
-      params->not_input_indices[next_option_index++] = i;
-      continue;
-    }
-
-    /* Too many options. The expected longest option list is:
-       "-q 0 -w 10 -o f -D d -S b -d -f -k -n -v -K --", i.e. 17 items in total.
-       This check is an additional guard that is never triggered, but provides
-       a guard for future changes. */
+    /* Too many options. Guard against overflowing not_input_indices array. */
     if (next_option_index > (MAX_OPTIONS - 2)) {
       fprintf(stderr, "too many options passed\n");
       return COMMAND_INVALID;
     }
 
+    if (arg_len == 0) {
+      params->not_input_indices[next_option_index++] = i;
+      continue;
+    }
+
     /* Input file entry. */
     if (after_dash_dash || arg[0] != '-' || arg_len == 1) {
       input_count++;
```

## 4. Verification Results

- **Reproducer on unpatched code**: `args=(); for ((k=0; k<50; k++)); do args+=(""); done; ./build/brotli "${args[@]}"` triggered `AddressSanitizer: SEGV` at `c/enc/encode.c:1808` due to corrupted `context.dictionary` stack pointer.
- **Reproducer on patched code**: Cleanly outputs `too many options passed` and exits gracefully with 0 ASan/UBSan diagnostics.
- **Test Suite**: 100% of 73 unit and roundtrip tests passed (`ctest`).
- **Deduplication Check**: 0 open PRs on GitHub repository `google/brotli`.
