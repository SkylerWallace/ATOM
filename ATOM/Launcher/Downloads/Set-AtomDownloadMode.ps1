function Set-AtomDownloadMode {
    param (
        [Parameter(Mandatory)]
        [Boolean]$Enabled
    )

    if ($script:downloadMode -eq $Enabled) { return }

    $script:catalogView.ScrollViewer.Visibility = 'Collapsed'
    $script:downloadMode = $Enabled
    $script:catalogView = if ($Enabled) { $script:catalogViews.Downloads } else { $script:catalogViews.Plugins }
    $script:pluginWrapPanel = $script:catalogView.Panel
    $script:catalogView.ScrollViewer.Visibility = 'Visible'

    $searchTextBox.Text = $script:catalogView.SearchText
    $searchTimer.Stop()
    $searchTextBlock.Visibility = if (!$searchTextBox.Text -and !$searchTextBox.IsKeyboardFocusWithin) { 'Visible' } else { 'Collapsed' }

    $descriptionButton.Visibility = if ($Enabled) { 'Collapsed' } else { 'Visible' }
    $downloadsVisibility = if ($Enabled) { 'Visible' } else { 'Collapsed' }
    $downloadManagerPanel.Visibility = $downloadsVisibility
    $downloadSelectedButton.Visibility = $downloadsVisibility
    $programUpdateButton.Visibility = $downloadsVisibility

    Update-AtomDownloadCatalogLoading
    if (!$script:downloadMode) { Set-AtomQuip }
}
