function Uninstall-Programs {
	if ($selectedPrograms) {
		Write-OutputBox "Programs"
	}
	
	foreach ($programName in $selectedPrograms) {
		foreach ($uninstallPath in $uninstallPaths) {
			$uninstallKeys = Get-ChildItem $uninstallPath | Where-Object { $_.GetValue("DisplayName") -match $programName}
			foreach ($key in $uninstallKeys) {
				$uninstallString = $key.GetValue("QuietUninstallString")
				if ([string]::IsNullOrWhiteSpace($uninstallString)) {
					$uninstallString = $key.GetValue("UninstallString")
				}
			}
		}
		
		# Add quotation marks to the file path only if it contains spaces and does not already have them
		$uninstallString = $uninstallString -replace '(?<!")([a-zA-Z]:\\[^"]+\.(exe|msi))(?!")', '"$1"'
		
		Write-OutputBox "- Uninstalling $programName"
		cmd /c "$uninstallString"
	}
}