$ErrorActionPreference = 'Stop'

$FailureLine = 'Pine screener winner screenshot failed.'
$MaxAgeMinutes = 60
$ManifestPath = 'C:\Users\anmar\.openclaw\workspace-llama\artifacts\pine_screener_winner\latest_manifest.json'
$RunnerPath = 'C:\Users\anmar\.openclaw\workspace-llama\scripts\run_pine_screener_with_winner_shots.ps1'

try {
    $useCache = $false
    if (Test-Path $ManifestPath) {
        $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
        if ($manifest.generatedAt -and $manifest.tablePath -and $manifest.image4H -and $manifest.image1D) {
            $generatedAt = [datetime]::Parse($manifest.generatedAt).ToUniversalTime()
            $ageMinutes = ((Get-Date).ToUniversalTime() - $generatedAt).TotalMinutes
            if ($ageMinutes -le $MaxAgeMinutes -and (Test-Path $manifest.tablePath) -and (Test-Path $manifest.image4H) -and (Test-Path $manifest.image1D)) {
                $useCache = $true
                Get-Content $manifest.tablePath -Raw
                exit 0
            }
        }
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
