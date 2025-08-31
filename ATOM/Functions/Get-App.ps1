function Get-App {
    <#
    .SYNOPSIS
    Retrieves properties of applications installed on the system.

    .DESCRIPTION
    The `Get-App` function scans the registry for uninstall information  of software installed in both 64-bit and 32-bit program areas, as well as user-specific installations. It returns details including the display name, uninstall string, and a quiet uninstall string if available.

    .PARAMETER DisplayName
    Specifies the name or part of the name of the software to search for. This function supports pipeline input for this parameter.

    .PARAMETER Scope
    Specifies whether to search for 64-bit, 32-bit, and/or user applications. Can be `All`, `User`, `x64`, or `x86`. Default is `All`.

    .EXAMPLE
    Get-App
    Retrieves all installed applications.

    .EXAMPLE
    Get-App -Name 'Windows' -Scope x64
    Retrieves all 64-bit applications that match the display name 'Windows'.

    .EXAMPLE
    'Microsoft', 'Windows' | Get-App
    Retrieves all applications that match the display names 'Microsoft' and 'Windows'.

    .INPUTS
    [System.String]
    Accepts an array of strings representing software names to search for.

    .OUTPUTS
    [PsCustomObject]
    Returns a list of custom objects representing installed applications. Each object contains the following properties:
    - DisplayName          : The name of the application as shown in Programs and Features.
    - DisplayVersion       : The version number of the application.
    - Publisher            : The software publisher.
    - EstimatedSize        : The approximate size of the application, in KB.
    - PsPath               : The full registry path of the uninstall entry.
    - UninstallString      : The command used to uninstall the application.
    - QuietUninstallString : The command used to silently uninstall the application, if available.

    .NOTES
    Author: Skyler Wallace
    #>

    [CmdletBinding()]

    param (
        [Alias('Name')][Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position = 0)]
        [String[]]$displayName = '',
        [ValidateSet('All', 'User', 'x64', 'x86')]
        [String[]]$scope = 'All'
    )

    $uninstallPaths = switch ($scope) {
        { $_ -in 'User', 'All' } { 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' }
        { $_ -in  'x64', 'All' } { 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' }
        { $_ -in  'x86', 'All' } { 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' }
    }
    
    $uninstallKeys = Get-ChildItem $uninstallPaths | ForEach-Object {
        Get-ItemProperty $_.PsPath | Where-Object { $_.DisplayName -and ($_.UninstallString -or $_.QuietUninstallString) }
    }

    $apps = foreach ($n in $displayName) {
        $uninstallKeys | Where-Object { $_.DisplayName -match $n } |
        Select-Object DisplayName, DisplayVersion, Publisher, EstimatedSize, PsPath, UninstallString, QuietUninstallString
    }

    $apps | Sort-Object PsPath -Unique
}