# Verify Controller Channel Fix Walkthrough

## What Changed
- `VerifyController.check(...)` now overwrites the request channel to `GATE`
- `VerifyController.manual(...)` now overwrites the request channel to `ADMIN_MANUAL`

## Result
- `/check` and `/manual` no longer depend on caller-provided verification channel values
- Verification logs now reflect controller route semantics more reliably

## Scope
- Controller-only change
- No changes to voucher verification core logic
