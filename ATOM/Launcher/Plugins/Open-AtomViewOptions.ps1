function Open-AtomViewOptions {
    if (!$script:catalogOptionsPopup) {
        $panel = [Windows.Controls.StackPanel]::new()
        $panel.SetResourceReference([Windows.FrameworkElement]::LayoutTransformProperty, 'uiScaleTransform')
        $border = [Windows.Controls.Border]::new()
        $border.SetResourceReference([Windows.Controls.Border]::BackgroundProperty, 'surfaceBrush')
        $border.SetResourceReference([Windows.Controls.Border]::BorderBrushProperty, 'surfaceHighlight')
        $border.SetResourceReference([Windows.Controls.Border]::CornerRadiusProperty, 'cornerStrength')
        $border.BorderThickness = 1
        $border.Padding = 5
        $border.Child = $panel
        $border.Resources = $window.Resources
        [Windows.Documents.TextElement]::SetFontFamily($border, $window.FontFamily)
        [Windows.Documents.TextElement]::SetFontSize($border, $window.FontSize)
        $script:catalogOptionRows = @{}

        foreach ($option in @(
            @{ Setting = 'ShowPluginDescriptions'; Label = 'Show descriptions'; Button = 'descriptionButton'; EnabledIcon = 'SubtitlesIcon'; DisabledIcon = 'SubtitlesOffIcon' }
            @{ Setting = 'ShowHiddenPlugins'; Label = 'Show hidden plugins'; Button = 'visibilityButton'; EnabledIcon = 'VisibilityIcon'; DisabledIcon = 'VisibilityOffIcon' }
            @{ Setting = 'SortPlugins'; Label = 'Sort alphabetically'; Button = 'sortButton'; EnabledIcon = 'TextDescendingIcon'; DisabledIcon = 'CategoryIcon' }
        )) {
            $icon = $window.FindName($option.Button)
            $icon.Parent.Children.Remove($icon)
            $icon.IsHitTestVisible = $false
            $icon.Margin = '6,0,2,0'
            $row = New-ListBoxControlItem -ControlType CheckBox -Text $option.Label -TrailingContent $icon
            $row.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            $row.MinHeight = 30
            $row.VerticalContentAlignment = 'Center'
            $row.Control.Tag = $option + @{ IconButton = $icon }
            $changed = {
                if ($script:syncingCatalogOptions) { return }
                $this.Tag.IconButton.RaiseEvent([Windows.RoutedEventArgs]::new([Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                $geometry = if ($this.IsChecked) { $this.Tag.EnabledIcon } else { $this.Tag.DisabledIcon }
                Set-VectorIcon -Window $window -ResourceMappings @{ ($this.Tag.Button) = $geometry } -Filled:([bool]$this.IsChecked)
            }
            $row.Control.Add_Checked($changed)
            $row.Control.Add_Unchecked($changed)
            $script:catalogOptionRows[$option.Setting] = $row
            [void]$panel.Children.Add($row)
        }

        $script:catalogOptionsPopup = [Windows.Controls.Primitives.Popup]::new()
        $script:catalogOptionsPopup.Child = $border
        $script:catalogOptionsPopup.PlacementTarget = $window.FindName('viewOptionsButton')
        $script:catalogOptionsPopup.Placement = 'Custom'
        $script:catalogOptionsPopup.CustomPopupPlacementCallback = [Windows.Controls.Primitives.CustomPopupPlacementCallback]{
            param($popupSize, $targetSize, $offset)
            [Windows.Controls.Primitives.CustomPopupPlacement]::new(
                [Windows.Point]::new($targetSize.Width - $popupSize.Width, $targetSize.Height),
                [Windows.Controls.Primitives.PopupPrimaryAxis]::Horizontal
            )
        }
        $script:catalogOptionsPopup.StaysOpen = $true
        $script:catalogOptionsPopup.AllowsTransparency = $true
        $window.Add_PreviewMouseDown({
            if (!$window.FindName('viewOptionsButton').IsMouseOver) { $script:catalogOptionsPopup.IsOpen = $false }
        })
        $window.Add_Deactivated({ $script:catalogOptionsPopup.IsOpen = $false })
        $script:catalogOptionsPopup.Add_Opened({
            Set-VectorIcon -Window $window -ResourceMappings @{ viewOptionsButton = 'TuneIcon' } -ForegroundResource controlBrush
            [void]$script:catalogOptionRows.ShowHiddenPlugins.Control.Focus()
        })
        $script:catalogOptionsPopup.Add_Closed({
            Set-VectorIcon -Window $window -ResourceMappings @{ viewOptionsButton = 'TuneIcon' }
        })
        $border.Add_PreviewKeyDown({
            if ($_.Key -eq 'Escape') { $script:catalogOptionsPopup.IsOpen = $false; $_.Handled = $true }
        })
    }

    $script:syncingCatalogOptions = $true
    try {
        foreach ($name in 'ShowPluginDescriptions', 'ShowHiddenPlugins') {
            $script:catalogOptionRows[$name].Control.IsChecked = [bool]$atomSettings[$name].Value
        }
        $script:catalogOptionRows.SortPlugins.Control.IsChecked = $atomSettings.SortPlugins.Value -eq 'Alphabetical'
        foreach ($row in $script:catalogOptionRows.Values) {
            $row.IsEnabled = $row.Control.Tag.IconButton.IsEnabled
            $geometry = if ($row.Control.IsChecked) { $row.Control.Tag.EnabledIcon } else { $row.Control.Tag.DisabledIcon }
            Set-VectorIcon -Window $window -ResourceMappings @{ ($row.Control.Tag.Button) = $geometry } -Filled:([bool]$row.Control.IsChecked)
        }
    } finally {
        $script:syncingCatalogOptions = $false
    }
    $script:catalogOptionRows.ShowPluginDescriptions.Visibility = if ($script:downloadMode) { 'Collapsed' } else { 'Visible' }
    $script:catalogOptionsPopup.IsOpen = !$script:catalogOptionsPopup.IsOpen
}
