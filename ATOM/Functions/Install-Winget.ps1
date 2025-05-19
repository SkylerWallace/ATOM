function Install-Winget {
	<#
	.SYNOPSIS
	Installs or updates Winget (Windows Package Manager) on the system.

	.DESCRIPTION
	The Install-Winget function checks if Winget is installed on the system.
	If not installed or if an update is available, it downloads and installs Winget along with its dependencies.

	.PARAMETER None
	This function does not accept parameters.

	.EXAMPLE
	Install-Winget
	Installs or updates Winget on the local system if not already present or if an update is available.

	.INPUTS
	None. This function does not accept any pipeline input.

	.OUTPUTS
	None. The function outputs status messages to the console.

	.NOTES
	Author: Skyler Wallace
	Requires: 
	- Requires administrative privileges to install or update Winget.
	- Internet connectivity is required for downloading Winget and its dependencies.

	.LINK
	For more information about installing Winget, visit:
	https://docs.microsoft.com/en-us/windows/package-manager/winget/
	#>

	$wingetPath = Get-Command winget | Select-Object -Expand Source
	[version]$currentWingetVersion = (cmd /c $wingetPath --version).Trim('v')
	[version]$latestWingetVersion = (Invoke-RestMethod -Uri 'https://api.github.com/repos/microsoft/Winget-cli/releases/latest' -Method Get -UseBasicParsing).tag_name.Trim('v')

	Write-Host "Winget $currentWingetVersion"

	if (!$wingetPath -or ($currentWingetVersion -lt $latestWingetVersion)) {
		Write-Host "- Updating to $latestWingetVersion"
		$wingetInstall = Start-Process $wingetPath -ArgumentList 'install --id Microsoft.AppInstaller --accept-source-agreements --accept-package-agreements' -Wait -PassThru

		if ($wingetInstall.ExitCode -eq 0) {
			Write-Host '- Success'
		} else {
			Write-Host '- Failure'
			Write-Host "- ExitCode: $($wingetInstall.ExitCode)"
		}
	}
	
	Write-Host ''
}