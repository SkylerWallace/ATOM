function Increment-TextBox {
	param(
		[Parameter(Mandatory=$true)]
		[System.Windows.Controls.TextBox]$textBox,
		
		[Parameter(Mandatory=$false)]
		[int]$increment = 1
	)
	
	$minValue = -12
	$maxValue = 14
	
	$currentValue = [int]$textBox.Text
	$newValue = $currentValue + $increment
	
	# Clamp to range
	if ($newValue -lt $minValue) {
		$newValue = $minValue
	} elseif ($newValue -gt $maxValue) {
		$newValue = $maxValue
	}
	
	$textBox.Text = $newValue.ToString()
}

function New-RadioButton {
	param(
		[string]$name,
		[string]$timezoneId,
		[string]$content,
		[boolean]$special
	)
	
	$radioButton = New-Object Windows.Controls.RadioButton
	$radioButton.Name = $name
	$radioButton.Content = $content
	$radioButton.VerticalContentAlignment = "Center"
	$radioButton.GroupName = "UpdateOption"
	$radioButton.IsChecked = $false
	$radioButton.Margin = 5
	
	if (!$special) {
		$radioButton.Tag = $timezoneId
		return $radioButton
	}
	
	$script:textBox = New-Object Windows.Controls.TextBox
	$script:textBox.Text = "0"
	$script:textBox.Width = 25
	$script:textBox.VerticalAlignment = "Center"
	$script:textBox.HorizontalAlignment = "Left"
	$script:textBox.TextAlignment = "Center"
	$script:textBox.Add_TextChanged({
		$radioButton.Tag = 	
		switch ($script:textBox.Text) {
			-12 { "Dateline Standard Time" }
			-11 { "UTC-11" }
			-10 { "Aleutian Standard Time" }
			-9 { "Alaskan Standard Time" }
			-8 { "Pacific Standard Time" }
			-7 { "Mountain Standard Time" }
			-6 { "Central Standard Time" }
			-5 { "Eastern Standard Time" }
			-4 { "Atlantic Standard Time" }
			-3 { "Argentina Standard Time" }
			-2 { "Greenland Standard Time" }
			-1 { "Azores Standard Time" }
			0 { "GMT Standard Time" }
			1 { "Central Europe Standard Time" }
			2 { "Middle East Standard Time" }
			3 { "Arabic Standard Time" }
			4 { "Caucasus Standard Time" }
			5 { "Pakistan Standard Time" }
			6 { "Bangladesh Standard Time" }
			7 { "North Asia Standard Time" }
			8 { "W. Australia Standard Time" }
			9 { "North Korea Standard Time" }
			10 { "Tasmania Standard Time" }
			11 { "Norfolk Standard Time" }
			12 { "New Zealand Standard Time" }
			13 { "Samoa Standard Time" }
			14 { "Line Islands Standard Time" }
			default { "GMT Standard Time" }
		}
	})
	
	$upButton = New-Object Windows.Controls.Button
	$upButton.Content = "▲"
	$upButton.FontSize = "5"
	$upButton.Width = "15"
	$upButton.Height = "7"
	$upButton.Style = $window.Resources["RoundedTopButton"]
	$upButton.Add_Click({
		$radioButton.IsChecked = $true
		Increment-TextBox -TextBox $script:textBox -Increment 1
	})

	$downButton = New-Object Windows.Controls.Button
	$downButton.Content = "▼"
	$downButton.FontSize = "5"
	$downButton.Width = "15"
	$downButton.Height = "7"
	$downButton.Style = $window.Resources["RoundedBottomButton"]
	$downButton.Add_Click({
		$radioButton.IsChecked = $true
		Increment-TextBox -TextBox $script:textBox -Increment -1
	})

	$incrementStackPanel = New-Object System.Windows.Controls.StackPanel
	$incrementStackPanel.Margin = 5
	$incrementStackPanel.VerticalAlignment = "Center"
	$incrementStackPanel.Children.Add($upButton) | Out-Null
	$incrementStackPanel.Children.Add($downButton) | Out-Null

	$horizStackPanel = New-Object System.Windows.Controls.StackPanel
	$horizStackPanel.Orientation = "Horizontal"
	$horizStackPanel.VerticalAlignment = "Center"
	$horizStackPanel.Children.Add($radioButton) | Out-Null
	$horizStackPanel.Children.Add($textBox) | Out-Null
	$horizStackPanel.Children.Add($incrementStackPanel) | Out-Null
	
	return $horizStackPanel
}

