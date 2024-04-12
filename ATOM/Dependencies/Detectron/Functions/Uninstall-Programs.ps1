function Uninstall-Programs {
	if ($selectedPrograms) {
		Write-OutputBox "Programs"
		
		foreach ($programName in $selectedPrograms) {
			# Iterate through all category keys in detectedPrograms hashtable
			foreach ($category in $detectedPrograms.Keys) {
				# Search for program in current category
				$detectedProgram = $detectedPrograms[$category][$programName]
				
				# If detected, set uninstallString and break category loop
				if ($detectedProgram) {
					$uninstallString = $detectedProgram['UninstallString']
					break
				}
			}
			
			# Uninstall selected program
			Write-OutputBox "- Uninstalling $programName"
			cmd /c "$uninstallString"
			
			# Output if uninstall was successful
			if (Test-Path $detectedProgram['Key']) {
				Write-OutputBox "  > Could not verify if program uninstalled"
			} else {
				Write-OutputBox "  > Program uninstalled"
			}
		}
		
		Write-OutputBox ""
	}
}