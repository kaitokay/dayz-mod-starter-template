# Renames the mod everywhere: file contents and file names.
param([Parameter(Mandatory = $true)] [string] $Name)
. "$PSScriptRoot\common.ps1"

$Name = $Name.Trim()
if ($Name -notmatch '^[A-Za-z][A-Za-z0-9]{1,39}$') {
    Stop-WithError "Name rejected: '$Name'. Start with a letter, then letters and digits only, no spaces or accents. Example: MyCoolMod"
}
$oldName = Get-ModName
if ($Name -ceq $oldName) { Stop-WithError "The mod is already called $Name." }

$excluded = '^(\.git|build|release|tools)(\\|$)'
$files = Get-ChildItem -Path $Root -Recurse -File -Force | Where-Object {
    $_.FullName.Substring($Root.Length + 1) -notmatch $excluded -and
    $_.Extension -in '.c', '.cpp', '.h', '.md', '.txt', '.csv', '.json'
}

# Whole word only: MyMod_Log changes, a word like MyModel doesn't.
$pattern = "(?<![A-Za-z0-9])$([regex]::Escape($oldName))(?![A-Za-z0-9])"
$utf8 = New-Object Text.UTF8Encoding($false)
$changed = 0
foreach ($file in $files) {
    $text = [IO.File]::ReadAllText($file.FullName, $utf8)
    $newText = [regex]::Replace($text, $pattern, $Name)
    if ($newText -cne $text) {
        [IO.File]::WriteAllText($file.FullName, $newText, $utf8)
        $changed++
    }
    if ($file.Name -cmatch $pattern) {
        Rename-Item -LiteralPath $file.FullName -NewName ([regex]::Replace($file.Name, $pattern, $Name))
    }
}

# Old generated files carry the old name.
foreach ($folder in @("build\@$oldName", "release\@$oldName")) {
    $path = Join-Path $Root $folder
    if (Test-Path $path) { Remove-Item -Recurse -Force $path }
}

Show-Ok "$oldName is now $Name ($changed files changed)."
Show-Info "Remember to set your name and description in mod.cpp."
Show-Info "New keys will be created at the next build. The keys for $oldName stay in $(Get-KeysFolder $oldName)."
