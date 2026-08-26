---
id: R-2026-08-26-OSS-0003
target: madler/zlib (contrib/minizip/unzip.c)
type: vulnerability_remediation
upstream_issue: "https://github.com/madler/zlib/issues/1299"
debian_bug: "Debian Bug #1143912"
date: 2026-08-26
status: verified_clean
patch: projects/01-oss-sentinel/patches/zlib_fix_minizip_null_termination.patch
reproducer: projects/01-oss-sentinel/targets/zlib/contrib/minizip/test_null_term_reproducer.c
---

# Vulnerability Remediation Report: Stack Buffer Over-Read in minizip unzGetCurrentFileInfo() due to Missing Null Termination (Issue #1299 / Debian #1143912)

## 1. Executive Summary

A vulnerability was identified in `madler/zlib` (`contrib/minizip/unzip.c`, Issue [#1299](https://github.com/madler/zlib/issues/1299)). When `unzGetCurrentFileInfo()` is called with a caller-allocated buffer smaller than the entry filename or comment, the function fills the buffer without appending a null terminator `'\0'`. Subsequent calls to `unzLocateFile()` or string functions (`strlen()`) read beyond the buffer boundary, resulting in a stack buffer over-read / info leak / DoS under AddressSanitizer.

## 2. Root Cause Analysis

In `unzip.c`:
```c
if (file_info.size_filename < fileNameBufferSize) {
    *(szFileName + file_info.size_filename) = '\0';
    uSizeRead = file_info.size_filename;
} else {
    uSizeRead = fileNameBufferSize; // BUG: No null terminator is written!
}
```

## 3. Verified Defensive Patch

```diff
--- a/contrib/minizip/unzip.c
+++ b/contrib/minizip/unzip.c
@@ -860,7 +860,11 @@ local int unz64local_GetCurrentFileInfoInternal(unzFile file,
             uSizeRead = file_info.size_filename;
         }
         else
-            uSizeRead = fileNameBufferSize;
+        {
+            uSizeRead = fileNameBufferSize > 0 ? fileNameBufferSize - 1 : 0;
+            if (fileNameBufferSize > 0)
+                *(szFileName + uSizeRead) = '\0';
+        }
 
         if ((file_info.size_filename>0) && (fileNameBufferSize>0))
             if (ZREAD64(s->z_filefunc, s->filestream,szFileName,uSizeRead)!=uSizeRead)
@@ -970,7 +974,11 @@ local int unz64local_GetCurrentFileInfoInternal(unzFile file,
             uSizeRead = file_info.size_file_comment;
         }
         else
-            uSizeRead = commentBufferSize;
+        {
+            uSizeRead = commentBufferSize > 0 ? commentBufferSize - 1 : 0;
+            if (commentBufferSize > 0)
+                *(szComment + uSizeRead) = '\0';
+        }
```

## 4. Verification Results

- **Reproducer on unpatched code**: `test_null_term_reproducer.c` failed assertion `small_buf[15] == '\0'` (held character `'A'`).
- **Reproducer on patched code**: Exits code `0` cleanly with `small_buf[15] == '\0'`.
- **Sanitizers**: 0 AddressSanitizer/UBSan errors, 0 memory leaks.
- **Upstream Deduplication**: 0 open PRs on GitHub.
