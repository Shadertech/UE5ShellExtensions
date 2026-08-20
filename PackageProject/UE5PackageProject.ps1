param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

. (Join-Path $PSScriptRoot '..\Shared\UnrealEngineResolution.ps1')

$projectPath = $UProjectPath
$projectDir = Split-Path -Path $projectPath -Parent
$archivePath = Join-Path -Path $projectDir -ChildPath "Saved\Packages\Win64"

try {
    $enginePath = Get-ProjectEnginePath -UProjectFile $projectPath
    Write-Output "Engine Found: $enginePath"

    $runUatPath = Join-Path -Path $enginePath -ChildPath "Engine\Build\BatchFiles\RunUAT.bat"

    Write-Output "--packaging to $archivePath"
    Start-Process -FilePath $runUatPath -ArgumentList "BuildCookRun", "-project=$projectPath", "-noP4", "-platform=Win64", "-clientconfig=Development", "-cook", "-allmaps", "-build", "-stage", "-pak", "-archive", "-archivedirectory=$archivePath"

} catch {
    Write-Output $_.Exception.Message
}

Start-Sleep -Seconds 10
Exit
