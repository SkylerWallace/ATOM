$inspectorOutput = "$scriptPath\Inspector Output"

Write-InspectorHeader
Write-Host "Select an option, then press 'Enter'.`n"
Write-Host "[1] Read Debloat log files"
Write-Host "[2] Locate program uninstall strings"
Write-Host "[3] Find program startup paths"
Write-Host "[4] Clear Inspector Output folder"
Write-Host "[X] Exit (return to Debloat)`n" -ForegroundColor Red
do {
	$answer = Read-Host "Option"
} until ($answer -in 1..4 -or $answer -eq 'X')

switch ($answer) {
	1 {
		Invoke-Expression -Command (Get-Content $inspectorDependencies\Inspector-ReadLogs.ps1 | Out-String)
	}
	2 {
		Invoke-Expression -Command (Get-Content $inspectorDependencies\Inspector-UninstallStrings.ps1 | Out-String)
	}
	3 {
		Invoke-Expression -Command (Get-Content $inspectorDependencies\Inspector-Startups.ps1 | Out-String)
	}
	4 {
		Invoke-Expression -Command (Get-Content $inspectorDependencies\Inspector-ClearOutput.ps1 | Out-String)
	}
	X {
		return
	}
}