# Verify Idempotency Cache Tighten Walkthrough

## What Changed
- Verification request idempotency now caches only success responses
- Failed verification responses clear the processing marker instead of being long-cached

## Result
- Repeat success requests still reuse the same result
- Retryable failure requests are no longer pinned by Redis for 24 hours
