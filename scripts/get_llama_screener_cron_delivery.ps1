$ErrorActionPreference = 'Stop'

$FailureLine = 'llama does not respond'
$StatusScript = 'C:\Users\anmar\.openclaw\workspace-llama\scripts\get_pine_screener_with_winner_shots_status.ps1'
$ManifestPath = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner\latest_manifest.json'
$AllowedWorkspaceRoot = 'C:\Users\anmar\.openclaw\workspace'
$AllowedMediaDir = Join-Path $AllowedWorkspaceRoot 'artifacts\llama_screener_winner'

function Sync-FileIfNeeded {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    if (-not (Test-Path $SourcePath)) {
        throw "Source file missing: $SourcePath"
    }

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

try {
    if (-not (Test-Path $StatusScript)) {
        throw "Status script not found: $StatusScript"
    }

    $table = & powershell -ExecutionPolicy Bypass -File $StatusScript | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw 'Winner-shot status script failed'
    }

    $table = $table.Trim()
    if (-not $table -or $table -eq 'Pine screener winner screenshot failed.') {
        throw 'Winner-shot table unavailable'
    }

    if (-not (Test-Path $ManifestPath)) {
        throw "Manifest not found: $ManifestPath"
    }

    $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
    $image4H = [string]$manifest.image4H
    $image1D = [string]$manifest.image1D

    if (-not $image4H -or -not (Test-Path $image4H)) {
        throw '4H screenshot missing'
    }
    if (-not $image1D -or -not (Test-Path $image1D)) {
        throw '1D screenshot missing'
    }

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
