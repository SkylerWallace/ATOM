<#
.SYNOPSIS
    Configures an automated Webroot scan.
.DESCRIPTION
    Supports scan-only and automatic removal modes. In Windows PE, MountOS must
    select the offline Windows installation. Execution remains disabled because
    Webroot installs components on the computer.
.PARAMETER ScanType
    Quick or Full in Windows. In PE, Quick targets the mounted Windows folder
    and Full targets its volume.
.PARAMETER RemoveThreats
    Enables automatic cleanup. When omitted, requests a scan without removals.
.PARAMETER LogPath
    Destination for the scan report. Defaults to Webroot_Results.txt in the
    Webroot program directory.
.EXAMPLE
    & '.\Webroot.ps1' -ScanType Quick
.EXAMPLE
    & '.\Webroot.ps1' -ScanType Full -RemoveThreats
#>
[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Full')][string]$ScanType = 'Quick',
    [switch]$RemoveThreats,
    [string]$LogPath
)

throw 'Webroot is temporarily disabled because its automated scan installs components on the computer.'

. "$PSScriptRoot/../Functions/Import-Atom.ps1" -Function 'Start-Program' -Feature Catalog
$program = $programs.Webroot.ProgramInfo.Clone()

$inPE = (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT') -or (Test-Path (Join-Path $env:SystemRoot 'System32\wpeutil.exe'))
$scanTarget = $ScanType.ToLowerInvariant()

if ($inPE) {
    $mountedDrive = (Get-ItemProperty 'HKLM:\SOFTWARE\ATOM' -Name MountedDrive -ErrorAction Stop).MountedDrive
    $offlineWindows = (Get-ItemProperty 'HKLM:\RemoteOS-HKLM-SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name SystemRoot -ErrorAction Stop).SystemRoot

    if ($mountedDrive -notmatch '^[A-Za-z]:$' -or $offlineWindows -notmatch '^[A-Za-z]:\\[^"\r\n]+$') {
        throw 'Use MountOS to select a Windows installation before running Webroot in PE.'
    }

    $scanTarget = [IO.Path]::GetFullPath($mountedDrive + $offlineWindows.Substring(2)).TrimEnd('\')

    if (!$scanTarget.StartsWith($mountedDrive + '\', [StringComparison]::OrdinalIgnoreCase) -or
        $mountedDrive -eq [IO.Path]::GetPathRoot($env:SystemRoot).TrimEnd('\') -or
        !(Test-Path -LiteralPath "$scanTarget\System32\config\SYSTEM" -PathType Leaf)) {
        throw 'The Windows installation selected in MountOS is unavailable. Run MountOS again before scanning.'
    }

    if ($ScanType -eq 'Full') {
        $scanTarget = $mountedDrive + '\'
    }
}

if (!$LogPath) {
    $LogPath = Join-Path $program.DestinationPath 'Webroot_Results.txt'
}

if ($LogPath -match '["\r\n]') {
    throw 'The report path cannot contain quotation marks or line breaks.'
}

$LogPath = [IO.Path]::GetFullPath($LogPath)
[void][IO.Directory]::CreateDirectory((Split-Path -Parent $LogPath))

$arguments = @('-automate', '-autoexit', '-neverreboot')
if ($RemoveThreats) {
    $arguments += '-autoclean'
}

# Escape a trailing backslash before the closing command-line quote.
$quotedTarget = $scanTarget -replace '(\\+)$', '$1$1'
$arguments += "-scandepth=`"$quotedTarget`"", "-savelog=`"$LogPath`""
$program.ArgumentList = $arguments -join ' '

Start-Program @program
