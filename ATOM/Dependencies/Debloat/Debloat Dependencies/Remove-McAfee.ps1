function Remove-McAfee {
	$mcprPath = "$($driveLetter)\Malware\Product Fixes\McAfee\MCPR.exe"
	if (Test-Path $mcprPath) {
		Write-Host "`nDetected MCPR on drive, launching..."
	}
	else {
		$url = "https://download.mcafee.com/molbin/iss-loc/SupportTools/MCPR/MCPR.exe"
		$mcprPath = "$env:TEMP\MCPR.exe"
		Write-Host "`nMCPR not detected, downloading..."
		Invoke-WebRequest $url -OutFile $mcprPath
		Write-Host "MCPR downloaded, launching..."
	}
	Get-AppxPackage 5A894077.McAfeeSecurity | Remove-AppxPackage
#	$matchingFolders | ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
	Start-Process $mcprPath
}