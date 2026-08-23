$ErrorActionPreference = 'Stop'
$propertiesPath = [Environment]::GetEnvironmentVariable(
    'CHECKLIST_VOYAGE_SIGNING_PROPERTIES',
    'User'
)
if ([string]::IsNullOrWhiteSpace($propertiesPath)) {
    $propertiesPath = $env:CHECKLIST_VOYAGE_SIGNING_PROPERTIES
}
if ([string]::IsNullOrWhiteSpace($propertiesPath) -or -not (Test-Path -LiteralPath $propertiesPath)) {
    throw 'Configuration de signature absente : CHECKLIST_VOYAGE_SIGNING_PROPERTIES.'
}
$env:CHECKLIST_VOYAGE_SIGNING_PROPERTIES = [System.IO.Path]::GetFullPath($propertiesPath)
& (Join-Path $PSScriptRoot 'flutter_windows.ps1') `
    -FlutterArgs 'build apk --release --no-pub'
exit $LASTEXITCODE
