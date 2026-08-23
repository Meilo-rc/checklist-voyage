param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]] $DartArgs
)

$ErrorActionPreference = 'Stop'
$projectPath = Split-Path -Parent $PSScriptRoot
$flutterSdkPath = [System.IO.Path]::GetFullPath(
    (Join-Path $projectPath '..\..\..\Appli Recettes\.flutter-sdk')
)
$tempRoot = [System.IO.Path]::GetTempPath()
$projectLink = Join-Path $tempRoot 'checklist_voyage_dart_project'
$sdkLink = Join-Path $tempRoot 'checklist_voyage_dart_sdk'

function Ensure-Junction([string] $Path, [string] $Target) {
    if (Test-Path -LiteralPath $Path) {
        $existing = Get-Item -LiteralPath $Path -Force
        $existingTarget = [System.IO.Path]::GetFullPath(@($existing.Target)[0])
        if ($existing.LinkType -ne 'Junction' -or $existingTarget -ne $Target) {
            throw "Le chemin temporaire $Path existe déjà avec une autre cible."
        }
        return
    }
    New-Item -ItemType Junction -Path $Path -Target $Target | Out-Null
}

function Remove-ValidatedJunction([string] $Path, [string] $Target) {
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $link = Get-Item -LiteralPath $Path -Force
    $linkTarget = [System.IO.Path]::GetFullPath(@($link.Target)[0])
    if ($link.LinkType -eq 'Junction' -and $linkTarget -eq $Target) {
        [System.IO.Directory]::Delete($Path)
    }
}

try {
    Ensure-Junction $projectLink $projectPath
    Ensure-Junction $sdkLink $flutterSdkPath
    Push-Location $projectLink
    try {
        $env:DART_SUPPRESS_ANALYTICS = 'true'
        & (Join-Path $sdkLink 'bin\cache\dart-sdk\bin\dart.exe') @DartArgs
        $dartExitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
} finally {
    Remove-ValidatedJunction $sdkLink $flutterSdkPath
    Remove-ValidatedJunction $projectLink $projectPath
}
exit $dartExitCode
