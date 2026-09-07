function Set-AtomFocusedPluginItem {
    param (
        [Parameter(Mandatory)]
        [Object]$Item
    )

    Clear-AtomPluginSelection
    $Item.IsSelected = $true
    $Item.BringIntoView()
    $Item.Focus() | Out-Null
}
