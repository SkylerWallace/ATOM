function Clear-AtomPluginMetadata {
    <#
    .SYNOPSIS
        Clears catalog metadata overrides while retaining program download configuration.
    #>
    [CmdletBinding()]
    param ([Parameter(Mandatory)][String]$Path)

    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return }
    $userPrograms = Read-AtomPluginOverrides -Path $Path
    $retained = [ordered]@{}
    foreach ($entry in $userPrograms.GetEnumerator() | Sort-Object Key) {
        if ($entry.Value -isnot [Collections.IDictionary]) { throw "Invalid plugin override for '$($entry.Key)'." }
        if ($entry.Value.UserOwned -eq $true) {
            $retained[$entry.Key] = $entry.Value
        } elseif ($entry.Value.Contains('ProgramInfo')) {
            $retained[$entry.Key] = [ordered]@{ ProgramInfo = $entry.Value['ProgramInfo'] }
        }
        # Retain identities for unmanaged files without keeping their metadata overrides.
        if ($entry.Value.Name -and !$entry.Value.UserOwned) {
            if (!$retained.Contains($entry.Key)) { $retained[$entry.Key] = [ordered]@{} }
            $retained[$entry.Key].Name = $entry.Value.Name
            $retained[$entry.Key].Id = $entry.Key
        }
    }
    Write-AtomPluginOverrides -Path $Path -Overrides $retained
}
