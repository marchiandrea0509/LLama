$ErrorActionPreference = 'Stop'

$FailureLine = 'llama does not respond'
$ExportScript = 'C:\Users\anmar\.openclaw\workspace-llama\scripts\run_pine_screener_export.ps1'
$TvRoot = 'C:\Users\anmar\.openclaw\workspace\tradingview'
$CaptureScript = Join-Path $TvRoot 'scripts\capture_live.js'
$ReportsDir = Join-Path $TvRoot 'reports\pine_screener'
$ArtifactDir = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner'
$LogPath = Join-Path $ArtifactDir 'capture.log'
$PreferredLayout = 'Openclaw-structure'
$PreferredChartUrl = 'https://www.tradingview.com/chart/0ZPSKaZ4/'
$SourceProfileDir = Join-Path $TvRoot 'profile'
$CaptureProfileName = 'profile-llama-capture'
$CaptureProfileDir = Join-Path $TvRoot $CaptureProfileName
$AllowedWorkspaceRoot = 'C:\Users\anmar\.openclaw\workspace'
$AllowedMediaDir = Join-Path $AllowedWorkspaceRoot 'artifacts\llama_screener_winner'

function Get-NodePath {
    $cmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $cmd) { throw 'node executable not found in PATH' }
    return $cmd.Source
}

function Ensure-CaptureProfile {
    if (Test-Path $CaptureProfileDir) { return }
    if (-not (Test-Path $SourceProfileDir)) { throw "Source TradingView profile not found: $SourceProfileDir" }
    Copy-Item -Path $SourceProfileDir -Destination $CaptureProfileDir -Recurse -Force
}

function Sync-FileIfNeeded {
    param([string]$SourcePath, [string]$DestinationPath)

    if (-not (Test-Path $SourcePath)) { throw "Source file missing: $SourcePath" }

    $copyNeeded = $true
    if (Test-Path $DestinationPath) {
        $src = Get-Item $SourcePath
        $dst = Get-Item $DestinationPath
        if ($dst.Length -eq $src.Length -and $dst.LastWriteTimeUtc -ge $src.LastWriteTimeUtc) {
            $copyNeeded = $false
        }
    }

    if ($copyNeeded) {
        Copy-Item -Path $SourcePath -Destination $DestinationPath -Force
    }
}

function Resolve-FreshImage {
    param([string]$Winner, [string]$Timeframe, [datetime]$Started)

    $preferred = Join-Path $ArtifactDir ($Winner + '_' + $Timeframe + '_' + $PreferredLayout + '.png')
    $fallback = Join-Path $ArtifactDir ($Winner + '_' + $Timeframe + '.png')

    $candidates = @()
    foreach ($path in @($preferred, $fallback)) {
        if (Test-Path $path) {
            $item = Get-Item $path
            if ($item.LastWriteTime -ge $Started.AddMinutes(-5)) {
                $candidates += $item
            }
        }
    }

    if (-not $candidates -or $candidates.Count -eq 0) {
        throw "Fresh $Timeframe screenshot missing for $Winner"
    }

    return ($candidates | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1).FullName
}

function Invoke-CaptureWithRetry {
    param(
        [string]$Winner,
        [string]$Timeframe,
        [int]$Attempts = 2
    )

    $node = Get-NodePath

    for ($i = 0; $i -lt $Attempts; $i++) {
        & $node $CaptureScript '--symbol' $Winner '--timeframe' $Timeframe '--outdir' $ArtifactDir '--log' $LogPath '--layout' $PreferredLayout '--chartUrl' $PreferredChartUrl '--profile' $CaptureProfileName | Out-Null
        if ($LASTEXITCODE -eq 0) {
            return $true
        }
        Start-Sleep -Seconds 2
    }

    return $false
}

try {
    if (-not (Test-Path $ExportScript)) { throw "Export script not found: $ExportScript" }
    if (-not (Test-Path $CaptureScript)) { throw "Capture script not found: $CaptureScript" }

    New-Item -ItemType Directory -Path $ArtifactDir -Force | Out-Null
    Ensure-CaptureProfile

    $started = Get-Date

    $table = & powershell -ExecutionPolicy Bypass -File $ExportScript | Out-String
    if ($LASTEXITCODE -ne 0) { throw 'Pine screener export failed' }

    $table = $table.Trim()
    if (-not $table -or $table -eq 'Pine screener export failed.') {
        throw 'Fresh screener table unavailable'
    }

    $latestJson = Get-ChildItem -Path $ReportsDir -Filter 'pine_screener_*.json' -File |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1

    if (-not $latestJson) { throw 'No Pine screener JSON report found after export' }
    if ($latestJson.LastWriteTime -lt $started.AddMinutes(-2)) { throw 'Latest Pine screener JSON report is stale' }

    $payload = Get-Content $latestJson.FullName -Raw | ConvertFrom-Json
    $winner = $null
    if ($payload.top5 -and $payload.top5.Count -gt 0) {
        $winner = $payload.top5[0].symbol
    } elseif ($payload.top5Symbols -and $payload.top5Symbols.Count -gt 0) {
        $winner = $payload.top5Symbols[0]
    }
    if (-not $winner) { throw 'Could not determine fresh winner symbol' }

    $cap4HOk = Invoke-CaptureWithRetry -Winner $winner -Timeframe '4H' -Attempts 2
    if (-not $cap4HOk) { throw '4H capture command failed' }

    $cap1DOk = Invoke-CaptureWithRetry -Winner $winner -Timeframe '1D' -Attempts 2
    if (-not $cap1DOk) { throw '1D capture command failed' }

    $image4H = Resolve-FreshImage -Winner $winner -Timeframe '4H' -Started $started
    $image1D = Resolve-FreshImage -Winner $winner -Timeframe '1D' -Started $started

    New-Item -ItemType Directory -Path $AllowedMediaDir -Force | Out-Null

    $dest4H = Join-Path $AllowedMediaDir ([IO.Path]::GetFileName($image4H))
    $dest1D = Join-Path $AllowedMediaDir ([IO.Path]::GetFileName($image1D))

    Sync-FileIfNeeded -SourcePath $image4H -DestinationPath $dest4H
    Sync-FileIfNeeded -SourcePath $image1D -DestinationPath $dest1D

    $body = @(
        $table
        "MEDIA:$dest4H"
        "MEDIA:$dest1D"
    ) -join "`n"

    $body.Trim()
    exit 0
}
catch {
    $FailureLine
    exit 1
}
