function Resolve-AtomWorkflowPluginPath {
    <# .SYNOPSIS
        Resolves a workflow's plugin ID to its current file, or uses a filename-only reference.
    .DESCRIPTION
        A specified ID must resolve successfully; PluginFile is only used when no
        PluginId is supplied. Catalog loading stays local to this invocation.
    #>
    param([Parameter(Mandatory)][hashtable]$Action, [Parameter(Mandatory)][string]$AtomRoot)
    $pluginsPath = Join-Path $AtomRoot 'Plugins'
    if ($Action.PluginId) {
        if ($Action.PluginId -notmatch '^[a-f0-9]{32}$') { throw "Invalid workflow plugin ID: $($Action.PluginId)" }
        $catalog = & {
            param($CatalogPath)
            . $CatalogPath
            return ,$programs
        } (Join-Path $AtomRoot 'Config/Plugins.ps1')
        $matches = @($catalog.GetEnumerator() | Where-Object { $_.Value.Id -eq $Action.PluginId })
        if ($matches.Count -ne 1) { throw "Workflow plugin ID '$($Action.PluginId)' must match exactly one catalog entry; found $($matches.Count)." }
        $plugin = $matches[0]
        if ($plugin.Value.FileName) {
            $path = Join-Path $pluginsPath $plugin.Value.FileName
        } else {
            $files = @(Get-ChildItem -LiteralPath $pluginsPath -File -ErrorAction Stop | Where-Object { $_.BaseName -eq $plugin.Key -and $_.Extension -in '.ps1','.cmd','.bat','.exe','.lnk' })
            if ($files.Count -ne 1) { throw "Workflow plugin '$($plugin.Key)' must have exactly one launcher file; found $($files.Count)." }
            $path = $files[0].FullName
        }
    } else {
        if (!$Action.PluginFile) { throw 'A plugin workflow action must specify PluginId or PluginFile.' }
        $path = Join-Path $pluginsPath $Action.PluginFile
    }
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Workflow plugin file missing: $path" }
    return $path
}
