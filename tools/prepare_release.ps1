# Creates release/@Mod, ready for the DayZ Tools Publisher, then checks it.
. "$PSScriptRoot\common.ps1"

$mod = Get-ModName
& "$PSScriptRoot\build.ps1"
if ($LASTEXITCODE) { exit $LASTEXITCODE }

$output = Join-Path $Root "build\@$mod"
$release = Join-Path $Root 'release'
if (Test-Path $release) { Remove-Item -Recurse -Force $release }
New-Item -ItemType Directory -Force -Path $release | Out-Null

# Test profiles and logs live in build\profiles, so they aren't copied.
Copy-Item -Recurse $output (Join-Path $release "@$mod")
Show-Ok "Release created: $release\@$mod"
Write-Host ''

& "$PSScriptRoot\check_publish.ps1"
exit $LASTEXITCODE
