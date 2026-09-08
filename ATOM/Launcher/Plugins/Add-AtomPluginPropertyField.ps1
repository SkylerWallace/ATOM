function Add-AtomPluginPropertyField {
    param($Panel, [String]$Label, $Value, [String]$Kind = 'Text', $Options, [Switch]$ReadOnly, [Switch]$Multiline)
    if ($Kind -eq 'Choice') {
        $item = New-ListBoxControlItem -ControlType ComboBox -ControlOptions $Options -SelectedValue $Value -ControlStyle ($window.FindResource('CustomComboBox')) -ControlWidth ([Double]::NaN)
        $choice = $item.Control
        $item.Content.Children.Remove($choice)
    }
    $row = [Windows.Controls.Grid]::new()
    $row.Margin = '5'
    $column = [Windows.Controls.ColumnDefinition]::new()
    $column.Width = 120
    [void]$row.ColumnDefinitions.Add($column)
    [void]$row.ColumnDefinitions.Add([Windows.Controls.ColumnDefinition]::new())
    $labelText = [Windows.Controls.TextBlock]::new()
    $labelText.Text = $Label
    $labelText.TextWrapping = 'Wrap'
    $labelText.Margin = '0,0,10,0'
    $labelText.VerticalAlignment = 'Center'
    $labelText.SetResourceReference([Windows.Controls.TextBlock]::ForegroundProperty, 'surfaceText')
    [void]$row.Children.Add($labelText)
    if ($Kind -eq 'Choice') {
        $control = $choice
        $control.IsEnabled = !$ReadOnly
        $control.Height = 32
    } elseif ($Kind -eq 'Boolean') {
        $control = [Windows.Controls.CheckBox]::new()
        $control.IsChecked = [Boolean]$Value
        $control.IsEnabled = !$ReadOnly
        $control.VerticalAlignment = 'Center'
    } else {
        $control = [Windows.Controls.TextBox]::new()
        $control.Text = [String]$Value
        $control.IsReadOnly = $ReadOnly
        $control.TextWrapping = if ($Multiline) { 'Wrap' } else { 'NoWrap' }
        $control.AcceptsReturn = $Multiline
        $control.Height = if ($Multiline) { 64 } else { 32 }
        $control.VerticalContentAlignment = if ($Multiline) { 'Top' } else { 'Center' }
        $control.VerticalAlignment = 'Center'
        $control.Padding = '6,4'
        $control.ToolTip = [String]$Value
        $control.SetResourceReference([Windows.Controls.Control]::BackgroundProperty, 'surfaceBrush')
        $control.SetResourceReference([Windows.Controls.Control]::ForegroundProperty, 'surfaceText')
        $control.SetResourceReference([Windows.Controls.Control]::BorderBrushProperty, 'surfaceText')
        $control.BorderThickness = if ($ReadOnly) { 0 } else { 1 }
    }
    [Windows.Controls.Grid]::SetColumn($control, 1)
    [void]$row.Children.Add($control)
    [void]$Panel.Children.Add($row)
    return $control
}
