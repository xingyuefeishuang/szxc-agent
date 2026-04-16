# Verify Success After Commit Plan

## Goal
- Make verification success callback timing transaction-safe.

## Scope
- `DouyinChannelAdapter.onVerifySuccess(...)`

## Change
- Replace normal Spring event listener timing with `AFTER_COMMIT`
- Keep asynchronous callback behavior

## Reason
- Avoid notifying external channels before local verification transaction is committed
