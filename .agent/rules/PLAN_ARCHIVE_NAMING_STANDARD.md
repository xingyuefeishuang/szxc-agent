# `.agent/plan` Shared Naming Standard

## 1. Scope

- Applies to all archived task records under `.agent/plan/{module}/`.
- Applies to both human and AI generated records.
- Includes both required document types:
  - `implementation_plan`
  - `walkthrough`

## 2. Single Naming Rule

All new archive files MUST follow:

`YYYY-MM-DD_{featureKey}_vNN_{docType}.md`

- `YYYY-MM-DD`: calendar date.
- `{featureKey}`: short feature/task key, lowercase kebab-case.
- `vNN`: version number, starts from `v01` and increments by `1` for each revision of the same feature.
- `{docType}`: one of:
  - `implementation_plan`
  - `walkthrough`

Examples:

- `2026-04-04_req1024-voucher-query_v01_implementation_plan.md`
- `2026-04-04_req1024-voucher-query_v01_walkthrough.md`
- `2026-04-05_req1024-voucher-query_v02_implementation_plan.md`

## 3. Directory Ownership Rule

- Path is fixed: `.agent/plan/{module}/`.
- `{module}` is represented by folder name only and MUST NOT be duplicated in file name.
- Every task MUST generate a pair:
  - same date
  - same featureKey
  - same version (`vNN`)
  - different `docType` (`implementation_plan` + `walkthrough`)

## 4. Naming Vocabulary and Length

- `featureKey`: lowercase letters, digits, hyphen (`[a-z0-9-]`).
- `vNN`: exactly `v` + 2 digits, e.g. `v01`, `v02`, `v10`.
- No spaces, no underscore, no Chinese characters in file name segments.
- Human-readable Chinese description should be kept inside the markdown body, not in the file name.
- Total filename length SHOULD be `<= 120` characters.

## 5. Change Management Rule

- Historical files are read-only by default.
- Batch rename is allowed only in a dedicated change set with:
  - rename mapping list (`old -> new`)
  - no content semantics change
  - index regeneration if index is enabled
- Never rename one file in a pair without renaming the paired file.
- For same `{featureKey}`, version MUST be strictly increasing (`v01 -> v02 -> v03...`) without duplicate version pairs.

## 6. Enforcement Rule

Use script (Windows PowerShell):

`powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode strict`

Or if PowerShell 7 (`pwsh`) is available:

`pwsh .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode strict`

Recommended enforcement:

- Local pre-commit: run in `compatible` mode first, then switch to `strict` after legacy cleanup.
- CI merge gate: run in `strict` mode.

## 7. Rollout Strategy

1. Start now: all new files use this standard.
2. Transitional period: run validator in `compatible` mode (legacy files only warn).
3. Cleanup window: batch rename legacy files by module.
4. Steady state: CI enforces `strict` mode.
