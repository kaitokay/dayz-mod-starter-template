# One-click test: build, key copy, server, client with BattlEye, live logs.
. "$PSScriptRoot\common.ps1"

$mod = Get-ModName
if ($Root -match '\s') {
    Stop-WithError "The project path contains a space: $Root. Move the project, for example to C:\Mods\$mod."
}

& "$PSScriptRoot\build.ps1"
if ($LASTEXITCODE) { exit $LASTEXITCODE }

$game = Get-RequiredPath (Find-Game) 'DayZ'
$server = Get-RequiredPath (Find-Server) 'DayZ Server'

$cfg = Join-Path $server 'serverDZ.cfg'
if (-not (Test-Path $cfg)) { Stop-WithError "serverDZ.cfg not found in $server" }

# Without the .bikey, the server rejects the mod's signature.
$output = Join-Path $Root "build\@$mod"
$serverKeys = Join-Path $server 'keys'
New-Item -ItemType Directory -Force -Path $serverKeys | Out-Null
Copy-Item (Join-Path $output "keys\$mod.bikey") $serverKeys -Force
Show-Ok "Public key copied to the server"

$serverProfile = Join-Path $Root 'build\profiles\server'
$clientProfile = Join-Path $Root 'build\profiles\client'
New-Item -ItemType Directory -Force -Path $serverProfile, $clientProfile | Out-Null

$startTime = Get-Date
Show-Info "Starting the server"
$serverArguments = "-config=serverDZ.cfg -port=2302 `"-mod=$output`" `"-profiles=$serverProfile`" -dologs -adminlog -freezecheck"
$serverProcess = Start-Process -FilePath (Join-Path $server 'DayZServer_x64.exe') -ArgumentList $serverArguments -WorkingDirectory $server -PassThru

# The client waits until the mod has written its first line to the server log.
$marker = "[$mod] Server started"
$ready = $false
for ($i = 0; $i -lt 180 -and -not $ready; $i++) {
    Start-Sleep -Seconds 1
    if ($serverProcess.HasExited) {
        Stop-WithError "The server closed on its own. See the logs in $serverProfile"
    }
    $log = Get-ChildItem -Path $serverProfile -Filter 'script_*.log' -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -ge $startTime } | Sort-Object CreationTime | Select-Object -Last 1
    if ($log) {
        $stream = New-Object IO.FileStream($log.FullName, 'Open', 'Read', 'ReadWrite, Delete')
        $reader = New-Object IO.StreamReader($stream)
        $ready = $reader.ReadToEnd().Contains($marker)
        $reader.Dispose()
    }
}
if (-not $ready) {
    Stop-WithError "The mod wrote nothing after 3 minutes. See the logs in $serverProfile, then run the task '6. Close everything'."
}
Show-Ok "Mod loaded by the server"

# Gives the server time to open its connections.
Start-Sleep -Seconds 20

# DayZ_BE.exe enables BattlEye, then starts DayZ_x64.exe. Steam must be open.
Show-Info "Starting the client with BattlEye"
$clientArguments = "-exe DayZ_x64.exe `"-mod=$output`" `"-profiles=$clientProfile`" -connect=127.0.0.1 -port=2302 -name=Survivor -nosplash -nopause"
Start-Process -FilePath (Join-Path $game 'DayZ_BE.exe') -ArgumentList $clientArguments -WorkingDirectory $game | Out-Null

& "$PSScriptRoot\live_logs.ps1" -Side server -Since $startTime
