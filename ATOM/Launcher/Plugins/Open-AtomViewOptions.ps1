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
            @{ Setting = 'HidePluginStatusIcons'; Label = 'Hide status icons'; EnabledIcon = 'HidePluginImageIcon'; DisabledIcon = 'PluginImageIcon' }
            @{ Setting = 'SortPlugins'; Label = 'Sort alphabetically'; Button = 'sortButton'; EnabledIcon = 'TextDescendingIcon'; DisabledIcon = 'CategoryIcon' }
            @{ Setting = 'StackPluginCategories'; Label = 'Stack categories'; Button = 'categoryLayoutButton'; EnabledIcon = 'ViewAgendaIcon'; DisabledIcon = 'ViewAgendaIcon' }
            @{ Setting = 'FavoritePluginsOnly'; Label = 'Favorites only'; EnabledIcon = 'StarIcon'; DisabledIcon = 'StarIcon' }
            @{ Setting = 'LocalPluginsOnly'; Label = 'Available locally only'; EnabledIcon = 'OfflineDownloadIcon'; DisabledIcon = 'OfflineDownloadIcon' }
            @{ Setting = 'ProgramPluginsOnly'; Label = 'Programs only'; EnabledIcon = 'DesktopWindowsIcon'; DisabledIcon = 'DesktopWindowsIcon' }
            @{ Setting = 'ScriptPluginsOnly'; Label = 'Scripts only'; EnabledIcon = 'TerminalIcon'; DisabledIcon = 'TerminalIcon' }
            @{ Setting = 'ShowHiddenPlugins'; Label = 'Show hidden plugins'; Button = 'visibilityButton'; EnabledIcon = 'VisibilityIcon'; DisabledIcon = 'VisibilityOffIcon' }
        )) {
            if ($option.Setting -eq 'FavoritePluginsOnly') {
                $separator = [Windows.Controls.Separator]::new()
                $separator.Style = $window.FindResource('CustomContextMenuSeparator')
                $separator.Margin = '3,3,3,4'
                $separator.Opacity = 0.44
                [void]$panel.Children.Add($separator)
            }
            if ($option.Button) {
                $icon = $window.FindName($option.Button)
                $icon.Parent.Children.Remove($icon)
            } else {
                $icon = New-VectorIcon -Window $window -Icon $option.DisabledIcon
            }
            $icon.IsHitTestVisible = $false
            $icon.Margin = '6,0,2,0'
            $row = New-ListBoxControlItem -ControlType CheckBox -Text $option.Label -TrailingContent $icon
            $row.Text.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
            $row.MinHeight = 30
            $row.VerticalContentAlignment = 'Center'
            $row.Control.Tag = $option + @{ IconButton = $icon }
            $changed = {
                if ($script:syncingCatalogOptions) { return }
                if ($this.Tag.Button) {
                    $this.Tag.IconButton.RaiseEvent([Windows.RoutedEventArgs]::new([Windows.Controls.Primitives.ButtonBase]::ClickEvent))
                } else {
                    $setting = $this.Tag.Setting
                    $script:atomSettings[$setting].Value = [bool]$this.IsChecked
                    if ($this.IsChecked -and $setting -in 'ProgramPluginsOnly', 'ScriptPluginsOnly') {
                        $other = if ($setting -eq 'ProgramPluginsOnly') { 'ScriptPluginsOnly' } else { 'ProgramPluginsOnly' }
                        $script:atomSettings[$other].Value = $false
                        $script:syncingCatalogOptions = $true
                        try {
                            $script:catalogOptionRows[$other].Control.IsChecked = $false
                            $script:catalogOptionRows[$other].Control.Tag.IconButton.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
                            $script:catalogOptionRows[$other].Control.Tag.IconButton.Content = Get-VectorIconGeometry -Window $window -Icon $script:catalogOptionRows[$other].Control.Tag.DisabledIcon
                        } finally { $script:syncingCatalogOptions = $false }
                    }
                    Save-AtomSettings
                    Update-AtomCatalogFilter
                }
                $geometry = if ($this.IsChecked) { $this.Tag.EnabledIcon } else { $this.Tag.DisabledIcon }
                if ($this.Tag.Button) {
                    Set-VectorIcon -Window $window -ResourceMappings @{ ($this.Tag.Button) = $geometry } -Filled:([bool]$this.IsChecked)
                } else {
                    $this.Tag.IconButton.Content = Get-VectorIconGeometry -Window $window -Icon $geometry -Filled:([bool]$this.IsChecked)
                    $this.Tag.IconButton.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
                }
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
        foreach ($name in 'ShowPluginDescriptions', 'ShowHiddenPlugins', 'StackPluginCategories', 'HidePluginStatusIcons', 'FavoritePluginsOnly', 'LocalPluginsOnly', 'ProgramPluginsOnly', 'ScriptPluginsOnly') {
            $script:catalogOptionRows[$name].Control.IsChecked = [bool]$atomSettings[$name].Value
        }
        $script:catalogOptionRows.SortPlugins.Control.IsChecked = $atomSettings.SortPlugins.Value -eq 'Alphabetical'
        foreach ($row in $script:catalogOptionRows.Values) {
            $row.IsEnabled = $row.Control.Tag.IconButton.IsEnabled
            $geometry = if ($row.Control.IsChecked) { $row.Control.Tag.EnabledIcon } else { $row.Control.Tag.DisabledIcon }
            if ($row.Control.Tag.Button) {
                Set-VectorIcon -Window $window -ResourceMappings @{ ($row.Control.Tag.Button) = $geometry } -Filled:([bool]$row.Control.IsChecked)
            } else {
                $row.Control.Tag.IconButton.Content = Get-VectorIconGeometry -Window $window -Icon $geometry -Filled:([bool]$row.Control.IsChecked)
                $row.Control.Tag.IconButton.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
                $row.Visibility = if ($script:downloadMode) { 'Collapsed' } else { 'Visible' }
            }
        }
    } finally {
        $script:syncingCatalogOptions = $false
    }
    $script:catalogOptionRows.ShowPluginDescriptions.Visibility = if ($script:downloadMode) { 'Collapsed' } else { 'Visible' }
    $script:catalogOptionsPopup.IsOpen = !$script:catalogOptionsPopup.IsOpen
}
