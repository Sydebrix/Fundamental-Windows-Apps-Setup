# WinGet offline bootstrap

`Update-WinGetCache.ps1` downloads the latest stable WinGet/App Installer package
from Microsoft's `winget-cli` GitHub release together with the dependency bundle.

Run while online:

```powershell
.\winget\Update-WinGetCache.ps1
```

On a machine where WinGet is missing:

```powershell
.\winget\Install-WinGetOffline.ps1
```

The main `bootstrap.ps1` does this automatically if WinGet cannot be found and a
WinGet cache exists.

This is mainly insurance. Normal Windows 11 installations usually already ship
with App Installer/WinGet.
