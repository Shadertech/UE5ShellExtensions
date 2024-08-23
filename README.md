# UE5 Shell Extensions
**Overview**:
This project is a place where I put useful shell extensions for UE5 projects.

## Extensions

### 1. ClearCacheAndRebuild

**Overview**:
Adds a context menu option to the right click on all UProject files.
It will clear out binaries and intermediates folders of both the project and it's plugins. It then will regenerate project files. It automatically selects the version of the UProject; working with both binary releases and custom engines.

I have previously created a bat file that did the same thing as well as created a context menu item for a single project. If you need anything like that just give me a shout and I will help you out.

#### Prerequisites

- Unreal Engine 5.x
- [Powershell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4)
- Windows

##### Usage

To install this extension:
1. Clone the repository to your local machine.
2. Edit ClearCacheAndRebuild/UE5ClearCacheContextMenuAdd.reg and change the path of the UE5ClearCache.ps1 to the path on your machine.
3. Run ClearCacheAndRebuild/UE5ClearCacheContextMenuAdd.reg

To remove this extension:
1. Run ClearCacheAndRebuild/UE5ClearCacheContextMenuDel.reg

To update this extension:
1. Run ClearCacheAndRebuild/UE5ClearCacheContextMenuDel.reg
2. Pull the latest changes from github
3. Run ClearCacheAndRebuild/UE5ClearCacheContextMenuAdd.reg

## Contributing

Contributions to this project are welcome. Please follow the standard GitHub workflow for submitting pull requests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
