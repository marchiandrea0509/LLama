$ErrorActionPreference = 'Stop'

$status = openclaw status --json | ConvertFrom-Json

$gatewayState = if ($status.gateway.reachable) { 'reachable' } else { 'unreachable' }
$latency = if ($null -ne $status.gateway.connectLatencyMs) { "$($status.gateway.connectLatencyMs) ms" } else { 'n/a' }
$service = if ($status.gatewayService.runtimeShort) { $status.gatewayService.runtimeShort } else { 'unknown' }
$security = $status.securityAudit.summary
$update = if ($status.update.registry.latestVersion) { $status.update.registry.latestVersion } else { 'none' }

$lines = @()
$lines += 'OpenClaw health'
$lines += "- Gateway: $gatewayState ($latency)"
$lines += "- Gateway service: $service"

if ($status.channelSummary) {
    foreach ($line in $status.channelSummary) {
        if ($line -match '^\S') {
            $lines += "- $line"
        }
    }
}

$lines += "- Security: $($security.critical) critical / $($security.warn) warn / $($security.info) info"
$lines += "- Update available: $update"

$lines -join "`n"
