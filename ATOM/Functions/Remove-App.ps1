function Remove-App {
    <#
    .SYNOPSIS
    Uninstalls an application from the system.

    .DESCRIPTION
    The `Remove-App` function uninstalls an application using its uninstall or quiet uninstall string. Supports MSI and EXE-based uninstallers, handling path quoting and argument parsing automatically.

    .PARAMETER App
    Specifies an object from Get-App.

    .PARAMETER Confirm
    Specifies to prompt user to uninstall a program using UI uninstaller if `Force` and `Silent` parameters are `$true`.

    .PARAMETER Force
    Specifies to uninstall an application using UI uninstaller if silent uninstall is not available. Default is `$true`.

    .PARAMETER Silent
    Specifies to uninstall an application silently if available. Default is `$true`.

    .EXAMPLE
    Get-App 'Microsoft Edge' | Remove-App
    Uninstalls Microsoft Edge.

    .EXAMPLE
    Get-App 'Microsoft Edge' | Remove-App -Confirm
    If silent uninstall is not available, user will be prompted to perform UI uninstall.

    .EXAMPLE
    Get-App 'Microsoft Edge' | Remove-App -Force:$false
    If silent uninstall is not available, uninstall is skipped.

    .EXAMPLE
    Get-App 'Microsoft Edge' | Remove-App -Silent:$false
    Prefers UI uninstall over silent uninstall.

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
        [PsCustomObject]$app,
        [Switch]$confirm,
        [Bool]$force = $true,
        [Bool]$silent = $true
    )

    process {
        if (!$app.DisplayName -and !$app.PsPath -and (!$app.UninstallString -or !$app.QuietUninstallString)) {
            Write-Error "Invalid object passed to -App parameter. Please verify you are using `Get-App`."
            return
        }

        $uninstallString = @(
            if ($app.QuietUninstallString -and $silent) { $app.QuietUninstallString }
            elseif ($app.UninstallString -or ($app.UninstallString -and $force)) { $app.UninstallString }
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
                if ($silent -and ($uninstallParams.FilePath -match '/qn')) { $msiMatch.Value }
                elseif (!$silent -and ($uninstallParams.FilePath -match '/qn')) { $msiMatch.Value.Replace('/qn','') }
                elseif (!$silent) { $msiMatch.Value }
                else { "$($msiMatch.Value) /qn" }
        # If .cmd/.bat/.exe uninstaller
        } elseif ($exeMatch.Success) {
            $uninstallParams.FilePath     = $exeMatch.Value
            $uninstallParams.ArgumentList = ($uninstallString -replace [regex]::Escape($exeMatch.Value), '').Trim()
        }

        # Prompt user to uninstall non-silently
        if ($silent -and $confirm -and $exeMatch.Success -and !$app.QuietUninstallString) {
            Write-Host "Confirm"
            Write-Host "Performing the operation `"Remove App`" on target `"$($app.DisplayName)`"."
            Write-Host "Silent uninstall is unavailable, would you like to uninstall non-silently?"
            
            do {
                Write-Host "[Y] Yes  " -NoNewLine -ForegroundColor Yellow; Write-Host "[A] Yes to All  [N] No  [L] No to All (default is `"Y`"):" -NoNewLine
                $answer = Read-Host
            } until ($answer -in @('', 'Y', 'A', 'N', 'L'))

            switch ($answer) {
                A { $confirm = $false }
                N { return }
                L { $confirm = $false; return }
            }
        }

        # Uninstall app
        Write-Verbose "Uninstalling $($app.DisplayName)"
        Write-Progress -Activity "Uninstalling $($app.DisplayName)" -Status "Processing"
        $process = Start-Process @uninstallParams
        Write-Progress -Activity "Uninstalling $($app.DisplayName)" -Status "Completed" -Completed

        # Verify app uninstalled
        if (!(Test-Path $app.PsPath)) {
            Write-Verbose "- Uninstalled"
            return
        }

        Write-Error (
            "Failed to uninstall.",
            "DisplayName     : $($app.DisplayName)",
            "UninstallString : $($uninstallParams.FilePath) $($uninstallParams.ArgumentList)",
            "ExitCode        : $($process.ExitCode)" -join "`n"
        )
    }
}