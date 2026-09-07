function Install-Scoop {
    <#
    .SYNOPSIS
    Installs Scoop, a command-line installer for Windows, and configures additional Scoop buckets.

    .DESCRIPTION
    Ensures Scoop and Git are available, then configures the main, extras, games, nonportable, java, versions, and sysinternals buckets used by ATOM.

    .EXAMPLE
    Install-Scoop
    Ensures Scoop is installed and configures the buckets used by ATOM.

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
    
    if (!(Get-Command Update-AtomEnvironmentPath -CommandType Function -ErrorAction SilentlyContinue)) {
        . (Join-Path $PSScriptRoot 'Update-AtomEnvironmentPath.ps1')
    }

    function Test-Scoop {
        if ((Get-Command -Name scoop -ErrorAction SilentlyContinue)) { return $true }
        else { return $false }
    }

    function Install-ScoopBuckets {
        # Install git (dependency for Scoop)
        Update-AtomEnvironmentPath
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
        $buckets = 'main', 'extras', 'games', 'nonportable', 'java', 'versions', 'sysinternals'
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
    Update-AtomEnvironmentPath

    if (Test-Scoop) {
        Write-Host "Scoop"
        Install-ScoopBuckets
    } else {
        Write-Host "Scoop not detected"

        $installerPath = Join-Path ([IO.Path]::GetTempPath()) "scoop-install-$([Guid]::NewGuid().ToString('N')).ps1"
        try {
            Invoke-WebRequest -Uri get.scoop.sh -UseBasicParsing -OutFile $installerPath
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$installerPath`" -RunAsAdmin" -Wait
            Update-AtomEnvironmentPath
        } finally {
            if (Test-Path -LiteralPath $installerPath) {
                Remove-Item -LiteralPath $installerPath -Force
            }
        }

        if (Test-Scoop) {
            Write-Host "- Installed Scoop"
            Install-ScoopBuckets
        } else {
            Write-Host "- Failed to install Scoop"
        }
    }; Write-Host ""
}
