$optimizationsCheckbox = New-Object System.Windows.Controls.CheckBox
$optimizationsCheckbox.Content = "Optimizations"
$optimizationsCheckbox.ToolTip = "Check all optimizations."
$optimizationsCheckbox.FontWeight = "Bold"
$optimizationsCheckbox.Foreground = $surfaceText
$optimizationsCheckbox.Margin = "10,5,0,0"
$uninstallPanel.Children.Add($optimizationsCheckbox) | Out-Null

$optimizationsListBox = New-Object System.Windows.Controls.ListBox
$optimizationsListBox.Background = $surfaceColor
$optimizationsListBox.Foreground = $surfaceText
$optimizationsListBox.BorderThickness = 0
$optimizationsListBox.Margin = "10,5,0,5"
$optimizationsListBox.Style = $window.Resources["CustomListBoxStyle"]
$uninstallPanel.Children.Add($optimizationsListBox) | Out-Null

Get-ChildItem -Path $detectronOptimizations -Filter *.ps1 | Sort-Object | ForEach-Object {
    $checkBox = New-Object System.Windows.Controls.CheckBox
    $checkBox.Content = $_.BaseName
    $checkBox.Tag = $_.FullName
    $checkBox.Foreground = $surfaceText
    $checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    
    # Add tooltip if first line of script starts with "$tooltip = "
    $firstLine = Get-Content $_.FullName -First 1
    if ($firstLine.StartsWith('$tooltip = ')) {
        Invoke-Expression $firstLine
        $checkBox.ToolTip = $tooltip
    }
    
    $optimizationsItems = $optimizationsListBox.Items
    $optimizationsItems.Add($checkBox) | Out-Null
}

$optimizationsCheckbox.Add_Checked({
    foreach ($item in $optimizationsItems) {
        if ($item.IsEnabled) {
            $item.IsChecked = $true
        }
    }
})

$optimizationsCheckbox.Add_Unchecked({
    foreach ($item in $optimizationsItems) {
        if ($item.IsEnabled) {
            $item.IsChecked = $false
        }
    }
})