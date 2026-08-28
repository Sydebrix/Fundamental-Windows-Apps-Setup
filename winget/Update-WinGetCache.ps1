[CmdletBinding()]
param(
    [string]$CacheDirectory = (Join-Path $PSScriptRoot "cache")
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$headers = @{
    "User-Agent" = "pc-setup-winget-cache"
    "Accept" = "application/vnd.github+json"
}

Write-Host "Querying latest stable WinGet release..."
$release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest" `
    -Headers $headers

$bundleAsset = $release.assets |
    Where-Object { $_.name -eq "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" } |
    Select-Object -First 1

$dependencyAsset = $release.assets |
    Where-Object { $_.name -match "DesktopAppInstaller.*Dependencies.*\.zip$" } |
    Select-Object -First 1

$licenseAsset = $release.assets |
    Where-Object { $_.name -match "_License.*\.xml$" } |
    Select-Object -First 1

if (-not $bundleAsset) {
    throw "Could not find the DesktopAppInstaller MSIX bundle in the latest WinGet release."
}

if (-not $dependencyAsset) {
    throw "Could not find the WinGet dependency ZIP in the latest WinGet release."
}

$tempDirectory = "$CacheDirectory.new"
if (Test-Path $tempDirectory) {
    Remove-Item $tempDirectory -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null

try {
    $bundlePath = Join-Path $tempDirectory $bundleAsset.name
    $dependencyZip = Join-Path $tempDirectory $dependencyAsset.name
    $dependencyDirectory = Join-Path $tempDirectory "dependencies"

    Write-Host "Downloading WinGet $($release.tag_name)..."
    Invoke-WebRequest -Uri $bundleAsset.browser_download_url -OutFile $bundlePath -Headers $headers
    Invoke-WebRequest -Uri $dependencyAsset.browser_download_url -OutFile $dependencyZip -Headers $headers

    if ($licenseAsset) {
        Invoke-WebRequest `
            -Uri $licenseAsset.browser_download_url `
            -OutFile (Join-Path $tempDirectory $licenseAsset.name) `
            -Headers $headers
    }

    New-Item -ItemType Directory -Path $dependencyDirectory -Force | Out-Null
    Expand-Archive -Path $dependencyZip -DestinationPath $dependencyDirectory -Force
    Remove-Item $dependencyZip -Force

    [pscustomobject]@{
        Tag = $release.tag_name
        PublishedAt = $release.published_at
        CachedAt = (Get-Date).ToString("o")
    } | ConvertTo-Json | Set-Content (Join-Path $tempDirectory "cache-info.json") -Encoding UTF8

    if (Test-Path $CacheDirectory) {
        Remove-Item $CacheDirectory -Recurse -Force
    }
    Move-Item $tempDirectory $CacheDirectory

    Write-Host "WinGet offline cache updated: $CacheDirectory"
}
catch {
    if (Test-Path $tempDirectory) {
        Remove-Item $tempDirectory -Recurse -Force
    }
    throw
}
