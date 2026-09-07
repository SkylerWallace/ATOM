function Set-AtomUiScaling {
    param (
        [Double]$Scale
    )

    $scale = [Math]::Round($Scale * 8) / 8
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

    $uiScalingValueText.Text = '{0:0.0##}x' -f $scale
}
