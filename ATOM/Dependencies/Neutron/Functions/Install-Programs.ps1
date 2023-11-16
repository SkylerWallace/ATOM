. $hashtable
function Install-Programs {
	param (
		[Parameter(Mandatory=$true)]
		[System.Collections.ArrayList]$selectedInstallPrograms
	)
	
	# Install Winget if not detected
	$wingetPath = Join-Path $env:LOCALAPPDATA "Microsoft\WindowsApps\winget.exe"
	$wingetExists = Test-Path $wingetPath
	if (!$wingetExists) {
		Write-OutputBox "Winget not detected. Installing..."
		Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
		Install-Script -Name winget-install -Force
		$wingetArgument = "-ExecutionPolicy Bypass winget-install.ps1"
		Start-Process powershell -ArgumentList $wingetArgument -Wait
		
		$wingetExists = Test-Path $wingetPath
		if ($wingetExists) {
			Write-OutputBox "- Installed Winget"
		} else {
			Write-OutputBox "- Failed to install Winget"
		}
		
		Write-OutputBox ""
	}
	
	# Install Chocolatey if not detected
	$chocoPath = Join-Path $env:PROGRAMDATA "chocolatey\choco.exe"
	$chocoExists = Test-Path $chocoPath
	if (!$chocoExists) {
		Write-OutputBox "Chocolatey not detected. Installing..."
		$chocoArgument = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
		Start-Process powershell -ArgumentList $chocoArgument -Wait
		
		$chocoExists = Test-Path $chocoPath
		if ($chocoExists) {
			Write-OutputBox "- Installed Chocolatey"
		} else {
			Write-OutputBox "- Failed to install Chocolatey"
		}
		
		Write-OutputBox ""
	}
	
	foreach ($selectedProgram in $selectedInstallPrograms) {

		foreach ($category in $installPrograms.Keys) {
			
			if ($installPrograms[$category].Keys -contains $selectedProgram) {
				$programInfo = $installPrograms[$category][$selectedProgram]
				Write-OutputBox $selectedProgram
				
				# Try to install with Winget
				if ($programInfo['winget'] -and $wingetExists) {
					$process = Start-Process -FilePath 'winget' -ArgumentList "install --id $($programInfo['winget']) --accept-package-agreements --accept-source-agreements --force" -Wait -PassThru
					if ($process.ExitCode -ne 0) {
						Write-OutputBox "- Failed to install with Winget"
					} else {
						Write-OutputBox "- Installed with Winget"
						continue
					}
				}

				# If Winget fails, try to install with Chocolatey
				if ($programInfo['choco'] -and $chocoExists) {
					$process = Start-Process -FilePath 'choco' -ArgumentList "install $($programInfo['choco']) -y" -Wait -PassThru
					if ($process.ExitCode -ne 0) {
						Write-OutputBox "- Failed to install with Chocolatey"
					} else {
						Write-OutputBox "- Installed with Chocolatey"
						continue
					}
				}

				# If Chocolatey fails, try to download and install from URL
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