function Reset-AtomPluginMetadata {
    <#
    .SYNOPSIS
        Confirms and resets user plugin metadata from Settings.
    #>
    $answer = [Windows.MessageBox]::Show(
        $window,
        'Reset all plugin metadata to its defaults, including categories, favorites, visibility, descriptions, and tags? Custom program download settings and downloaded files will be kept.',
        'Reset plugin metadata',
        [Windows.MessageBoxButton]::YesNo,
        [Windows.MessageBoxImage]::Question,
        [Windows.MessageBoxResult]::No
    )
    if ($answer -ne [Windows.MessageBoxResult]::Yes) { return }
    try {
        Clear-AtomPluginMetadata -Path (Join-Path $configPath 'PluginsUser.ps1')
        Update-AtomPluginList -Reload
        Update-AtomCatalogFilter
        $script:pluginListDirty = $false
    } catch {
        [void][Windows.MessageBox]::Show($window, $_.Exception.Message, 'Unable to reset plugin metadata', 'OK', 'Error')
    }
}
