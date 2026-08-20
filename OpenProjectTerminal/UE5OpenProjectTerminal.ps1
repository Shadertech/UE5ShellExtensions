param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

$projectDir = Split-Path -Path $UProjectPath -Parent

if (Get-Command wt.exe -ErrorAction SilentlyContinue) {
    Start-Process -FilePath "wt.exe" -ArgumentList "-d", "`"$projectDir`""
} else {
    Start-Process -FilePath "powershell.exe" -WorkingDirectory $projectDir
}
