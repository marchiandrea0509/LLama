$ErrorActionPreference = 'Stop'

$FailureLine = 'Pine screener unavailable.'
$StaleLine = 'Pine screener stale. Run refresh pine screener.'
$MaxAgeMinutes = 60
$ReportDir = 'C:\Users\anmar\.openclaw\workspace\tradingview\reports\pine_screener'

try {
    if (-not (Test-Path $ReportDir)) {
        throw "Report directory not found: $ReportDir"
    }

    $latest = Get-ChildItem -Path $ReportDir -Filter 'pine_screener_*.txt' -File |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1

    if (-not $latest) {
        throw 'No Pine screener text report found'
    }

    $ageMinutes = ((Get-Date).ToUniversalTime() - $latest.LastWriteTimeUtc).TotalMinutes
    if ($ageMinutes -gt $MaxAgeMinutes) {
        $StaleLine
        exit 0
    }

    $content = Get-Content $latest.FullName -Raw
    if (-not $content -or -not $content.Trim()) {
        throw "Latest report is empty: $($latest.FullName)"
    }

    $content.TrimEnd()
    exit 0
}
catch {
    $FailureLine
    exit 1
}
