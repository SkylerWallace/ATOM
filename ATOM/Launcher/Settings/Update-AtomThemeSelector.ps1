function Update-AtomThemeSelector {
    $themeName = [String]$script:atomSettings.Theme.Value
    $palette = $themes[$themeName]
    if (!$palette) { return }

    $themeSelectorText.Text = $themeName
    foreach ($entry in $themeSwatches.GetEnumerator()) {
        $color = [System.Windows.Media.ColorConverter]::ConvertFromString($palette[$entry.Key])
        $entry.Value.Background = [System.Windows.Media.SolidColorBrush]::new($color)
    }
}
