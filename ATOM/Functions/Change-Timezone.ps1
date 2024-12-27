function Change-Timezone {
	Start-Service w32time

	$checkedTimezone = $null

	foreach ($radioButton in $radioButtons) {
		$isChecked = $radioButton.Dispatcher.Invoke([func[bool]]{ $radioButton.IsChecked }, "Render")
		if ($isChecked) {
			$checkedTimezone = $radioButton.Dispatcher.Invoke([func[string]]{ $radioButton.Tag }, "Render")
			break
		}
	}
	
	Write-Host "Timezone:"

	if ($checkedTimezone -ne $null) {
		Set-Timezone -Id $checkedTimezone
		Write-Host "- $checkedTimezone"
	} else {
		Write-Host "- None selected"
	}
	
	try {
		w32tm /resync
		Write-Host "- Time synchronized`n"
	} catch {
		Write-Host "- Failed to sync time`n"
	}
}