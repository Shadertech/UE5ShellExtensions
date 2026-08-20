<#
.SYNOPSIS
    Installs, uninstalls, and reports status for this repo's UE5 shell extension features.
.PARAMETER Feature
    A feature Id from $Features to target. Omit to target all features.
.PARAMETER ScriptPath
    Overrides auto-detection of the feature's script for -Install. Requires -Feature.
#>
param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Status,
    [string]$Feature,
    [string]$ScriptPath
)

$MenuLabelSuffix = ' (SE)'

$Features = @(
    [PSCustomObject]@{
        Id           = 'ClearCacheAndRebuild'
        MenuLabel    = 'Clear Cache and Rebuild'
        RelativePath = 'ClearCacheAndRebuild\UE5ClearCache.ps1'
    },
    [PSCustomObject]@{
        Id           = 'Build'
        MenuLabel    = 'Build'
        RelativePath = 'Build\UE5Build.ps1'
    },
    [PSCustomObject]@{
        Id           = 'RunHeadlessServer'
        MenuLabel    = 'Run Headless Server'
        RelativePath = 'RunHeadlessServer\UE5RunHeadlessServer.ps1'
    },
    [PSCustomObject]@{
        Id           = 'CookContent'
        MenuLabel    = 'Cook Content'
        RelativePath = 'CookContent\UE5CookContent.ps1'
    },
    [PSCustomObject]@{
        Id           = 'PackageProject'
        MenuLabel    = 'Package Project'
        RelativePath = 'PackageProject\UE5PackageProject.ps1'
    },
    [PSCustomObject]@{
        Id           = 'RunAutomationTests'
        MenuLabel    = 'Run Automation Tests'
        RelativePath = 'RunAutomationTests\UE5RunAutomationTests.ps1'
    },
    [PSCustomObject]@{
        Id           = 'ClearDDC'
        MenuLabel    = 'Clear Derived Data Cache'
        RelativePath = 'ClearDDC\UE5ClearDDC.ps1'
    },
    [PSCustomObject]@{
        Id           = 'OpenSavedLogs'
        MenuLabel    = 'Open Saved Logs'
        RelativePath = 'OpenSavedLogs\UE5OpenSavedLogs.ps1'
    },
    [PSCustomObject]@{
        Id           = 'OpenProjectTerminal'
        MenuLabel    = 'Open Terminal Here'
        RelativePath = 'OpenProjectTerminal\UE5OpenProjectTerminal.ps1'
    }
)

$RegRoot = 'HKCU:\Software\Classes\SystemFileAssociations\.uproject\shell'

function Get-FeatureRegKeyPath {
    param($FeatureItem)
    "$RegRoot\$($FeatureItem.Id)"
}

function Get-FeatureRegCommandPath {
    param($FeatureItem)
    "$(Get-FeatureRegKeyPath $FeatureItem)\command"
}

function Get-FeatureDefaultScriptPath {
    param($FeatureItem)
    Join-Path $PSScriptRoot $FeatureItem.RelativePath
}

function Test-FeatureInstalled {
    param($FeatureItem)
    Test-Path (Get-FeatureRegKeyPath $FeatureItem)
}

function Get-FeatureInstalledScriptPath {
    param($FeatureItem)
    $cmdPath = Get-FeatureRegCommandPath $FeatureItem
    if (-not (Test-Path $cmdPath)) { return $null }
    $command = (Get-ItemProperty -Path $cmdPath -Name '(default)' -ErrorAction SilentlyContinue).'(default)'
    if ($command -match '-File\s+"([^"]+)"') { return $Matches[1] }
    return $null
}

function Get-FeatureAutoScriptPath {
    param($FeatureItem)
    $installedPath = Get-FeatureVerifiedInstalledScriptPath $FeatureItem
    if ($installedPath) { return $installedPath }
    return Get-FeatureVerifiedDefaultScriptPath $FeatureItem
}

function Get-FeatureVerifiedInstalledScriptPath {
    param($FeatureItem)
    if (-not (Test-FeatureInstalled $FeatureItem)) { return $null }
    $installedPath = Get-FeatureInstalledScriptPath $FeatureItem
    if ($installedPath -and (Test-Path $installedPath -PathType Leaf)) { return $installedPath }
    return $null
}

function Get-FeatureVerifiedDefaultScriptPath {
    param($FeatureItem)
    $defaultPath = Get-FeatureDefaultScriptPath $FeatureItem
    if (Test-Path $defaultPath -PathType Leaf) { return $defaultPath }
    return $null
}

function Find-UnrealLogoIcon {
    $icon = Get-UProjectFileAssociationIcon
    if ($icon) { return $icon }
    return Find-InstalledEngineExecutableIcon
}

