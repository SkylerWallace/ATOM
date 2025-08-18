function Get-UninstallString {
    <#
    .SYNOPSIS
    Retrieves uninstall strings for software installed on the system.

    .DESCRIPTION
    The `Get-UninstallString` function scans the registry for uninstall information 
    of software installed in both 64-bit and 32-bit program areas, as well as user-specific 
    installations. It returns details including the display name, uninstall string, 
    and a quiet uninstall string if available.

    .PARAMETER Name
    Specifies the name or part of the name of the software to search for. 
    This function supports pipeline input for this parameter.

    .EXAMPLE
    Get-UninstallString -name "Microsoft Office"
    Searches for any software with "Microsoft Office" in its name and returns uninstall information.

    .EXAMPLE
    "Adobe Reader","Google Chrome" | Get-UninstallString
    Uses pipeline input to search for uninstall strings of Adobe Reader and Google Chrome.

    .INPUTS
    [string[]] Accepts an array of strings representing software names to search for.

    .OUTPUTS
    [PsCustomObject] Returns custom objects with properties for DisplayName, UninstallString, 
    QuietUninstallString, and PsPath for matching software entries.

    .NOTES
    Author: Skyler Wallace
    #>

    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]$name
    )

    # Get all uninstall keys
    $uninstallKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",             # 64-bit programs
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", # 32-bit programs
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"              # User programs
    ) | Get-ChildItem | ForEach-Object {
        Get-ItemProperty $_.PsPath | Where-Object { $_.DisplayName -and $_.UninstallString } | ForEach-Object {
            [PsCustomObject]@{
                DisplayName = $_.DisplayName
                UninstallString = if ($_.UninstallString) { $_.UninstallString -replace '(?<!")([a-zA-Z]:\\[^"]+\.(exe|msi))(?!")', '"$1"' } else { $null }
                QuietUninstallString = if ($_.QuietUninstallString) { $_.QuietUninstallString -replace '(?<!")([a-zA-Z]:\\[^"]+\.(exe|msi))(?!")', '"$1"' } else { $null }
                PsPath = $_.PsPath
            }
        }
    }

    # Display uninstall keys
    $name | ForEach-Object {
        $programName = $_
        $uninstallKeys | Where-Object { $_.DisplayName -match $programName }
    } | Sort-Object -Property DisplayName
}