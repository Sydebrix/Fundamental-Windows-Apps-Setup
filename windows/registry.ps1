# Registry customizations.
# Intentionally does nothing by default.
#
# Example:
#
# New-Item -Path "HKCU:\Software\Example" -Force | Out-Null
# Set-ItemProperty -Path "HKCU:\Software\Example" -Name "Enabled" -Value 1
#
# Registry tweak collections age badly and are excellent at turning a fresh
# Windows install into an archaeological dig, so keep this file deliberate.
Write-Host "windows/registry.ps1: no changes configured."
