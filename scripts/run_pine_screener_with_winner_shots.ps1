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
$PreferredLayout = 'Openclaw-structure'
$PreferredChartUrl = 'https://www.tradingview.com/chart/0ZPSKaZ4/'

function Get-NodePath {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw 'node executable not found in PATH'
    }
    return $cmd.Source
}

function Invoke-NodeWithTimeout {
    param(
        [string]$ScriptPath,
        [string[]]$Arguments,
        [int]$TimeoutSeconds = 180
    )

    $node = Get-NodePath
    $stdoutPath = Join-Path $env:TEMP ("oc-node-out-" + [guid]::NewGuid().ToString() + '.txt')
    $stderrPath = Join-Path $env:TEMP ("oc-node-err-" + [guid]::NewGuid().ToString() + '.txt')

    try {
        $argList = @($ScriptPath) + $Arguments
        $proc = Start-Process -FilePath $node -ArgumentList $argList -NoNewWindow -PassThru -RedirectStandardOutput $stdoutPath -RedirectStandardError $stderrPath
        $finished = $proc.WaitForExit($TimeoutSeconds * 1000)

        if (-not $finished) {
            try { Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue } catch {}
            return [pscustomobject]@{
                ExitCode = -1
                TimedOut = $true
                StdOut = ''
                StdErr = 'Timed out'
            }
        }

        return [pscustomobject]@{
            ExitCode = $proc.ExitCode
            TimedOut = $false
            StdOut = if (Test-Path $stdoutPath) { Get-Content $stdoutPath -Raw } else { '' }
            StdErr = if (Test-Path $stderrPath) { Get-Content $stderrPath -Raw } else { '' }
        }
    }
    finally {
        Remove-Item $stdoutPath, $stderrPath -Force -ErrorAction SilentlyContinue
    }
}

function Try-RunExport {
    $result = Invoke-NodeWithTimeout -ScriptPath $ExportScript -Arguments @() -TimeoutSeconds 240
    if ($result.ExitCode -eq 0) {
        return $true
    }
    return $false
}

function Try-Capture {
    param(
        [string]$Winner,
        [string]$Timeframe,
        [string]$ExpectedImagePath
    )

    $started = Get-Date
    $result = Invoke-NodeWithTimeout -ScriptPath $CaptureScript -Arguments @('--symbol', $Winner, '--timeframe', $Timeframe, '--outdir', $ArtifactDir, '--log', $LogPath, '--layout', $PreferredLayout, '--chartUrl', $PreferredChartUrl) -TimeoutSeconds 180

    if ((Test-Path $ExpectedImagePath) -and ((Get-Item $ExpectedImagePath).LastWriteTime -ge $started.AddSeconds(-2))) {
        return $true
    }

    if ($result.ExitCode -eq 0 -and (Test-Path $ExpectedImagePath)) {
        return $true
    }

    return $false
}

try {
    New-Item -ItemType Directory -Path $ArtifactDir -Force | Out-Null

    if (-not (Test-Path $ExportScript)) {
        throw "Export script not found: $ExportScript"
    }
    if (-not (Test-Path $CaptureScript)) {
        throw "Capture script not found: $CaptureScript"
    }

    $exportOk = $false
    for ($i = 0; $i -lt 2 -and -not $exportOk; $i++) {
        $exportOk = Try-RunExport
    }
    if (-not $exportOk) {
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

    $image4H = Join-Path $ArtifactDir ($winner + '_4H.png')
    $image1D = Join-Path $ArtifactDir ($winner + '_1D.png')

    $capture4HOk = $false
    for ($i = 0; $i -lt 2 -and -not $capture4HOk; $i++) {
        $capture4HOk = Try-Capture -Winner $winner -Timeframe '4H' -ExpectedImagePath $image4H
    }
    if (-not $capture4HOk) {
        throw "4H capture failed for $winner"
    }

    $capture1DOk = $false
    for ($i = 0; $i -lt 2 -and -not $capture1DOk; $i++) {
        $capture1DOk = Try-Capture -Winner $winner -Timeframe '1D' -ExpectedImagePath $image1D
    }
    if (-not $capture1DOk) {
        throw "1D capture failed for $winner"
    }

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
        layout = $PreferredLayout
        chartUrl = $PreferredChartUrl
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $ManifestPath -Encoding UTF8

    Get-Content $LatestTablePath -Raw
    exit 0
}
catch {
    $FailureLine
    exit 1
}
