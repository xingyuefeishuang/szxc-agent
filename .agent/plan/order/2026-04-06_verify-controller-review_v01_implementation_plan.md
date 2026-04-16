# Verify Controller Review Plan

## Scope
- Review `VerifyController` and the voucher verification flow only.
- Focus on controller semantics, verification input contract, state transitions, and side effects.

## Read Path
- `VerifyController`
- `VerifyRequestDO`
- `VoucherServiceImpl.verify(...)`
- `VerifyChannelEnum`
- `OrderStateMachine`
- Verify success callback / notify related code

## Review Focus
- Whether `/check` and `/manual` route semantics are actually enforced
- Whether verification idempotency and concurrency handling are coherent
- Whether verification logs and callback state reflect real execution semantics
- Whether order completion transition matches current fulfillment model

## Expected Output
- Findings ordered by severity
- File references to the relevant controller/service/model code
- Residual risks and suggested next fixes
