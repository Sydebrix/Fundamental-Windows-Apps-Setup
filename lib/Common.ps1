function Get-WinGetPath {
    $command = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $app = Get-AppxPackage -Name "Microsoft.DesktopAppInstaller" -ErrorAction SilentlyContinue |
        Sort-Object Version -Descending |
        Select-Object -First 1

    if ($app -and $app.InstallLocation) {
        $candidate = Join-Path $app.InstallLocation "winget.exe"
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    return $null
}

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-SuccessExitCode {
    param([int]$ExitCode)
    return $ExitCode -in @(0, 1641, 3010)
}

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host "=== $Text ==="
}