# Add other radio buttons
$radioButtons = @(
	(New-RadioButton -Name "rbPST" -Content "Pacific Time" -TimezoneId "Pacific Standard Time"),
	(New-RadioButton -Name "rbMST" -Content "Mountain Time" -TimezoneId "Mountain Standard Time"),
	(New-RadioButton -Name "rbCST" -Content "Central Time" -TimezoneId "Central Standard Time"),
	(New-RadioButton -Name "rbEST" -Content "Eastern Time" -TimezoneId "Eastern Standard Time")
	#(New-RadioButton -Name "rbUTC" -Content "UTC:" -TimezoneId "GMT Standard Time" -Special $true)
)

$radioButtons | ForEach-Object { $timezonePanel.Children.Add($_) | Out-Null }

<#
# Custom stuff for UTC radio button
$textBox = New-Object Windows.Controls.TextBox
$textBox.Text = "0"
$textBox.Width = 25
$textBox.VerticalAlignment = "Center"
$textBox.HorizontalAlignment = "Left"
$textBox.TextAlignment = "Center"
$textBox.Add_TextChanged({
	$rbUTC.Tag = 	
	switch ($textBox.Text) {
		-12 { "Dateline Standard Time" }
		-11 { "UTC-11" }
		-10 { "Aleutian Standard Time" }
		-9 { "Alaskan Standard Time" }
		-8 { "Pacific Standard Time" }
		-7 { "Mountain Standard Time" }
		-6 { "Central Standard Time" }
		-5 { "Eastern Standard Time" }
		-4 { "Atlantic Standard Time" }
		-3 { "Argentina Standard Time" }
		-2 { "Greenland Standard Time" }
		-1 { "Azores Standard Time" }
		0 { "GMT Standard Time" }
		1 { "Central Europe Standard Time" }
		2 { "Middle East Standard Time" }
		3 { "Arabic Standard Time" }
		4 { "Caucasus Standard Time" }
		5 { "Pakistan Standard Time" }
		6 { "Bangladesh Standard Time" }
		7 { "North Asia Standard Time" }
		8 { "W. Australia Standard Time" }
		9 { "North Korea Standard Time" }
		10 { "Tasmania Standard Time" }
		11 { "Norfolk Standard Time" }
		12 { "New Zealand Standard Time" }
		13 { "Samoa Standard Time" }
		14 { "Line Islands Standard Time" }
	}
})

$upButton = New-Object Windows.Controls.Button
$upButton.Content = "▲"
$upButton.FontSize = "5"
$upButton.Width = "15"
$upButton.Height = "7"
$upButton.Style = $window.Resources["RoundedTopButton"]
$upButton.Add_Click({
	$rbUTC.IsChecked = $true
	Increment-TextBox -TextBox $textBox -Increment 1
})

$downButton = New-Object Windows.Controls.Button
$downButton.Content = "▼"
$downButton.FontSize = "5"
$downButton.Width = "15"
$downButton.Height = "7"
$downButton.Style = $window.Resources["RoundedBottomButton"]
$downButton.Add_Click({
	$rbUTC.IsChecked = $true
	Increment-TextBox -TextBox $textBox -Increment -1
})

$incrementStackPanel = New-Object System.Windows.Controls.StackPanel
$incrementStackPanel.Margin = 5
$incrementStackPanel.VerticalAlignment = "Center"
$incrementStackPanel.Children.Add($upButton) | Out-Null
$incrementStackPanel.Children.Add($downButton) | Out-Null

$horizStackPanel = New-Object System.Windows.Controls.StackPanel
$horizStackPanel.Orientation = "Horizontal"
$horizStackPanel.VerticalAlignment = "Center"
$horizStackPanel.Children.Add($incrementStackPanel) | Out-Null
$horizStackPanel.Children.Add($textBox) | Out-Null

$timezonePanel.Children.Add($horizStackPanel) | Out-Null
#>