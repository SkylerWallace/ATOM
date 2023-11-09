function New-RadioButton {
	param(
		[string]$Name,
		[string]$Content,
		[string]$GroupName,
		[bool]$IsChecked,
		[Windows.Thickness]$Margin
	)
	
	$radioButton = New-Object Windows.Controls.RadioButton
	$radioButton.Name = $Name
	$radioButton.Content = $Content
	$radioButton.Background = [Windows.Media.Brushes]::Transparent
	$radioButton.Foreground = [Windows.Media.Brushes]::White
	$radioButton.VerticalContentAlignment = "Center"
	$radioButton.GroupName = $GroupName
	$radioButton.IsChecked = $IsChecked
	$radioButton.Margin = $Margin
	
	return $radioButton
}

$radioButtons = @(
	(New-RadioButton -Name "rbPST" -Content "Pacific Time" -GroupName "UpdateOption" -IsChecked $false -Margin (New-Object Windows.Thickness(5, 5, 5, 0))),
	(New-RadioButton -Name "rbMST" -Content "Mountain Time" -GroupName "UpdateOption" -IsChecked $false -Margin (New-Object Windows.Thickness(5, 5, 5, 0))),
	(New-RadioButton -Name "rbCST" -Content "Central Time" -GroupName "UpdateOption" -IsChecked $false -Margin (New-Object Windows.Thickness(5, 5, 5, 0))),
	(New-RadioButton -Name "rbEST" -Content "Eastern Time" -GroupName "UpdateOption" -IsChecked $false -Margin (New-Object Windows.Thickness(5)))
)

$radioButtons | ForEach-Object { $timezonePanel.Children.Add($_) | Out-Null }