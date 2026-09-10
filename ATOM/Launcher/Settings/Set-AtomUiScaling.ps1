function Set-AtomUiScaling {
    param (
        [Double]$Scale
    )

    $automatic = [bool]$script:atomSettings.AutomaticUIScaling.Value
    if ($automatic) { $Scale = Get-AtomAutomaticUiScale }
    $scale = [Math]::Max(1.0, [Math]::Min(2.0, [Math]::Round($Scale * 8) / 8))
    $window.Resources['uiScale'] = $scale
    $window.Resources['uiScaleTransform'] = [Windows.Media.ScaleTransform]::new($scale, $scale)

    foreach ($categoryGrid in @($pluginWrapPanel.Children)) {
        $listBox = @($categoryGrid.Children | Where-Object { $_ -is [Windows.Controls.Border] })[0].Child
        foreach ($pluginItem in @($listBox.Items)) {
            if ($pluginItem.ContextMenu) {
                $pluginItem.ContextMenu.LayoutTransform = [Windows.Media.ScaleTransform]::new($scale, $scale)
            }
        }
    }

    Set-AtomPluginColumnCount -ColumnCount $script:atomSettings.StartupColumns.Value

    $uiScalingValueText.Text = '{0:0.#}%' -f ($scale * 100)
    if ($automatic) { $uiScalingValueText.Text = 'Automatic - ' + $uiScalingValueText.Text }
    $window.FindName('uiScalingSlider').IsEnabled = !$automatic
}
