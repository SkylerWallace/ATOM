function Install-Choco {
    <#
    .SYNOPSIS
    Installs Chocolatey or verifies its existing installation on the system.

    .DESCRIPTION
    The `Install-Choco` function checks for an existing installation of Chocolatey on the system. If Chocolatey is not detected, the function attempts to install it using one of two methods:
    - The official PowerShell installation script.
    - The `winget` package manager as a fallback.

    After installation, the function verifies the installation and displays the installed version of Chocolatey.

    .EXAMPLE
    Install-Choco
    Checks for Chocolatey and installs it if necessary, displaying the installed version or failure status.

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    None. The function outputs status messages to the console.

    .NOTES
    Author: Skyler Wallace
    Requires: Internet connection to download Chocolatey.
    
    .LINK
    For more information about installing Chocolatey, visit:
    https://chocolatey.org/install
    #>

    function Update-EnvironmentPath {
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    function Test-Choco {
        if (Get-Command choco -ErrorAction SilentlyContinue) { return $true }
        else { return $false }
    }

    if (Test-Choco) {
        $chocoVersion = [System.Version]::Parse((choco --version))
        Write-Host "Chocolatey v$chocoVersion"
    } else {
        Write-Host "Chocolatey not detected"

        # Remove broken Chocolatey if detected
        $chocoPath = "$env:PROGRAMDATA\chocolatey"
        if (Test-Path $chocoPath) {
            Remove-Item $chocoPath -Recurse -Force
        }
        
        Start-Process powershell -ArgumentList "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -Wait
        Update-EnvironmentPath
        
        if (Test-Choco) {
            $chocoVersion = [Version]::Parse((choco --version))
            Write-Host "- Installed Chocolatey v$chocoVersion"
        } else {
            Write-Host "- Failed to install Chocolatey"
        }
    }; Write-Host ""
}