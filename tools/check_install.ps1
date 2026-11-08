# Checks the requirements and says what to do if one is missing.
. "$PSScriptRoot\common.ps1"
$problems = 0

function Test-Requirement($result, $name) {
    if ($result.Path) {
        Show-Ok "${name}: $($result.Path) ($($result.Message))"
    } else {
        Show-Error "${name}: $($result.Message)"
        $script:problems++
    }
}

$mod = Get-ModName
Show-Info "Mod: $mod, version $(Get-ModVersion $mod)"

$game = Find-Game
$server = Find-Server
$tools = Find-Tools
Test-Requirement $game 'DayZ'
Test-Requirement $server 'DayZ Server'
Test-Requirement $tools 'DayZ Tools'

if ($server.Path) {
    $cfg = Join-Path $server.Path 'serverDZ.cfg'
    if (-not (Test-Path $cfg)) {
        Show-Error "serverDZ.cfg not found in $($server.Path). Verify the DayZ Server files in Steam."
        $problems++
    } elseif ((Get-Content $cfg -Raw) -match '(?im)^\s*BattlEye\s*=\s*0') {
        Show-Warning "serverDZ.cfg contains BattlEye = 0. Set BattlEye = 1 to test under real conditions."
    }
}

$keys = Get-KeysFolder $mod
$privateKey = Join-Path $keys "$mod.biprivatekey"
$publicKey = Join-Path $keys "$mod.bikey"
if ((Test-Path $privateKey) -and (Test-Path $publicKey)) {
    Show-Ok "Keys: $keys"
} elseif (Test-Path $privateKey) {
    Show-Error "Public key missing: $publicKey. Restore it from your backups."
    $problems++
} else {
    Show-Info "Keys: not created yet. The first build will create them in $keys"
}

if ($Root -match '\s') {
    Show-Warning "The project path contains a space: $Root"
    Show-Warning "Local testing will refuse to start. Move the project, for example to C:\Mods\$mod."
}

Write-Host ''
if ($problems -gt 0) { Stop-WithError "$problems problem(s) to fix before going further." }
Show-Ok "All set. Run the build with Ctrl+Shift+B."
