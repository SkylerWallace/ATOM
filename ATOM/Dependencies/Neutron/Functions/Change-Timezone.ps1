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
	
	Write-OutputBox "Timezone:"

	if ($checkedTimezone -ne $null) {
		Set-Timezone -Id $checkedTimezone
		Write-OutputBox "- $checkedTimezone"
	} else {
		Write-OutputBox "- None selected"
	}
	
	try {
		w32tm /resync
		Write-OutputBox "- Time synchronized`n"
	} catch {
		Write-OutputBox "- Failed to sync time`n"
	}
}