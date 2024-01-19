function New-RadioButton {
	param(
		[string]$Name,
		[string]$TimezoneId,
		[string]$Content
	)
	
	$radioButton = New-Object Windows.Controls.RadioButton
	$radioButton.Name = $Name
	$radioButton.Content = $Content
	$radioButton.Tag = $TimezoneId
	$radioButton.VerticalContentAlignment = "Center"
	$radioButton.GroupName = "UpdateOption"
	$radioButton.IsChecked = $false
	$radioButton.Margin = 5
	
	return $radioButton
}

$radioButtons = @(
	(New-RadioButton -Name "rbPST" -Content "Pacific Time" -TimezoneId "Pacific Standard Time"),
	(New-RadioButton -Name "rbMST" -Content "Mountain Time" -TimezoneId "Mountain Standard Time"),
	(New-RadioButton -Name "rbCST" -Content "Central Time" -TimezoneId "Central Standard Time"),
	(New-RadioButton -Name "rbEST" -Content "Eastern Time" -TimezoneId "Eastern Standard Time")
)

$radioButtons | ForEach-Object { $timezonePanel.Children.Add($_) | Out-Null }