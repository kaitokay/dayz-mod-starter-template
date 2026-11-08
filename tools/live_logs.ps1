# Shows the mod's lines and errors live. Ctrl+C to quit.
param(
    [ValidateSet('server', 'client')] [string] $Side = 'server',
    [datetime] $Since = [datetime]::MinValue
)
. "$PSScriptRoot\common.ps1"

$mod = Get-ModName
$folder = Join-Path $Root "build\profiles\$Side"
$prefix = "[$mod]"

# The newest log: only one file is followed, so no line ever shows twice.
function Find-LatestLog {
    Get-ChildItem -Path $folder -Filter 'script_*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $Since } |
        Sort-Object CreationTime |
        Select-Object -Last 1
}

function Show-LogLine($line) {
    if ($line -match "\(E\)|Can't compile|SCRIPT\s+ERROR|$([regex]::Escape($prefix)) ERROR") {
        Write-Host $line -ForegroundColor Red
    } elseif ($line.Contains("$prefix WARNING")) {
        Write-Host $line -ForegroundColor Yellow
    } elseif ($line.Contains($prefix)) {
        Write-Host $line -ForegroundColor Green
    }
}

Show-Info "Waiting for the $Side log in $folder (Ctrl+C to quit)"
$followed = $null
$reader = $null
$rest = ''
try {
    while ($true) {
        $latest = Find-LatestLog
        if ($latest -and (-not $followed -or $latest.FullName -ne $followed)) {
            if ($reader) { $reader.Dispose() }
            $followed = $latest.FullName
            $rest = ''
            Show-Info "Following: $($latest.Name)"
            # Shared for writing: DayZ keeps writing to this file.
            $stream = New-Object IO.FileStream($followed, 'Open', 'Read', 'ReadWrite, Delete')
            $reader = New-Object IO.StreamReader($stream)
        }

        if ($reader) {
            $text = $rest + $reader.ReadToEnd()
            # The last line may be incomplete: keep it for the next pass.
            $lines = $text -split "`n"
            $rest = $lines[-1]
            if ($lines.Count -gt 1) {
                foreach ($line in $lines[0..($lines.Count - 2)]) { Show-LogLine $line.TrimEnd("`r") }
            }
        }
        Start-Sleep -Milliseconds 500
    }
} finally {
    if ($reader) { $reader.Dispose() }
}
