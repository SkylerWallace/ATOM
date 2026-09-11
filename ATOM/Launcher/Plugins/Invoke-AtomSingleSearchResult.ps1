function Invoke-AtomSingleSearchResult {
    $items = @(Get-AtomVisiblePluginItems)
    if (!$script:downloadMode -and $items.Count -eq 1) { Invoke-AtomPlugin -Plugin $items[0].Tag }
}
