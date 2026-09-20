<#
.SYNOPSIS
    Opens the scanner or runs an automated quick or deep scan.
.PARAMETER ScanType
    Interactive opens the normal interface. Deep scans the Windows drive.
    In PE, Quick scans the mounted Windows folder and Deep scans its volume.
.PARAMETER LogDirectory
    Destination for scanner reports. Required for automated scans.
.PARAMETER ScanState
    Shared workflow cancellation state. StopRequested stops the scanner ATOM launched.
.EXAMPLE
    & '.\Emsisoft Emergency Kit.ps1' -ScanType Quick -LogDirectory 'C:\ProgramData\ATOM\Logs\ManualScan'
#>
[CmdletBinding()]
param(
    [ValidateSet('Interactive', 'Quick', 'Deep')][string]$ScanType = 'Interactive',
    [string]$LogDirectory,
    [hashtable]$ScanState
)

. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function Start-Program, Invoke-AtomAntivirusScan -Feature Catalog
$program = $programs.'Emsisoft Emergency Kit'.ProgramInfo
if ($ScanType -eq 'Interactive') {
    Start-Program @program
    return
}
if (!$LogDirectory) { throw 'Specify LogDirectory for an automated scan.' }
$executable = Join-Path $program.DestinationPath 'bin64\a2cmd.exe'
Invoke-AtomAntivirusScan -Scanner Emsisoft -ScanType $ScanType -Executable $executable -LogDirectory $LogDirectory -ScanState $ScanState
