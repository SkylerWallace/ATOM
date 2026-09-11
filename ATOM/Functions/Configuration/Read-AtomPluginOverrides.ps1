function Read-AtomPluginOverrides {
    param([Parameter(Mandatory)][String]$Path)
    $userPrograms = [ordered]@{}
    if (Test-Path -LiteralPath $Path -PathType Leaf) { . $Path }
    if ($userPrograms -isnot [Collections.IDictionary]) { throw 'PluginsUser.ps1 must define a userPrograms hashtable.' }
    foreach ($entry in $userPrograms.GetEnumerator()) {
        if ($entry.Value -isnot [Collections.IDictionary]) { throw "Invalid metadata for '$($entry.Key)'." }
    }
    return ,$userPrograms
}
