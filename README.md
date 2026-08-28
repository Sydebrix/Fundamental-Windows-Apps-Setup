# PC Setup / Offline Installer Cache

A small Windows 11 bootstrap base built around WinGet **without making Internet
access a hard dependency**.

## TLDR

`I got a new laptop at work and don't want to install all my fundamental applications by hand.`

```text
0_update-cache.ps1
    |
    |  Run on a healthy/online machine.
    |  Refreshes the local installer cache and caches WinGet itself.
    v
1_bootstrap-machine.ps1
    |
    |  Run on a fresh/reset machine.
    |  Prepares the machine, restores WinGet if needed, installs applications,
    |  and can optionally apply Windows configuration.
    v
2_install-applications.ps1
       |
       |  Application installer only.
       |  Can also be run independently later without re-running machine setup.
       v
    Installed applications
```

### Quickstart:
1. Clone/Download this project to your normal machine
2. Do a right-click in the root of this project, select "Open in Terminal" 
   - Check whether the title is "Windows PowerShell", if not, type `PowerShell.exe` and press Enter
3. Create a local, offline backup:
   - `.\0_update-cache.ps1`
4. Copy the directory to a USB-Stick, online drive, etc. 
5. On a new machine, open the Terminal like in `1.` and install all the packages:
   - `.\1_bootstrap-machine.ps1`

It will try to resolve the packages from the internet and get the newest version, and fall-back to your offline backups
in case it fails.

---


#### Difference between `1_bootstrap-machine.ps1` and `2_install-applications.ps1` 
For now there is none. Former runs optional Windows configurations from `./configs`, but given they are empty, both scripts
behave the same. `1_bootstrap-machine.ps1` calls `2_install-applications.ps1` internally. The two
scripts are separate so application installation can later be repeated without
also re-running machine initialization or Windows configuration.

```text
1_bootstrap-machine.ps1
    = machine setup / recovery entry point

2_install-applications.ps1
    = application installation engine
```

---

## Current WinGet package IDs

- Base: Generally useful.
- Media: Related to Images, Audio and Videos
- Dev: Basic Runtimes + Docker
- Extra: Stuff that requires an Account

| Software          | WinGet ID                        | Source    | Profiles | Status                                                                             |
|-------------------|----------------------------------|-----------|----------|------------------------------------------------------------------------------------|
| Firefox           | `Mozilla.Firefox`                | `winget`  | Base     | Resolvable / cacheable                                                             |
| 7-Zip             | `7zip.7zip`                      | `winget`  | Base     | Resolvable / cacheable                                                             |
| Notepad++         | `Notepad++.Notepad++`            | `winget`  | Base     | Resolvable / cacheable                                                             |
| PowerToys         | `Microsoft.PowerToys`            | `winget`  | Base     | Resolvable / cacheable                                                             |
| Everything        | `voidtools.Everything`           | `winget`  | Base     | Resolvable / cacheable                                                             |
| Tailscale         | `Tailscale.Tailscale`            | `winget`  | Base     | Resolvable / cacheable                                                             |
| Git               | `Git.Git`                        | `winget`  | Base     | Resolvable / cacheable                                                             |
| Obsidian          | `Obsidian.Obsidian`              | `winget`  | Base     | Resolvable / cacheable                                                             |
| VLC               | `VideoLAN.VLC`                   | `winget`  | Media    | Resolvable / cacheable                                                             |
| Spotify           | `Spotify.Spotify`                | `winget`  | Media    | Resolvable / Not cacheable, Spotify replaced the installer and hashes don't match. |
| Screenpresso      | `Learnpulse.Screenpresso`        | `winget`  | Media    | Resolvable / cacheable                                                             |
| FFmpeg            | `Gyan.FFmpeg`                    | `winget`  | Media    | Resolvable / cacheable; ZIP offline handling not yet implemented                   |
| Java JDK 25       | `EclipseAdoptium.Temurin.25.JDK` | `winget`  | Dev      | Resolvable / cacheable                                                             |
| Python 3.14       | `Python.Python.3.14`             | `winget`  | Dev      | Resolvable / cacheable                                                             |
| .NET SDK 10       | `Microsoft.DotNet.SDK.10`        | `winget`  | Dev      | Resolvable / cacheable                                                             |
| Docker Desktop    | `Docker.DockerDesktop`           | `winget`  | Dev      | Resolvable / cacheable; requires virtualization backend                            |
| JetBrains Toolbox | `JetBrains.Toolbox`              | `winget`  | Extra    | Resolvable / cacheable                                                             |
| Proton Drive      | `Proton.ProtonDrive`             | `winget`  | Extra    | Resolvable / cacheable                                                             |
| Proton Pass       | `Proton.ProtonPass`              | `winget`  | Extra    | Resolvable / cacheable                                                             |
| WhatsApp          | `9NBDXK71NK08`                   | `msstore` | Extra    | Resolvable online; not cached                                                      |

