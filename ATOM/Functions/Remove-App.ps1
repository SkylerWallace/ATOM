function Remove-App {
    <#
    .SYNOPSIS
    Uninstalls an application from the system.

    .DESCRIPTION
    The `Remove-App` function uninstalls an application using its uninstall or quiet uninstall string. Supports MSI and EXE-based uninstallers, handling path quoting and argument parsing automatically.

    .PARAMETER App
    Specifies an object from Get-App.

    .EXAMPLE
    Get-App 'Microsoft Edge' | Remove-App
    Uninstalls Microsoft Edge.

    .INPUTS
    [PsCustomObject]
    Accepts output from Get-App which has the following properties:
    - DisplayName          : The name of the application as shown in Programs and Features.
    - DisplayVersion       : The version number of the application.
    - Publisher            : The software publisher.
    - EstimatedSize        : The approximate size of the application, in KB.
    - PsPath               : The full registry path of the uninstall entry.
    - UninstallString      : The command used to uninstall the application.
    - QuietUninstallString : The command used to silently uninstall the application, if available.

    .OUTPUTS
    None. This function does not produce output to the pipeline.

    .NOTES
    Author: Skyler Wallace
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [PsCustomObject]$App
    )

    process {
        $uninstallString = @(
            if ($App.QuietUninstallString) { $App.QuietUninstallString }
            elseif ($App.UninstallString) { $App.UninstallString }
        ) -replace '(?<!")([a-zA-Z]:\\[^"]+\.(bat|cmd|exe|msi))(?!")', '"$1"'

        $uninstallParams = @{
            Wait     = $true
            PassThru = $true
        }

        # Check if uninstaller uses msiexec with regex
        $msiMatch = [regex]::Match($uninstallString, '\/[IX]\{[^}]*\}')
        $exeMatch = [regex]::Match($uninstallString, '"[^"]+"')

        # If msiexec uninstaller
        if ($msiMatch.Success) {
            $uninstallParams.FilePath     = ($uninstallString -replace $msiMatch.Value, '').Trim()
            $uninstallParams.ArgumentList = 
                if ($uninstallParams.FilePath -match '/qn') { $msiMatch.Value } 
                else { "$($msiMatch.Value) /qn" }
        # If .cmd/.bat/.exe uninstaller
        } elseif ($exeMatch.Success) {
            $uninstallParams.FilePath     = $exeMatch.Value
            $uninstallParams.ArgumentList = ($uninstallString -replace [regex]::Escape($exeMatch.Value), '').Trim()
        }

        Write-Verbose "Uninstalling $($App.DisplayName)"
        Write-Progress $App.DisplayName 'Uninstalling...'
        $process = Start-Process @uninstallParams
        Write-Progress $App.DisplayName 'Uninstalling...' -Completed

        if (!(Test-Path $App.PsPath)) {
            Write-Verbose "- Uninstalled"
            return
        }

        Write-Error (
            "Failed to uninstall.",
            "DisplayName     : $($App.DisplayName)",
            "UninstallString : $($uninstallParams.FilePath) $($uninstallParams.ArgumentList)",
            "ExitCode        : $($process.ExitCode)" -join "`n"
        )
    }
}