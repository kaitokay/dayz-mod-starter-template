# Creates build/@Mod: signed .pbo, public key, and mod.cpp with the version.
. "$PSScriptRoot\common.ps1"

$mod = Get-ModName
$version = Get-ModVersion $mod
Show-Info "Building $mod, version $version"

if (Get-DayZProcesses) {
    Stop-WithError "DayZ or the server is still open and locks the files. Run the task '6. Close everything', then try again."
}
$tools = Get-RequiredPath (Find-Tools) 'DayZ Tools'

# First time only: DSCreateKey writes both keys to the current folder.
$keys = Get-KeysFolder $mod
$privateKey = Join-Path $keys "$mod.biprivatekey"
$publicKey = Join-Path $keys "$mod.bikey"
if (-not (Test-Path $privateKey)) {
    if (Test-Path $publicKey) { Stop-WithError "Private key missing while the public one exists: $privateKey. Restore it from your backups." }
    New-Item -ItemType Directory -Force -Path $keys | Out-Null
    Start-Process -FilePath (Join-Path $tools 'Bin\DsUtils\DSCreateKey.exe') -ArgumentList $mod -WorkingDirectory $keys -Wait -NoNewWindow
    if (-not (Test-Path $privateKey)) { Stop-WithError "DSCreateKey did not create the key in $keys" }
    Show-Ok "Keys created in $keys"
    Show-Warning "Back this folder up: without the private key, servers will have to change keys at your next update."
}
if (-not (Test-Path $publicKey)) { Stop-WithError "Public key missing: $publicKey. Restore it from your backups." }

$build = Join-Path $Root 'build'
$output = Join-Path $build "@$mod"
$addons = Join-Path $output 'addons'
$stage = Join-Path $build "stage\$mod"
foreach ($folder in @($output, (Split-Path $stage))) {
    if (Test-Path $folder) { Remove-Item -Recurse -Force $folder }
}
New-Item -ItemType Directory -Force -Path $addons, $stage, (Join-Path $output 'keys') | Out-Null

# Only what include.txt lists goes into the .pbo.
foreach ($line in Get-Content (Join-Path $PSScriptRoot 'include.txt')) {
    $item = $line.Trim()
    if (-not $item -or $item.StartsWith('#')) { continue }
    $source = Join-Path $Root $item
    if (-not (Test-Path $source)) { Stop-WithError "include.txt lists a missing item: $item" }
    Copy-Item -Recurse -Force $source (Join-Path $stage $item)
}

# -packonly: no binarizing, so no need for the P: drive.
$arguments = "`"$stage`" `"$addons`" -clear -packonly -prefix=$mod `"-sign=$privateKey`""
Start-Process -FilePath (Join-Path $tools 'Bin\AddonBuilder\AddonBuilder.exe') -ArgumentList $arguments -Wait -NoNewWindow

# AddonBuilder has no reliable exit code, so check the files instead.
$pbo = Join-Path $addons "$mod.pbo"
if (-not (Test-Path $pbo)) { Stop-WithError "AddonBuilder did not create $mod.pbo. See its messages above." }
if (-not (Get-ChildItem $addons -Filter '*.bisign')) { Stop-WithError "$mod.pbo is not signed. Check the key: $privateKey" }

Copy-Item $publicKey (Join-Path $output 'keys')
$modCpp = (Get-Content (Join-Path $Root 'mod.cpp') -Raw).TrimEnd() + "`r`nversion = `"$version`";`r`n"
[IO.File]::WriteAllText((Join-Path $output 'mod.cpp'), $modCpp, (New-Object Text.UTF8Encoding($false)))
Remove-Item -Recurse -Force (Split-Path $stage)

Show-Ok "Build finished: $output"
