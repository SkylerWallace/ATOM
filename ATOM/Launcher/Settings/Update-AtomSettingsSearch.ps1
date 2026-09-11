function Update-AtomSettingsSearch {
    if (!$script:settingsControlsInitialized) { return }
    $query = $window.FindName('settingsSearchTextBox').Text.Trim()
    $sections = @{}
    foreach ($entry in $script:settingsSearchEntries) {
        $matches = !$query -or $entry.Name.IndexOf($query, [StringComparison]::OrdinalIgnoreCase) -ge 0
        $entry.Row.Visibility = if ($matches) { 'Visible' } else { 'Collapsed' }
        $entry.Description.Visibility = if ($script:atomSettings.ShowSettingsDescriptions.Value) { 'Visible' } else { 'Collapsed' }
        if ($matches) { $sections[$entry.Section] = $true }
    }
    foreach ($section in 'general', 'plugin', 'quip', 'appearance', 'atom', 'reset') {
        $visibility = if ($sections[$section]) { 'Visible' } else { 'Collapsed' }
        $window.FindName($section + 'SettingsHeading').Visibility = $visibility
        $window.FindName($section + 'SettingsBorder').Visibility = $visibility
    }
    $window.FindName('settingsNoResults').Visibility = if ($sections.Count) { 'Collapsed' } else { 'Visible' }
    $window.FindName('settingsSearchPlaceholder').Visibility = if ($window.FindName('settingsSearchTextBox').Text.Length) { 'Collapsed' } else { 'Visible' }
    $button = $window.FindName('settingsDescriptionButton')
    $button.ToolTip = if ($script:atomSettings.ShowSettingsDescriptions.Value) { 'Hide descriptions' } else { 'Show descriptions' }
    $icon = if ($script:atomSettings.ShowSettingsDescriptions.Value) { 'SubtitlesIcon' } else { 'SubtitlesOffIcon' }
    [Windows.Automation.AutomationProperties]::SetName($button, $button.ToolTip)
    Set-VectorIcon -Window $window -ResourceMappings @{ settingsDescriptionButton = $icon } -Filled:([bool]$script:atomSettings.ShowSettingsDescriptions.Value)
}
