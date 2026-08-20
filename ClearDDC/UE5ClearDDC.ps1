param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

$projectDir = Split-Path -Path $UProjectPath -Parent
$ddcPath = Join-Path -Path $projectDir -ChildPath "Saved\DerivedDataCache"

if (Test-Path $ddcPath) {
    Write-Output "----clearing $ddcPath"
    Remove-Item -Recurse -Force $ddcPath -ErrorAction SilentlyContinue
} else {
    Write-Output "No project-local Derived Data Cache found at $ddcPath"
}

Start-Sleep -Seconds 5
Exit
