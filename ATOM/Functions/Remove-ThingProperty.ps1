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
        [String]$path,
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]$name,
        [Switch]$defaultUser = $false,
        [Switch]$output = $false
    )
    
    # Make function stop if any errors occur
    $errorActionPreference = 'Stop'

    # Apply to default user hive if -DefaultUser parameter is used
    if ($defaultUser -and ($path -match 'HKCU:|HKEY_CURRENT_USER|HKEY_USERS')) {
        $itemParams.Path = $itemParams.Path.Replace($matches[1],'HKDU:')

        if (Test-Path HKDU:) {
            Remove-ItemProperty -Path $path -Name $name -Force
        } else {
            Mount-RegistryHive -FilePath C:\Users\Default\NTUSER.dat -Key HKLM\DEFAULT -Name HKDU
            Remove-ItemProperty -Path $path -Name $name -Force
            Dismount-RegistryHive -Key HKLM\DEFAULT -Name HKDU
        }
    }

    if ((Get-Item $path).Property -contains $name) {
        Remove-ItemProperty -Path $path -Name $name -Force
    } else {
        Write-Error "$path not detected"
    }
    
    # Output info if -Output switch is used
    if ($output) {
        Write-Host "Property removed"
        Write-Host "- Path : $path"
        Write-Host "- Name : $name"
    }
}