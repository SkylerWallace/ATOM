function Initialize-AtomPluginViewOptions {
    <# .SYNOPSIS
        Creates a lazy view-options menu and persists plugin-local preferences.
    #>
    param(
        [Windows.Window]$Window,
        [String]$SettingsPath,
        [Collections.IDictionary]$Options,
        [ScriptBlock]$OnChanged
    )

    $settings = [ordered]@{ RowSpacing = 0.0 }
    foreach ($key in $Options.Keys) { $settings[$key] = [bool]$Options[$key].Default }
    if (Test-Path -LiteralPath $SettingsPath) {
        try {
            $saved = & {
                param($path)
                $userAtomSettings = $null
                . $path
                $userAtomSettings
            } $SettingsPath
            foreach ($key in $Options.Keys) {
                if ($saved[$key].Value -is [bool]) { $settings[$key] = $saved[$key].Value }
            }
            $spacing = $saved.RowSpacing.Value
            if ($spacing -is [ValueType] -and $spacing -isnot [bool] -and $spacing -ge 0 -and $spacing -le 2) {
                $settings.RowSpacing = [Math]::Round([double]$spacing * 2) / 2
            }
        } catch { Write-Warning "Unable to read view settings: $($_.Exception.Message)" }
    }
    $state = @{ Settings = $settings; Path = $SettingsPath; Options = $Options; Changed = $OnChanged; Window = $Window; Popup = $null; Controls = @{}; Resetting = $false }
    $button = $Window.FindName('viewOptionsButton')
    $button.Tag = $state
    Set-VectorIcon -Window $Window -ResourceMappings @{ viewOptionsButton = 'TuneIcon' }
    $button.Add_Click({
        $state = $this.Tag
        if (!$state.Popup) {
            $panel = [Windows.Controls.StackPanel]::new()
            $panel.MinWidth = 220
            $panel.SetResourceReference([Windows.FrameworkElement]::LayoutTransformProperty, 'uiScaleTransform')
            $changed = {
                $state = $this.Tag.State
                if ($state.Resetting) { return }
                $key = $this.Tag.Key
                $state.Settings[$key] = if ($this -is [Windows.Controls.Slider]) { $this.Value } else { [bool]$this.IsChecked }
                if ($this.Tag.Icon) {
                    $option = $state.Options[$key]
                    $geometry = if ($this.IsChecked) { $option.EnabledIcon } else { $option.DisabledIcon }
                    $this.Tag.Icon.Content = Get-VectorIconGeometry -Window $state.Window -Icon $geometry -Filled:([bool]$this.IsChecked)
                }
                & $state.Changed $key $state.Settings
                try {
                    $values = [ordered]@{}
                    foreach ($entry in $state.Settings.GetEnumerator()) { $values[$entry.Key] = @{ Value = $entry.Value } }
                    Write-AtomSettingsFile -Path $state.Path -Settings $values
                }
                catch { Write-Warning "Unable to save view settings: $($_.Exception.Message)" }
            }
            foreach ($key in $state.Options.Keys) {
                $option = $state.Options[$key]
                $geometry = if ($state.Settings[$key]) { $option.EnabledIcon } else { $option.DisabledIcon }
                $icon = New-VectorIcon -Window $state.Window -Icon $geometry -Filled:([bool]$state.Settings[$key])
                $icon.IsHitTestVisible = $false
                $icon.Margin = '8,0,2,0'
                $row = New-ListBoxControlItem -ControlType CheckBox -Text $option.Label -TrailingContent $icon
                $row.MinHeight = 32
                $row.VerticalContentAlignment = 'Center'
                $row.Control.Tag = @{ State = $state; Key = $key; Icon = $icon }
                $row.Control.IsChecked = $state.Settings[$key]
                $row.Control.Add_Checked($changed)
                $row.Control.Add_Unchecked($changed)
                $state.Controls[$key] = $row.Control
                [void]$panel.Children.Add($row)
            }
            $row = New-ListBoxControlItem -Text 'Row spacing'
            $row.MinHeight = 32
            $slider = [Windows.Controls.Slider]::new()
            $slider.Minimum = 0; $slider.Maximum = 2
            $slider.TickFrequency = 0.5; $slider.SmallChange = 0.5; $slider.LargeChange = 0.5
            $slider.IsSnapToTickEnabled = $true; $slider.IsMoveToPointEnabled = $true
            $slider.AutoToolTipPlacement = 'None'
            $slider.Width = 100; $slider.Margin = '8,0,2,0'; $slider.VerticalAlignment = 'Center'
            $slider.Tag = @{ State = $state; Key = 'RowSpacing' }
            $slider.Value = $state.Settings.RowSpacing
            $slider.Add_ValueChanged($changed)
            $state.Controls.RowSpacing = $slider
            [Windows.Controls.DockPanel]::SetDock($slider, 'Right')
            $row.Content.Children.Insert(0, $slider)
            [void]$panel.Children.Add($row)
            $restore = [Windows.Controls.Button]::new()
            $restore.Style = $state.Window.FindResource('RoundedButton')
            $restore.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'surfaceRaisedBrush')
            $restore.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
            $restore.Margin = 4; $restore.Padding = '8,4'; $restore.Tag = $state
            $content = [Windows.Controls.StackPanel]::new()
            $content.Orientation = 'Horizontal'
            $icon = New-VectorIcon -Window $state.Window -Icon 'ResetWrenchIcon'
            $icon.Margin = '0,0,8,0'; $icon.VerticalAlignment = 'Center'
            [void]$content.Children.Add($icon)
            $label = [Windows.Controls.TextBlock]::new()
            $label.Text = 'Restore view defaults'; $label.VerticalAlignment = 'Center'
            [void]$content.Children.Add($label)
            $contentBorder = [Windows.Controls.Border]::new()
            $contentBorder.Padding = $restore.Padding
            $contentBorder.Child = $content
            $restore.Content = $contentBorder
            $restore.Add_Click({
                $state = $this.Tag
                try {
                    if (Test-Path -LiteralPath $state.Path) { Remove-Item -LiteralPath $state.Path -ErrorAction Stop }
                } catch { Write-Warning "Unable to restore view defaults: $($_.Exception.Message)"; return }
                $state.Resetting = $true
                try {
                    foreach ($key in $state.Options.Keys) {
                        $value = [bool]$state.Options[$key].Default
                        $state.Settings[$key] = $value
                        $control = $state.Controls[$key]
                        $control.IsChecked = $value
                        $geometry = if ($value) { $state.Options[$key].EnabledIcon } else { $state.Options[$key].DisabledIcon }
                        $control.Tag.Icon.Content = Get-VectorIconGeometry -Window $state.Window -Icon $geometry -Filled:$value
                    }
                    $state.Settings.RowSpacing = 0.0
                    $state.Controls.RowSpacing.Value = 0
                } finally { $state.Resetting = $false }
                & $state.Changed 'RestoreDefaults' $state.Settings
                $state.Popup.IsOpen = $false
            })
            [void]$panel.Children.Add($restore)
            $border = [Windows.Controls.Border]::new()
            $border.Resources = $state.Window.Resources
            $border.SetResourceReference([Windows.Controls.Border]::BackgroundProperty, 'surfaceBrush')
            $border.SetResourceReference([Windows.Controls.Border]::BorderBrushProperty, 'surfaceRaisedBrush')
            $border.SetResourceReference([Windows.Controls.Border]::CornerRadiusProperty, 'cornerStrength')
            $border.BorderThickness = 1; $border.Padding = 4; $border.Child = $panel
            [Windows.Documents.TextElement]::SetFontFamily($border, $state.Window.FontFamily)
            [Windows.Documents.TextElement]::SetFontSize($border, $state.Window.FontSize)
            $state.Popup = [Windows.Controls.Primitives.Popup]::new()
            $state.Popup.Child = $border
            $state.Popup.PlacementTarget = $this
            $state.Popup.Placement = 'Custom'
            $state.Popup.CustomPopupPlacementCallback = [Windows.Controls.Primitives.CustomPopupPlacementCallback]{
                param($popupSize, $targetSize, $offset)
                [Windows.Controls.Primitives.CustomPopupPlacement]::new(
                    [Windows.Point]::new($targetSize.Width - $popupSize.Width, $targetSize.Height),
                    [Windows.Controls.Primitives.PopupPrimaryAxis]::Horizontal)
            }
            $state.Popup.AllowsTransparency = $true
            $state.Popup.StaysOpen = $true
        }
        $state.Popup.IsOpen = !$state.Popup.IsOpen
    })
    $Window.Add_PreviewMouseDown({
        if ($state.Popup -and !$state.Window.FindName('viewOptionsButton').IsMouseOver) { $state.Popup.IsOpen = $false }
    }.GetNewClosure())
    $Window.Add_Deactivated({ if ($state.Popup) { $state.Popup.IsOpen = $false } }.GetNewClosure())
    $Window.Add_Closed({ if ($state.Popup) { $state.Popup.IsOpen = $false } }.GetNewClosure())
    return $state
}
