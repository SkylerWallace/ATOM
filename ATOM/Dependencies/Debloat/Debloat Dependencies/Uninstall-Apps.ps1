function Uninstall-Apps {
	foreach ($app in $apps) {
		$appName = $app.Split("_")[1]
		$appString = $app.Split("\")[1]
		$debloatModeThreshold = $app[2]
		$installPath = "C:\Users\$env:username\AppData\Local\Packages\$appString"
		$userDataPath = "C:\Users\$env:username\AppData\Local\Packages\$($app[1])"
		if ($debloatMode -ge $debloatModeThreshold){
			if ((Test-Path -Path $installPath) -And !(Test-Path -Path $userDataPath)) {
				Get-AppxPackage $appName | Remove-AppxPackage
				if ($debloatMode -eq 1){
				Write-Host "$($app[0]) uninstalled." -ForegroundColor Cyan
				}
				if ($debloatMode -eq 2 -And $debloatModeThreshold -eq 2){
				Write-Host "$($app[0]) uninstalled." -ForegroundColor Green
				}
				if ($debloatMode -eq 3 -And $debloatModeThreshold -ge 2){
				Write-Host "$($app[0]) uninstalled." -ForegroundColor Magenta
				}  
			}
			elseif (Test-Path -Path $userDataPath) {
				Write-Host "$($app[0]) has user data, uninstall aborted." -ForegroundColor Red
			}
			else {
				Write-Host "$($app[0]) not detected." -ForegroundColor DarkGray
			}
		}
	}
}