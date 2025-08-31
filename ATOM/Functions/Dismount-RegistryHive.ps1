function Dismount-RegistryHive {
    <#
    .SYNOPSIS
    Unmounts a previously mounted registry hive and optionally removes the associated PSDrive.

    .DESCRIPTION
    The `Dismount-RegistryHive` cmdlet unloads a registry hive from the specified key path in the Windows registry. If a PSDrive was created for this hive, it can be removed using the -Name parameter. This function uses `reg.exe` for hive unloading and PowerShell cmdlets for drive management.

    .PARAMETER Key
    Specifies the registry key path where the hive is currently mounted. Must start with either 'HKLM\' or 'HKCU\'. This parameter is mandatory and is validated to ensure proper format.

    .PARAMETER Name
    Specifies the name of the PsDrive associated with the mounted hive to be removed. This should match the name used when the hive was mounted. If not provided, no PSDrive will be removed.

    .EXAMPLE
    Dismount-RegistryHive -Key HKLM\DEFAULT -Name HKDU
    Dismounts registry hive HKLM:\DEFAULT and removes PsDrive HKDU.

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    None. The function outputs error messages to the console.
    
    .NOTES
    Author: Skyler Wallace
    #>

    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^(HKLM\\|HKCU\\)[a-zA-Z0-9- _\\]+$')]
        [String]$key,
        [ValidatePattern('^[^;~/\\\.\:]+$')]
        [String]$name
    )

    # Make function stop if any errors occur
    $errorActionPreference = 'Stop'

    # Perform garbage collection, avoids 'error access denied' error when unloading
    [gc]::Collect()

    # Remove PsDrive if -Name specified
    if ($name -and (Test-Path $name)) {
        try {
            Remove-PsDrive -Name $name -Force
        } catch {
            Write-Error "Failed to dismount PsDrive $name"
        }
    }

    # Unload reg hive with reg.exe
    $process = Start-Process reg -ArgumentList "unload $key" -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Error "Failed to unload $filePath from $key"
    }
}