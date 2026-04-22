$ErrorActionPreference = 'Stop'

$ConfigPath = 'C:\Users\anmar\.openclaw\openclaw.json'
if (-not (Test-Path $ConfigPath)) {
    Write-Output 'Qwen backend config missing.'
    exit 1
}

try {
    $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    $baseUrl = [string]$config.models.providers.ollama.baseUrl
    if (-not $baseUrl) {
        Write-Output 'Qwen backend baseUrl missing.'
        exit 1
    }

    $uri = [Uri]$baseUrl
    $hostName = $uri.Host
    $port = if ($uri.Port -gt 0) { $uri.Port } else { 11434 }

    $tcp = Test-NetConnection -ComputerName $hostName -Port $port -WarningAction SilentlyContinue
    if (-not $tcp.TcpTestSucceeded) {
        Write-Output "Qwen backend offline: $hostName`:$port"
        exit 1
    }

    try {
        $null = Invoke-RestMethod -Method Get -Uri ($baseUrl.TrimEnd('/') + '/api/tags') -TimeoutSec 8
    }
    catch {
        Write-Output "Qwen backend API unreachable: $hostName`:$port"
        exit 1
    }

    Write-Output "Qwen backend OK: $hostName`:$port"
    exit 0
}
catch {
    Write-Output 'Qwen backend check failed.'
    exit 1
}
