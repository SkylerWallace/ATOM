function New-ListBoxControlItem {
    <#
    .SYNOPSIS
    Creates a WPF ListBoxItem containing a control with optional leading image, text, and trailing content.

    .DESCRIPTION
    The `New-ListBoxControlItem` function creates a Windows Presentation Foundation (WPF) ListBoxItem that contains a control (CheckBox, ComboBox, RadioButton, or ToggleButton), an optional leading image, optional text, and optional trailing content. Trailing content is docked to the right in the supplied order while text remains the fill element.

    .PARAMETER ControlAlignment
    Specifies the alignment of the control within the ListBoxItem. Valid values are 'Left' or 'Right'. Default is 'Left'.

    .PARAMETER ControlOptions
    Specifies the display labels and values used to populate a ComboBox control.

    .PARAMETER ControlStyle
    Specifies a WPF style to apply to the control. Must be a valid System.Windows.Style object.

    .PARAMETER ControlType
    Specifies the type of control to include in the ListBoxItem. Valid values are 'CheckBox', 'ComboBox', 'RadioButton', or 'ToggleButton'. If not specified, no control is included.

    .PARAMETER ControlWidth
    Specifies the width of a ComboBox control.

    .PARAMETER ImageSource
    Specifies the path or URI to an image to display in the ListBoxItem. The image is displayed with a height of 16 pixels and centered vertically.

    .PARAMETER SelectedValue
    Specifies the initially selected value for a ComboBox control.

    .PARAMETER Tag
    Specifies a custom object or script block to associate with the control. This is stored in the control's Tag property.

    .PARAMETER Text
    Specifies the text to display in the ListBoxItem. The text is displayed in a TextBlock with customizable foreground color.

    .PARAMETER TextForeground
    Specifies the foreground color of the text in the TextBlock.

    .PARAMETER ToolTip
    Specifies a tooltip to display when hovering over the ListBoxItem.

    .PARAMETER TrailingContent
    Specifies UI elements to display at the trailing edge of the ListBoxItem, such as status icons, badges, switches, or metadata. The first element is placed closest to the right edge.

    .EXAMPLE
    $listBoxItem = New-ListBoxControlItem -ControlType CheckBox -Text "Sample App" -ImageSource "C:\Icons\app.png" -TextForeground "Blue" -Tag "SampleApp"
    Creates a ListBoxItem with a CheckBox, the text "Sample App" in blue, and an image from the specified path.

    .EXAMPLE
    $listBoxItem = New-ListBoxControlItem -ControlType RadioButton -Text "Option 1" -ControlAlignment Right -ToolTip "Select this option"
    Creates a ListBoxItem with a RadioButton aligned to the right, displaying "Option 1" with a tooltip.

    .EXAMPLE
    $listBoxItem = New-ListBoxControlItem -Text "Favorite" -TrailingContent $favoriteIcon, $hiddenIcon
    Creates a ListBoxItem with two trailing status icons. The favorite icon is placed closest to the right edge.

    .INPUTS
    None. This function does not accept pipeline input.

    .OUTPUTS
    [System.Windows.Controls.ListBoxItem]
    Returns a WPF ListBoxItem object containing a control (if specified), an optional leading image, optional text, and optional trailing content. The ListBoxItem includes the following NoteProperties:
    - Control: The control object (CheckBox, ComboBox, RadioButton, or ToggleButton).
    - Image: The image object (System.Windows.Controls.Image), if specified.
    - Text: The text block object (System.Windows.Controls.TextBlock), if specified.
    - TrailingContent: The trailing UI elements supplied to the item.

    .NOTES
    Author: Skyler Wallace
    #>

    [CmdletBinding()]

    param (
        [ValidateSet('Left', 'Right')]
        [String]$controlAlignment = 'Left',
        [System.Collections.IDictionary]$controlOptions,
        [System.Windows.Style]$controlStyle,
        [ValidateSet('CheckBox', 'ComboBox', 'RadioButton', 'ToggleButton')]
        [String]$controlType = $null,
        [Double]$controlWidth = 110,
        [String]$imageSource,
        [Object]$selectedValue,
        [Alias('ScriptBlock')]
        [Object]$tag,
        [String]$text,
        [String]$textForeground,
        [String]$toolTip,
        [System.Windows.UIElement[]]$trailingContent
    )

    if ($controlType) {
        if ($controlType -eq 'ComboBox' -and !$controlOptions) {
            throw 'ControlOptions is required when ControlType is ComboBox.'
        }

        $control = switch ($controlType) {
            'ToggleButton' { New-Object System.Windows.Controls.Primitives.$controlType  }
            'ComboBox' {
                $comboBox = New-Object System.Windows.Controls.ComboBox
                $comboBox.SelectedValuePath = 'Tag'
                $comboBox.Width = $controlWidth

                foreach ($option in $controlOptions.GetEnumerator()) {
                    $comboBoxItem = New-Object System.Windows.Controls.ComboBoxItem
                    $comboBoxItem.Content = $option.Key
                    $comboBoxItem.Tag = $option.Value
                    $comboBox.Items.Add($comboBoxItem) | Out-Null
                }

                $comboBox.SelectedValue = $selectedValue
                $comboBox
            }
            default { New-Object System.Windows.Controls.$controlType }
        }
        $control.VerticalAlignment = 'Center'
        if ($controlStyle) { $control.Style = $controlStyle}
        if ($tag) { $control.Tag = $tag }
    }

    if ($imageSource) {
        $image = New-Object System.Windows.Controls.Image
        $image.Source = Get-CachedImage -Path $imageSource
        $image.Height = 16
        $image.VerticalAlignment = 'Center'
        $image.Margin = '0,0,2.5,0'
    }

    if ($text) {
        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.Text = $text
        if ($textForeground) { $textBlock.Foreground = $textForeground }
        $textBlock.TextTrimming = 'CharacterEllipsis'
        $textBlock.VerticalAlignment = 'Center'
        $textBlock.Margin = '2.5,0,2.5,0'
    }

    $listBoxItem = New-Object System.Windows.Controls.ListBoxItem
    $listBoxItem.Tag = $control
    if ($toolTip) { $listBoxItem.ToolTip = $toolTip }

    if ($controlType) {
        if ($control -is [System.Windows.Controls.ComboBox]) {
            $listBoxItem | Add-Member -MemberType NoteProperty -Name ControlWasOpen -Value $false
            $listBoxItem.Add_PreviewMouseLeftButtonDown({
                $this.ControlWasOpen = $this.Control.IsDropDownOpen
            })
        }

        $listBoxItem.Add_MouseLeftButtonUp({
            param($sender, $eventArgs)

            $source = $eventArgs.OriginalSource
            while ($source -and $source -ne $sender) {
                if ($source -eq $sender.Control) { return }
                $source = [System.Windows.Media.VisualTreeHelper]::GetParent($source)
            }

            if ($sender.Control -is [System.Windows.Controls.ComboBox]) {
                $sender.Control.Focus() | Out-Null
                $sender.Control.IsDropDownOpen = !$sender.ControlWasOpen
            } else {
                $sender.Control.IsChecked =
                    if ($sender.Control -is [System.Windows.Controls.RadioButton]) { $true }
                    else { !$sender.Control.IsChecked }
            }
        })
    }

    $trailingElements = @($trailingContent | Where-Object { $null -ne $_ })
    $contentPanel = New-Object System.Windows.Controls.DockPanel
    $contentPanel.LastChildFill = [bool]$textBlock
    if ($control) {
        [System.Windows.Controls.DockPanel]::SetDock($control, $controlAlignment)
        $contentPanel.Children.Add($control) | Out-Null
    }
    if ($image) {
        [System.Windows.Controls.DockPanel]::SetDock($image, 'Left')
        $contentPanel.Children.Add($image) | Out-Null
    }
    foreach ($element in $trailingElements) {
        if (!$element) { continue }
        [System.Windows.Controls.DockPanel]::SetDock($element, 'Right')
        $contentPanel.Children.Add($element) | Out-Null
    }
    if ($textBlock) { $contentPanel.Children.Add($textBlock) | Out-Null }

    $listBoxItem.HorizontalContentAlignment = 'Stretch'
    $listBoxItem.Content = $contentPanel
    
    $listBoxItem | Add-Member -MemberType NoteProperty -Name Control -Value $control
    $listBoxItem | Add-Member -MemberType NoteProperty -Name Image -Value $image
    $listBoxItem | Add-Member -MemberType NoteProperty -Name Text -Value $textBlock
    $listBoxItem | Add-Member -MemberType NoteProperty -Name TrailingContent -Value $trailingElements

    return $listBoxItem
}
