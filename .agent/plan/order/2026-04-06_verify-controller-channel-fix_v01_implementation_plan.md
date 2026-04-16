# Verify Controller Channel Fix Plan

## Goal
- Enforce verification route semantics at the controller layer.

## Scope
- `VerifyController` only

## Change
- `/check` forces `verifyChannel = GATE`
- `/manual` forces `verifyChannel = ADMIN_MANUAL`

## Reason
- Avoid trusting client-provided `verifyChannel`
- Keep route semantics and verify log semantics aligned
