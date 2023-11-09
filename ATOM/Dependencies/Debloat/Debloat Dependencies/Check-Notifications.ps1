# The Check-Notifications function checks the browsers' "Preferences" files (for each profile too!).
# The contents of Preferences is imported and then a combination of Select-String & regex is used
# to extract the URLs of sites with notifications enabled/disabled.
# Chrome and Edge require different methods for finding the usernames since they use different syntax.
# Edge cannot use ConvertFrom-Json due to case-sensitivity issues and so regex is used instead.
function Check-Notifications {
	$preferencesFilePaths = @("$userDataPath\Default\Preferences")
	$profiles = Get-ChildItem "$userDataPath" | Where-Object {$_.PSIsContainer -and $_.Name.StartsWith("Profile")}
	foreach ($profile in $profiles) {
		$preferencesFilePaths += "$($profile.FullName)\Preferences"
	}
	$totalSiteCounter = 0
	$totalWhitelistCounter = 0
	
	Write-Host "$browserName"
	foreach ($preferencesFilePath in $preferencesFilePaths) {
		$preferences = Get-Content $preferencesFilePath -Raw
		if ($browserName -eq "Chrome") {
			$username = ($preferences | ConvertFrom-Json).account_info[0].full_name
		}
		elseif ($browserName -eq "MSEdge") {
			$username = [regex]::Match($preferences, '"edge_account_first_name":"([^"]+)"').Groups[1].Value
		}
		$notifications = ($preferences | Select-String -Pattern '(?<="notifications":{)(.*?)(?=},"password_protection":)').Matches.Value | Out-String
		$urls = [regex]::Matches($notifications, '(?:www\.)?[a-z]+\.[a-z]+(?:\.[a-z]+)*') | ForEach-Object { $_.Value }
		$whitelistCounter = 0
		foreach ($url in $urls) {
			if ($whitelistSites -contains $url) {
				$whitelistCounter++
				$totalWhitelistCounter++
			}
			else {
				$totalSiteCounter++
			}
		}
		$totalSiteCounter += $whitelistCounter
		Write-Host -NoNewLine "- $($username): " -Foreground DarkGray
		if ($whitelistCounter -eq $urls.Count) {
			Write-Host -NoNewLine "$whitelistCounter / $($urls.Count) " -ForegroundColor Green
		}
		else {
			Write-Host -NoNewLine "$whitelistCounter / $($urls.Count) " -ForegroundColor Red
		}
		Write-Host "sites whitelisted." -ForegroundColor DarkGray
	}
	if ($totalSiteCounter -gt $totalWhitelistCounter) {
		Write-Host "`nWould you like to launch $($browserName)?"
		do { $answer = Read-Host "[Y] Yes [N] No" } until ($answer -match "^(y|n)$")
		if ($answer -match "y") {
			Add-Type -AssemblyName System.Windows.Forms
			[System.Windows.Forms.Clipboard]::SetText("$browserNotificationsPath")
			Write-Host "`nWhen $($browserName) launches, perform the following:"
			Write-Host "- 1. Select the Address Bar."
			Write-Host "- 2. Press 'Ctrl + V' (paste)."
			Write-Host "- 3. Press 'Enter'."
			Write-Host "This will bring you to the notifications settings page."
			Write-Warning "Please remove suspicious sites from 'Allowed' or disable notifications if there are many suspicious URLs."
			Read-Host "Press `Enter` to launch $($browserName)"
			start $browserName
		}
	}
}