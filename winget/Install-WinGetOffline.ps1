[CmdletBinding()]
param(
    [ValidateSet("x64", "x86", "arm64")]
    [string]$Architecture = "x64",

    [string]$CacheDirectory = (Join-Path $PSScriptRoot "cache")
)

$ErrorActionPreference = "Stop"

$bundle = Get-ChildItem $CacheDirectory -Filter "*.msixbundle" -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $bundle) {
    throw "No cached WinGet MSIX bundle found in '$CacheDirectory'. Run Update-WinGetCache.ps1 while online first."
}

$dependencyDirectory = Join-Path $CacheDirectory "dependencies"
$dependencies = @()

if (Test-Path $dependencyDirectory) {
    $dependencies = Get-ChildItem $dependencyDirectory -Recurse -File |
        Where-Object {
            $_.Extension -in @(".appx", ".msix", ".appxbundle", ".msixbundle")
        }

    switch ($Architecture) {
        "x64" {
            $dependencies = $dependencies | Where-Object {
                $_.Name -notmatch "(?i)(x86|arm64|arm)"
            }
        }
        "x86" {
            $dependencies = $dependencies | Where-Object {
                $_.Name -notmatch "(?i)(x64|arm64|arm)"
            }
        }
        "arm64" {
            $dependencies = $dependencies | Where-Object {
                $_.Name -notmatch "(?i)(x86|x64)"
            }
        }
    }
}

Write-Host "Installing cached WinGet package..."
if ($dependencies.Count -gt 0) {
    Add-AppxPackage `
        -Path $bundle.FullName `
        -DependencyPath $dependencies.FullName `
        -ForceApplicationShutdown
}
else {
    Add-AppxPackage -Path $bundle.FullName -ForceApplicationShutdown
}

Write-Host "WinGet/App Installer installation completed."
