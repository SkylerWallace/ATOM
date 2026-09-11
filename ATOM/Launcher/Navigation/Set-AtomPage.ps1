function Set-AtomPage {
    <#
    .SYNOPSIS
        Selects a launcher page while preserving its existing controls and state.
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateSet('Plugins', 'Downloads', 'Settings', 'Updates')]
        [String]$Page
    )

    # Plugins and Downloads share the existing catalog and download implementation.
    # Keep the original mode-switch lock while a download/update check is running.
    if ($Page -eq 'Plugins' -and !$pluginsButton.IsEnabled) { return }
    if ($Page -in 'Plugins', 'Downloads') {
        Set-AtomDownloadMode -Enabled ($Page -eq 'Downloads')
    }
    if ($Page -eq 'Downloads') {
        $downloadManagerTimer.Start()
        if (!$script:downloadStorage) { Start-AtomDownloadStorageScan }
    }
    if ($Page -eq 'Settings') { Initialize-AtomSettingsControls }
    $script:activePage = $Page
    $pluginsPage.Visibility = if ($Page -in 'Plugins', 'Downloads') { 'Visible' } else { 'Collapsed' }
    $window.FindName('settingsPage').Visibility = if ($Page -eq 'Settings') { 'Visible' } else { 'Collapsed' }
    $scrollViewerUpdates.Visibility = if ($Page -eq 'Updates') { 'Visible' } else { 'Collapsed' }

    foreach ($entry in @{
        Plugins = $pluginsButton
        Downloads = $downloadsButton
        Settings = $settingsButton
        Updates = $updatesButton
    }.GetEnumerator()) {
        $entry.Value.Tag = if ($entry.Key -eq $Page) { 'Selected' } else { $null }
    }

    if ($Page -in 'Plugins', 'Downloads' -and $script:pluginListDirty) {
        Update-AtomPluginList
        $script:pluginListDirty = $false
    }
}
