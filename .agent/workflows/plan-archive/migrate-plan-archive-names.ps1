param(
    [string]$PlanRoot = ".agent/plan",
    [string]$OutputCsv = ".agent/workflows/plan-archive/migration-plan.csv",
    [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Convert-ToFeatureKey {
    param([Parameter(Mandatory = $true)][string]$Raw)

    $s = $Raw.ToLowerInvariant()
    $s = $s -replace '[^a-z0-9]+', '-'
    $s = $s -replace '-{2,}', '-'
    $s = $s.Trim('-')
    if ([string]::IsNullOrWhiteSpace($s)) { return "legacy-task" }
    return $s
}

function Parse-LegacyName {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$File
    )

    $name = $File.BaseName
    $date = $null
    $featureRaw = $null
    $docType = $null
    $matched = $false

    # New standard, skip migration
    if ($name -match '^(?<date>\d{4}-\d{2}-\d{2})_(?<featureKey>[a-z0-9][a-z0-9-]*)_(?<version>v\d{2})_(?<docType>implementation_plan|walkthrough)$') {
        return [pscustomobject]@{
            Parsed = $true
            AlreadyNew = $true
            Date = $Matches['date']
            FeatureRaw = $Matches['featureKey']
            DocType = $Matches['docType']
            SourcePattern = "new"
        }
    }

    # Pattern A: YYYY-MM-DD_topic_implementation_plan / walkthrough
    if ($name -match '^(?<date>\d{4}-\d{2}-\d{2})_(?<topic>.+)_(?<docType>implementation_plan|walkthrough)$') {
        $date = $Matches['date']; $featureRaw = $Matches['topic']; $docType = $Matches['docType']; $matched = $true
        $sourcePattern = "date-topic-doctype"
    }

    # Pattern B: implementation_plan_topic_YYYYMMDD / walkthrough_topic_YYYYMMDD
    if (-not $matched -and $name -match '^(?<docType>implementation_plan|walkthrough)_(?<topic>.+)_(?<date>\d{8})$') {
        $d = $Matches['date']
        $date = "{0}-{1}-{2}" -f $d.Substring(0,4), $d.Substring(4,2), $d.Substring(6,2)
        $featureRaw = $Matches['topic']; $docType = $Matches['docType']; $matched = $true
        $sourcePattern = "doctype-topic-date8"
    }

    # Pattern C: topic_plan / topic_walkthrough
    if (-not $matched -and $name -match '^(?<topic>.+)_(?<short>plan|walkthrough)$') {
        $date = $File.LastWriteTime.ToString("yyyy-MM-dd")
        $featureRaw = $Matches['topic']
        $docType = if ($Matches['short'] -eq 'plan') { 'implementation_plan' } else { 'walkthrough' }
        $matched = $true
        $sourcePattern = "topic-shorttype"
    }

    # Pattern D: implementation_plan_topic / walkthrough_topic
    if (-not $matched -and $name -match '^(?<docType>implementation_plan|walkthrough)_(?<topic>.+)$') {
        $date = $File.LastWriteTime.ToString("yyyy-MM-dd")
        $featureRaw = $Matches['topic']; $docType = $Matches['docType']; $matched = $true
        $sourcePattern = "doctype-topic"
    }

    if (-not $matched) {
        return [pscustomobject]@{
            Parsed = $false
            AlreadyNew = $false
            Date = $null
            FeatureRaw = $null
            DocType = $null
            SourcePattern = "unmatched"
        }
    }

    return [pscustomobject]@{
        Parsed = $true
        AlreadyNew = $false
        Date = $date
        FeatureRaw = $featureRaw
        DocType = $docType
        SourcePattern = $sourcePattern
    }
}

if (-not (Test-Path -LiteralPath $PlanRoot)) {
    Write-Host "[ERROR] Plan root not found: $PlanRoot"
    exit 1
}

$files = Get-ChildItem -LiteralPath $PlanRoot -Recurse -File -Filter *.md
$mappings = New-Object System.Collections.Generic.List[object]
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]

