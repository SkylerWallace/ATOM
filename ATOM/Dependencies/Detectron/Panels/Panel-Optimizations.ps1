$optimizationsCheckbox = New-Object System.Windows.Controls.CheckBox
$optimizationsCheckbox.Content = "Optimizations"
$optimizationsCheckbox.FontWeight = "Bold"
$optimizationsCheckbox.Foreground = $secondaryText
$optimizationsCheckbox.Margin = "10,5,0,0"
$optimizationsCheckbox.Style = $window.Resources["CustomCheckBoxStyle"]
$uninstallPanel.Children.Add($optimizationsCheckbox) | Out-Null

$optimizationsListBox = New-Object System.Windows.Controls.ListBox
$optimizationsListBox.Background = $secondaryColor1
$optimizationsListBox.Foreground = $secondaryText
$optimizationsListBox.BorderThickness = 0
$optimizationsListBox.Margin = "10,5,0,5"
$optimizationsListBox.Style = $window.Resources["CustomListBoxStyle"]
$uninstallPanel.Children.Add($optimizationsListBox) | Out-Null

Get-ChildItem -Path $detectronOptimizations -Filter *.ps1 | Sort-Object | ForEach-Object {
	$checkBox = New-Object System.Windows.Controls.CheckBox
	$checkBox.Content = $_.BaseName
	$checkBox.Tag = $_.FullName
	$checkBox.Foreground = $secondaryText
	$checkBox.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
	$checkBox.Style = $window.Resources["CustomCheckBoxStyle"]
	
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