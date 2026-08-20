param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

$projectDir = Split-Path -Path $UProjectPath -Parent
$logsPath = Join-Path -Path $projectDir -ChildPath "Saved\Logs"

if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
}

Start-Process -FilePath "explorer.exe" -ArgumentList "`"$logsPath`""
