. $hashtable
function Install-Programs {
	param (
		[Parameter(Mandatory=$true)]
		[System.Collections.ArrayList]$selectedInstallPrograms
	)
	
	foreach ($selectedProgram in $selectedInstallPrograms) {

		foreach ($category in $installPrograms.Keys) {
			
			if ($installPrograms[$category].Keys -contains $selectedProgram) {
				$programInfo = $installPrograms[$category][$selectedProgram]
				Write-OutputBox $selectedProgram
				
				# Try to install with winget
				if ($programInfo['winget']) {
					$process = Start-Process -FilePath 'winget' -ArgumentList "install --id $($programInfo['winget']) --accept-package-agreements --accept-source-agreements --force" -Wait -PassThru
					if ($process.ExitCode -ne 0) {
						Write-OutputBox "- Failed to install with Winget"
					} else {
						Write-OutputBox "- Installed with Winget"
						continue
					}
				}

				# If winget fails, try to install with Chocolatey
				if ($programInfo['choco']) {
					$process = Start-Process -FilePath 'choco' -ArgumentList "install $($programInfo['choco']) -y" -Wait -PassThru
					if ($process.ExitCode -ne 0) {
						Write-OutputBox "- Failed to install with Chocolatey"
					} else {
						Write-OutputBox "- Installed with Chocolatey"
						continue
					}
				}

				# If chocolatey fails, try to download and install from URL
				if ($programInfo['url']) {
					try {
						$installerPath = Join-Path $env:TEMP "$selectedProgram.exe"
						Invoke-WebRequest -Uri $programInfo['url'] -OutFile $installerPath
						Start-Process -Wait -FilePath $installerPath
						Write-OutputBox "- Installed with URL"
						continue
					} catch {
						Write-OutputBox "- Failed to install with URL"
					}
				}
				
				# If URL fails, try to download and install from mirror URL
				if ($programInfo['mirror']) {
					try {
						$installerPath = Join-Path $env:TEMP "$selectedProgram.exe"
						Invoke-WebRequest -Uri $programInfo['mirror'] -OutFile $installerPath
						Start-Process -Wait -FilePath $installerPath
						Write-OutputBox "- Installed with URL (mirror)"
						continue
					} catch {
						Write-OutputBox "- Failed to install with URL (mirror)"
					}
				}
			}
		}
	}
}