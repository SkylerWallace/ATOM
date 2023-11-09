function Uninstall-Programs {
	$detectedPrograms = @{}
	$undetectedPrograms = @()
	foreach ($uninstallPath in $uninstallPaths) {
		$programRegex = ($programs -join "|")
		$uninstallKeys = Get-ChildItem $uninstallPath | Where-Object { $_.GetValue("DisplayName") -match $programRegex }
		foreach ($key in $uninstallKeys) {
			$programName = $key.GetValue("DisplayName")
			$uninstallString = $key.GetValue("QuietUninstallString")
			if (![string]::IsNullOrWhiteSpace($uninstallString)) {
				$detectedPrograms[$programName] = $uninstallString
			}
			else {
				$uninstallString = $key.GetValue("UninstallString")
				$detectedPrograms[$programName] = $uninstallString
			}
		}
	}
	foreach ($program in $programs) {
		$found = $false
		foreach ($detectedProgram in $detectedPrograms.Keys) {
			if ($detectedProgram -like "$program*") {
				$found = $true
				break
			}
		}
		if (!$found) {
			$undetectedPrograms += $program
		}
	}
	foreach ($programName in $detectedPrograms.Keys) {
		$uninstallString = $detectedPrograms[$programName]
		# Add quotation marks to the file path only if it contains spaces and does not already have them
		$uninstallString = $uninstallString -replace '(?<!")([a-zA-Z]:\\[^"]+\.(exe|msi))(?!")', '"$1"'
		Write-Host -NoNewLine "$programName detected - "
		cmd /c "$uninstallString"
		Write-Host "uninstalled." -ForegroundColor Cyan
	}
	foreach ($program in $undetectedPrograms) {
		Write-Host "$program not detected." -ForegroundColor DarkGray
	}
}