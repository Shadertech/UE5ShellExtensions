param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

. (Join-Path $PSScriptRoot '..\Shared\UnrealEngineResolution.ps1')

$projectPath = $UProjectPath

try {
    $enginePath = Get-ProjectEnginePath -UProjectFile $projectPath
    Write-Output "Engine Found: $enginePath"

    $editorCmdPath = Join-Path -Path $enginePath -ChildPath "Engine\Binaries\Win64\UnrealEditor-Cmd.exe"

    Write-Output "--starting headless server"
    Start-Process -FilePath $editorCmdPath -ArgumentList "$projectPath", "-server", "-log"

} catch {
    Write-Output $_.Exception.Message
}

Start-Sleep -Seconds 10
Exit
