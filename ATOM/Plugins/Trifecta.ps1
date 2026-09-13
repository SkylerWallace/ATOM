[CmdletBinding()]
param([ValidateSet('Interactive','VerifySystemFiles')][string]$Action='Interactive', [switch]$NonInteractive)

if ($Action -eq 'VerifySystemFiles') {
    $ErrorActionPreference='Stop'
    if (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') { throw 'Verification currently supports running Windows only.' }
    $principal=[Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent())
    if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'SFC verification requires administrator privileges.' }
    $executable=Join-Path $env:SystemRoot 'System32/sfc.exe'
    if ([Environment]::Is64BitOperatingSystem -and ![Environment]::Is64BitProcess) { $executable=Join-Path $env:SystemRoot 'Sysnative/sfc.exe' }
    $output = & $executable /verifyonly 2>&1 | Out-String
    $code=$LASTEXITCODE
    [pscustomobject]@{ExitCode=$code;Status=$(if($code -eq 0){'NeedsAttention'}else{'Failed'});Summary='SFC finished. Review its output for findings; completion does not establish system health.';Output=$output}
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