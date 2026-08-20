param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

. (Join-Path $PSScriptRoot '..\Shared\UnrealEngineResolution.ps1')

$projectPath = $UProjectPath
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($UProjectPath)
$projectDir = Split-Path -Path $projectPath -Parent
$targetName = "${projectName}Editor"

if (-not (Test-Path (Join-Path $projectDir "Source"))) {
    Write-Output "$projectName has no Source folder - nothing to compile."
    Start-Sleep -Seconds 5
    Exit
}

$dt = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
$logPath = Join-Path -Path $projectDir -ChildPath "Saved\Logs\Build-$dt.log"

try {
    $enginePath = Get-ProjectEnginePath -UProjectFile $projectPath
    Write-Output "Engine Found: $enginePath"

    $buildToolPath = Join-Path -Path $enginePath -ChildPath "Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"

    Write-Output "--building $targetName Win64 Development"
    Write-Output "logPath: $logPath"
    Start-Process -FilePath $buildToolPath -ArgumentList "$targetName", "Win64", "Development", "-Project=$projectPath", "-WaitMutex", "-log=$logPath"

} catch {
    Write-Output $_.Exception.Message
}

Start-Sleep -Seconds 10
Exit
