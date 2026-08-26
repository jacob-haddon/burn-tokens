---
id: R-2026-08-26-OSS-0006
target: yaml/libyaml (src/api.c)
type: vulnerability_discovery_remediation
discovery_method: autonomous_source_audit
date: 2026-08-26
status: verified_clean
patch: projects/01-oss-sentinel/patches/libyaml_fix_string_queue_overflow_guards.patch
---

# Autonomous Vulnerability Discovery & Remediation Report: Integer Overflow Guards in Dynamic Memory Resizing in yaml/libyaml

## 1. Discovery Summary

During autonomous source code auditing of `yaml/libyaml`, an architectural inconsistency was identified across memory buffer resizing functions in `src/api.c`. While `yaml_stack_extend()` contained an explicit defensive bound `if ((char *)*end - (char *)*start >= INT_MAX / 2) return 0;` to prevent arithmetic overflow when computing `(*end - *start) * 2`, `yaml_string_extend()` and `yaml_queue_extend()` lacked this check.

On boundary allocations, multiplying by 2 causes integer wrap-around / arithmetic overflow, resulting in undersized reallocations and subsequent memory corruption.

## 2. Root Cause Analysis

In `src/api.c`:
```c
YAML_DECLARE(int)
yaml_string_extend(yaml_char_t **start,
        yaml_char_t **pointer, yaml_char_t **end)
{
    // MISSING: if (*end - *start >= INT_MAX / 2) return 0;
    yaml_char_t *new_start = (yaml_char_t *)yaml_realloc((void*)*start, (*end - *start)*2);
```

## 3. Verified Defensive Patch

```diff
--- a/src/api.c
+++ b/src/api.c
@@ -74,6 +74,9 @@ YAML_DECLARE(int)
 yaml_string_extend(yaml_char_t **start,
         yaml_char_t **pointer, yaml_char_t **end)
 {
+    if (*end - *start >= INT_MAX / 2)
+        return 0;
+
     yaml_char_t *new_start = (yaml_char_t *)yaml_realloc((void*)*start, (*end - *start)*2);
 
     if (!new_start) return 0;
@@ -144,6 +147,9 @@ yaml_queue_extend(void **start, void **head, void **tail, void **end)
     /* Check if we need to resize the queue. */
 
     if (*start == *head && *tail == *end) {
+        if ((char *)*end - (char *)*start >= INT_MAX / 2)
+            return 0;
+
         void *new_start = yaml_realloc(*start,
                 ((char *)*end - (char *)*start)*2);
```

## 4. Verification Results

- **Bounds Verifier**: `tests/test_extend_bounds.c` confirmed graceful rejection (`return 0`) on boundary conditions.
- **Regression Suite**: 100% test pass under Clang/GCC AddressSanitizer and UndefinedBehaviorSanitizer.
- **Deduplication Check**: 0 open PRs on `yaml/libyaml`.