foreach ($f in $files) {
    $module = Split-Path -Leaf $f.DirectoryName
    $parsed = Parse-LegacyName -File $f

    if (-not $parsed.Parsed) {
        $warnings.Add("Unmatched legacy filename, skipped: $($f.FullName)")
        continue
    }
    if ($parsed.AlreadyNew) {
        continue
    }

    $featureRaw = $parsed.FeatureRaw
    # Remove legacy leading time token, e.g. 14-24-27_topic
    $featureRaw = $featureRaw -replace '^\d{2}-\d{2}(?:-\d{2})?_', ''
    # Remove legacy duplicated module prefix in name, e.g. order_topic
    if ($featureRaw -match ("^" + [regex]::Escape($module) + "_")) {
        $featureRaw = $featureRaw.Substring($module.Length + 1)
    }

    $featureKey = Convert-ToFeatureKey -Raw $featureRaw
    if ($f.Name.Length -gt 120) {
        $warnings.Add("Legacy filename too long (>120): $($f.FullName)")
    }

    $legacyTaskKey = "{0}|{1}|{2}|{3}" -f $module, $parsed.Date, $featureKey, $featureRaw.ToLowerInvariant()
    $mappings.Add([pscustomobject]@{
        OldFullPath = $f.FullName
        OldName = $f.Name
        Module = $module
        Date = $parsed.Date
        FeatureKey = $featureKey
        DocType = $parsed.DocType
        SourcePattern = $parsed.SourcePattern
        LegacyTaskKey = $legacyTaskKey
        Version = $null
        NewName = $null
        NewFullPath = $null
    })
}

# Assign versions per module + featureKey by chronological legacy task key
$groupedByFeature = $mappings | Group-Object Module, FeatureKey
foreach ($g in $groupedByFeature) {
    $tasks = $g.Group | Group-Object LegacyTaskKey | Sort-Object { $_.Group[0].Date }, Name
    $v = 1
    foreach ($task in $tasks) {
        $vTag = "v{0}" -f $v.ToString("00")
        foreach ($row in $task.Group) {
            $row.Version = $vTag
            $row.NewName = "{0}_{1}_{2}_{3}.md" -f $row.Date, $row.FeatureKey, $row.Version, $row.DocType
            $row.NewFullPath = Join-Path -Path (Split-Path -Parent $row.OldFullPath) -ChildPath $row.NewName
        }
        $v++
    }
}

# Conflict checks
$dupTargets = $mappings | Group-Object NewFullPath | Where-Object { $_.Count -gt 1 }
foreach ($d in $dupTargets) {
    $errors.Add("Target collision: $($d.Name)")
}

foreach ($row in $mappings) {
    if ($row.NewName.Length -gt 120) {
        $errors.Add("New filename too long (>120): $($row.NewName)")
    }
}

$pairGroups = $mappings | Group-Object Module, Date, FeatureKey, Version
foreach ($pg in $pairGroups) {
    $types = $pg.Group.DocType
    if (-not ($types -contains "implementation_plan")) {
        $warnings.Add("Missing implementation_plan after migration group: $($pg.Name)")
    }
    if (-not ($types -contains "walkthrough")) {
        $warnings.Add("Missing walkthrough after migration group: $($pg.Name)")
    }
}

# Export plan
$outDir = Split-Path -Parent $OutputCsv
if (-not [string]::IsNullOrWhiteSpace($outDir) -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
$mappings | Sort-Object Module, Date, FeatureKey, Version, DocType | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8

Write-Host "Scanned files: $($files.Count)"
Write-Host "Migration candidates: $($mappings.Count)"
Write-Host "Warnings: $($warnings.Count)"
Write-Host "Errors: $($errors.Count)"
Write-Host "Mapping CSV: $OutputCsv"

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Warnings ==="
    foreach ($w in $warnings) { Write-Host "[WARN] $w" }
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Errors ==="
    foreach ($e in $errors) { Write-Host "[ERROR] $e" }
    exit 1
}

if (-not $Apply) {
    Write-Host ""
    Write-Host "Dry-run only. Re-run with -Apply to rename files."
    exit 0
}

$renamed = 0
foreach ($row in ($mappings | Sort-Object OldFullPath)) {
    if ($row.OldFullPath -eq $row.NewFullPath) { continue }
    if (Test-Path -LiteralPath $row.NewFullPath) {
        $errors.Add("Target already exists, abort rename: $($row.NewFullPath)")
        continue
    }
    Rename-Item -LiteralPath $row.OldFullPath -NewName $row.NewName
    $renamed++
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Rename Errors ==="
    foreach ($e in $errors) { Write-Host "[ERROR] $e" }
    exit 1
}

Write-Host ""
Write-Host "Rename completed. Renamed files: $renamed"
exit 0
