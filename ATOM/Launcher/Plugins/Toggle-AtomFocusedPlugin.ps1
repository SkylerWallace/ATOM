function Toggle-AtomFocusedPlugin {
    $item = Get-AtomFocusedPluginItem
    if (!$item) { return }

    if ($script:downloadMode) {
        if (!$pluginsButton.IsEnabled) { return }
        $item.Control.IsChecked = !$item.Control.IsChecked
    } else {
        Set-AtomPluginFavorite -Name $item.Tag.Name -Favorite (!$item.Tag.Config.Favorite)
    }
}
