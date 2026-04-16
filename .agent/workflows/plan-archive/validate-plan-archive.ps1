param(
    [string]$PlanRoot = ".agent/plan",
    [ValidateSet("compatible", "strict")]
    [string]$Mode = "compatible"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PlanRoot)) {
    Write-Host "[ERROR] Plan root not found: $PlanRoot"
    exit 1
}

$filePattern = '^(?<date>\d{4}-\d{2}-\d{2})_(?<featureKey>[a-z0-9][a-z0-9-]*)_(?<version>v\d{2})_(?<docType>implementation_plan|walkthrough)\.md$'
$allFiles = Get-ChildItem -LiteralPath $PlanRoot -Recurse -File -Filter *.md

$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
$pairs = @{}

foreach ($file in $allFiles) {
    $name = $file.Name
    $m = [regex]::Match($name, $filePattern)

    if (-not $m.Success) {
        if ($Mode -eq "strict") {
            $errors.Add("Non-standard name: $($file.FullName)")
        } else {
            $warnings.Add("Legacy name (ignored in compatible mode): $($file.FullName)")
        }
        continue
    }

    $featureKey = $m.Groups["featureKey"].Value
    $version = $m.Groups["version"].Value
    $docType = $m.Groups["docType"].Value
    $date = $m.Groups["date"].Value

    if ($name.Length -gt 120) {
        $errors.Add("Filename too long (>120): $($file.FullName)")
    }

    $taskKey = "$date|$featureKey|$version"
    if (-not $pairs.ContainsKey($taskKey)) {
        $pairs[$taskKey] = @{}
    }

    if ($pairs[$taskKey].ContainsKey($docType)) {
        $errors.Add("Duplicate docType '$docType' for task '$taskKey': $($file.FullName)")
    } else {
        $pairs[$taskKey][$docType] = $file.FullName
    }
}

foreach ($taskKey in $pairs.Keys) {
    $entry = $pairs[$taskKey]
    if (-not $entry.ContainsKey("implementation_plan")) {
        $errors.Add("Missing implementation_plan for task '$taskKey'")
    }
    if (-not $entry.ContainsKey("walkthrough")) {
        $errors.Add("Missing walkthrough for task '$taskKey'")
    }
}

Write-Host "Mode: $Mode"
Write-Host "Scanned files: $($allFiles.Count)"
Write-Host "Validated tasks: $($pairs.Count)"
Write-Host "Warnings: $($warnings.Count)"
Write-Host "Errors: $($errors.Count)"

if ($warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Warnings ==="
    foreach ($w in $warnings) {
        Write-Host "[WARN] $w"
    }
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "=== Errors ==="
    foreach ($e in $errors) {
        Write-Host "[ERROR] $e"
    }
    exit 1
}

Write-Host ""
Write-Host "Validation passed."
exit 0
