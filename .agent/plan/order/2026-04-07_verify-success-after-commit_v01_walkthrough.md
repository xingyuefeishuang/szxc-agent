# Verify Success After Commit Walkthrough

## What Changed
- `onVerifySuccess(...)` now listens with `@TransactionalEventListener(phase = AFTER_COMMIT)`
- `@Async` is still retained

## Result
- External verification callback is triggered only after the local verification transaction commits
- This reduces the risk of external callback success while local verification data later rolls back
