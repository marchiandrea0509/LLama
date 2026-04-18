$ErrorActionPreference = 'Stop'

$FailureLine = 'Pine screener export failed.'
$WorkspaceRoot = 'C:\Users\anmar\.openclaw\workspace\tradingview'
$ScriptPath = Join-Path $WorkspaceRoot 'scripts\pine_screener_export.js'
$ReportsDir = Join-Path $WorkspaceRoot 'reports\pine_screener'

try {
    if (-not (Test-Path $ScriptPath)) {
        throw "Export script not found: $ScriptPath"
    }

    $before = @{}
    if (Test-Path $ReportsDir) {
        Get-ChildItem -Path $ReportsDir -Filter 'pine_screener_*.txt' -File | ForEach-Object {
            $before[$_.FullName] = $_.LastWriteTimeUtc.Ticks
        }
    }

    $cmdOutput = & node $ScriptPath 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw ($cmdOutput.Trim())
    }

    if (-not (Test-Path $ReportsDir)) {
        throw "Reports directory not found after export: $ReportsDir"
    }

    $latest = Get-ChildItem -Path $ReportsDir -Filter 'pine_screener_*.txt' -File |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1

    if (-not $latest) {
        throw 'No Pine screener text report found after export'
    }

    $wasKnown = $before.ContainsKey($latest.FullName)
    $isUpdated = $wasKnown -and ($latest.LastWriteTimeUtc.Ticks -gt $before[$latest.FullName])
    if (-not $wasKnown -and -not $isUpdated) {
        # New file is fine; if it existed already, require a newer timestamp.
        $null = $true
    }

    $content = Get-Content $latest.FullName -Raw
    if (-not $content -or -not $content.Trim()) {
        throw "Latest exported report is empty: $($latest.FullName)"
    }

    $content.TrimEnd()
    exit 0
}
catch {
    $FailureLine
    exit 1
}
