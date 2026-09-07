function Set-AtomPluginOverride {
    <#
    .SYNOPSIS
        Persists one user-defined plugin property override.

    .DESCRIPTION
        Updates the canonical userPrograms hashtable and removes properties that
        match their built-in defaults. Entries are sorted before being written.
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

    $userPrograms = [ordered]@{}
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        . $Path
        if ($userPrograms -isnot [System.Collections.IDictionary]) {
            throw 'PluginsUser.ps1 must define $userPrograms as a hashtable.'
        }
    }

    if (!$userPrograms.Contains($Name)) { $userPrograms[$Name] = [ordered]@{} }
    if ($userPrograms[$Name] -isnot [System.Collections.IDictionary]) {
        throw "The userPrograms entry for '$Name' must be a hashtable."
    }

    $defaultConfig = $Defaults[$Name]
    $matchesDefault =
        if (!$defaultConfig) { $false }
        elseif ($Property -eq 'Category') { [String]$Value -eq [String]$defaultConfig.Category }
        else { [Boolean]$Value -eq [Boolean]$defaultConfig[$Property] }

    if ($matchesDefault) {
        [void]$userPrograms[$Name].Remove($Property)
        if ($userPrograms[$Name].Count -eq 0) { [void]$userPrograms.Remove($Name) }
    } else {
        $userPrograms[$Name][$Property] = $Value
    }

    $sortedPrograms = [ordered]@{}
    $userPrograms.GetEnumerator() | Sort-Object Key | ForEach-Object {
        $sortedPrograms[$_.Key] = $_.Value
    }


    $literal = ConvertTo-AtomPowerShellLiteral -Value $sortedPrograms
    $content = ([Char]36) + "userPrograms = $literal$([Environment]::NewLine)"
    Write-AtomFileAtomic -Path $Path -Content $content
}
