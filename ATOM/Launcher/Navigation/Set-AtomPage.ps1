function Set-AtomPage {
    <#
    .SYNOPSIS
        Selects a launcher page while preserving its existing controls and state.
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Plugins', 'Downloads', 'Workflows', 'Settings', 'Updates')]
        [String]$Page
    )

    if ($script:catalogOptionsPopup) { $script:catalogOptionsPopup.IsOpen = $false }
    # Keep the original mode-switch lock while a download/update check is running.
    if ($Page -eq 'Plugins' -and !$pluginsButton.IsEnabled) { return }
    if ($script:activePage -eq 'Plugins' -or ($script:activePage -eq 'Downloads' -and !$script:downloadCatalogBuild)) {
        $script:catalogView.ScrollOffset = $script:catalogView.ScrollViewer.VerticalOffset
    }
    if ($Page -in 'Plugins', 'Downloads') {
        $showDownloads = $Page -eq 'Downloads'
        $modeChanged = $script:downloadMode -ne $showDownloads
        if ($script:pluginListDirty) {
            $script:catalogViews.Plugins.NeedsRefresh = $true
            $script:catalogViews.Downloads.NeedsRefresh = $true
            $script:pluginListDirty = $false
            if ($script:downloadCatalogBuild) { Stop-AtomDownloadCatalogBuild }
        }

        Set-AtomDownloadMode -Enabled $showDownloads
        if ($showDownloads) {
            if ($script:catalogView.NeedsRefresh) { Start-AtomDownloadCatalogBuild }
            elseif ($modeChanged) { Update-AtomDownloadSelectionState }
        } else {
            if ($script:catalogView.NeedsRefresh) {
                Update-AtomPluginList -KeepOtherView
                Start-AtomDownloadCatalogBuild
            } elseif ($modeChanged) {
                Update-AtomCatalogFilter
            }
        }
    }
    if ($Page -eq 'Workflows') { Initialize-AtomWorkflows }
    if ($Page -eq 'Settings') { Initialize-AtomSettingsControls }
    if ($Page -eq 'Updates') { Initialize-AtomUpdatesPage }
    $script:activePage = $Page
    $pluginsPage.Visibility = if ($Page -in 'Plugins', 'Downloads') { 'Visible' } else { 'Collapsed' }
    $window.FindName('settingsPage').Visibility = if ($Page -eq 'Settings') { 'Visible' } else { 'Collapsed' }
    $window.FindName('workflowsPage').Visibility = if ($Page -eq 'Workflows') { 'Visible' } else { 'Collapsed' }
    $scrollViewerUpdates.Visibility = if ($Page -eq 'Updates') { 'Visible' } else { 'Collapsed' }
    if ($Page -eq 'Downloads' -and !$script:downloadCatalogBuild) { Start-AtomDownloadPageTracking }
    if ($Page -eq 'Plugins' -or ($Page -eq 'Downloads' -and !$script:downloadCatalogBuild)) {
        $script:catalogView.ScrollViewer.ScrollToVerticalOffset($script:catalogView.ScrollOffset)
    }

    foreach ($entry in @{
        Plugins = $pluginsButton
        Downloads = $downloadsButton
        Workflows = $workflowsButton
        Settings = $settingsButton
        Updates = $updatesButton
    }.GetEnumerator()) {
        $entry.Value.Tag = if ($entry.Key -eq $Page) { 'Selected' } else { $null }
    }
}
