function Set-AtomPluginColumnCount {
    param (
        [Parameter(Mandatory)]
        [Int]$ColumnCount
    )

    $columnWidth = 220
    $panelChromeWidth =
        $pluginWrapPanel.Margin.Left +
        $pluginWrapPanel.Margin.Right +
        [Windows.SystemParameters]::VerticalScrollBarWidth
    $scale = [Double]$window.Resources['uiScale']

    # MinWidth and MaxWidth describe the unscaled layout in the window parameters.
    # Scale those constraints along with the content so they do not clip it.
    $window.MinWidth = ($windowParameters.MinWidth + $sidebar.Width) * $scale
    $window.MaxWidth = ($windowParameters.MaxWidth + $sidebar.Width) * $scale

    $logicalWidth = [Math]::Max(
        $windowParameters.MinWidth,
        ($columnWidth * $ColumnCount) + $panelChromeWidth
    )
    $window.Width = [Math]::Min($window.MaxWidth, ($logicalWidth + $sidebar.Width) * $scale)
}
