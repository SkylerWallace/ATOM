function Uninstall-Apps {
	if ($selectedApps) {
		Write-OutputBox "AppX Bloatware"
		
		foreach ($app in $selectedApps) {
			Write-OutputBox "- Uninstalling $app"
			Get-AppxPackage -Name $apps[$app]['PackageName'] | Remove-AppxPackage
		}
		
		Write-OutputBox ""
	}
}