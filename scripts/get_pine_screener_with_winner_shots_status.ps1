$ErrorActionPreference = 'Stop'

$FailureLine = 'Pine screener winner screenshot failed.'
$ManifestPath = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner\latest_manifest.json'
$RunnerPath = 'C:\Users\anmar\.openclaw\workspace-llama\scripts\run_pine_screener_with_winner_shots.ps1'
$ArtifactDir = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner'
$PreferredLayout = 'Openclaw-structure'
$PreferredChartUrl = 'https://www.tradingview.com/chart/0ZPSKaZ4/'
$LatestTablePath = Join-Path $ArtifactDir 'latest_table.txt'

function Write-ManifestFromFiles {
    param(
        [string]$Winner,
        [string]$Image4H,
        [string]$Image1D
    )

    $manifest = [ordered]@{
        generatedAt = (Get-Date).ToUniversalTime().ToString('o')
        winner = $Winner
        tablePath = $LatestTablePath
        image4H = $Image4H
        image1D = $Image1D
        sourceJson = $null
        sourceText = $LatestTablePath
        layout = $PreferredLayout
        chartUrl = $PreferredChartUrl
    }
    $manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $ManifestPath -Encoding UTF8
}

function Try-UseValidManifest {
    if (-not (Test-Path $ManifestPath)) {
        return $false
    }

    $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    if (
        $manifest.tablePath -and $manifest.image4H -and $manifest.image1D -and $manifest.layout -and
        ([string]$manifest.layout -eq $PreferredLayout) -and
        (Test-Path $manifest.tablePath) -and
        (Test-Path $manifest.image4H) -and
        (Test-Path $manifest.image1D)
    ) {
        Get-Content ([string]$manifest.tablePath) -Raw
        return $true
    }

    return $false
}

function Try-RebuildFromArtifacts {
    if (-not (Test-Path $LatestTablePath)) {
        return $false
    }

    $files4H = Get-ChildItem -Path $ArtifactDir -Filter '*_4H_Openclaw-structure.png' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTimeUtc -Descending
    foreach ($file4H in $files4H) {
        $winner = $file4H.BaseName -replace '_4H_Openclaw-structure$',''
        $image1D = Join-Path $ArtifactDir ($winner + '_1D_Openclaw-structure.png')
        if (Test-Path $image1D) {
            Write-ManifestFromFiles -Winner $winner -Image4H $file4H.FullName -Image1D $image1D
            Get-Content $LatestTablePath -Raw
            return $true
        }
    }

    return $false
}

try {
    if (Try-UseValidManifest) {
        exit 0
    }

    if (Try-RebuildFromArtifacts) {
        exit 0
    }

    if (-not (Test-Path $RunnerPath)) {
        throw "Runner script not found: $RunnerPath"
    }

    & powershell -ExecutionPolicy Bypass -File $RunnerPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Runner script failed'
    }
    exit 0
}
catch {
    $FailureLine
    exit 1
}
