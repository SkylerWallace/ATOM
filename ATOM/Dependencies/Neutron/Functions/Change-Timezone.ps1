function Change-Timezone {
	Start-Service w32time
	if ($radioButtons[0].IsChecked -eq $true) {
		Set-TimeZone -Id "Pacific Standard Time"
		Write-OutputBox "Set Timezone to PST"
	} elseif ($radioButtons[1].IsChecked -eq $true) {
		Set-TimeZone -Id "Mountain Standard Time"
		Write-OutputBox "Set Timezone to MST"
	} elseif ($radioButtons[2].IsChecked -eq $true) {
		Set-TimeZone -Id "Central Standard Time"
		Write-OutputBox "Set Timezone to CST"
	} elseif ($radioButtons[3].IsChecked -eq $true) {
		Set-TimeZone -Id "Eastern Standard Time"
		Write-OutputBox "Set Timezone to EST"
	}
	w32tm /resync
}