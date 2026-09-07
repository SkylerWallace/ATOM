function Select-AllAtomDownloads {
    if (!$pluginsButton.IsEnabled) { return }
    $window.Tag.UpdatingDownloadSelection = $true
    try {
        foreach ($item in @(Get-AtomPluginItems | Where-Object { $_.IsEnabled -and $_.Visibility -eq 'Visible' })) { $item.Control.IsChecked = $true }
    } finally {
        $window.Tag.UpdatingDownloadSelection = $false
    }
    Update-AtomDownloadSelectionState
}
