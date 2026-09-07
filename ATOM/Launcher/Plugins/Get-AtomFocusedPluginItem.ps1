function Get-AtomFocusedPluginItem {
    @(Get-AtomVisiblePluginItems | Where-Object IsKeyboardFocusWithin | Select-Object -First 1)[0]
}
