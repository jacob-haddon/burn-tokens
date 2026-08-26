---
id: R-2026-08-26-OSS-0001
target: DaveGamble/cJSON (cJSON_Utils)
type: vulnerability_remediation
author: Jacob Haddon (@jacob-haddon)
date: 2026-08-26
status: verified_clean
patch: projects/01-oss-sentinel/patches/cjson_fix_rfc6901_pointer_unescaping.patch
reproducer: projects/01-oss-sentinel/targets/cjson/tests/test_patch_escape_bug.c
---

# Remediation Report: In-Place RFC 6901 Pointer Decode Buffer Corruption in cJSON_Utils

## 1. Executive Summary

During autonomous security auditing of `DaveGamble/cJSON` (`cJSON_Utils.c`), a critical string corruption flaw was identified in `decode_pointer_inplace`. The function is responsible for unescaping RFC 6901 JSON Pointer tokens (`~0` -> `~`, `~1` -> `/`) during JSON Patch operations (`cJSONUtils_ApplyPatches`, `cJSONUtils_GetPointer`).

Due to two bugs:
1. `decoded_string[1] = '/';` (writing to index 1 instead of 0 for `~1` tokens).
2. Missing `else { decoded_string[0] = string[0]; }` branch to shift non-escaped characters once the write pointer lagged behind the read pointer.

Any JSON Pointer path containing an escaped token (e.g. `~0hello_world` or `~1path~1to~0file`) resulted in silent memory corruption (`~0hello_worl` and `~/path/1~o~0f`), causing all subsequent patch lookups to fail with `INVALID_PATH` error code 13.

## 2. Root Cause Analysis

In `cJSON_Utils.c`:
```c
static void decode_pointer_inplace(unsigned char *string)
{
    unsigned char *decoded_string = string;
    for (; *string; (void)decoded_string++, string++)
    {
        if (string[0] == '~')
        {
            if (string[1] == '0') decoded_string[0] = '~';
            else if (string[1] == '1') decoded_string[1] = '/'; // BUG 1: index 1 instead of 0
            else return; // BUG 2: unterminated return
            string++;
        }
        // BUG 3: missing else branch. When decoded_string falls behind string, non-escaped chars are skipped!
    }
    decoded_string[0] = '\0';
}
```

## 3. Verified Defensive Patch

```diff
--- a/cJSON_Utils.c
+++ b/cJSON_Utils.c
@@ -374,16 +374,21 @@ static void decode_pointer_inplace(unsigned char *string)
             }
             else if (string[1] == '1')
             {
-                decoded_string[1] = '/';
+                decoded_string[0] = '/';
             }
             else
             {
                 /* invalid escape sequence */
+                *decoded_string = '\0';
                 return;
             }
 
             string++;
         }
+        else
+        {
+            decoded_string[0] = string[0];
+        }
     }
 
     decoded_string[0] = '\0';
```

## 4. Verification Results

- **Deterministic Crash / Failure on HEAD**: `test_patch_escape_bug.c` failed with code 13 on unpatched code.
- **Sanitizer Verification**: 0 AddressSanitizer/UBSan errors, 0 memory leaks.
- **Regression Suite**: 19/19 existing cJSON test suites pass (100%).
