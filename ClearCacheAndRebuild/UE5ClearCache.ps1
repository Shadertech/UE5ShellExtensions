param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

. (Join-Path $PSScriptRoot '..\Shared\UnrealEngineResolution.ps1')

function Remove-Directory {
    param (
        [string]$Path
    )
    if (Test-Path $Path) {
        Write-Output "----cleared $Path"
        Remove-Item -Recurse -Force $Path -ErrorAction SilentlyContinue
    }
}

$dt = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
$projectPath = $UProjectPath
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($UProjectPath)

Write-Output "removing cache"
Write-Output "--searching root"

Remove-Directory -Path "Binaries"
Remove-Directory -Path "Intermediate"

Get-ChildItem -Directory "Plugins" | ForEach-Object {
    Write-Output "--searching $($_.FullName)"
    Remove-Directory -Path "$($_.FullName)\Binaries"
    Remove-Directory -Path "$($_.FullName)\Intermediate"
}

Write-Output "searching root for UProject"

if (-not (Test-Path $projectPath)) {
    Write-Output "UProject file not found."
    Exit
}

$logPath = Join-Path -Path (Join-Path -Path $PWD -ChildPath "Saved\Logs") -ChildPath "UnrealVersionSelector-$dt.log"

try {
    $enginePath = Get-ProjectEnginePath -UProjectFile $projectPath

    Write-Output "Engine Found: $enginePath"
    $buildToolPath = Join-Path -Path $enginePath -ChildPath "Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"

    Write-Output "--rebuilding $projectName"
    Write-Output "buildToolPath: $buildToolPath"
    Write-Output "logPath: $logPath"
    Start-Process -FilePath $buildToolPath -ArgumentList "-projectfiles", "-project=$projectPath", "-game", "-rocket", "-progress", "-log=$logPath"

} catch {
    Write-Output $_.Exception.Message
}

Start-Sleep -Seconds 10
Exit
