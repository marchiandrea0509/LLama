$ErrorActionPreference = 'Stop'

$FailureLine = 'Winner screenshots unavailable.'
$ManifestPath = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner\latest_manifest.json'
$ArtifactsRoot = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner'

try {
    if (-not (Test-Path $ManifestPath)) {
        throw "Manifest not found: $ManifestPath"
    }

    $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    $image4H = [string]$manifest.image4H
    $image1D = [string]$manifest.image1D
    $winner = [string]$manifest.winner

    if (-not $image4H -or -not (Test-Path $image4H)) {
        throw '4H screenshot missing'
    }
    if (-not $image1D -or -not (Test-Path $image1D)) {
        throw '1D screenshot missing'
    }

    $resolvedRoot = (Resolve-Path $ArtifactsRoot).Path
    $resolved4H = (Resolve-Path $image4H).Path
    $resolved1D = (Resolve-Path $image1D).Path

    if (-not $resolved4H.StartsWith($resolvedRoot) -or -not $resolved1D.StartsWith($resolvedRoot)) {
        throw 'Winner screenshots are outside the expected artifacts directory'
    }

    $rel4H = $resolved4H.Substring($resolvedRoot.Length).TrimStart('\\') -replace '\\','/'
    $rel1D = $resolved1D.Substring($resolvedRoot.Length).TrimStart('\\') -replace '\\','/'

    $out = [ordered]@{
        winner = $winner
        media4H = "MEDIA:./artifacts/pine_screener_winner/$rel4H"
        media1D = "MEDIA:./artifacts/pine_screener_winner/$rel1D"
    }

    $out | ConvertTo-Json -Depth 3
    exit 0
}
catch {
    $FailureLine
    exit 1
}
