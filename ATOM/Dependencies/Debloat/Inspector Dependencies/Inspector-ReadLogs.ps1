while ($true) {
	# Get the list of log files
	$logFiles = Get-ChildItem -Path $tempPath -Filter "debloat_*.txt"

	# Clear the screen and display the log files in a numbered list
	Clear-Host
	Write-InspectorHeader
	Write-Host "Log files:"
	for ($i = 0; $i -lt $logFiles.Count; $i++) {
		Write-Host ("[{0}] {1}" -f ($i + 1), $logFiles[$i].Name)
	}
	Write-Host "[X] Exit (return to Debloat)`n" -ForegroundColor Red
	
	# Prompt the user to select a log file
	do {
		$selectedNumber = Read-Host "Select a log file"
		if ($selectedNumber -eq 'x') {
			return
		}
	} until (($selectedNumber -gt 0) -and ($selectedNumber -le $logFiles.Count))

	$selectedLogFile = $logFiles[$selectedNumber - 1]

	# Clear the screen and display the selected log file
	Clear-Host
	Write-InspectorHeader
	Write-Host "LOG FILE:"
	Write-Host $selectedLogFile.Name "`n"

	# Give user two options
	Write-Host "Options:"
	Write-Host "[1] View log in window"
	Write-Host "[2] Copy log to Inspector Output"
	Write-Host "[X] Exit (return to Debloat)" -ForegroundColor Red

	do {
		$selectedOption = Read-Host "`nSelect an option"
	} until (($selectedOption -in 1..2) -or ($selectedOption -eq 'X'))

	switch ($selectedOption) {
		1 {
			# Clear the screen, display the selected log file, and view the .txt file in the PowerShell window
			Clear-Host
			Write-InspectorHeader
			Write-Host "Selected log file:"
			Write-Host $selectedLogFile.Name
			Write-Host ""
			Get-Content -Path $selectedLogFile.FullName
			Read-Host "Press Enter to go back to the log files list"
		}
		2 {
			# Copy the .txt file to the Inspector Output directory
			Clear-Host
			Write-InspectorHeader
			Copy-Item -Path $selectedLogFile.FullName -Destination $inspectorOutput
			Write-Host "File copied to: $inspectorOutput"
			Read-Host "Press Enter to go back to the log files list"
		}
		X {
			return
		}
	}
}