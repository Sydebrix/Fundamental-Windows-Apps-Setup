[CmdletBinding()]
param(
    [ValidateSet("Auto", "Online", "Offline")]
    [string]$Mode = "Auto",

    [ValidateSet("x64", "x86", "arm64")]
    [string]$Architecture = "x64",

    [switch]$InteractiveOfflineFallback
)

$invokeArgs = @{
    Profile = "Media"
    Mode = $Mode
    Architecture = $Architecture
}

if ($InteractiveOfflineFallback) {
    $invokeArgs.InteractiveOfflineFallback = $true
}

& (Join-Path $PSScriptRoot "..\install.ps1") @invokeArgs
exit $LASTEXITCODE
