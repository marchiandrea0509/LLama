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
$SourceProfileDir = Join-Path $TvRoot 'profile'
$CaptureProfileName = 'profile-llama-capture'
$CaptureProfileDir = Join-Path $TvRoot $CaptureProfileName

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

function Ensure-CaptureProfile {
    if (Test-Path $CaptureProfileDir) {
        return
    }
    if (-not (Test-Path $SourceProfileDir)) {
        throw "Source TradingView profile not found: $SourceProfileDir"
    }
    Copy-Item -Path $SourceProfileDir -Destination $CaptureProfileDir -Recurse -Force
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
        [string[]]$ExpectedImagePaths
    )

    $started = Get-Date
    $result = Invoke-NodeWithTimeout -ScriptPath $CaptureScript -Arguments @('--symbol', $Winner, '--timeframe', $Timeframe, '--outdir', $ArtifactDir, '--log', $LogPath, '--layout', $PreferredLayout, '--chartUrl', $PreferredChartUrl, '--profile', $CaptureProfileName) -TimeoutSeconds 180

    foreach ($path in $ExpectedImagePaths) {
        if ((Test-Path $path) -and ((Get-Item $path).LastWriteTime -ge $started.AddSeconds(-2))) {
            return $true
        }
    }

    if ($result.ExitCode -eq 0) {
        foreach ($path in $ExpectedImagePaths) {
            if (Test-Path $path) {
                return $true
            }
        }
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

    Ensure-CaptureProfile

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

    $layoutSuffix = '_' + ($PreferredLayout -replace '[^a-zA-Z0-9-_]', '-')
    $image4HPreferred = Join-Path $ArtifactDir ($winner + '_4H' + $layoutSuffix + '.png')
    $image1DPreferred = Join-Path $ArtifactDir ($winner + '_1D' + $layoutSuffix + '.png')
    $image4HFallback = Join-Path $ArtifactDir ($winner + '_4H.png')
    $image1DFallback = Join-Path $ArtifactDir ($winner + '_1D.png')

    $capture4HOk = $false
    for ($i = 0; $i -lt 2 -and -not $capture4HOk; $i++) {
        $capture4HOk = Try-Capture -Winner $winner -Timeframe '4H' -ExpectedImagePaths @($image4HPreferred, $image4HFallback)
    }
    if (-not $capture4HOk) {
        throw "4H capture failed for $winner"
    }

    $capture1DOk = $false
    for ($i = 0; $i -lt 2 -and -not $capture1DOk; $i++) {
        $capture1DOk = Try-Capture -Winner $winner -Timeframe '1D' -ExpectedImagePaths @($image1DPreferred, $image1DFallback)
    }
    if (-not $capture1DOk) {
        throw "1D capture failed for $winner"
    }

    $image4H = if (Test-Path $image4HPreferred) { $image4HPreferred } elseif (Test-Path $image4HFallback) { $image4HFallback } else { $null }
    $image1D = if (Test-Path $image1DPreferred) { $image1DPreferred } elseif (Test-Path $image1DFallback) { $image1DFallback } else { $null }

    if (-not $image4H) {
        throw "Missing 4H screenshot for $winner"
    }
    if (-not $image1D) {
        throw "Missing 1D screenshot for $winner"
    }

    $actualLayout = if (($image4H -eq $image4HPreferred) -and ($image1D -eq $image1DPreferred)) { $PreferredLayout } else { 'default' }

    $manifest = [ordered]@{
        generatedAt = (Get-Date).ToUniversalTime().ToString('o')
        winner = $winner
        tablePath = $LatestTablePath
        image4H = $image4H
        image1D = $image1D
        sourceJson = $latestJson.FullName
        sourceText = $textPath
        layout = $actualLayout
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
