Add-Type -AssemblyName System.Windows.Forms

$whitelistSites = @(
	("www.calendar.google.com"),
	("www.facebook.com"),
	("www.mail.google.com"),
	("www.outlook.live.com"),
	("www.meet.google.com"),
	("www.netflix.com"),
	("www.youtube.com"),
	("www.zoom.us")
)

function Check-Notifications {
	$textBlock = New-Object System.Windows.Controls.TextBlock
	$textBlock.Foreground = $secondaryText
	$textBlock.Margin = "5"
	$stackPanel.Children.Add($textBlock) | Out-Null
	
	$browserButton = New-Object System.Windows.Controls.Button
	$browserButton.Tag = $browserName
	$browserButton.Content = $buttonContent
	$browserButton.Tooltip = $buttonTooltip
	$browserButton.Style = $window.Resources["RoundedButton"]
	$browserButton.Margin = "5"
	$browserButton.Tag = @{ "Name" = $browserName; "URL" = $notificationsUrl }
	$stackPanel.Children.Add($browserButton) | Out-Null
	$browserButton.Add_Click({
		$buttonTag = $_.Source.Tag
		[System.Windows.Forms.Clipboard]::SetText($buttonTag["URL"])
		start $buttonTag["Name"]
	})
	
	$preferencesFilePaths = @("$userDataPath\Default\Preferences")
	$profiles = Get-ChildItem "$userDataPath" | Where-Object {$_.PSIsContainer -and $_.Name.StartsWith("Profile")}
	foreach ($profile in $profiles) {
		$preferencesFilePaths += "$($profile.FullName)\Preferences"
	}
	$totalSiteCounter = 0
	$totalWhitelistCounter = 0
	
	$textBlock.Text = $browserName
	foreach ($preferencesFilePath in $preferencesFilePaths) {
		$preferences = Get-Content $preferencesFilePath -Raw
		$userName = if ($browserName -eq "Chrome") { ($preferences | ConvertFrom-Json).account_info[0].full_name }
					elseif ($browserName -eq "MSEdge") { [regex]::Match($preferences, '"edge_account_first_name":"([^"]+)"').Groups[1].Value }
		
		$notifications = ($preferences | Select-String -Pattern '(?<="notifications":{)(.*?)(?=},"password_protection":)').Matches.Value | Out-String
		$urls = [regex]::Matches($notifications, '(?:www\.)?[a-z]+\.[a-z]+(?:\.[a-z]+)*') | ForEach-Object { $_.Value }
		$whitelistCounter = 0
		foreach ($url in $urls) {
			if ($whitelistSites -contains $url) {
				$whitelistCounter++
				$totalWhitelistCounter++
			} else {
				$totalSiteCounter++
			}
		}
		$totalSiteCounter += $whitelistCounter
		
		$textBlock.Text += "`n- $($username): $whitelistCounter / $($urls.Count) sites whitelisted"
	}
}

$browserTextBlock = New-Object System.Windows.Controls.TextBlock
$browserTextBlock.Text = "Browser Notifications"
$browserTextBlock.FontWeight = "Bold"
$browserTextBlock.Foreground = $secondaryText
$browserTextBlock.Margin = "10,5,0,0"
$uninstallPanel.Children.Add($browserTextBlock) | Out-Null

$border = New-Object System.Windows.Controls.Border
$border.CornerRadius = [System.Windows.CornerRadius]::new(5)
$border.Background = $secondaryColor1
$border.Margin = "10,10,0,10"
$border.Padding = "5"
$uninstallPanel.Children.Add($border) | Out-Null

$stackPanel = New-Object System.Windows.Controls.StackPanel
$border.Child = $stackPanel

# Edge
$browserPath = "C:\Program Files*\Microsoft\Edge"
$userDataPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
$preferencesPath = "$userDataPath\*\Preferences"

if ((Test-Path $browserPath) -And (Test-Path $preferencesPath)) {
	$buttonContent = "Launch Edge"
	$buttonTooltip = "- Launches Edge`n- Adds notification URL to clipboard"
	
	$browserName = "MSEdge"
	$notificationsUrl = "edge://settings/content/notifications"

	Check-Notifications
}

# Chrome
$browserPath = "C:\Program Files*\Google\Chrome"
$userDataPath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
$preferencesPath = "$userDataPath\*\Preferences"

if ((Test-Path $browserPath) -And (Test-Path $preferencesPath)) {
	$buttonContent = "Launch Chrome"
	$buttonTooltip = "- Launches Chrome`n- Adds notification URL to clipboard"
	
	$browserName = "Chrome"
	$notificationsUrl = "chrome://settings/content/notifications"

	Check-Notifications
}