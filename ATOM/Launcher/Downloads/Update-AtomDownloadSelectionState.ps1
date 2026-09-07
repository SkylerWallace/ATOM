function Update-AtomDownloadSelectionState {
    if (!$script:downloadMode -or $window.Tag.UpdatingDownloadSelection) { return }

    $selectedCount = 0
    $window.Tag.UpdatingDownloadSelection = $true

    try {
        foreach ($categoryGrid in $pluginWrapPanel.Children) {
            $border = $categoryGrid.Children | Where-Object { $_ -is [System.Windows.Controls.Border] } | Select-Object -First 1
            $categoryCheckBox = $categoryGrid.Tag
            if (!$border -or $categoryCheckBox -isnot [System.Windows.Controls.CheckBox]) { continue }

            $availableItems = @($border.Child.Items | Where-Object { $_.IsEnabled -and $_.Visibility -eq 'Visible' })
            $checkedItems = @($availableItems | Where-Object { $_.Control.IsChecked })
            $selectedCount += $checkedItems.Count

            $categoryCheckBox.IsEnabled = $availableItems.Count -gt 0
            $categoryCheckBox.Opacity = if ($categoryCheckBox.IsEnabled) { 1.0 } else { 0.44 }
            $categoryCheckBox.IsChecked = $availableItems.Count -gt 0 -and $checkedItems.Count -eq $availableItems.Count
        }
    } finally {
        $window.Tag.UpdatingDownloadSelection = $false
    }

    $selectedCount = @(Get-AtomDownloadItem | Where-Object { $_.Control.IsChecked }).Count
    if ($pluginsButton.IsEnabled) { $statusBarStatus.Text = if ($selectedCount -eq 1) { '1 program selected' } else { "$selectedCount programs selected" } }
    $downloadSelectedButton.IsEnabled = $pluginsButton.IsEnabled -and $selectedCount -gt 0
    Update-AtomCatalogFilter
}
