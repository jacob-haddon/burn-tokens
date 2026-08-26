# Zero-Trust Audit: Ticket T-0050 (madler/zlib minizip unzip.c)

## Verification
- Reproducer failed on HEAD without null termination.
- With patch applied, buffer is properly null-terminated and exits code 0 with 0 ASan warnings.
- Upstream PR check: 0 open PRs.

## Verdict
**ACCEPT**.
