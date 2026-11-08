# Closes the DayZ server and client.
. "$PSScriptRoot\common.ps1"

$processes = Get-DayZProcesses
if (-not $processes) {
    Show-Info "Nothing to close."
    exit 0
}
$processes | Stop-Process -Force
Show-Ok "Closed: $(($processes | Select-Object -ExpandProperty Name -Unique) -join ', ')"
