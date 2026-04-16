# Verify Request Idempotency Plan

## Goal
- Make `VerifyRequestDO.requestId` a real idempotency key in the verification flow.

## Scope
- `VoucherServiceImpl`
- `OrderRedisKeyConstant`

## Approach
- If `requestId` is blank, keep existing verification logic unchanged.
- If `requestId` is present:
  - build Redis key from `requestId + voucherCode`
  - return cached verification result if already completed
  - use Redis processing marker to reduce duplicate concurrent execution
  - cache the final `VerifyResultVO`

## Boundaries
- No DB schema changes
- No changes to voucher optimistic-lock verification core
