# Verify Request Idempotency Walkthrough

## What Changed
- Added verification request idempotency Redis key prefix
- Wrapped `VoucherServiceImpl.verify(...)` with request-id based idempotency handling
- Split the original verification body into `doVerify(...)`

## Current Behavior
- Requests without `requestId` keep the original behavior
- Requests with `requestId`:
  - reuse cached result on repeat
  - use `requestId + voucherCode` as idempotency key
  - return a processing response if the same request is already in flight

## Notes
- This is Redis-backed request idempotency, not DB-backed final truth
- Verification correctness still relies on the original voucher status optimistic update
