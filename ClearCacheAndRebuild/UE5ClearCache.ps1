param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

if (-not (Test-Path $UProjectPath)) {
    Write-Output "UProject file not found: $UProjectPath"
    Start-Sleep -Seconds 5
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

function Remove-BuildArtifactDirectories {
    param (
        [string]$Path
    )
    Remove-Directory -Path (Join-Path -Path $Path -ChildPath "Binaries")
    Remove-Directory -Path (Join-Path -Path $Path -ChildPath "Intermediate")
}

function Get-PluginDirectories {
    param (
        [string]$ProjectDir
    )
    $pluginsRoot = Join-Path -Path $ProjectDir -ChildPath "Plugins"
    if (-not (Test-Path $pluginsRoot)) {
        return @()
    }
    Get-ChildItem -Directory -Path $pluginsRoot
}

$dt = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
$projectPath = (Resolve-Path -Path $UProjectPath).Path
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($projectPath)
$projectDir = Split-Path -Path $projectPath -Parent

Write-Output "removing cache"
Write-Output "--searching $projectDir"

Remove-BuildArtifactDirectories -Path $projectDir

Get-PluginDirectories -ProjectDir $projectDir | ForEach-Object {
    Write-Output "--searching $($_.FullName)"
    Remove-BuildArtifactDirectories -Path $_.FullName
}

$logPath = Join-Path -Path $projectDir -ChildPath "Saved\Logs\UnrealVersionSelector-$dt.log"

try {
    $enginePath = Get-ProjectEnginePath -UProjectFile $projectPath

    Write-Output "Engine Found: $enginePath"
    $buildToolPath = Join-Path -Path $enginePath -ChildPath "Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"

    Write-Output "--rebuilding $projectName"
    Write-Output "buildToolPath: $buildToolPath"
    Write-Output "logPath: $logPath"
    Start-Process -FilePath $buildToolPath -WorkingDirectory $projectDir -ArgumentList "-projectfiles", "-project=$projectPath", "-game", "-rocket", "-progress", "-log=$logPath"

} catch {
    Write-Output $_.Exception.Message
}

Start-Sleep -Seconds 10
Exit
