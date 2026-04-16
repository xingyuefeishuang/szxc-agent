# Verify Idempotency Cache Tighten Plan

## Goal
- Tighten request-id idempotency cache behavior for verification.

## Scope
- `VoucherServiceImpl.verify(...)`

## Change
- Cache only successful verification results
- Do not long-cache failed verification results
- Release the in-flight marker when verification returns a fail result

## Reason
- Avoid freezing retryable verification failures behind a 24-hour cached fail result
