# UTF-8 Console Skill

## Purpose
Fix PowerShell console output encoding issues so Chinese text displays correctly when using `Get-Content` or other commands.

## Files
- `set-utf8.ps1`: Sets console output encoding to UTF-8 and updates `$OutputEncoding`.

## Usage
```powershell
.\.agent\skills\utf8-console\set-utf8.ps1
Get-Content .agent\rules\AI_BEHAVIOR_RULES.md -Encoding UTF8
```

## Notes
- This does not modify file contents; it only affects console output for the current session.
