function Resolve-AtomWorkflowSelection {
    <# .SYNOPSIS
        Resolves a catalog choice without modifying the shared definition.
    #>
    param(
        [Parameter(Mandatory)][hashtable]$Definition,
        [string]$OptionId
    )

    $resolved = @{} + $Definition
    if ($Definition.Parameters) { $resolved.Parameters = @{} + $Definition.Parameters }
    if (!$Definition.Option) {
        if ($OptionId) { throw "'$($Definition.Name)' does not support options." }
        return $resolved
    }

    if (!$OptionId) { $OptionId = $Definition.Option.Default }
    $choices = @($Definition.Option.Choices | Where-Object Id -eq $OptionId)
    if ($choices.Count -ne 1) { throw "Unknown or duplicate option '$OptionId' for '$($Definition.Name)'." }
    $choice = $choices[0]
    $resolved.OptionId = $OptionId
    $resolved.Name = "$($Definition.Name) - $($choice.Name)"
    if ($choice.Description) { $resolved.Description = $choice.Description }
    if ($choice.ContainsKey('Actions')) { $resolved.Actions = $choice.Actions }
    if ($choice.Parameters) {
        if (!$resolved.Parameters) { $resolved.Parameters = @{} }
        foreach ($key in $choice.Parameters.Keys) { $resolved.Parameters[$key] = $choice.Parameters[$key] }
    }
    return $resolved
}
