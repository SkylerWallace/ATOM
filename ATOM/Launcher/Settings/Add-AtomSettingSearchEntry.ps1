function Add-AtomSettingSearchEntry {
    param($Element, [String]$Name, [String]$Description, [String]$Section)

    $panel = [Windows.Controls.StackPanel]::new()
    $row = $Element
    if ($Element -is [Windows.Controls.ListBoxItem]) {
        $content = $Element.Content
        $Element.Content = $null
        [void]$panel.Children.Add($content)
        $Element.Content = $panel
    } else {
        $parent = $Element.Parent
        if ($parent -is [Windows.Controls.Panel]) {
            $index = $parent.Children.IndexOf($Element)
            $parent.Children.Remove($Element)
            $parent.Children.Insert($index, $panel)
        } else {
            $parent.Child = $null
            $parent.Child = $panel
        }
        [void]$panel.Children.Add($Element)
        $row = $panel
    }
    $details = [Windows.Controls.TextBlock]::new()
    $details.Text = $Description
    $details.TextWrapping = 'Wrap'
    $details.FontSize = 10
    $details.Margin = '5,2,5,5'
    $details.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
    [void]$panel.Children.Add($details)
    $script:settingsSearchEntries.Add([PSCustomObject]@{ Row = $row; Name = $Name; Description = $details; Section = $Section })
}
