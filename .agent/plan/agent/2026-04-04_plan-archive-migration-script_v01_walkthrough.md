# walkthrough

- Delivered `.agent/workflows/plan-archive/migrate-plan-archive-names.ps1`.
- Script behavior:
  - scans `.agent/plan` recursively
  - parses legacy file-name patterns
  - normalizes `featureKey`
  - assigns `vNN` by chronological task groups per `module + featureKey`
  - exports mapping to `.agent/workflows/plan-archive/migration-plan.csv`
  - supports dry-run and `-Apply` rename
- Added migration usage to workflow README.
- Dry-run execution result:
  - scanned: 30
  - candidates: 28
  - warnings: 0
  - errors: 0

