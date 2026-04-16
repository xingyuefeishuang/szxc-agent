# implementation_plan

- Task: Add batch migration script for `.agent/plan` legacy filenames.
- Date: 2026-04-04
- Module: agent
- FeatureKey: plan-archive-migration-script
- Version: v01

## Steps

1. Implement migration script to parse common legacy naming patterns.
2. Generate deterministic `old -> new` mapping CSV.
3. Support dry-run by default and `-Apply` for actual rename.
4. Add conflict/length checks and pair warnings.
5. Update workflow README with migration commands.

