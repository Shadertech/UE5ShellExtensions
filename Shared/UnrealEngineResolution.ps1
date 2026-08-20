function Get-EngineAssociation {
    param (
        [string]$UProjectFile
    )
    $uprojectContent = Get-Content -Path $UProjectFile -Raw | ConvertFrom-Json
    return $uprojectContent.EngineAssociation
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

function Get-ProjectEnginePath {
    param (
        [string]$UProjectFile
    )
    $engineAssociation = Get-EngineAssociation -UProjectFile $UProjectFile
    return Get-EnginePath -EngineAssociation $engineAssociation
}