## 0. Refresh the offline cache

Run this periodically on a healthy machine while Internet access is available:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\0_update-cache.ps1
```

Default architecture is `x64`.

This script:

1. caches WinGet/App Installer itself;
2. downloads current installers for the configured packages;
3. stores them under `installers\`;
4. leaves an existing cached installer untouched if its replacement fails to
   download.

The updater is deliberately transactional per package. It downloads into a
temporary directory and replaces the previous cached package only after WinGet
exits successfully.

A summary is written to:

```text
installers\cache-summary.json
```

You can also refresh only one logical profile:

```powershell
.\0_update-cache.ps1 -IncludeProfile Dev
.\0_update-cache.ps1 -IncludeProfile Media
```

After refreshing the cache, copy or back up the entire project directory somewhere
safe.

---

## 1. Bootstrap a fresh machine

For a fresh Windows installation or after a reset, use:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\1_bootstrap-machine.ps1
```

This is the normal **machine recovery entry point**.

It performs the higher-level setup work:

```text
Check basic environment
        |
        v
Is WinGet available?
        |
        +-- yes ----------------------+
        |                             |
        +-- no                        |
             |                        |
             v                        |
    Try cached WinGet                 |
             |                        |
             +------------------------+
                                      |
                                      v
                         2_install-applications.ps1
                                      |
                                      v
                         Optional Windows configuration
```

Its current responsibilities are:

1. warn if PowerShell is not elevated;
2. locate WinGet;
3. attempt to restore WinGet from the local `winget\cache\` if it is missing;
4. invoke `2_install-applications.ps1`;
5. optionally run the Windows configuration scripts.

By default, Windows configuration is **not** applied.

To explicitly enable it:

```powershell
.\1_bootstrap-machine.ps1 -ApplyWindowsTweaks
```

That runs:

```text
windows\
    features.ps1
    registry.ps1
    services.ps1
```

The separation is intentional: bootstrapping a machine is broader than merely
installing applications.

---

## 2. Install or reinstall applications

`2_install-applications.ps1` is the actual package installation engine.

You can run it directly whenever you only want to install applications:

```powershell
.\2_install-applications.ps1
```

It:

1. loads `package-list.ps1`;
2. selects packages belonging to the requested profile;
3. installs each package according to the selected mode.

This makes it suitable not only for a fresh machine, but also for later use when
you add software, rebuild a development environment, or want to install one of
the package profiles without touching the rest of the machine configuration.

### Installation modes

`Auto` is the default:

```powershell
.\2_install-applications.ps1 -Mode Auto
```

For each package it tries:

```text
WinGet online installation
        |
        +-- success -> done
        |
        `-- failure
              |
              v
       cached installer
```

Force offline installation:

```powershell
.\2_install-applications.ps1 -Mode Offline
```

Force WinGet/online installation only:

```powershell
.\2_install-applications.ps1 -Mode Online
```

If a cached EXE has no known unattended switches, it is skipped by default rather
than guessing.

To allow a normal installer wizard in that situation:

```powershell
.\2_install-applications.ps1 -Mode Offline -InteractiveOfflineFallback
```

The same installation options can also be passed through
`1_bootstrap-machine.ps1`.

---

## Profiles

Packages are assigned to one or more logical profiles in:

