# Verify Request Doc Fix Plan

## Goal
- Align `VerifyRequestDO` API documentation with the actual verification enum and current controller behavior.

## Scope
- `VerifyRequestDO`

## Changes
- Update `verifyChannel` schema description to the actual enum values
- Clarify that some controller routes may override `verifyChannel`
- Update `requestId` schema description to match the new idempotency behavior
