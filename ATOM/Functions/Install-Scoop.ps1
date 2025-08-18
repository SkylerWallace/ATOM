function Install-Scoop {
    <#
    .SYNOPSIS
    Installs Scoop, a command-line installer for Windows, and configures additional Scoop buckets.

    .DESCRIPTION
    The `Install-Scoop` function ensures that Scoop is installed on the system. If Scoop is already present, it validates the installation and adds commonly used buckets ("main", "extras", "games", "nonportable"). 
    If Scoop is not detected, the function attempts to install it by downloading the official installation script. Additionally, it installs `git`, which is a dependency for managing buckets, if not already present.

    .PARAMETER None
    This function does not accept any parameters; it uses predefined settings for installation and configuration.

    .EXAMPLE
    Install-Scoop
    Ensures that Scoop is installed and configured on the system, including essential buckets like "main", "extras", "games", and "nonportable".

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    None. The function outputs status messages to the console.

    .NOTES
    Author: Skyler Wallace
    Requires: Internet connection to download Scoop and buckets.
    
    .LINK
    For more information about installing Scoop, visit:
    https://scoop.sh/
    #>
    
    function Update-EnvironmentPath {
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }

    function Test-Scoop {
        if ((Get-Command -Name scoop -ErrorAction SilentlyContinue)) { return $true }
        else { return $false }
    }

    function Install-ScoopBuckets {
        # Install git (dependency for Scoop)
        Update-EnvironmentPath
        $gitMissing = !(Get-Command git -ErrorAction SilentlyContinue)
        if ($gitMissing) {
            # Install git w/ Scoop
            $gitProcess = Start-Process powershell -ArgumentList "scoop install git" -Wait -PassThru
            
            if ($gitProcess.ExitCode -eq 0) {
                Write-Host "- Git installed"
            } else {
                Write-Host "- Failed to install git"
                Write-Host "  Cannot install buckets"
                Write-Host "  Some apps may not install"
                return
            }
        }
        
        # Adding "buckets" for Scoop
        $buckets = 'main', 'extras', 'games', 'nonportable'
        $installedBuckets = scoop bucket list | ForEach-Object { $_.Name }
        $buckets | Where-Object { $installedBuckets -notcontains $_ } | ForEach-Object {
            Start-Process powershell -ArgumentList "scoop bucket add $_" -Wait
        }
        
        # Verify all buckets were added
        $installedBuckets = scoop bucket list | ForEach-Object { $_.Name }
        $missingBuckets = $buckets | Where-Object { $installedBuckets -notcontains $_ }

        if ($missingBuckets) {
            Write-Host "- Missing buckets"
            Write-Host "  Some apps may not install"
        } else {
            Write-Host "- Buckets installed"
            Write-Host "  $($buckets -join ',')"
        }
    }
    
    # Import user path and then check for Scoop
    Update-EnvironmentPath

    if (Test-Scoop) {
        Write-Host "Scoop"
        Install-ScoopBuckets
    } else {
        Write-Host "Scoop not detected"

        Invoke-WebRequest -Uri get.scoop.sh -UseBasicParsing -OutFile install.ps1
        Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass .\install.ps1 -RunAsAdmin" -Wait
        Update-EnvironmentPath

        if (Test-Path install.ps1) {
            Remove-Item install.ps1 -Force
        }

        if (Test-Scoop) {
            Write-Host "- Installed Scoop"
            Install-ScoopBuckets
        } else {
            Write-Host "- Failed to install Scoop"
        }
    }; Write-Host ""
}