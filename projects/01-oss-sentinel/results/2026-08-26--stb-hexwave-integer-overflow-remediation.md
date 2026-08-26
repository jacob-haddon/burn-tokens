---
id: R-2026-08-26-OSS-0002
target: nothings/stb (stb_hexwave.h)
type: vulnerability_remediation
upstream_issue: "https://github.com/nothings/stb/issues/1961"
date: 2026-08-26
status: verified_clean
patch: projects/01-oss-sentinel/patches/stb_fix_hexwave_integer_overflow.patch
reproducer: projects/01-oss-sentinel/targets/stb/tests/poc_hexwave_overflow.c
---

# Vulnerability Remediation Report: Integer Overflow in hexwave_init() Causing Heap/Stack Buffer Overflow in stb_hexwave.h (Issue #1961)

## 1. Executive Summary

A severe memory corruption vulnerability was reported in `nothings/stb` ([Issue #1961](https://github.com/nothings/stb/issues/1961)) within the `stb_hexwave.h` audio synthesizer header. When unvalidated or attacker-controllable `width` and `oversample` arguments are passed to `hexwave_init()`, signed integer overflow occurs in the buffer sizing calculations (`halfwidth * oversample` and `width * (oversample + 1)`), resulting in undersized allocations and massive subsequent out-of-bounds writes (up to 15.75 MB past bounds) in the deinterleaving loop.

## 2. Root Cause Analysis

In `stb_hexwave.h`:
```c
STB_HEXWAVE_DEF void hexwave_init(int width, int oversample, float *user_buffer)
{
   int halfwidth = width/2;
   int half = halfwidth*oversample;           // 1. Signed integer overflow when oversample is large
   int blep_buffer_count = width*(oversample+1); // 2. Signed integer overflow
   int n = 2*half+1;                          // 3. Negative or tiny allocation size
   ...
   float *buffers = user_buffer ? user_buffer : (float *) malloc(sizeof(float) * n * 2);
   ...
   if (width > STB_HEXWAVE_MAX_BLEP_LENGTH)   // 4. Clamping occurs AFTER all allocations have already completed!
      width = STB_HEXWAVE_MAX_BLEP_LENGTH;
   ...
   for (j=0; j <= oversample; ++j)
      for (i=0; i < width; ++i)
         blep_buffer [j*width+i] = step[j+i*oversample]; // 5. Severe Out-Of-Bounds heap/stack write!
}
```

## 3. Verified Defensive Patch

We enforce input validation and bounds clamping *before* any buffer size calculation or memory allocation takes place:
1. `width` is clamped to $[4, \text{STB\_HEXWAVE\_MAX\_BLEP\_LENGTH}]$ and forced even.
2. `oversample` is clamped to $[2, 1024]$ to guarantee that intermediate multiplications never overflow 32-bit signed integers.
3. `malloc` return value is checked before dereferencing.

```diff
--- a/stb_hexwave.h
+++ b/stb_hexwave.h
@@ -556,23 +556,37 @@ STB_HEXWAVE_DEF void hexwave_shutdown(float *user_buffer)
 // buffer should be NULL or must be 4*(width*(oversample+1)*2 + 
 STB_HEXWAVE_DEF void hexwave_init(int width, int oversample, float *user_buffer)
 {
-   int halfwidth = width/2;
-   int half = halfwidth*oversample;
-   int blep_buffer_count = width*(oversample+1);
-   int n = 2*half+1;
-#ifdef STB_HEXWAVE_NO_ALLOCATION
-   float *buffers = user_buffer;
-#else
-   float *buffers = user_buffer ? user_buffer : (float *) malloc(sizeof(float) * n * 2);
-#endif
-   float *step    = buffers+0*n;
-   float *ramp    = buffers+1*n;
-   float *blep_buffer, *blamp_buffer;
+   int halfwidth, half, blep_buffer_count, n;
+   float *buffers, *step, *ramp, *blep_buffer, *blamp_buffer;
    double integrate_impulse=0, integrate_step=0;
    int i,j;
 
+   if (width < 4)
+      width = 4;
    if (width > STB_HEXWAVE_MAX_BLEP_LENGTH)
       width = STB_HEXWAVE_MAX_BLEP_LENGTH;
+   width &= ~1;
+
+   if (oversample < 2)
+      oversample = 2;
+   if (oversample > 1024)
+      oversample = 1024;
+
+   halfwidth = width/2;
+   half = halfwidth*oversample;
+   blep_buffer_count = width*(oversample+1);
+   n = 2*half+1;
+
+#ifdef STB_HEXWAVE_NO_ALLOCATION
+   buffers = user_buffer;
+#else
+   buffers = user_buffer ? user_buffer : (float *) malloc(sizeof(float) * n * 2);
+#endif
+   if (!buffers)
+      return;
+
+   step    = buffers+0*n;
+   ramp    = buffers+1*n;
```

## 4. Dual-Engine Verification Results

- **Reproducer on HEAD**: `poc_hexwave_overflow.c` crashed with `AddressSanitizer: SEGV in hexwave_init` and `signed integer overflow` in UBSan.
- **Verification on Patched**: Exits `0` cleanly with 0 ASan/UBSan warnings.
- **Regression Suite**: `test_hexwave_valid.c` passed 100% with zero errors.
- **Upstream Deduplication**: `scripts/check_upstream.py` confirms 0 existing PRs on `nothings/stb`.
