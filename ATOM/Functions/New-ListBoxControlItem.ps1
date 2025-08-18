function New-ListBoxControlItem {
    <#
    .SYNOPSIS
    Creates a WPF ListBoxItem containing a control with optional image and text.

    .DESCRIPTION
    The `New-ListBoxControlItem` function creates a Windows Presentation Foundation (WPF) ListBoxItem that contains a control (CheckBox, RadioButton, or ToggleButton), an optional image, and optional text. The control can be aligned to the left or right within the item, and the function supports customization of styles, tooltips, and event handling for mouse interactions.

    .PARAMETER ControlAlignment
    Specifies the alignment of the control within the ListBoxItem. Valid values are 'Left' or 'Right'. Default is 'Left'.

    .PARAMETER ControlStyle
    Specifies a WPF style to apply to the control. Must be a valid System.Windows.Style object.

    .PARAMETER ControlType
    Specifies the type of control to include in the ListBoxItem. Valid values are 'CheckBox', 'RadioButton', or 'ToggleButton'. If not specified, no control is included.

    .PARAMETER ImageSource
    Specifies the path or URI to an image to display in the ListBoxItem. The image is displayed with a height of 16 pixels and centered vertically.

    .PARAMETER Tag
    Specifies a custom object or script block to associate with the control. This is stored in the control's Tag property.

    .PARAMETER Text
    Specifies the text to display in the ListBoxItem. The text is displayed in a TextBlock with customizable foreground color.

    .PARAMETER TextForeground
    Specifies the foreground color of the text in the TextBlock.

    .PARAMETER ToolTip
    Specifies a tooltip to display when hovering over the ListBoxItem.

    .EXAMPLE
    $listBoxItem = New-ListBoxControlItem -ControlType CheckBox -Text "Sample App" -ImageSource "C:\Icons\app.png" -TextForeground "Blue" -Tag "SampleApp"
    Creates a ListBoxItem with a CheckBox, the text "Sample App" in blue, and an image from the specified path.

    .EXAMPLE
    $listBoxItem = New-ListBoxControlItem -ControlType RadioButton -Text "Option 1" -ControlAlignment Right -ToolTip "Select this option"
    Creates a ListBoxItem with a RadioButton aligned to the right, displaying "Option 1" with a tooltip.

    .INPUTS
    None. This function does not accept pipeline input.

    .OUTPUTS
    [System.Windows.Controls.ListBoxItem]
    Returns a WPF ListBoxItem object containing a control (if specified), an optional image, and optional text. The ListBoxItem includes the following NoteProperties:
    - Control: The control object (CheckBox, RadioButton, or ToggleButton).
    - Image: The image object (System.Windows.Controls.Image), if specified.
    - Text: The text block object (System.Windows.Controls.TextBlock), if specified.

    .NOTES
    Author: Skyler Wallace
    #>

    [CmdletBinding()]

    param (
        [ValidateSet('Left', 'Right')]
        [string]$controlAlignment = 'Left',
        [system.windows.style]$controlStyle,
        [ValidateSet('CheckBox', 'RadioButton', 'ToggleButton')]
        [string]$controlType = $null,
        [string]$imageSource,
        [Alias('ScriptBlock')]
        [object]$tag,
        [string]$text,
        [string]$textForeground,
        [string]$toolTip
    )

    if ($controlType) {
        $control = switch ($controlType) {
            'ToggleButton' { New-Object System.Windows.Controls.Primitives.$controlType  }
            default { New-Object System.Windows.Controls.$controlType }
        }
        $control.VerticalAlignment = 'Center'
        if ($controlStyle) { $control.Style = $controlStyle}
        if ($tag) { $control.Tag = $tag }
    }

    if ($imageSource) {
        $image = New-Object System.Windows.Controls.Image
        $image.Source = $imageSource
        $image.Height = 16
        $image.VerticalAlignment = 'Center'
        $image.Margin = '0,0,2.5,0'
    }

    if ($text) {
        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $text
        if ($textForeground) { $textBlock.Foreground = $textForeground }
        $textBlock.VerticalAlignment = 'Center'
        $textBlock.Margin = '2.5,0,2.5,0'
    }

    $stackPanel = New-Object System.Windows.Controls.StackPanel
    $stackPanel.Orientation = 'Horizontal'
    if ($image) { $stackPanel.Children.Add($image) | Out-Null }
    if ($textBlock) { $stackPanel.Children.Add($textBlock) | Out-Null }

    $listBoxItem = New-Object System.Windows.Controls.ListBoxItem
    $listBoxItem.Tag = $control
    if ($toolTip) { $listBoxItem.ToolTip = $toolTip }

    if ($controlType -eq 'RadioButton') { $listBoxItem.Add_MouseLeftButtonUp({ $this.Tag.IsChecked = $true }) }
    elseif ($controlType) { $listBoxItem.Add_MouseLeftButtonUp({ $this.Tag.IsChecked = !$this.Tag.IsChecked }) }

    if (!$control) {
        $listBoxItem.Content = $stackPanel
    } elseif ($controlAlignment -eq 'Left') {
        $stackPanel.Children.Insert(0, $control) | Out-Null
        $listBoxItem.Content = $stackPanel
    } else {
        $grid = New-Object System.Windows.Controls.Grid
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = '1*' }))
        $grid.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{ Width = [System.Windows.GridLength]::Auto }))

        $grid.Children.Add($stackPanel) | Out-Null
        $grid.Children.Add($control) | Out-Null

        $stackPanel.HorizontalAlignment = 'Left'
        $control.HorizontalAlignment = 'Right'

        $listBoxItem.Content = $grid
    }
    
    $listBoxItem | Add-Member -MemberType NoteProperty -Name Control -Value $control
    $listBoxItem | Add-Member -MemberType NoteProperty -Name Image -Value $image
    $listBoxItem | Add-Member -MemberType NoteProperty -Name Text -Value $textBlock

    return $listBoxItem
}