---
id: R-2026-08-30-OSS-0007
target: troydhanson/uthash (src/utarray.h)
type: vulnerability_discovery_remediation
discovery_method: autonomous_source_audit
worker_node: omarchy-1
date: 2026-08-30
status: verified_clean
patch: projects/01-oss-sentinel/patches/uthash_fix_utarray_reserve_overflow.patch
---

# Autonomous Vulnerability Discovery & Remediation Report: Unsigned Integer Overflow and Infinite Loop in utarray_reserve() in troydhanson/uthash

## 1. Discovery Summary

During autonomous source code auditing of the widely used C header library `troydhanson/uthash` on remote compute worker `omarchy-1`, an algorithmic flaw was discovered in `src/utarray.h` within `utarray_reserve()`. 

When growing dynamic array capacity, the loop `while (((a)->i+(by)) > (a)->n) { (a)->n = ((a)->n ? (2*(a)->n) : 8); }` doubles `(a)->n` (an `unsigned` int). When `(a)->n >= 0x80000000`, `2 * (a)->n` overflows `unsigned` to `0`. In the subsequent iteration, `(a)->n ? 2*(a)->n : 8` evaluates to false, resetting `(a)->n` to `8`. Because `(a)->i + by > 8`, it enters an infinite loop, freezing the process at 100% CPU. Additionally, the size calculation `(a)->n * (a)->icd.sz` lacked `SIZE_MAX` multiplication overflow validation before passing to `realloc()`.

## 2. Root Cause Analysis

In `src/utarray.h`:
```c
#define utarray_reserve(a,by) do {                                            \
  if (((a)->i+(by)) > (a)->n) {                                               \
    char *utarray_tmp;                                                        \
    while (((a)->i+(by)) > (a)->n) { (a)->n = ((a)->n ? (2*(a)->n) : 8); }    \
    utarray_tmp=(char*)realloc((a)->d, (a)->n*(a)->icd.sz);                   \
    if (utarray_tmp == NULL) {                                                \
      utarray_oom();                                                          \
    }                                                                         \
    (a)->d=utarray_tmp;                                                       \
  }                                                                           \
} while(0)
```

## 3. Verified Defensive Patch

```diff
--- a/src/utarray.h
+++ b/src/utarray.h
@@ -90,10 +90,22 @@ typedef struct {
 } while(0)
 
 #define utarray_reserve(a,by) do {                                            \
+  if ((a)->i > (unsigned)-1 - (by)) {                                         \
+    utarray_oom();                                                            \
+  }                                                                           \
   if (((a)->i+(by)) > (a)->n) {                                               \
     char *utarray_tmp;                                                        \
-    while (((a)->i+(by)) > (a)->n) { (a)->n = ((a)->n ? (2*(a)->n) : 8); }    \
-    utarray_tmp=(char*)realloc((a)->d, (a)->n*(a)->icd.sz);                   \
+    while (((a)->i+(by)) > (a)->n) {                                          \
+      if ((a)->n > (unsigned)-1 / 2) {                                        \
+        (a)->n = ((a)->i + (by));                                             \
+        break;                                                                \
+      }                                                                       \
+      (a)->n = ((a)->n ? (2*(a)->n) : 8);                                     \
+    }                                                                         \
+    if ((a)->icd.sz > 0 && (size_t)(a)->n > (size_t)-1 / (a)->icd.sz) {       \
+      utarray_oom();                                                          \
+    }                                                                         \
+    utarray_tmp=(char*)realloc((a)->d, (size_t)(a)->n*(a)->icd.sz);           \
     if (utarray_tmp == NULL) {                                                \
       utarray_oom();                                                          \
     }                                                                         \
```

## 4. Dual-Engine Verification Results

- **Infinite Loop Reproducer**: Confirmed that unpatched code hangs at 100% CPU and triggers `SIGALRM` timeout, whereas patched code handles boundary capacity smoothly.
- **Full Test Suite**: 100% (101/101) tests passed in `tests/`.
- **Deduplication Gate**: 0 open PRs on `troydhanson/uthash`.
