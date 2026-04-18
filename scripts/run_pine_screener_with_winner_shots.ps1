$ErrorActionPreference = 'Stop'

$FailureLine = 'Pine screener winner screenshot failed.'
$TvRoot = 'C:\Users\anmar\.openclaw\workspace\tradingview'
$ExportScript = Join-Path $TvRoot 'scripts\pine_screener_export.js'
$CaptureScript = Join-Path $TvRoot 'scripts\capture_live.js'
$ReportsDir = Join-Path $TvRoot 'reports\pine_screener'
$ArtifactDir = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner'
$LogPath = Join-Path $ArtifactDir 'capture.log'
$LatestTablePath = Join-Path $ArtifactDir 'latest_table.txt'
$ManifestPath = Join-Path $ArtifactDir 'latest_manifest.json'

try {
    New-Item -ItemType Directory -Path $ArtifactDir -Force | Out-Null

    if (-not (Test-Path $ExportScript)) {
        throw "Export script not found: $ExportScript"
    }
    if (-not (Test-Path $CaptureScript)) {
        throw "Capture script not found: $CaptureScript"
    }

    & node $ExportScript 2>&1 | Out-String | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw 'pine_screener_export.js failed'
    }

    $latestJson = Get-ChildItem -Path $ReportsDir -Filter 'pine_screener_*.json' -File |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1

    if (-not $latestJson) {
        throw 'No Pine screener JSON report found after export'
    }

    $payload = Get-Content $latestJson.FullName -Raw | ConvertFrom-Json
    $winner = $null
    if ($payload.top5 -and $payload.top5.Count -gt 0) {
        $winner = $payload.top5[0].symbol
    } elseif ($payload.top5Symbols -and $payload.top5Symbols.Count -gt 0) {
        $winner = $payload.top5Symbols[0]
    }

    if (-not $winner) {
        throw 'Could not determine winner symbol from Pine screener export'
    }

    $textPath = [string]$payload.textPath
    if (-not $textPath -or -not (Test-Path $textPath)) {
        throw 'Fresh Pine screener text output not found'
    }

    Copy-Item -Path $textPath -Destination $LatestTablePath -Force

    $capture4H = & node $CaptureScript --symbol $winner --timeframe 4H --outdir $ArtifactDir --log $LogPath 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "4H capture failed for $winner"
    }

    $capture1D = & node $CaptureScript --symbol $winner --timeframe 1D --outdir $ArtifactDir --log $LogPath 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "1D capture failed for $winner"
    }

    $image4H = Join-Path $ArtifactDir ($winner + '_4H.png')
    $image1D = Join-Path $ArtifactDir ($winner + '_1D.png')

    if (-not (Test-Path $image4H)) {
        throw "Missing 4H screenshot: $image4H"
    }
    if (-not (Test-Path $image1D)) {
        throw "Missing 1D screenshot: $image1D"
    }

    $manifest = [ordered]@{
        generatedAt = (Get-Date).ToUniversalTime().ToString('o')
        winner = $winner
        tablePath = $LatestTablePath
        image4H = $image4H
        image1D = $image1D
        sourceJson = $latestJson.FullName
        sourceText = $textPath
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $ManifestPath -Encoding UTF8

    Get-Content $LatestTablePath -Raw
    exit 0
}
catch {
    $FailureLine
    exit 1
}