```text
package-list.ps1
```

For example:

```powershell
Groups = @("Base", "Dev")
```

means the package is included in both the `Base` and `Dev` profiles.

Available profile values are currently:

```text
Base
Dev
AI
Media
Extra
All
```

`All` selects every configured package.

Examples:

```powershell
.\1_bootstrap-machine.ps1 -IncludeProfile Base
.\1_bootstrap-machine.ps1 -IncludeProfile Dev

.\2_install-applications.ps1 -IncludeProfile Media
.\2_install-applications.ps1 -IncludeProfile AI
```

You can also specify multiple profiles, as well as exclude them:
```text 
Install everything (default):
    .\2_install-applications.ps1

Install multiple profiles:
    .\2_install-applications.ps1 -IncludeProfile Base,Dev,AI

Install everything except Dev packages:
    .\2_install-applications.ps1 -ExcludeProfile Dev

Install Base + Media, but exclude anything also tagged Dev:
    .\2_install-applications.ps1 -IncludeProfile Base,Media -ExcludeProfile Dev

Bootstrap with the same selection:
    .\1_bootstrap-machine.ps1 -IncludeProfile Base,AI -ExcludeProfile Dev

Refresh all cached installers except Dev:
    .\0_update-cache.ps1 -ExcludeProfile Dev
```

---

## Package source of truth

Edit:

```text
package-list.ps1
```

Each package definition contains information such as:

- display name;
- WinGet ID;
- WinGet source;
- profile memberships;
- whether the installer should be cached;
- preferred installer type;
- installation scope;
- cached filename pattern;
- offline EXE silent arguments.

Where WinGet exposes a suitable MSI installer, this setup prefers it because the
offline installation path is predictable:

```powershell
msiexec.exe /i package.msi /qn /norestart
```

---

## WinGet itself

`0_update-cache.ps1` also runs the WinGet cache updater under:

```text
winget\
    Update-WinGetCache.ps1
```

That stores Microsoft's App Installer/WinGet package and its dependencies under:

```text
winget\
    cache\
```

If WinGet is missing on a fresh machine, `1_bootstrap-machine.ps1` attempts to
restore it from this local cache before application installation begins.

This is mainly disaster-recovery insurance. A normal Windows 11 installation
usually already includes App Installer/WinGet, but the recovery process should
not depend on that assumption.

---

## Windows customization

These files are deliberately separate from application installation:

```text
windows\
    features.ps1
    registry.ps1
    services.ps1
```

They are intended for machine-level configuration such as:

- Windows optional features;
- registry settings;
- service configuration.

They are only executed when explicitly requested:

```powershell
.\1_bootstrap-machine.ps1 -ApplyWindowsTweaks
```

Keeping these separate means:

```text
2_install-applications.ps1
```

can safely be reused later without also reapplying machine configuration.

---

## Config backups

`configs\` contains placeholder directories for application configuration, for
example:

```text
configs\
    git\
    powershell\
    vscode\
    firefox\
```

Nothing is restored automatically yet.

That is intentional. Configuration restore is often more machine- and
user-specific than application installation, especially for things such as:

- credentials;
- Git identity;
- SSH keys;
- browser state;
- IDE configuration;
- work-vs-personal settings.

Explicit restore logic can be added once it is clear which configuration should
actually be portable between machines.

---

## Typical workflow

### On your existing machine

```powershell
.\0_update-cache.ps1
```

Then back up the complete directory.

### On a fresh/reset machine

```powershell
.\1_bootstrap-machine.ps1
```

### Later, when you only want applications

```powershell
.\2_install-applications.ps1 -IncludeProfile Dev
```

So the short version is:

```text
0 = prepare recovery cache
1 = bootstrap/recover machine
2 = install applications only
```

---

## Important notes

Read `NOTES.md`.

In particular:

- all requested applications are currently resolvable through WinGet;
- WhatsApp currently comes from the `msstore` source and is not cached by this
  base;
- RustDesk's WinGet package may lag upstream;
- an installer cached by WinGet is not guaranteed to be a fully self-contained
  offline installer if the vendor ships a web bootstrapper.
