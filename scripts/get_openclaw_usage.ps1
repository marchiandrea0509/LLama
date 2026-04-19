$ErrorActionPreference = 'Stop'

$output = & openclaw status --usage 2>&1 | Out-String
if (-not $output) {
    throw 'No output from openclaw status --usage'
}

$lines = $output -split "`r?`n"
$start = -1
$end = $lines.Length - 1

for ($i = 0; $i -lt $lines.Length; $i++) {
    if ($lines[$i].Trim() -eq 'Usage') {
        $start = $i
        break
    }
}

if ($start -lt 0) {
    # Fallback: print trimmed full output if the Usage heading is not found.
    $output.Trim()
    exit 0
}

for ($j = $start + 1; $j -lt $lines.Length; $j++) {
    $trim = $lines[$j].Trim()
    if ($trim -like 'FAQ:*' -or $trim -like 'Troubleshooting:*' -or $trim -eq '') {
        $end = $j - 1
        break
    }
}

$block = ($lines[$start..$end] -join "`n").Trim()
$block
