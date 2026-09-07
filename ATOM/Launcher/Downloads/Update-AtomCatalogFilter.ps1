function Update-AtomCatalogFilter {
    $searchText = [String]$searchTextBox.Text
    $filter = if ($downloadFilter.SelectedItem) { [String]$downloadFilter.SelectedItem.Content } else { 'All' }
    $visibleCount = 0
    foreach ($categoryGrid in $pluginWrapPanel.Children) {
        $listBox = $categoryGrid.Children.Child
        $anyVisible = $false
        foreach ($item in $listBox.Items) {
            $visible = ([String]$item.DataContext).IndexOf($searchText, [StringComparison]::OrdinalIgnoreCase) -ge 0
            if ($script:downloadMode) {
                $name = $item.Tag.Name
                $row = $script:downloadRows[$name]
                $visible = $visible -and (Test-AtomDownloadFilter -Filter $filter -Downloaded $row.Downloaded -UpdateAvailable ($script:availableProgramUpdates -contains $name) -Status $script:downloadResults[$name].Status)
            }
            $item.Visibility = if ($visible) { 'Visible' } else { 'Collapsed' }
            if ($visible) { $visibleCount++; $anyVisible = $true }
        }
        $categoryGrid.Visibility = if ($anyVisible) { 'Visible' } else { 'Collapsed' }
        if ($script:downloadMode -and $categoryGrid.Tag -is [Windows.Controls.CheckBox]) {
            $previousSelectionGuard = $window.Tag.UpdatingDownloadSelection
            $window.Tag.UpdatingDownloadSelection = $true
            try {
                $visibleItems = @($listBox.Items | Where-Object { $_.Visibility -eq 'Visible' -and $_.IsEnabled })
                $categoryGrid.Tag.IsEnabled = $pluginsButton.IsEnabled -and $visibleItems.Count -gt 0
                $categoryGrid.Tag.IsChecked = $visibleItems.Count -gt 0 -and @($visibleItems | Where-Object { !$_.Control.IsChecked }).Count -eq 0
            } finally { $window.Tag.UpdatingDownloadSelection = $previousSelectionGuard }
        }
    }
    if ($script:downloadMode) {
        $selected = @(Get-AtomDownloadItem | Where-Object { $_.Control.IsChecked })
        Update-AtomDownloadActionEmphasis -SelectedCount $selected.Count
        $hiddenSelected = @($selected | Where-Object { $_.Visibility -eq 'Collapsed' }).Count
        $downloadSummaryText.Text = "$visibleCount shown | $($selected.Count) selected ($hiddenSelected hidden)"
        if (!$visibleCount) { $downloadSummaryText.Text += ' | No matching downloads' }
        Update-AtomDownloadDetails
    }
}
