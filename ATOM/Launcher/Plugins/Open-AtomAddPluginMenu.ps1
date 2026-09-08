function Open-AtomAddPluginMenu {
    param([Parameter(Mandatory)]$Source)
    if ($script:downloadMode) { return $false }
    $category = 'Uncategorized'
    $element = $Source
    while ($element -and $element -ne $scrollViewer) {
        if ($element -is [Windows.Controls.ListBoxItem] -or $element -is [Windows.Controls.Primitives.ScrollBar]) { return $false }
        if ($element -is [Windows.FrameworkElement] -and $element.Tag.AddPluginCategory) { $category = $element.Tag.AddPluginCategory }
        $element = if ($element -is [Windows.FrameworkContentElement]) { $element.Parent } else { [Windows.Media.VisualTreeHelper]::GetParent($element) }
    }
    if (!$element) { return $false }
    $menu = [Windows.Controls.ContextMenu]::new()
    $menu.Style = $window.FindResource('CustomContextMenu')
    $menu.Background = $window.FindResource('accentBrush')
    $item = [Windows.Controls.MenuItem]::new()
    $item.Header = 'Add plugin...'
    $item.Tag = $category
    $item.Style = $window.FindResource('CustomContextMenuItem')
    $item.Foreground = $window.FindResource('accentText')
    $item.Add_Click({ Show-AtomPluginProperties -Category $this.Tag })
    [void]$menu.Items.Add($item)
    $menu.PlacementTarget = $scrollViewer
    $menu.Placement = 'MousePoint'
    $menu.IsOpen = $true
    return $true
}
