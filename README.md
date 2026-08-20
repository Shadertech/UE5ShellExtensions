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
<img width="290" height="128" alt="clearCacheAndRebuild (2)" src="https://github.com/user-attachments/assets/dc6d08df-ac04-4a3e-b89f-69d3c7ad3738" />

### ClearCacheAndRebuild

Clears `Binaries`/`Intermediate` (project and plugins) and regenerates project files, auto-detecting the project's engine version.

**Requires:** Unreal Engine 5.x, [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4), Windows.

## Contributing

PRs welcome.

## License

[MIT](LICENSE)
