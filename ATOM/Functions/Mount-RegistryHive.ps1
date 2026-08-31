function Mount-RegistryHive {
    <#
    .SYNOPSIS
    Mounts a registry hive to a specified key and optionally creates a PSDrive for it.

    .DESCRIPTION
    The `Mount-RegistryHive` cmdlet loads a registry hive file into the Windows registry at the specified key path. It can also create a PsDrive for easier access if a name is provided. This function uses `reg.exe` for loading the hive and PowerShell cmdlets for managing PsDrives.

    .PARAMETER FilePath
    Specifies the path to the registry hive file to be mounted.

    .PARAMETER Key
    Specifies the registry key where the hive will be mounted. Must start with either 'HKLM\' or 'HKCU\'.

    .PARAMETER Name
    Specifies an optional name for creating a PsDrive to the mounted hive. Optional.

    .EXAMPLE
    Mount-RegistryHive -FilePath C:\Users\Default\NTUSER.dat -Key HKLM\DEFAULT -Name HKDU
    Mounts the Default User registry hive to HKLM:\DEFAULT and maps to PsDrive HKDU.

    .INPUTS
    None. This function does not accept any pipeline input.

    .OUTPUTS
    None. The function outputs error messages to the console.
    
    .NOTES
    Author: Skyler Wallace
    #>

    param (
        [Parameter(Mandatory)]
        [String]$FilePath,

        [Parameter(Mandatory)]
        [ValidatePattern('^(HKLM\\|HKCU\\)[a-zA-Z0-9- _\\]+$')]
        [String]$Key,

        [ValidatePattern('^[^;~/\\\.\:]+$')]
        [String]$Name = $null
    )

    # Make function stop if any errors occur
    $errorActionPreference = 'Stop'

    # Verify presence of filePath
    if (!(Test-Path $FilePath)) {
        Write-Error "$FilePath not detected"
    }

    # Verify PsDrive isn't already in-use if -Name specified
    if ($Name -and (Test-Path $Name)) {
        Write-Error "$Name already mounted"
    }

    # Load hive with reg.exe
    $process = Start-Process reg -ArgumentList "load $Key $FilePath" -WindowStyle Hidden -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Error "Failed to load $FilePath to $Key"
    }

    # Create PsDrive if -Name specified
    if ($Name) {
        try {
            New-PsDrive -Name $Name -PsProvider Registry -Root $Key -Scope Script | Out-Null
        } catch {
            Start-Process reg -ArgumentList "unload $FilePath" -WindowStyle Hidden
            Write-Error "Failed to mount PsDrive $Name"
        }
    }
}