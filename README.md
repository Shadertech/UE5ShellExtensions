# UE5 Shell Extensions

Windows right-click context menu extensions for `.uproject` files.

## Setup

Run `UE5ShellConfiguration.ps1` (right-click → **Run with PowerShell**) to install, uninstall, or check the status of features. It's menu-driven, writes to `HKCU` (no admin needed), and auto-detects each feature's script path.

Non-interactive: `-Install [-Feature <id>] [-ScriptPath <path>]`, `-Uninstall [-Feature <id>]`, `-Status [-Feature <id>]`. Omitting `-Feature` targets all features.

## Upgrading from an old install

Versions before `UE5ShellConfiguration.ps1` installed via a `.reg` file that wrote to `HKLM`, which the new script can't see or remove (it's `HKCU`-only).

- **Not yet upgraded?** Run your existing `ClearCacheAndRebuild/UE5ClearCacheContextMenuDel.reg` first, then pull the latest changes.
- **Already upgraded** (that file's gone)? Remove the leftover key from an elevated PowerShell:

```powershell
Remove-Item -Path "HKLM:\SOFTWARE\Classes\SystemFileAssociations\.uproject\shell\UE5ClearCache" -Recurse -Force
```

## Features

### ClearCacheAndRebuild

<img width="290" height="128" alt="clearCacheAndRebuild (2)" src="https://github.com/user-attachments/assets/dc6d08df-ac04-4a3e-b89f-69d3c7ad3738" />

Clears `Binaries`/`Intermediate` (project and plugins) and regenerates project files, auto-detecting the project's engine version.

**Requires:** Unreal Engine 5.x, [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4), Windows.

## Contributing

PRs welcome.

## License

[MIT](LICENSE)
