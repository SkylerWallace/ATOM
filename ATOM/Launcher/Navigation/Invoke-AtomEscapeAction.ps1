function Invoke-AtomEscapeAction {
    $openContextMenu = @(Get-AtomPluginItems | Where-Object { $_.ContextMenu -and $_.ContextMenu.IsOpen } | Select-Object -First 1)[0]
    if ($openContextMenu) {
        $openContextMenu.ContextMenu.IsOpen = $false
        return $true
    }

    $settingComboBoxes = @($updateChannelSelector) + @(
        $settingsPanels.Values.Children |
            Where-Object { $_.Control -is [Windows.Controls.ComboBox] } |
            ForEach-Object Control
    )
    $openComboBox = @($settingComboBoxes | Where-Object IsDropDownOpen | Select-Object -First 1)[0]
    if ($openComboBox) {
        $openComboBox.IsDropDownOpen = $false
        return $true
    }

    if ($script:activePage -in 'Plugins', 'Downloads' -and $searchTextBox.Text.Length) {
        Clear-AtomSearchTextBox
        return $true
    }

    if ($script:activePage -eq 'Settings' -and $window.FindName('settingsSearchTextBox').Text.Length) {
        $window.FindName('settingsSearchTextBox').Clear()
        return $true
    }

    $homePage = if ($atomSettings.StartupPage.Value -eq 'Workflows') { 'Workflows' } else { 'Plugins' }
    if ($script:activePage -ne $homePage) {
        Set-AtomPage -Page $homePage
        return $true
    }

    if ($script:activePage -eq 'Plugins' -and @(Get-AtomPluginItems | Where-Object IsSelected).Count) {
        Clear-AtomPluginSelection
        return $true
    }

    return $false
}
