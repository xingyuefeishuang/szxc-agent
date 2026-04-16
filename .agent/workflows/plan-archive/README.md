# Plan Archive Workflow

## Purpose

Validate `.agent/plan` naming and pairing conventions for shared maintenance.

## Command

```powershell
powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode compatible
powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode strict

# Optional if pwsh is installed:
pwsh .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode compatible
pwsh .agent/workflows/plan-archive/validate-plan-archive.ps1 -Mode strict
```

## Migration Script

```powershell
# 1) Dry-run and export mapping CSV
powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/migrate-plan-archive-names.ps1

# 2) Apply batch rename
powershell -ExecutionPolicy Bypass -File .agent/workflows/plan-archive/migrate-plan-archive-names.ps1 -Apply
```

Output mapping:

- `.agent/workflows/plan-archive/migration-plan.csv`

## Mode

- `compatible`: legacy names are warnings; new standard is enforced for matched files.
- `strict`: every file must match standard name.

## Suggested Integration

- Local pre-commit:
  - start with `compatible`
  - switch to `strict` after historical cleanup
- CI merge gate:
  - always run `strict`
