function Set-ThingProperty {
    <#
    .SYNOPSIS
    Creates or changes the value of a property of an item.

    .DESCRIPTION
    The `Set-ThingProperty` cmdlet changes the value of the property of the specified item. This cmdlet functions
    similarly to `New-ItemProperty` and `Set-ItemProperty` and can be used interchangably with them. This function differs
    in that it provides additional functionality such as using -Force by default, creating parent keys if not detected,
    applying to the default user registry hive if specified, and providing verbose output if specified.

    .PARAMETER InputObject
    Specifies the object that has the properties that this cmdlet changes. Enter a variable that contains the object
    or a command that gets the object. Mandatory unless Path specified.

    .PARAMETER Path
    Specifies the path of the property. Mandatory unless InputObject specified.

    .PARAMETER Name
    Specifies the name of the property. Optional.

    .PARAMETER Value
    Specifies the value of the property. Optional.

    .PARAMETER Type
    Specifies the type of the property. Optional.

    .PARAMETER DefaultUser
    A switch indicating to also apply the registry modification to the default user registry hive. Optional.

    .PARAMETER Output
    A switch indicating to provide verbose output. Optional.
    
    .EXAMPLE
    Set-ThingProperty -Path HKLM:\SOFTWARE\Microsoft\Windows -Name Enabled -Type DWord -Value 0

    .EXAMPLE
    Set-ThingProperty -Path HKCU:\Control Panel\International\User Profile -Name HttpAcceptLanguageOptOut -Type DWord -Value 1 -DefaultUser

    .EXAMPLE
    Set-ThingProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\System -Name EnableActivityFeed -Type DWord -Value 0 -Output

    .INPUTS
    [object] The object that contains the properties.

    [string] The path of the property.

    [string] The name of the property.

    [string] The type of the property.

    [string] The value of the property.

    .OUTPUTS
    [string] If `Output` is specified, the function returns key, name, type, and/or value.

    Key   : HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows
    Name  : Enabled
    Type  : DWord
    Value : 0
    
    .NOTES
    Author: Skyler Wallace
    Requires: The custom functions `Mount-RegistryHive` and `Dismount-RegistryHive` if `DefaultUser` is specified.
    #>

    [alias('New-ThingProperty')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'InputObject')]
        [Parameter(ValueFromPipeline)]
        [object]$inputObject,
        [Parameter(Mandatory, ParameterSetName = 'Path', Position = 0)]
        [Parameter(ValueFromPipeline)]
        [string]$path,
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ValueFromPipeline)]
        [string]$name,
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ValueFromPipeline)]
        [string]$value,
        [Parameter(ParameterSetName = 'Path')]
        [Parameter(ValueFromPipeline)]
        [string]$type = 'String',
        [switch]$defaultUser = $false,
        [switch]$output = $false
    )
    
    # Make function stop if any errors occur
    $errorActionPreference = 'Stop'
    
    # Set parameters for item
    $itemParams = $psBoundParameters
    $itemParams.Force = $true
    $($itemParams.Keys) | ForEach-Object {
        if ($_ -notin 'InputObject', 'Path', 'Name', 'Type', 'Value', 'Force') {
            $itemParams.Remove($_) | Out-Null
        }
    }
    
    # Apply to default user hive if -DefaultUser parameter is used
    if ($defaultUser -and ($path -match 'HKCU:|HKEY_CURRENT_USER|HKEY_USERS')) {
        $itemParams.Path = $itemParams.Path.Replace($matches[1],'HKDU:')

        if (Test-Path HKDU:) {
            Set-ThingProperty @itemParams
        } else {
            Mount-RegistryHive -FilePath C:\Users\Default\NTUSER.dat -Key HKLM\DEFAULT -Name HKDU
            Set-ThingProperty @itemParams
            Dismount-RegistryHive -Key HKLM\DEFAULT -Name HKDU
        }
    }
    
    # Create parent key if not detected
    if (!(Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
    
    # Create/set reg value
    if ((Get-Item $path).Property -contains $name) {
        Set-ItemProperty @itemParams | Out-Null
    } else {
        New-ItemProperty @itemParams | Out-Null
    }
    
    # Output info if -Output switch is used
    if ($output) {
        Write-Host "Property set"
        switch ($true) {
            {$null -ne $path} { Write-Host "- Path  : $path" }
            {$null -ne $name} { Write-Host "- Name  : $name" }
            {$null -ne $type} { Write-Host "- Type  : $type" }
            {$null -ne $value} { Write-Host "- Value : $value" }
            {$null -ne $inputObject} { $inputObject.Keys | ForEach-Object {
                Write-Host "  $_  : $($inputObject.$_)"
            }}
        }
    }
}