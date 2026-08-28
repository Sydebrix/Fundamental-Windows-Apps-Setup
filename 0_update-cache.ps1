[CmdletBinding()]
param(
    [ValidateSet("All", "Base", "Dev", "AI", "Media", "Extra")]
    [string[]]$IncludeProfile = @("All"),

    [ValidateSet("All", "Base", "Dev", "AI", "Media", "Extra")]
    [string[]]$ExcludeProfile = @(),

    [ValidateSet("x64", "x86", "arm64")]
    [string]$Architecture = "x64",

    [switch]$SkipWinGetCache
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib\Common.ps1")
. (Join-Path $PSScriptRoot "package-list.ps1")

$installerRoot = Join-Path $PSScriptRoot "installers"
New-Item -ItemType Directory -Path $installerRoot -Force | Out-Null

if (-not $SkipWinGetCache) {
    Write-Section "Caching WinGet itself"
    & (Join-Path $PSScriptRoot "winget\Update-WinGetCache.ps1")
}

$winget = Get-WinGetPath
if (-not $winget) {
    throw "WinGet is not available. Install it first, then rerun this cache update."
}

$packages = Select-PackagesByProfile `
    -PackageList $PackageList `
    -Profile $IncludeProfile `
    -ExcludeProfile $ExcludeProfile

$results = @()

foreach ($package in $packages) {
    Write-Section "Caching $($package.Name) [$($package.Id)]"

    if (-not $package.Cacheable) {
        Write-Warning "$($package.Name) is WinGet-resolvable but intentionally not cached by this script. Source: $($package.Source)"
        $results += [pscustomobject]@{
            Name = $package.Name
            Id = $package.Id
            Success = $true
            CachedAt = (Get-Date).ToString("o")
            Error = "Skipped: online-only source/package in this base"
        }
        continue
    }

    $finalDirectory = Join-Path $installerRoot $package.Id
    $tempDirectory = "$finalDirectory.new"

    if (Test-Path $tempDirectory) {
        Remove-Item $tempDirectory -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null

    & $winget show `
        --id $package.Id `
        --exact `
        --source $package.Source `
        --accept-source-agreements 2>&1 |
        Out-File (Join-Path $tempDirectory "winget-show.txt") -Encoding UTF8

    $wingetArgs = @(
        "download",
        "--id", $package.Id,
        "--exact",
        "--source", $package.Source,
        "--architecture", $Architecture,
        "--download-directory", $tempDirectory,
        "--accept-package-agreements",
        "--accept-source-agreements"
    )

    if ($package.Scope) {
        $wingetArgs += @("--scope", $package.Scope)
    }

    if ($package.PreferredInstallerType) {
        $wingetArgs += @("--installer-type", $package.PreferredInstallerType)
    }

    & $winget @wingetArgs
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0 -and $package.PreferredInstallerType) {
        Write-Warning "Preferred installer type '$($package.PreferredInstallerType)' failed. Retrying with WinGet default selection..."

        Remove-Item $tempDirectory -Recurse -Force
        New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null

        $retryArgs = @(
            "download",
            "--id", $package.Id,
            "--exact",
            "--source", $package.Source,
            "--architecture", $Architecture,
            "--download-directory", $tempDirectory,
            "--accept-package-agreements",
            "--accept-source-agreements"
        )

        if ($package.Scope) {
            $retryArgs += @("--scope", $package.Scope)
        }

        & $winget @retryArgs
        $exitCode = $LASTEXITCODE
    }

    if ($exitCode -eq 0) {
        if (Test-Path $finalDirectory) {
            Remove-Item $finalDirectory -Recurse -Force
        }
        Move-Item $tempDirectory $finalDirectory

        $results += [pscustomobject]@{
            Name = $package.Name
            Id = $package.Id
            Success = $true
            CachedAt = (Get-Date).ToString("o")
            Error = ""
        }

        Write-Host "Cached successfully."
    }
    else {
        Remove-Item $tempDirectory -Recurse -Force -ErrorAction SilentlyContinue

        $results += [pscustomobject]@{
            Name = $package.Name
            Id = $package.Id
            Success = $false
            CachedAt = (Get-Date).ToString("o")
            Error = "winget download exited with code $exitCode"
        }

        Write-Warning "Could not refresh $($package.Name). Existing cache, if any, was left untouched."
    }
}

$results |
    ConvertTo-Json -Depth 4 |
    Set-Content (Join-Path $installerRoot "cache-summary.json") -Encoding UTF8

$failed = $results | Where-Object { -not $_.Success }

Write-Section "Cache update complete"
Write-Host "Successful: $($results.Count - $failed.Count)"
Write-Host "Failed:     $($failed.Count)"

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed packages:"
    $failed | ForEach-Object { Write-Host " - $($_.Name) [$($_.Id)]" }
}
