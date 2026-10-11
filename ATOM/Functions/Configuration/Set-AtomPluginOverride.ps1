function Set-AtomPluginOverride {
    <#
    .SYNOPSIS
        Persists one user-defined plugin property override.

    .DESCRIPTION
        Updates preferences under the catalog's permanent plugin ID and removes
        properties that match built-in defaults. Unmanaged files receive an ID
        when preferences are first saved. Entries are sorted before being written.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Defaults,

        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Category', 'Hidden', 'Favorite')]
        [String]$Property,

        [Parameter(Mandatory)]
        [Object]$Value
    )

    if ([String]::IsNullOrWhiteSpace($Name)) { throw 'Plugin name is required.' }

    $defaultConfig = $Defaults[$Name]
    $userPrograms = Read-AtomPluginOverrides -Path $Path
    $key = [String]$defaultConfig.Id
    if (!$defaultConfig) {
        # Unmanaged launcher files receive an identity when preferences are first saved.
        $entries = @($userPrograms.GetEnumerator() | Where-Object { $_.Value.Name -eq $Name })
        if ($entries.Count -gt 1) { throw "Multiple plugin IDs are registered for '$Name'." }
        $key = if ($entries.Count) { $entries[0].Key } else { [Guid]::NewGuid().ToString('N') }
    }
    if ($key -notmatch '^[a-f0-9]{32}$') { throw "No plugin ID is registered for '$Name'." }
    if (!$userPrograms.Contains($key)) { $userPrograms[$key] = [ordered]@{} }
    if (!$defaultConfig) { $userPrograms[$key].Name = $Name; $userPrograms[$key].Id = $key }
    $matchesDefault =
        if (!$defaultConfig) { $false }
        elseif ($Property -eq 'Category') { [String]$Value -eq [String]$defaultConfig.Category }
        else { [Boolean]$Value -eq [Boolean]$defaultConfig[$Property] }

    if ($matchesDefault) {
        [void]$userPrograms[$key].Remove($Property)
        if (!$userPrograms[$key].Count) { [void]$userPrograms.Remove($key) }
    } else {
        $userPrograms[$key][$Property] = $Value
    }

    $sortedPrograms = [ordered]@{}
    $userPrograms.GetEnumerator() | Sort-Object Key | ForEach-Object {
        $sortedPrograms[$_.Key] = $_.Value
    }


    Write-AtomPluginOverrides -Path $Path -Overrides $sortedPrograms
}
