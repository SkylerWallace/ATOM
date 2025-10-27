function Get-App {
    <#
    .SYNOPSIS
    Retrieves properties of applications installed on the system.

    .DESCRIPTION
    The `Get-App` function scans the registry for uninstall information of software installed in both 64-bit and 32-bit program areas, as well as user-specific installations. It returns details including the display name, uninstall string, and a quiet uninstall string if available.

    .PARAMETER DisplayName
    Specifies the name or part of the name of the software to search for. This function supports pipeline input for this parameter.

    .PARAMETER Scope
    Specifies whether to search for 64-bit, 32-bit, and/or user applications. The acceptable values for this parameter are:
    - `All`      : Targets 64-bit, 32-bit, and user-installed applications for the current user. Equivalent to using `User`, `x64`, and `x86`. `All` is the default scope when the scope parameter is not specified. 
    - `AllUsers` : Targets user-installed applications for all users.
    - `User`     : Targets user-installed applications for the current user.
    - `x64`      : Targets 64-bit applications.
    - `x86`      : Targets 32-bit applications.

    .EXAMPLE
    Get-App
    Retrieves all installed applications (excluding other user-install applications).

    .EXAMPLE
    Get-App -Scope All, AllUsers
    Retrieves all installed applications (including other user-install applications).

    .EXAMPLE
    Get-App -Name 'Windows' -Scope x64
    Retrieves all 64-bit applications that match the display name 'Windows'.

    .EXAMPLE
    'Microsoft', 'Windows' | Get-App
    Retrieves all applications (excluding other user-install applications) that match the display names 'Microsoft' and 'Windows'.

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
        [string[]]$displayName = '*',
        [ValidateSet('All', 'AllUsers', 'User', 'x64', 'x86')]
        [string[]]$scope = 'All'
    )

    # Use current logged on user if using SYSTEM user
    if ([Security.Principal.WindowsIdentity]::GetCurrent().IsSystem) {
        $username = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Expand UserName
        if ($username) {
            $user = New-Object Security.Principal.NTAccount($username.Split('\')[1])
            $sid = $user.Translate([Security.Principal.SecurityIdentifier]).Value
            Remove-PsDrive -Name HKCU -ErrorAction SilentlyContinue
            New-PsDrive -Name HKCU -PsProvider Registry -Root Registry::HKEY_USERS\$sid | Out-Null
        }
    }

    $uninstallPaths = switch ($scope) {
        { $_ -in 'User', 'All' } { 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' }
        { $_ -in  'x64', 'All' } { 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall' }
        { $_ -in  'x86', 'All' } { 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall' }
        AllUsers {
            Get-ChildItem Registry::HKEY_USERS | Where-Object { !$_.PsChildName.EndsWith('Classes') } | ForEach-Object {
                Join-Path $_.PsPath 'Software\Microsoft\Windows\CurrentVersion\Uninstall'
            }
        }
    }
    
    $uninstallKeys = Get-ChildItem $uninstallPaths -ErrorAction SilentlyContinue | ForEach-Object {
        Get-ItemProperty $_.PsPath | Where-Object { $_.DisplayName -and ($_.UninstallString -or $_.QuietUninstallString) }
    }

    $apps = foreach ($n in $displayName) {
        $uninstallKeys | Where-Object { $_.DisplayName -like $n } |
        Select-Object DisplayName, DisplayVersion, Publisher, EstimatedSize, PsPath, UninstallString, QuietUninstallString
    }

    $apps | Sort-Object PsPath -Unique
}