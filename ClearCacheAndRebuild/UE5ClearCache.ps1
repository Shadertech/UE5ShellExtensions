param (
    [string]$UProjectPath
)

if (-not $UProjectPath) {
    Write-Output "No .uproject file specified."
    Exit
}

function Remove-Directory {
    param (
        [string]$Path
    )
    if (Test-Path $Path) {
        Write-Output "----cleared $Path"
        Remove-Item -Recurse -Force $Path -ErrorAction SilentlyContinue
    }
}

function Get-EnginePathFromInstalledEngines {
    param (
        [string]$EngineAssociation
    )
    Get-ItemProperty -Path "HKLM:\SOFTWARE\EpicGames\Unreal Engine\$EngineAssociation" -Name "InstalledDirectory" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty InstalledDirectory
}

function Get-EnginePathFromCustomBuilds {
    param (
        [string]$EngineAssociation
    )
    Get-ItemProperty -Path "HKCU:\Software\Epic Games\Unreal Engine\Builds" -Name "$EngineAssociation" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $EngineAssociation
}

function Get-EnginePath {
    param (
        [string]$EngineAssociation
    )

    $enginePath = Get-EnginePathFromInstalledEngines -EngineAssociation $EngineAssociation
    if (-not $enginePath) {
        $enginePath = Get-EnginePathFromCustomBuilds -EngineAssociation $EngineAssociation
    }

    if ($enginePath) {
        return $enginePath
    } else {
        throw "Engine path not found for EngineAssociation: $EngineAssociation"
    }
}


function Get-EngineAssociation {
    param (
        [string]$UProjectFile
    )
    $uprojectContent = Get-Content -Path $UProjectFile -Raw | ConvertFrom-Json
    return $uprojectContent.EngineAssociation
}

$dt = Get-Date -Format "yyyy.MM.dd-HH.mm.ss"
$projectPath = $UProjectPath
$projectName = [System.IO.Path]::GetFileNameWithoutExtension($UProjectPath)

$ID = 0

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
    $engineAssociation = Get-EngineAssociation -UProjectFile $projectPath
    $enginePath = Get-EnginePath -EngineAssociation $engineAssociation

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