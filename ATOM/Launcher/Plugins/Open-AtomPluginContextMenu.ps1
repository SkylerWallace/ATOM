function Open-AtomPluginContextMenu {
    $item = Get-AtomFocusedPluginItem
    if (!$item -or !$item.ContextMenu) { return }

    $item.ContextMenu.PlacementTarget = $item
    $item.ContextMenu.Placement = [Windows.Controls.Primitives.PlacementMode]::Right
    $item.ContextMenu.IsOpen = $true
}
