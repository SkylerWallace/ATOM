function Get-Startup {
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

    # Use current logged on user if using SYSTEM user
    if ([Security.Principal.WindowsIdentity]::GetCurrent().IsSystem) {
        $username = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -Expand UserName
        if ($username) {
            $user = New-Object Security.Principal.NTAccount($username.Split('\')[1])
            $sid = $user.Translate([Security.Principal.SecurityIdentifier]).Value

            # Redirect HKCU PsDrive
            Remove-PsDrive -Name HKCU -ErrorAction SilentlyContinue
            New-PsDrive -Name HKCU -PsProvider Registry -Root Registry::HKEY_USERS\$sid | Out-Null

            # Redirect $env:AppData variable
            $env:AppData = (Get-ItemProperty "Registry::HKEY_USERS\$sid\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")
        }
    }

    $startupPaths = @(
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:AppData\Microsoft\Windows\Start Menu\Programs\Startup"
    )

    $startupPaths | ForEach-Object {
        $path = $_
        if (!(Test-Path $path)) { return }

        $item = Get-Item -Path $path

        if ($item -is [System.IO.DirectoryInfo]) {
            Get-ChildItem -Path $path -File | ForEach-Object {
                [PSCustomObject]@{
                    Name = $_.Name
                    PSPath = $_.PSPath
                    State = "Enabled" # Files in Startup folders are always enabled
                    Path = $path
                    Type = "File"
                    Value = $null
                }
            }
        } elseif ($item -is [Microsoft.Win32.RegistryKey]) {
            $regKey = Get-ItemProperty -Path $path

            $regKey.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' -and $_.Name -ne '(default)' } | ForEach-Object {
                $propName = $_.Name
                $propValue = $_.Value
                $psPath = "$($item.PSPath)\$propName"

                $state = if ($path -like "*StartupApproved*") {
                    $value = $propValue
                    if ($null -eq $value -or ($value -is [array] -and $value.Count -lt 4)) {
                        "Unknown"
                    } else {
                        $flagBytes = $value[0..3]
                        $enabledFlags = @(@(2,0,0,0), @(6,0,0,0))
                        $disabledFlags = @(@(3,0,0,0), @(7,0,0,0))
                        if ($enabledFlags | Where-Object { !(Compare-Object $_ $flagBytes) }) { "Enabled" }
                        elseif ($disabledFlags | Where-Object { !(Compare-Object $_ $flagBytes) }) { "Disabled" }
                        else { "Unknown" }
                    }
                }
                else {
                    "Enabled"
                }

                [PSCustomObject]@{
                    Name = $propName
                    PSPath = $psPath
                    State = $state
                    Path = $path
                    Type = "Registry"
                    Value = $propValue
                }
            }
        }
    }
}