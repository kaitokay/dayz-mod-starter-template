# Blocks publishing if a private key, a personal path or a stray file is left behind.
. "$PSScriptRoot\common.ps1"

$mod = Get-ModName
$problems = New-Object Collections.ArrayList

function Add-Problem($text) {
    [void]$problems.Add($text)
    Show-Error $text
}

# Personal trace patterns. This script contains them, so it's excluded from the search.
$patterns = @('[A-Za-z]:[\\/]+Users[\\/]', '/home/[a-z]', [regex]::Escape($env:USERPROFILE))
if ($env:USERNAME -and $env:USERNAME.Length -ge 4) { $patterns += '[\\/]' + [regex]::Escape($env:USERNAME) + '([\\/]|$)' }
if ((Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $Root '.git'))) {
    $email = git -C $Root config user.email
    if ($email) { $patterns += [regex]::Escape($email) }
}
$personalTraces = $patterns -join '|'

function Find-PersonalTrace($file, $name) {
    # Latin1 also reads binary files without errors.
    $content = [IO.File]::ReadAllText($file, [Text.Encoding]::GetEncoding(28591))
    if ($content -match $personalTraces) { Add-Problem "Personal path or trace in ${name}: $($Matches[0])" }
}

# Anywhere in the project, even in a file git ignores.
$privateKeys = Get-ChildItem -Path $Root -Recurse -Force -Filter '*.biprivatekey' -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' }
foreach ($key in $privateKeys) { Add-Problem "PRIVATE KEY in the project: $($key.FullName). Move it out of the project." }

# release/: only what the Publisher has to send.
$release = Join-Path $Root "release\@$mod"
if (-not (Test-Path $release)) {
    Add-Problem "release\@$mod doesn't exist. Run the task '7. Prepare release' first."
} else {
    foreach ($expected in @('mod.cpp', "addons\$mod.pbo", "keys\$mod.bikey")) {
        if (-not (Test-Path (Join-Path $release $expected))) { Add-Problem "$expected is missing from the release." }
    }
    if (-not (Get-ChildItem (Join-Path $release 'addons') -Filter '*.bisign' -ErrorAction SilentlyContinue)) {
        Add-Problem "The .bisign signature is missing from the release."
    }
    $releaseFolder = Join-Path $Root 'release'
    $allowed = "^@$mod\\(mod\.cpp|addons\\[^\\]+\.(pbo|bisign)|keys\\[^\\]+\.bikey)$"
    foreach ($item in Get-ChildItem -Path $releaseFolder -Recurse -Force -File) {
        $relative = $item.FullName.Substring($releaseFolder.Length + 1)
        if ($relative -notmatch $allowed) {
            Add-Problem "Stray file in the release: $relative"
        } else {
            Find-PersonalTrace $item.FullName "release\$relative"
        }
    }
}

# What git tracks, or would track at the next "git add".
$strayFiles = '(^|/)(build|release)/|(^|/)tools/paths\.bat$|\.(pbo|bisign|bikey|log|rpt|adm|mdmp|zip|rar|7z)$|(^|/)(Thumbs\.db|desktop\.ini|\.DS_Store)$'
$tracked = @()
if ((Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $Root '.git'))) {
    $tracked = @(git -C $Root -c core.quotepath=off ls-files --cached --others --exclude-standard)
}
if (-not $tracked) { Show-Info "No git repository: tracked files check skipped." }
foreach ($relative in $tracked) {
    $file = Join-Path $Root $relative
    if (-not (Test-Path -LiteralPath $file)) { continue }
    if ($relative -match $strayFiles) { Add-Problem "Stray file in git: $relative"; continue }
    if ($relative -ne 'tools/check_publish.ps1') { Find-PersonalTrace $file $relative }
}

Write-Host ''
if ($problems.Count -gt 0) { Stop-WithError "PUBLISH BLOCKED: $($problems.Count) problem(s) above." }
Show-Ok "All clear. You can publish release\@$mod with the DayZ Tools Publisher."
