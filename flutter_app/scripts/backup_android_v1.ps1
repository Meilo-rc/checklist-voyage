param(
    [Parameter(Mandatory = $true)]
    [string] $OutputDirectory,
    [string] $Serial = 'RFCXC0FZAEF',
    [string] $Package = 'fr.checklistvoyage.app'
)

$ErrorActionPreference = 'Stop'
$projectPath = Split-Path -Parent $PSScriptRoot
$dartScript = Join-Path $PSScriptRoot 'dart_windows.ps1'
$adbPath = 'C:\Users\psyco\AppData\Local\Android\Sdk\platform-tools\adb.exe'
$tempRoot = [System.IO.Path]::GetTempPath()
$workingDirectory = Join-Path $tempRoot (
    'checklist-voyage-backup-' + [Guid]::NewGuid().ToString('N')
)
$databaseName = 'checklist_voyage_v1.sqlite'
$databasePath = Join-Path $workingDirectory $databaseName
$timestamp = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss')
$outputPath = [System.IO.Path]::GetFullPath(
    (Join-Path $OutputDirectory "checklist-voyage-v1-$timestamp.cv1backup.json")
)

function Copy-PrivateFile(
    [string] $RemotePath,
    [string] $Destination,
    [bool] $Required
) {
    $savedErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    & $adbPath -s $Serial shell run-as $Package ls $RemotePath *> $null
    $fileExists = $LASTEXITCODE -eq 0
    $ErrorActionPreference = $savedErrorPreference
    if (-not $fileExists) {
        if ($Required) {
            throw "Fichier Android introuvable : $RemotePath"
        }
        return
    }
    $startInfo = [Diagnostics.ProcessStartInfo]::new()
    $startInfo.FileName = $adbPath
    $startInfo.Arguments = "-s $Serial exec-out run-as $Package cat $RemotePath"
    $startInfo.UseShellExecute = $false
    $startInfo.RedirectStandardOutput = $true
    $startInfo.RedirectStandardError = $true
    $process = [Diagnostics.Process]::Start($startInfo)
    $target = [IO.File]::Create($Destination)
    try {
        $process.StandardOutput.BaseStream.CopyTo($target)
    } finally {
        $target.Dispose()
    }
    $errorOutput = $process.StandardError.ReadToEnd()
    $process.WaitForExit()
    if ($process.ExitCode -ne 0) {
        throw "Copie Android impossible : $errorOutput"
    }
}

if (-not (Test-Path -LiteralPath $adbPath)) {
    throw "ADB introuvable : $adbPath"
}
if (-not (Test-Path -LiteralPath $dartScript)) {
    throw "Script Dart introuvable : $dartScript"
}
& $adbPath -s $Serial get-state | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Samsung non disponible dans ADB : $Serial"
}
if (Test-Path -LiteralPath $outputPath) {
    throw "La sauvegarde existe déjà : $outputPath"
}

New-Item -ItemType Directory -Path $workingDirectory | Out-Null
New-Item -ItemType Directory -Path (Split-Path -Parent $outputPath) -Force | Out-Null
try {
    & $adbPath -s $Serial shell am force-stop $Package
    if ($LASTEXITCODE -ne 0) {
        throw 'Impossible d’arrêter proprement l’application.'
    }
    Copy-PrivateFile "app_flutter/$databaseName" $databasePath $true
    Copy-PrivateFile "app_flutter/$databaseName-wal" "$databasePath-wal" $false
    Copy-PrivateFile "app_flutter/$databaseName-shm" "$databasePath-shm" $false

    Push-Location $projectPath
    try {
        $manifest = & $dartScript run tool/v1_safety_backup.dart export `
            --database $databasePath --output $outputPath
        if ($LASTEXITCODE -ne 0) {
            throw 'La conversion en sauvegarde V1 a échoué.'
        }
    } finally {
        Pop-Location
    }

    $fileHash = (Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllText("$outputPath.sha256", "$fileHash  $([IO.Path]::GetFileName($outputPath))`n")
    [IO.File]::WriteAllText("$outputPath.manifest.json", ($manifest -join [Environment]::NewLine))
    Write-Output $outputPath
} finally {
    $savedErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    & $adbPath -s $Serial shell monkey -p $Package -c android.intent.category.LAUNCHER 1 *> $null
    $ErrorActionPreference = $savedErrorPreference
    $resolvedWorking = [System.IO.Path]::GetFullPath($workingDirectory)
    if ($resolvedWorking.StartsWith($tempRoot) -and (Test-Path -LiteralPath $resolvedWorking)) {
        Remove-Item -LiteralPath $resolvedWorking -Recurse -Force
    }
}
