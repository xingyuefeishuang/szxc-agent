# walkthrough

- Outcome: Naming rule migrated to the new team format and validator updated accordingly.

## Changes

1. Standard updated to:
   - `YYYY-MM-DD_{featureKey}_vNN_{docType}.md`
2. File name no longer requires `HH-mm` or `module` segment.
3. Version segment uses `vNN` and must increment per feature key.
4. Validator now checks:
   - new naming pattern
   - paired `implementation_plan` + `walkthrough`
   - same `date + featureKey + version`
   - filename length `<= 120`
5. Mandatory rule linkage added to:
   - `AI_BEHAVIOR_RULES.md`
   - `AGENTS.md`

