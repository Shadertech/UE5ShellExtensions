# UE5 Shell Extensions

Windows right-click context menu extensions for `.uproject` files.

## Setup

Run `UE5ShellConfiguration.ps1` (right-click → **Run with PowerShell**) to install, uninstall, or check the status of features. It's menu-driven, writes to `HKCU` (no admin needed), and auto-detects each feature's script path.

## Upgrading from the legacy install

The legacy installer used a `.reg` file and wrote to `HKLM`, which the new script can't see or remove.
- **If you have not yet updated the repo** Run `UE5ClearCacheContextMenuDel.reg` first, then pull the latest changes.
- **If you have already updated the repo** Remove the leftover key from an elevated PowerShell:

```powershell
Remove-Item -Path "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.uproject\shell\UE5ClearCache" -Recurse -Force
```

## Features
<img width="289" height="319" alt="UE5ShellExtensions" src="https://github.com/user-attachments/assets/083089ab-d4b3-4898-aa67-4db119001400" />

All features resolve the project's engine version automatically from its `.uproject` file - no hardcoded engine path.

| Feature | What it does |
| --- | --- |
| **ClearCacheAndRebuild** | Clears `Binaries`/`Intermediate` (project and plugins) and regenerates project files. |
| **Build** | Compiles the project's Editor target (Win64, Development). |
| **RunHeadlessServer** | Launches the project as a headless (no-render) server. |
| **CookContent** | Cooks content for Windows without opening the editor. |
| **PackageProject** | Runs a full `BuildCookRun` package for Win64. |
| **RunAutomationTests** | Runs automation tests headless, prompting for a test filter. |
| **ClearDDC** | Clears the project-local Derived Data Cache (`Saved\DerivedDataCache`). |
| **OpenSavedLogs** | Opens the project's `Saved\Logs` folder in Explorer. |
| **OpenProjectTerminal** | Opens a terminal at the project's root folder. |

**Requires:** Unreal Engine 5.x, [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4), Windows.

## Contributing

PRs welcome.

## License

[MIT](LICENSE)
