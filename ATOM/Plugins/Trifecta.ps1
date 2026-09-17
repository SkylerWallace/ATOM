<#
.SYNOPSIS
Starts Store and Windows updates and scans Windows system files.
.PARAMETER Action
Selects a single component. Interactive retains the original three-component launch.
VerifySystemFiles checks without repair; ScanSystemFiles runs SFC with repairs enabled.
.PARAMETER NonInteractive
Requires a specific action and returns a structured workflow result. Update actions
still open their Windows interfaces and may require user input.
.EXAMPLE
& '.\Trifecta.ps1' -Action StoreUpdates -NonInteractive
.EXAMPLE
& '.\Trifecta.ps1' -Action WindowsUpdates -NonInteractive
.EXAMPLE
& '.\Trifecta.ps1' -Action ScanSystemFiles -NonInteractive
#>
[CmdletBinding()]
param(
    [ValidateSet('Interactive', 'VerifySystemFiles', 'ScanSystemFiles', 'StoreUpdates', 'WindowsUpdates')]
    [string]$Action = 'Interactive',
    [switch]$NonInteractive
)

function Invoke-TrifectaAction {
    param([string]$SelectedAction)

    $ErrorActionPreference = 'Stop'
    $started = [datetime]::UtcNow.ToString('o')
    $result = [ordered]@{
        Status = 'Failed'
        ExitCode = $null
        Summary = ''
        Output = [ordered]@{
            Action = $SelectedAction
            StartedUtc = $started
            FinishedUtc = $null
            InterfaceLaunchRequested = $false
            UpdateRequestSubmitted = $false
            Details = $null
        }
    }
    try {
        $systemDirectory = if ([Environment]::Is64BitOperatingSystem -and ![Environment]::Is64BitProcess) { 'Sysnative' } else { 'System32' }
        switch ($SelectedAction) {
            { $_ -in 'VerifySystemFiles', 'ScanSystemFiles' } {
                $executable = Join-Path $env:SystemRoot "$systemDirectory/sfc.exe"
                $argument = if ($SelectedAction -eq 'ScanSystemFiles') { '/scannow' } else { '/verifyonly' }
                $result.Output.Details = (& $executable $argument 2>&1 | Out-String)
                $result.ExitCode = $LASTEXITCODE
                $result.Status = if ($LASTEXITCODE -eq 0) { 'NeedsAttention' } else { 'Failed' }
                $result.Summary = 'SFC finished. Review its output for findings and repair results; completion does not establish system health.'
            }
            WindowsUpdates {
                Start-Process -FilePath 'ms-settings:windowsupdate' -ErrorAction Stop
                $result.Output.InterfaceLaunchRequested = $true
                $executable = Join-Path $env:SystemRoot "$systemDirectory/UsoClient.exe"
                $process = Start-Process -FilePath $executable -ArgumentList 'StartInteractiveScan' -WindowStyle Hidden -Wait -PassThru -ErrorAction Stop
                try {
                    $result.ExitCode = $process.ExitCode
                    if ($process.ExitCode -ne 0) { throw "Windows Update scan command exited with code $($process.ExitCode)." }
                }
                finally { $process.Dispose() }
                $result.Output.UpdateRequestSubmitted = $true
                $result.Status = 'Succeeded'
                $result.Summary = 'Windows Update page launch and scan request submitted. Update progress and installation are not verified.'
            }
            StoreUpdates {
                Start-Process -FilePath 'ms-windows-store://downloadsandupdates' -ErrorAction Stop
                $result.Output.InterfaceLaunchRequested = $true
                $providers = @(Get-CimInstance -Namespace 'Root/cimv2/mdm/dmmap' -ClassName 'MDM_EnterpriseModernAppManagement_AppManagement01' -OperationTimeoutSec 30 -ErrorAction Stop)
                if (!$providers.Count) { throw 'The Store update provider is unavailable.' }
                $responses = @($providers | Invoke-CimMethod -MethodName UpdateScanMethod -OperationTimeoutSec 30 -ErrorAction Stop)
                $result.Output.Details = @($responses | Select-Object ReturnValue)
                if (!$responses.Count -or @($responses | Where-Object { $null -eq $_.ReturnValue -or $_.ReturnValue -ne 0 }).Count) { throw 'The Store update provider did not accept the scan request.' }
                $result.ExitCode = 0
                $result.Output.UpdateRequestSubmitted = $true
                $result.Status = 'Succeeded'
                $result.Summary = 'Microsoft Store page launch and update scan request submitted. Downloads and installation are not verified.'
            }
            default { throw "Unsupported Trifecta action: $SelectedAction" }
        }
    }
    catch { $result.Status = 'Failed'; $result.Summary = $_.Exception.Message }
    finally { $result.Output.FinishedUtc = [datetime]::UtcNow.ToString('o') }
    [pscustomobject]$result
}

if ($Action -ne 'Interactive') {
    if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') { throw 'Trifecta actions support running Windows only.' }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    try {
        $principal = [Security.Principal.WindowsPrincipal]::new($identity)
        if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Trifecta workflow actions require administrator privileges.' }
    }
    finally { $identity.Dispose() }
    Invoke-TrifectaAction -SelectedAction $Action
    return
}
if ($NonInteractive) { throw 'Specify a supported noninteractive action.' }

# SFC scan
Start-Process cmd "/c sfc /scannow & pause"

# Windows Update
Start-Process ms-settings:windowsupdate
usoclient startinteractivescan

# MS Store Updates
Start-Process ms-windows-store://downloadsandupdates
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod
