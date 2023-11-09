while ($true) {
	Clear-Host
	Write-InspectorHeader
	
	Write-Host "Enter the name of the program or press 'X' to exit."
	$programName = Read-Host "Input"
	
	if ($programName -eq 'x') {
		return
	}
	
	$uninstallKeys = @(
		"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
		"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
		"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
	)

	$results = Get-ChildItem $uninstallKeys | ForEach-Object {
		Get-ItemProperty $_.PSPath | Where-Object {
			$_.DisplayName -like "*$programName*"
		} | Select-Object DisplayName, UninstallString, @{Name='RegistryPath';Expression={$_.PSPath -replace 'Microsoft\.PowerShell\.Core\\Registry::', '' -replace 'HKEY_LOCAL_MACHINE', 'HKLM:' -replace 'HKEY_CURRENT_USER', 'HKCU:'}}
	}

	Write-Host "Results:"
	$results | Format-Table -AutoSize | Out-String -Width ([int]::MaxValue)

	Write-Host "Output results to file?"
	do { $answer = Read-Host "[Y] Yes [N] No" } until ($answer -match "^(y|n)$")
	if ($answer -eq "y") {
		$filePath = "$inspectorOutput\$programName.txt"
		$results | Out-File $filePath -Width ([int]::MaxValue)
		Write-Host "Results saved to $filePath `n" -ForegroundColor Green
		Read-Host "Press 'Enter' to continue"
	}
}
