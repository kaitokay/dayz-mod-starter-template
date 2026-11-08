# Functions shared by the scripts in tools/.
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot

function Show-Ok($text)      { Write-Host "[OK]      $text" -ForegroundColor Green }
function Show-Info($text)    { Write-Host "[INFO]    $text" -ForegroundColor Cyan }
function Show-Warning($text) { Write-Host "[WARNING] $text" -ForegroundColor Yellow }
function Show-Error($text)   { Write-Host "[ERROR]   $text" -ForegroundColor Red }
function Stop-WithError($text) { Show-Error $text; exit 1 }

# Reads the set "NAME=value" lines of tools/paths.bat. Empty values are ignored.
function Get-ForcedPaths {
    $forced = @{}
    $file = Join-Path $PSScriptRoot 'paths.bat'
    if (Test-Path $file) {
        foreach ($line in Get-Content $file -Encoding UTF8) {
            if ($line -match '^\s*set\s+"?([A-Z_]+)=([^"]*)"?\s*$' -and $Matches[2].Trim()) {
                $forced[$Matches[1]] = $Matches[2].Trim().TrimEnd('\')
            }
        }
    }
    return $forced
}

# All Steam libraries, read from libraryfolders.vdf.
function Get-SteamLibraries {
    $steamRoots = @()
    foreach ($key in @(
        @{ Path = 'HKCU:\Software\Valve\Steam'; Value = 'SteamPath' },
        @{ Path = 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam'; Value = 'InstallPath' }
    )) {
        $value = (Get-ItemProperty -Path $key.Path -Name $key.Value -ErrorAction SilentlyContinue).($key.Value)
        if ($value) { $steamRoots += $value.Replace('/', '\') }
    }

    $libraries = @()
    foreach ($steam in ($steamRoots | Select-Object -Unique)) {
        $libraries += $steam
        $vdf = [IO.Path]::Combine($steam, 'steamapps\libraryfolders.vdf')
        if (Test-Path $vdf) {
            foreach ($m in [regex]::Matches((Get-Content $vdf -Raw), '"path"\s+"([^"]+)"')) {
                $libraries += $m.Groups[1].Value.Replace('\\', '\')
            }
        }
    }
    return $libraries | Select-Object -Unique
}

# A forced path wins over Steam. If it's wrong, say so instead of looking elsewhere.
function Find-Folder($variable, $subFolder, $markerFile) {
    $forced = Get-ForcedPaths
    if ($forced.ContainsKey($variable)) {
        $path = $forced[$variable]
        if (Test-Path ([IO.Path]::Combine($path, $markerFile))) {
            return @{ Path = $path; Message = "forced by tools/paths.bat" }
        }
        return @{ Path = $null; Message = "$variable in tools/paths.bat is wrong: $markerFile not found in $path" }
    }

    # IO.Path rather than Join-Path: Join-Path fails if a library's drive is unplugged.
    foreach ($library in Get-SteamLibraries) {
        $path = [IO.Path]::Combine($library, "steamapps\common\$subFolder")
        if (Test-Path ([IO.Path]::Combine($path, $markerFile))) {
            return @{ Path = $path; Message = "detected through Steam" }
        }
    }
    return @{ Path = $null; Message = "not found. Install it from Steam, or set its path in tools/paths.bat (template: tools/paths.example.bat)" }
}

function Find-Game   { Find-Folder 'DAYZ_DIR' 'DayZ' 'DayZ_BE.exe' }
function Find-Server { Find-Folder 'DAYZ_SERVER_DIR' 'DayZServer' 'DayZServer_x64.exe' }
function Find-Tools  { Find-Folder 'DAYZ_TOOLS_DIR' 'DayZ Tools' 'Bin\AddonBuilder\AddonBuilder.exe' }

# Returns the path, or stops the script with the help message.
function Get-RequiredPath($result, $name) {
    if (-not $result.Path) { Stop-WithError "${name}: $($result.Message)" }
    Show-Ok "${name}: $($result.Path) ($($result.Message))"
    return $result.Path
}

# The mod name comes from config.cpp and the version from <Mod>_Version.c: nothing to set elsewhere.
function Get-ModName {
    $text = Get-Content (Join-Path $Root 'config.cpp') -Raw
    if ($text -notmatch 'dir\s*=\s*"([^"]+)"') { Stop-WithError "config.cpp: dir = ""..."" line not found." }
    return $Matches[1]
}

function Get-ModVersion($mod) {
    $file = Join-Path $Root "scripts\3_Game\$($mod)_Version.c"
    if (-not (Test-Path $file)) { Stop-WithError "Version file not found: $file" }
    $text = Get-Content $file -Raw
    if ($text -notmatch 'NUMBER\s*=\s*"([^"]+)"') { Stop-WithError "NUMBER = ""..."" not found in $file" }
    return $Matches[1]
}

# Keys stay outside the project, so they can't be published by mistake.
function Get-KeysFolder($mod) {
    $forced = Get-ForcedPaths
    if ($forced.ContainsKey('DAYZ_KEYS_DIR')) {
        $folder = $forced['DAYZ_KEYS_DIR']
    } else {
        $folder = Join-Path $env:USERPROFILE "DayZ-Mod-Keys\$mod"
    }
    $fullPath = [IO.Path]::GetFullPath($folder).TrimEnd('\') + '\'
    if ($fullPath.StartsWith($Root.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)) {
        Stop-WithError "The keys folder must not be inside the project: $folder"
    }
    return $folder
}

function Get-DayZProcesses {
    return @(Get-Process -Name 'DayZServer_x64', 'DayZ_x64', 'DayZ_BE' -ErrorAction SilentlyContinue)
}
