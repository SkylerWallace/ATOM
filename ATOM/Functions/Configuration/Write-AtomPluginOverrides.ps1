function Write-AtomPluginOverrides {
    param([Parameter(Mandatory)][String]$Path, [Parameter(Mandatory)][Collections.IDictionary]$Overrides)
    $sorted = [ordered]@{}
    foreach ($entry in $Overrides.GetEnumerator() | Sort-Object Key) { $sorted[$entry.Key] = $entry.Value }
    $literal = ConvertTo-AtomPowerShellLiteral -Value $sorted
    Write-AtomFileAtomic -Path $Path -Content (([Char]36) + "userPrograms = $literal$([Environment]::NewLine)") -Encoding ([Text.UTF8Encoding]::new($true))
}