function Get-UProjectFileAssociationIcon {
    # A source-built engine's own UnrealEditor.exe icon renders black, not the
    # blue Unreal logo, so copy the icon from the .uproject file association
    # itself - what "Switch Unreal Engine version...", "Generate Visual Studio
    # project files", etc. all already point at - to match those exactly.
    $progId = (Get-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\.uproject' -Name '(default)' -ErrorAction SilentlyContinue).'(default)'
    if (-not $progId) { return $null }
    return (Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\$progId\DefaultIcon" -Name '(default)' -ErrorAction SilentlyContinue).'(default)'
}

function Find-InstalledEngineExecutableIcon {
    $engineDirs = Get-InstalledEngineDirectories
    foreach ($exeName in @('UnrealVersionSelector.exe', 'UnrealEditor.exe')) {
        foreach ($dir in $engineDirs) {
            $exe = Join-Path $dir "Engine\Binaries\Win64\$exeName"
            if (Test-Path $exe -PathType Leaf) { return "`"$exe`",0" }
        }
    }
    return $null
}

function Get-InstalledEngineDirectories {
    $engineDirs = @()

    $hklmRoot = 'HKLM:\SOFTWARE\EpicGames\Unreal Engine'
    if (Test-Path $hklmRoot) {
        Get-ChildItem -Path $hklmRoot -ErrorAction SilentlyContinue | ForEach-Object {
            $dir = (Get-ItemProperty -Path $_.PSPath -Name 'InstalledDirectory' -ErrorAction SilentlyContinue).InstalledDirectory
            if ($dir) { $engineDirs += $dir }
        }
    }

    $buildsKey = 'HKCU:\Software\Epic Games\Unreal Engine\Builds'
    if (Test-Path $buildsKey) {
        $buildsItem = Get-Item -Path $buildsKey -ErrorAction SilentlyContinue
        foreach ($name in $buildsItem.Property) {
            $dir = (Get-ItemProperty -Path $buildsKey -Name $name -ErrorAction SilentlyContinue).$name
            if ($dir) { $engineDirs += $dir }
        }
    }

    return $engineDirs
}

function Confirm-RegistryPath {
    param([Parameter(Mandatory)][string]$Path)
    $segments = $Path.Substring(5) -split '\\'
    $current = 'HKCU:'
    foreach ($segment in $segments) {
        if ([string]::IsNullOrWhiteSpace($segment)) { continue }
        $current = "$current\$segment"
        if (-not (Test-Path $current)) {
            New-Item -Path $current -Force | Out-Null
        }
    }
}

function Read-ScriptPath {
    param($FeatureItem, [string]$Default)
    while ($true) {
        $label = "Path to $($FeatureItem.Id) script"
        $prompt = if ($Default) { "$label [$Default]" } else { $label }
        $response = Read-Host $prompt
        if ([string]::IsNullOrWhiteSpace($response)) {
            if (-not $Default) { continue }
            $response = $Default
        }
        $candidate = $response.Trim('"')
        if (-not (Test-Path $candidate -PathType Leaf)) {
            Write-Host "File not found: $candidate" -ForegroundColor Red
            continue
        }
        if ((Get-Item $candidate).Extension -ne '.ps1') {
            Write-Host 'Path must point to a .ps1 file.' -ForegroundColor Red
            continue
        }
        return (Resolve-Path $candidate).Path
    }
}

function Install-Feature {
    param($FeatureItem, [Parameter(Mandatory)][string]$TargetScriptPath)
    $keyPath = Get-FeatureRegKeyPath $FeatureItem
    $cmdPath = Get-FeatureRegCommandPath $FeatureItem
    Confirm-RegistryPath -Path $cmdPath
    Set-Item -Path $keyPath -Value "$($FeatureItem.MenuLabel)$MenuLabelSuffix"

    $iconValue = Find-UnrealLogoIcon
    if ($iconValue) {
        Set-ItemProperty -Path $keyPath -Name 'Icon' -Value $iconValue
    } else {
        Write-Host 'No installed Unreal Engine found - menu entry will use the default icon.' -ForegroundColor Yellow
    }

    $command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$TargetScriptPath`" `"%1`""
    Set-Item -Path $cmdPath -Value $command
    Write-Host "Installed $($FeatureItem.Id). Context menu will run: $TargetScriptPath" -ForegroundColor Green
}

function Uninstall-Feature {
    param($FeatureItem)
    if (-not (Test-FeatureInstalled $FeatureItem)) {
        Write-Host "$($FeatureItem.Id) is not installed." -ForegroundColor Yellow
        return
    }
    Remove-Item -Path (Get-FeatureRegKeyPath $FeatureItem) -Recurse -Force
    Write-Host "Uninstalled $($FeatureItem.Id)." -ForegroundColor Green
}

function Show-FeatureStatus {
    param([array]$FeaturesToShow = $Features)
    foreach ($featureItem in $FeaturesToShow) {
        if (Test-FeatureInstalled $featureItem) {
            $path = Get-FeatureInstalledScriptPath $featureItem
            Write-Host "[installed]     $($featureItem.Id)" -ForegroundColor Green
            Write-Host "                $(if ($path) { $path } else { '(unable to read path)' })"
        } else {
            Write-Host "[not installed] $($featureItem.Id)" -ForegroundColor Yellow
        }
    }
}

function Select-Features {
    param(
        [Parameter(Mandatory)][array]$Candidates,
        [string]$Prompt = 'Select feature(s)',
        [switch]$Single
    )
    if ($Candidates.Count -eq 0) { return @() }
    if ($Single -and $Candidates.Count -eq 1) { return @($Candidates[0]) }
    for ($i = 0; $i -lt $Candidates.Count; $i++) {
        Write-Host "  $($i + 1)) $($Candidates[$i].Id)"
    }
    while ($true) {
        $hint = if ($Single) { 'number' } else { 'numbers separated by commas, or "all"' }
        $response = Read-Host "$Prompt ($hint)"
        if ([string]::IsNullOrWhiteSpace($response)) { continue }
        if (-not $Single -and $response.Trim().ToLower() -eq 'all') { return $Candidates }

        $valid = $true
        $selected = @()
        foreach ($token in ($response -split ',')) {
            $token = $token.Trim()
            if ($token -match '^\d+$' -and [int]$token -ge 1 -and [int]$token -le $Candidates.Count) {
                $selected += $Candidates[[int]$token - 1]
            } else {
                Write-Host "Invalid selection: $token" -ForegroundColor Red
                $valid = $false
                break
            }
        }
        if (-not $valid) { continue }
        if ($Single -and $selected.Count -ne 1) {
            Write-Host 'Choose exactly one.' -ForegroundColor Red
            continue
        }
        return $selected
    }
}

function Get-TargetFeatures {
    param([string]$FeatureId)
    if (-not $FeatureId) { return $Features }
    $match = $Features | Where-Object { $_.Id -eq $FeatureId }
    if (-not $match) {
        Write-Host "Unknown feature: $FeatureId" -ForegroundColor Red
        Write-Host "Known features: $(($Features | ForEach-Object { $_.Id }) -join ', ')"
        exit 1
    }
    return @($match)
}

function Invoke-NonInteractiveInstall {
    param([array]$Targets)
    if ($ScriptPath -and $Targets.Count -gt 1) {
        Write-Host '-ScriptPath requires -Feature to target a single feature.' -ForegroundColor Red
        exit 1
    }
    foreach ($featureItem in $Targets) {
        $path = if ($ScriptPath) { $ScriptPath } else { Get-FeatureAutoScriptPath $featureItem }
        if (-not $path -or -not (Test-Path $path -PathType Leaf)) {
            Write-Host "Could not find a script for $($featureItem.Id) automatically. Pass -Feature $($featureItem.Id) -ScriptPath <path>." -ForegroundColor Red
            continue
        }
        Install-Feature -FeatureItem $featureItem -TargetScriptPath (Resolve-Path $path).Path
    }
}

function Invoke-NonInteractiveMode {
    $targets = Get-TargetFeatures -FeatureId $Feature
    if ($Status) { Show-FeatureStatus -FeaturesToShow $targets; return }
    if ($Uninstall) {
        foreach ($featureItem in $targets) { Uninstall-Feature -FeatureItem $featureItem }
        return
    }
    if ($Install) { Invoke-NonInteractiveInstall -Targets $targets }
}

function Install-SelectedFeatures {
    $selected = Select-Features -Candidates $Features -Prompt 'Install which feature(s)?'
    foreach ($featureItem in $selected) {
        $path = Get-FeatureAutoScriptPath $featureItem
        if (-not $path) { $path = Read-ScriptPath -FeatureItem $featureItem -Default $null }
        Install-Feature -FeatureItem $featureItem -TargetScriptPath $path
    }
}

function Uninstall-SelectedFeatures {
    $installed = @($Features | Where-Object { Test-FeatureInstalled $_ })
    if ($installed.Count -eq 0) {
        Write-Host 'No features installed.' -ForegroundColor Yellow
        return
    }
    $selected = Select-Features -Candidates $installed -Prompt 'Uninstall which feature(s)?'
    foreach ($featureItem in $selected) { Uninstall-Feature -FeatureItem $featureItem }
}

function Invoke-InteractiveMenu {
    do {
        Write-Host ''
        Write-Host '=== UE5 Shell Configuration ===' -ForegroundColor Cyan
        Show-FeatureStatus
        Write-Host ''
        Write-Host '1) Install / Reinstall feature(s)'
        Write-Host '2) Uninstall feature(s)'
        Write-Host '3) Exit'
        $choice = Read-Host 'Choose an option'

        switch ($choice) {
            '1' { Install-SelectedFeatures }
            '2' { Uninstall-SelectedFeatures }
            '3' { }
            default { Write-Host 'Invalid choice.' -ForegroundColor Red }
        }
    } while ($choice -ne '3')

    Write-Host ''
    Read-Host 'Press Enter to exit'
}

if ($Install -or $Uninstall -or $Status) {
    Invoke-NonInteractiveMode
} else {
    Invoke-InteractiveMenu
}
