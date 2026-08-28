# Central package definition.
#
# Source controls which WinGet source is used (normally "winget").
# Cacheable marks packages that this base can sensibly archive with winget download.
# PreferredInstallerType is used both for online installs and cache downloads.
# Choosing MSI where practical makes the offline fallback much less annoying.
#
# OfflineExeArgs is only used when the cached installer is an EXE.
# MSI/MSIX/APPX installers are handled generically.

$PackageList = @(
    [pscustomobject]@{
        Name = "VLC"
        Id = "VideoLAN.VLC"
        Source = "winget"
        Cacheable = $true
        Groups = @("Media")
        PreferredInstallerType = "msi"
        Scope = "machine"
        FilePattern = "vlc*"
        OfflineExeArgs = "/S"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "Notepad++"
        Id = "Notepad++.Notepad++"
        Source = "winget"
        Cacheable = $true
        Groups = @("Base")
        PreferredInstallerType = ""
        Scope = "machine"
        FilePattern = "npp*"
        OfflineExeArgs = "/S"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "7-Zip"
        Id = "7zip.7zip"
        Source = "winget"
        Cacheable = $true
        Groups = @("Base")
        PreferredInstallerType = "msi"
        Scope = "machine"
        FilePattern = "7z*"
        OfflineExeArgs = "/S"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "Git"
        Id = "Git.Git"
        Source = "winget"
        Cacheable = $true
        Groups = @("Base")
        PreferredInstallerType = ""
        Scope = "user"
        FilePattern = "Git-*"
        OfflineExeArgs = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "Obsidian"
        Id = "Obsidian.Obsidian"
        Source = "winget"
        Cacheable = $true
        Groups = @("Base")
        PreferredInstallerType = ""
        Scope = "user"
        FilePattern = "Obsidian*"
        OfflineExeArgs = "/S /currentuser"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "Firefox"
        Id = "Mozilla.Firefox"
        Source = "winget"
        Cacheable = $true
        Groups = @("Base")
        PreferredInstallerType = ""
        Scope = "machine"
        FilePattern = "Firefox*"
        OfflineExeArgs = "/S /PreventRebootRequired=true"
        Notes = "Mozilla.Firefox is the en-US package. Change the ID if you want another locale."
    },
    [pscustomobject]@{
        Name = "PowerToys"
        Id = "Microsoft.PowerToys"
        Source = "winget"
        Cacheable = $true
        Groups = @("Base", "Dev")
        PreferredInstallerType = ""
        Scope = "user"
        FilePattern = "PowerToys*"
        OfflineExeArgs = "/quiet /norestart"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "Everything"
        Id = "voidtools.Everything"
        Source = "winget"
        Cacheable = $true
        Groups = @("Base")
        PreferredInstallerType = "msi"
        Scope = "machine"
        FilePattern = "Everything*"
        OfflineExeArgs = "/S"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "Spotify"
        Id = "Spotify.Spotify"
        Source = "winget"
        Cacheable = $true
        Groups = @("Media")
        PreferredInstallerType = ""
        Scope = "user"
        FilePattern = "Spotify*"
        OfflineExeArgs = "/silent /skip-app-launch"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "WhatsApp"
        Id = "9NBDXK71NK08"
        Source = "msstore"
        Cacheable = $false
        Groups = @("Extra")
        PreferredInstallerType = ""
        Scope = "user"
        FilePattern = "*WhatsApp*"
        OfflineExeArgs = ""
        Notes = "Currently resolved through the Microsoft Store source. This base does not cache it offline because Store-package downloads have additional authentication/licensing requirements."
    },
    [pscustomobject]@{
        Name = "Tailscale"
        Id = "Tailscale.Tailscale"
        Source = "winget"
        Cacheable = $true
        Groups = @("Extra")
        PreferredInstallerType = "msi"
        Scope = "machine"
        FilePattern = "tailscale*"
        OfflineExeArgs = "/quiet /norestart"
        Notes = "The script explicitly requests the selected CPU architecture to avoid historical Tailscale WinGet architecture-selection issues."
    },
    [pscustomobject]@{
        Name = "Screenpresso"
        Id = "Learnpulse.Screenpresso"
        Source = "winget"
        Cacheable = $true
        Groups = @("Media")
        PreferredInstallerType = "msi"
        Scope = "machine"
        FilePattern = "Screenpresso*"
        OfflineExeArgs = "deploy --install --quiet"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "JetBrains Toolbox"
        Id = "JetBrains.Toolbox"
        Source = "winget"
        Cacheable = $true
        Groups = @("Extra")
        PreferredInstallerType = ""
        Scope = "user"
        FilePattern = "jetbrains-toolbox*"
        OfflineExeArgs = "/headless"
        Notes = ""
    },
#    [pscustomobject]@{
#        Name = "RustDesk"
#        Id = "RustDesk.RustDesk"
#        Source = "winget"
#        Cacheable = $true
#        Groups = @("Base", "Dev")
#        PreferredInstallerType = ""
#        Scope = "machine"
#        FilePattern = "rustdesk*"
#        OfflineExeArgs = "--silent-install"
#        Notes = "The WinGet package has historically lagged behind upstream RustDesk releases. See NOTES.md."
#    },
    [pscustomobject]@{
        Name = "Proton Drive"
        Id = "Proton.ProtonDrive"
        Source = "winget"
        Cacheable = $true
        Groups = @("Extra")
        PreferredInstallerType = ""
        Scope = "user"
        FilePattern = "Proton*Drive*"
        OfflineExeArgs = "/quiet /norestart"
        Notes = ""
    },
    [pscustomobject]@{
        Name = "Proton Pass"
        Id = "Proton.ProtonPass"
        Source = "winget"
        Cacheable = $true
        Groups = @("Extra")
        PreferredInstallerType = ""
        Scope = ""
        FilePattern = "ProtonPass*"
        OfflineExeArgs = ""
        Notes = "Current WinGet packaging is MSIX/APPX, which the offline installer handles directly."
    },
    [pscustomobject]@{
        Name = "FFmpeg"
        Id = "Gyan.FFmpeg"
        Source = "winget"
        Cacheable = $true
        Groups = @("Media")
        PreferredInstallerType = "zip"
        Scope = ""
        FilePattern = "ffmpeg*.zip"
        OfflineExeArgs = ""
        Notes = "WinGet package is a ZIP archive. Current offline installer script does not yet handle ZIP packages."
    },
    [pscustomobject]@{
        Name = "Java JDK 25"
        Id = "EclipseAdoptium.Temurin.25.JDK"
        Source = "winget"
        Cacheable = $true
        Groups = @("Dev")
        PreferredInstallerType = "msi"
        Scope = "machine"
        FilePattern = "OpenJDK25U-jdk*.msi"
        OfflineExeArgs = ""
        Notes = "Eclipse Temurin OpenJDK 25 LTS."
    },
    [pscustomobject]@{
        Name = "Python 3.14"
        Id = "Python.Python.3.14"
        Source = "winget"
        Cacheable = $true
        Groups = @("Dev")
        PreferredInstallerType = "exe"
        Scope = "machine"
        FilePattern = "python-3.14*-amd64.exe"
        OfflineExeArgs = "/quiet InstallAllUsers=1 PrependPath=1 Include_test=0"
        Notes = "System-wide Python installation with Python and Scripts directories added to PATH."
    },
    [pscustomobject]@{
        Name = ".NET SDK 10"
        Id = "Microsoft.DotNet.SDK.10"
        Source = "winget"
        Cacheable = $true
        Groups = @("Dev")
        PreferredInstallerType = "exe"
        Scope = "machine"
        FilePattern = "dotnet-sdk-10*-win-x64.exe"
        OfflineExeArgs = "/quiet /norestart"
        Notes = ".NET 10 SDK; includes the corresponding .NET runtime."
    },
    [pscustomobject]@{
        Name = "Docker Desktop"
        Id = "Docker.DockerDesktop"
        Source = "winget"
        Cacheable = $true
        Groups = @("Dev")
        PreferredInstallerType = "exe"
        Scope = "machine"
        FilePattern = "Docker Desktop Installer*.exe"
        OfflineExeArgs = "install --quiet --accept-license"
        Notes = "Requires a suitable virtualization backend such as WSL 2. Installer itself is cacheable."
    }
)
