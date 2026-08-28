[CmdletBinding()]
param(
    [ValidateSet("All", "Base", "Dev", "AI", "Media", "Extra")]
    [string[]]$IncludeProfile = @("All"),

    [ValidateSet("All", "Base", "Dev", "AI", "Media", "Extra")]
    [string[]]$ExcludeProfile = @(),

    [ValidateSet("Auto", "Online", "Offline")]
    [string]$Mode = "Auto",

    [ValidateSet("x64", "x86", "arm64")]
    [string]$Architecture = "x64",

    [switch]$InteractiveOfflineFallback
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib\Common.ps1")
. (Join-Path $PSScriptRoot "package-list.ps1")

$installerRoot = Join-Path $PSScriptRoot "installers"
$winget = Get-WinGetPath

function Get-CachedInstaller {
    param($Package)

    $packageDirectory = Join-Path $installerRoot $Package.Id
    if (-not (Test-Path $packageDirectory)) {
        return $null
    }

    $extensions = @(".msi", ".exe", ".msix", ".msixbundle", ".appx", ".appxbundle")

    $candidates = Get-ChildItem $packageDirectory -Recurse -File |
        Where-Object {
            $_.Extension.ToLowerInvariant() -in $extensions -and
            $_.Name -like $Package.FilePattern
        }

    if (-not $candidates) {
        $candidates = Get-ChildItem $packageDirectory -Recurse -File |
            Where-Object { $_.Extension.ToLowerInvariant() -in $extensions }
    }

    if (-not $candidates) {
        return $null
    }

    if ($Package.PreferredInstallerType) {
        $preferredExtension = switch ($Package.PreferredInstallerType.ToLowerInvariant()) {
            "msi" { ".msi" }
            "msix" { ".msix" }
            "appx" { ".appx" }
            default { "" }
        }

        if ($preferredExtension) {
            $preferred = $candidates |
                Where-Object { $_.Extension.ToLowerInvariant() -eq $preferredExtension } |
                Sort-Object LastWriteTime -Descending |
                Select-Object -First 1

            if ($preferred) {
                return $preferred
            }
        }
    }

    return $candidates |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

function Install-CachedPackage {
    param($Package)

    $installer = Get-CachedInstaller -Package $Package
    if (-not $installer) {
        Write-Warning "No cached installer found for $($Package.Name)."
        return $false
    }

    Write-Host "Using cached installer: $($installer.FullName)"
    $extension = $installer.Extension.ToLowerInvariant()

    switch ($extension) {
        ".msi" {
            $arguments = "/i `"$($installer.FullName)`" /qn /norestart"
            $process = Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -PassThru
            return (Test-SuccessExitCode $process.ExitCode)
        }

        ".msix" {
            Add-AppxPackage -Path $installer.FullName
            return $true
        }

        ".msixbundle" {
            Add-AppxPackage -Path $installer.FullName
            return $true
        }

        ".appx" {
            Add-AppxPackage -Path $installer.FullName
            return $true
        }

        ".appxbundle" {
            Add-AppxPackage -Path $installer.FullName
            return $true
        }

        ".exe" {
            if ($Package.OfflineExeArgs) {
                $process = Start-Process `
                    -FilePath $installer.FullName `
                    -ArgumentList $Package.OfflineExeArgs `
                    -Wait `
                    -PassThru

                return (Test-SuccessExitCode $process.ExitCode)
            }

            if ($InteractiveOfflineFallback) {
                Write-Warning "No known silent EXE arguments for $($Package.Name); launching interactively."
                $process = Start-Process -FilePath $installer.FullName -Wait -PassThru
                return (Test-SuccessExitCode $process.ExitCode)
            }

            Write-Warning "Cached EXE found, but no known silent arguments. Re-run with -InteractiveOfflineFallback to launch it normally."
            return $false
        }
    }

    Write-Warning "Unsupported cached installer type: $extension"
    return $false
}

function Install-OnlinePackage {
    param($Package)

    if (-not $winget) {
        return $false
    }

    $wingetArgs = @(
        "install",
        "--id", $Package.Id,
        "--exact",
        "--source", $Package.Source,
        "--architecture", $Architecture,
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )

    if ($Package.Scope) {
        $wingetArgs += @("--scope", $Package.Scope)
    }

    if ($Package.PreferredInstallerType) {
        $wingetArgs += @("--installer-type", $Package.PreferredInstallerType)
    }

    & $winget @wingetArgs
    return ($LASTEXITCODE -eq 0)
}

$packages = Select-PackagesByProfile `
    -PackageList $PackageList `
    -IncludeProfile $IncludeProfile `
    -ExcludeProfile $ExcludeProfile

if (-not $packages) {
    $includedText = $IncludeProfile -join ", "
    $excludedText = if ($ExcludeProfile.Count -gt 0) {
        $ExcludeProfile -join ", "
    }
    else {
        "<none>"
    }

    Write-Host "No packages matched the selected profiles."
    Write-Host "Included: $includedText"
    Write-Host "Excluded: $excludedText"
    exit 0
}

$failures = @()

foreach ($package in $packages) {
    Write-Section "Installing $($package.Name) [$($package.Id)]"

    $success = $false

    if ($Mode -in @("Auto", "Online")) {
        if ($winget) {
            $success = Install-OnlinePackage -Package $package
            if (-not $success) {
                Write-Warning "Online WinGet installation failed."
            }
        }
        elseif ($Mode -eq "Online") {
            Write-Warning "WinGet is unavailable."
        }
    }

    if (-not $success -and $Mode -in @("Auto", "Offline")) {
        if ($Mode -eq "Auto") {
            Write-Host "Trying cached offline installer..."
        }
        $success = Install-CachedPackage -Package $package
    }

    if (-not $success) {
        $failures += $package
    }
}

Write-Section "Installation complete"

if ($failures.Count -eq 0) {
    Write-Host "All selected packages completed successfully."
    exit 0
}

Write-Warning "$($failures.Count) package(s) did not complete:"
$failures | ForEach-Object {
    Write-Host " - $($_.Name) [$($_.Id)]"
}
exit 1
