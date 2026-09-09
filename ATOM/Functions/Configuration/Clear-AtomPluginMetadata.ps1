function Clear-AtomPluginMetadata {
    <#
    .SYNOPSIS
        Clears catalog metadata overrides while retaining program download configuration.
    #>
    [CmdletBinding()]
    param ([Parameter(Mandatory)][String]$Path)

    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return }
    $userPrograms = [ordered]@{}
    . $Path
    if ($userPrograms -isnot [Collections.IDictionary]) { throw 'PluginsUser.ps1 must define a userPrograms hashtable.' }
    $retained = [ordered]@{}
    foreach ($entry in $userPrograms.GetEnumerator() | Sort-Object Key) {
        if ($entry.Value -isnot [Collections.IDictionary]) { throw "Invalid plugin override for '$($entry.Key)'." }
        if ($entry.Value.UserOwned -eq $true) {
            $retained[$entry.Key] = $entry.Value
        } elseif ($entry.Value.Contains('ProgramInfo')) {
            $retained[$entry.Key] = [ordered]@{ ProgramInfo = $entry.Value['ProgramInfo'] }
        }
    }
    Write-AtomPluginOverrides -Path $Path -Overrides $retained
}
