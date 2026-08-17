param(
    [Parameter(Mandatory = $true)]
    [string] $FlutterArgs
)

$ErrorActionPreference = 'Stop'
$projectPath = Split-Path -Parent $PSScriptRoot
$flutterSdkPath = [System.IO.Path]::GetFullPath(
    (Join-Path $projectPath '..\..\..\Appli Recettes\.flutter-sdk')
)
$tempRoot = [System.IO.Path]::GetTempPath()
$projectLink = Join-Path $tempRoot 'checklist_voyage_flutter'
$sdkLink = Join-Path $tempRoot 'checklist_voyage_sdk'
$createdProjectLink = $false
$createdSdkLink = $false
$flutterExitCode = 0
$flutterArguments = $FlutterArgs.Split(
    ' ',
    [System.StringSplitOptions]::RemoveEmptyEntries
)

function Ensure-Junction([string] $Path, [string] $Target) {
    if (Test-Path -LiteralPath $Path) {
        $existing = Get-Item -LiteralPath $Path -Force
        $existingTarget = [System.IO.Path]::GetFullPath(@($existing.Target)[0])
        if ($existing.LinkType -ne 'Junction' -or $existingTarget -ne $Target) {
            throw "Le chemin temporaire $Path existe déjà et ne pointe pas vers $Target."
        }
        return $false
    }
    New-Item -ItemType Junction -Path $Path -Target $Target | Out-Null
    return $true
}

function Remove-ValidatedJunction([string] $Path, [string] $Target) {
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }
    $link = Get-Item -LiteralPath $Path -Force
    $linkTarget = [System.IO.Path]::GetFullPath(@($link.Target)[0])
    if ($link.LinkType -eq 'Junction' -and $linkTarget -eq $Target) {
        [System.IO.Directory]::Delete($Path)
    }
}

if (-not (Test-Path -LiteralPath (Join-Path $flutterSdkPath 'bin\flutter.bat'))) {
    throw "SDK Flutter introuvable : $flutterSdkPath"
}

try {
    $createdProjectLink = Ensure-Junction $projectLink $projectPath
    $createdSdkLink = Ensure-Junction $sdkLink $flutterSdkPath
    Push-Location $projectLink
    try {
        $env:CI = 'true'
        $env:FLUTTER_SUPPRESS_ANALYTICS = 'true'
        $env:ANDROID_HOME = 'C:\Users\psyco\AppData\Local\Android\Sdk'
        & (Join-Path $sdkLink 'bin\flutter.bat') @flutterArguments
        $flutterExitCode = $LASTEXITCODE
    } finally {
        Pop-Location
    }
} finally {
    Remove-ValidatedJunction $sdkLink $flutterSdkPath
    Remove-ValidatedJunction $projectLink $projectPath
}

exit $flutterExitCode
