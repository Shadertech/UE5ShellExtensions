param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

. (Join-Path $PSScriptRoot '..\Shared\UnrealEngineResolution.ps1')

$projectPath = $UProjectPath

$testFilter = Read-Host "Test filter (e.g. Project.MyTest) [default: Project]"
if ([string]::IsNullOrWhiteSpace($testFilter)) { $testFilter = "Project" }

try {
    $enginePath = Get-ProjectEnginePath -UProjectFile $projectPath
    Write-Output "Engine Found: $enginePath"

    $editorCmdPath = Join-Path -Path $enginePath -ChildPath "Engine\Binaries\Win64\UnrealEditor-Cmd.exe"

    Write-Output "--running tests matching '$testFilter'"
    Start-Process -FilePath $editorCmdPath -ArgumentList "$projectPath", "-ExecCmds=`"Automation RunTests $testFilter;Quit`"", "-unattended", "-nullrhi", "-log"

} catch {
    Write-Output $_.Exception.Message
}

Start-Sleep -Seconds 10
Exit
