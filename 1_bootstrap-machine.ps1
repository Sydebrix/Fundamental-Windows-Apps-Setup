[CmdletBinding()]
param(
    [ValidateSet("All", "Base", "Dev", "AI", "Media")]
    [string]$Profile = "All",

    [ValidateSet("Auto", "Online", "Offline")]
    [string]$Mode = "Auto",

    [ValidateSet("x64", "x86", "arm64")]
    [string]$Architecture = "x64",

    [switch]$ApplyWindowsTweaks,

    [switch]$InteractiveOfflineFallback
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "lib\Common.ps1")

if (-not (Test-IsAdministrator)) {
    Write-Warning "This bootstrap is intended to be run from an elevated PowerShell window."
    Write-Host "Some user-scope packages may work without elevation, but machine-scope MSI packages will not."
}

$winget = Get-WinGetPath

if (-not $winget -and $Mode -ne "Offline") {
    Write-Section "WinGet not found"

    $wingetCache = Join-Path $PSScriptRoot "winget\cache"
    if (Test-Path $wingetCache) {
        try {
            & (Join-Path $PSScriptRoot "winget\Install-WinGetOffline.ps1") -Architecture $Architecture
            $winget = Get-WinGetPath
        }
        catch {
            Write-Warning "Cached WinGet installation failed: $($_.Exception.Message)"
        }
    }
    else {
        Write-Warning "No cached WinGet package exists. Online installation mode may not be available."
    }
}

$installArgs = @{
    Profile = $Profile
    Mode = $Mode
    Architecture = $Architecture
}

if ($InteractiveOfflineFallback) {
    $installArgs.InteractiveOfflineFallback = $true
}

& (Join-Path $PSScriptRoot "2_install-applications.ps1") @installArgs
$installExitCode = $LASTEXITCODE

if ($ApplyWindowsTweaks) {
    Write-Section "Applying optional Windows customization scripts"

    & (Join-Path $PSScriptRoot "windows\features.ps1")
    & (Join-Path $PSScriptRoot "windows\registry.ps1")
    & (Join-Path $PSScriptRoot "windows\services.ps1")
}

exit $installExitCode
