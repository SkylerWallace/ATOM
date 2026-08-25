function Get-AtomThemeShadowResources {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Collections.IDictionary]$Theme,

        [Parameter(Mandatory)]
        [Collections.IDictionary]$Defaults
    )

    $resources = [ordered]@{}
    foreach ($entry in $Defaults.GetEnumerator()) {
        $resources[$entry.Key] = if ($Theme.Contains($entry.Key)) {
            $Theme[$entry.Key]
        } else {
            $entry.Value
        }
    }
    return $resources
}