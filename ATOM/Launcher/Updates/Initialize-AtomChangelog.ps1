function Initialize-AtomChangelog {
    <#
    .SYNOPSIS
        Reads the packaged changelog once, on its first expansion.
    #>
    if ($script:changelogLoaded) { return }
    $hostControl = $window.FindName('changelogContent')
    try {
        $path = Join-Path (Split-Path $atomPath) 'CHANGELOG.md'
        $panel = [Windows.Controls.StackPanel]::new()
        $panel.Margin = [Windows.Thickness]::new(5)
        foreach ($line in [IO.File]::ReadAllLines($path)) {
            if ([String]::IsNullOrWhiteSpace($line) -or $line -match '^# Changelog\s*$') { continue }
            $text = $line -replace '\[([^\]]+)\]\([^)]+\)', '$1'
            $paragraph = [Windows.Controls.TextBlock]::new()
            $paragraph.FontFamily = $window.FontFamily
            $paragraph.FontSize = 11
            $paragraph.TextWrapping = 'Wrap'
            $paragraph.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            $paragraph.Margin = [Windows.Thickness]::new(0,0,0,7)
            if ($text -match '^(#{1,6})\s+(.+)$') {
                $paragraph.FontSize = if ($Matches[1].Length -le 2) { 14 } else { 12 }
                $paragraph.FontWeight = [Windows.FontWeights]::Bold
                $text = $Matches[2]
            } elseif ($text -match '^[-*]\s+(.+)$') {
                $text = [Char]0x2022 + ' ' + $Matches[1]
            }
            $paragraph.Text = $text
            [void]$panel.Children.Add($paragraph)
        }
        $hostControl.Content = $panel
        $script:changelogLoaded = $true
    } catch {
        $message = [Windows.Controls.TextBlock]::new()
        $message.Text = 'The changelog could not be loaded. Expand it again to retry.'
        $message.TextWrapping = 'Wrap'
        $message.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
        $hostControl.Content = $message
    }
}
