function Remove-ThingProperty {
    <#
    .SYNOPSIS
    Removes the value of a property of an item.

    .DESCRIPTION
    The `Remove-ThingProperty` cmdlet changes the value of the property of the specified item. This cmdlet functions similarly to `Remove-ItemProperty` and can be used interchangably with it. This function differs in that it provides additional functionality such as using -Force by default, applying to the default user registry hive if specified, and providing verbose output if specified.

    .PARAMETER Path
    Specifies the path of the property.

    .PARAMETER Name
    Specifies the name of the property.

    .PARAMETER DefaultUser
    A switch indicating to also apply the registry modification to the default user registry hive. Optional.

    .PARAMETER Output
    A switch indicating to provide verbose output. Optional.
    
    .EXAMPLE
    Remove-ThingProperty -Path HKLM:\SOFTWARE\Microsoft\Windows -Name Enabled

    .EXAMPLE
    Remove-ThingProperty -Path HKLM:\SOFTWARE\Microsoft\Windows -Name Enabled -DefaultUser -Output

    .INPUTS
    [string] The path of the property.

    [string] The name of the property.

    .OUTPUTS
    [string] If `Output` is specified, the function returns key, name, type, and/or value.

    Key   : HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System
    Name  : EnableActivityFeed
    
    .NOTES
    Author: Skyler Wallace
    Requires: The custom functions `Mount-RegistryHive` and `Dismount-RegistryHive` if `DefaultUser` is specified.
    #>
    
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$Path,

        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$Name,

        [Switch]$DefaultUser = $false,

        [Switch]$Output = $false
    )
    
    # Make function stop if any errors occur
    $errorActionPreference = 'Stop'

    # Apply to default user hive if -DefaultUser parameter is used
    if ($DefaultUser -and ($Path -match 'HKCU:|HKEY_CURRENT_USER|HKEY_USERS')) {
        $itemParams.Path = $itemParams.Path.Replace($matches[1],'HKDU:')

        if (Test-Path HKDU:) {
            Remove-ItemProperty -Path $Path -Name $Name -Force
        } else {
            Mount-RegistryHive -FilePath C:\Users\Default\NTUSER.dat -Key HKLM\DEFAULT -Name HKDU
            Remove-ItemProperty -Path $Path -Name $Name -Force
            Dismount-RegistryHive -Key HKLM\DEFAULT -Name HKDU
        }
    }

    if ((Get-Item $Path).Property -contains $Name) {
        Remove-ItemProperty -Path $Path -Name $Name -Force
    } else {
        Write-Error "$Path not detected"
    }
    
    # Output info if -Output switch is used
    if ($Output) {
        Write-Host "Property removed"
        Write-Host "- Path : $Path"
        Write-Host "- Name : $Name"
    }
}