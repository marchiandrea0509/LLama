$ErrorActionPreference = 'Stop'

$storePath = 'C:\Users\anmar\.openclaw\agents\llama\sessions\sessions.json'
$key = 'agent:llama:discord:channel:1494983758745698417'

if (-not (Test-Path $storePath)) {
    throw "Session store not found: $storePath"
}

$data = Get-Content $storePath -Raw | ConvertFrom-Json
$prop = $data.PSObject.Properties[$key]

$lines = @()
$lines += 'Llamy room status'
$lines += '- Room: #llama'

if (-not $prop) {
    $lines += '- Session: missing (no active stored room session)'
    $lines -join "`n"
    exit 0
}

$entry = $prop.Value
$updatedAt = [double]$entry.updatedAt
$now = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
$ageMs = [Math]::Max(0, $now - $updatedAt)
$ageMin = [Math]::Floor($ageMs / 60000)
$percent = if ($null -ne $entry.percentUsed) { "$($entry.percentUsed)%" } else { 'unknown' }
$model = if ($entry.model) { $entry.model } else { 'unknown' }
$sessionId = if ($entry.sessionId) { $entry.sessionId } else { 'unknown' }

$lines += '- Session: present'
$lines += "- Model: $model"
$lines += "- Context used: $percent"
$lines += "- Last active: $ageMin min ago"
$lines += "- Session id: $sessionId"

$lines -join "`n"
