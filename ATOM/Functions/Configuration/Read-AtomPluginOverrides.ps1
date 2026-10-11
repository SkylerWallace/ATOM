function Read-AtomPluginOverrides {
    <# .SYNOPSIS
        Reads plugin metadata keyed by permanent plugin IDs.
    .DESCRIPTION
        Name-based entries from before 4.0 are ignored. Names and filenames are
        metadata; the dictionary key identifies the plugin independently of either.
    #>
    param([Parameter(Mandatory)][String]$Path)
    $userPrograms = [ordered]@{}
    if (Test-Path -LiteralPath $Path -PathType Leaf) { . $Path }
    if ($userPrograms -isnot [Collections.IDictionary]) { throw 'PluginsUser.ps1 must define a userPrograms hashtable.' }
    $overrides = [ordered]@{}
    foreach ($entry in $userPrograms.GetEnumerator()) {
        if ($entry.Value -isnot [Collections.IDictionary]) { throw "Invalid metadata for '$($entry.Key)'." }
        if ($entry.Key -notmatch '^[a-f0-9]{32}$') { continue }
        $id = ([String]$entry.Key).ToLowerInvariant()
        if ($entry.Value.Id -and $entry.Value.Id -ne $id) { throw "Plugin ID does not match its metadata key: '$id'." }
        if ($entry.Value.UserOwned -and !$entry.Value.Id) { throw "Registered user plugin '$id' is missing its Id." }
        $overrides[$id] = $entry.Value
    }
    return ,$overrides
}
