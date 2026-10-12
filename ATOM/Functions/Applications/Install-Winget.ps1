function Install-Winget {
    <#
    .SYNOPSIS
    Installs or updates Winget (Windows Package Manager) on the system.

    .DESCRIPTION
    The Install-Winget function checks if Winget is installed on the system. If not installed or if an update is available, it downloads and installs Winget along with its dependencies. The function can run under both user and system context, adapting its behavior accordingly.

    .PARAMETER ModulePath
    Path to a local Microsoft.WinGet.Client module manifest or directory. Uses this module to install or update WinGet without downloading the module from PowerShell Gallery.

    .EXAMPLE
    Install-Winget
    Installs or updates Winget on the local system if not already present or if an update is available.

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    None. The function outputs status messages to the console.

    .NOTES
    Author: Skyler Wallace
    Requires: 
    - The custom function `Copy-WebItem` to download files from URLs.
    - Installs module dependencies for the current user when running without administrative privileges.
    - Internet connectivity is required for downloading Winget and its dependencies.

    .LINK
    For more information about installing Winget, visit:
    https://docs.microsoft.com/en-us/windows/package-manager/winget/
    #>

    param (
        [String]$ModulePath
    )

    # Check if function is being ran in System context, adjust function as necessary
    $runningAsSystem = [Security.Principal.WindowsIdentity]::GetCurrent().IsSystem

    # Check if VC++ installed
    if ($runningAsSystem) {
        Write-Verbose "Running as SYSTEM user."
        $vccInstalled = Get-ChildItem 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | ForEach-Object {
            (Get-ItemProperty -LiteralPath $_.PsPath).DisplayName | Where-Object { $_ -like 'Microsoft Visual C++ 2015-2022 Redistributable (x64)*' }
        }
    }

    # Install VC++
    if ($runningAsSystem -and !$vccInstalled) {
        Write-Verbose "Visual C++ 2015-2022 must be installed when running as SYSTEM user."
        Write-Verbose "Installing Visual C++ 2015-2022..."
        
        try {
            $vccOutfile = Copy-WebItem -Uri 'https://aka.ms/vs/17/release/vc_redist.x64.exe'
            Start-Process $vccOutfile -ArgumentList '/q /norestart' -Wait
            Write-Verbose "Visual C++ 2015-2022 installed successfully."
        } catch {
            Write-Error "Failed to install Visual C++ 2015-2022."
        } finally {
            if (Test-Path $vccOutfile) {
                Remove-Item $vccOutfile -Force
            }
        }
    }

    if ($ModulePath) {
        Import-Module -Name $ModulePath -ErrorAction Stop
        Write-Host 'WinGet (local client module)'
        Write-Host '- Checking for updates...'
        Repair-WinGetPackageManager -Latest -ErrorAction Stop | Out-Null
        Write-Host '- Ready'
        return
    }

    # Get winget path, method compatible with running PowerShell as System
    $wingetPath = 
        if ($runningAsSystem) { (Resolve-Path 'C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe')[-1].Path }
        else                  { Get-Command winget -ErrorAction SilentlyContinue| Select-Object -Expand Source }

    # Get winget version
    if ($wingetPath) {
        [version]$currentWingetVersion = (cmd /c $wingetPath --version).Trim('v')
        [version]$latestWingetVersion = (Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/Winget-cli/releases/latest' -Method Get -UseBasicParsing).tag_name.Trim('v')
    }

    # Update winget
    if (!$wingetPath) {
        try {
            $progressPreference = 'SilentlyContinue'
            Write-Host 'WinGet'
            Write-Host '- Installing...'
            $moduleScope = if (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { 'AllUsers' } else { 'CurrentUser' }
            Install-PackageProvider -Name NuGet -Scope $moduleScope -Force | Out-Null
            Install-Module -Name Microsoft.WinGet.Client -Scope $moduleScope -Force -Repository PSGallery | Out-Null
            Repair-WinGetPackageManager
            Write-Host '- Installed WinGet'
        } catch {
            Write-Error 'Failed to install Winget'
        }
    } elseif ($currentWingetVersion -lt $latestWingetVersion) {
        Write-Host "WinGet $currentWingetVersion"
        Write-Host '- Updating...'
        $wingetInstall = Start-Process $wingetPath -ArgumentList 'install --id Microsoft.AppInstaller --accept-source-agreements --accept-package-agreements' -Wait -PassThru

        if ($wingetInstall.ExitCode -eq 0) {
            Write-Host "- Updated to $latestWingetVersion"
        } else {
            Write-Error "Failed to upgrade Winget.`nExit Code : $($wingetInstall.ExitCode)"
        }
    } else {
        Write-Host "WinGet $currentWingetVersion"
    }
}
