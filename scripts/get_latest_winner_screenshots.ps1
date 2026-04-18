$ErrorActionPreference = 'Stop'

$FailureLine = 'Winner screenshots unavailable.'
$ManifestPath = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner\latest_manifest.json'

try {
    if (-not (Test-Path $ManifestPath)) {
        throw "Manifest not found: $ManifestPath"
    }

    $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    if (-not $manifest.image4H -or -not (Test-Path $manifest.image4H)) {
        throw '4H screenshot missing'
    }
    if (-not $manifest.image1D -or -not (Test-Path $manifest.image1D)) {
        throw '1D screenshot missing'
    }

    $out = [ordered]@{
        winner = $manifest.winner
        image4H = $manifest.image4H
        image1D = $manifest.image1D
    }

    $out | ConvertTo-Json -Depth 3
    exit 0
}
catch {
    $FailureLine
    exit 1
}
