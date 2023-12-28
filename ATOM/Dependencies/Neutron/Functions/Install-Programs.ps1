. $hashtable
function Install-Programs {
	param (
		[Parameter(Mandatory=$true)]
		[System.Collections.ArrayList]$selectedInstallPrograms
	)
	
	# Install Winget if not detected
	try { $wingetExists = winget --version } catch { $null }
	
	if (!$wingetExists) {
		Write-OutputBox "Winget not detected"
		
		try {
			Write-OutputBox "- Attempting first install method..."
			
			$wingetURL = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
			$wingetFileName = Split-Path $wingetURL -Leaf
			$wingetInstallerPath = Join-Path $env:TEMP $wingetFileName
			
			$progressPreference = 'SilentlyContinue'
			Invoke-WebRequest -Uri $wingetURL -OutFile $wingetInstallerPath
			Add-AppxPackage -Path $wingetInstallerPath
		} catch {
			Write-OutputBox "- Attempting second install method..."
			
			Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
			Install-Script -Name winget-install -Force
			$wingetArgument = "-ExecutionPolicy Bypass winget-install.ps1"
			Start-Process powershell -ArgumentList $wingetArgument -Wait
		}
		
		$wingetExists = winget --version
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
		Write-OutputBox "Chocolatey not detected"
		
		try {
			Write-OutputBox "- Attempting first install method..."
			
			$chocoArgument = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
			Start-Process powershell -ArgumentList $chocoArgument -Wait
		} catch {
			Write-OutputBox "- Attempting second install method..."
			
			$chocoArgument = "install --id Chocolatey.Chocolatey --accept-package-agreements --accept-source-agreements --force"
			Start-Process -FilePath 'winget' -ArgumentList $chocoArgument -Wait -PassThru
		}
		
		$chocoExists = Test-Path $chocoPath
		if ($chocoExists) {
			Write-OutputBox "- Installed Chocolatey"
		} else {
			Write-OutputBox "- Failed to install Chocolatey"
		}
		
		Write-OutputBox ""
	}
	
	Write-OutputBox "Programs:"
	
	foreach ($selectedProgram in $selectedInstallPrograms) {

		foreach ($category in $installPrograms.Keys) {
			
			if ($installPrograms[$category].Keys -contains $selectedProgram) {
				$programInfo = $installPrograms[$category][$selectedProgram]
				Write-OutputBox "- $selectedProgram"
				
				# Try to install with Winget
				if ($programInfo['winget'] -and $wingetExists) {
					$process = Start-Process -FilePath 'winget' -ArgumentList "install --id $($programInfo['winget']) --accept-package-agreements --accept-source-agreements --force" -Wait -PassThru
					if ($process.ExitCode -ne 0) {
						Write-OutputBox " • Failed to install with Winget"
					} else {
						Write-OutputBox " • Installed with Winget"
						continue
					}
				}

				# If Winget fails, try to install with Chocolatey
				if ($programInfo['choco'] -and $chocoExists) {
					$process = Start-Process -FilePath 'choco' -ArgumentList "install $($programInfo['choco']) -y" -Wait -PassThru
					if ($process.ExitCode -ne 0) {
						Write-OutputBox " • Failed to install with Chocolatey"
					} else {
						Write-OutputBox " • Installed with Chocolatey"
						continue
					}
				}

				# If Chocolatey fails, try to download and install from URL
				if ($programInfo['url']) {
					try {
						$fileName = Split-Path $programInfo['url'] -Leaf
						$extension = if ($fileName.EndsWith(".zip") -or $fileName.EndsWith(".asp")) { ".zip" }
									 elseif (!$fileName.EndsWith(".exe") -and !$fileName.EndsWith(".msi")) { ".exe" }
									 else { [System.IO.Path]::GetExtension($fileName) }
						$fileName = $selectedProgram + $extension
						
						$installerPath = Join-Path $env:TEMP $fileName
						
						if ($programInfo['headers']) {
							Invoke-WebRequest -Uri $programInfo['url'] -Headers $programInfo['headers'] -OutFile $installerPath
						} else {
							Invoke-WebRequest -Uri $programInfo['url'] -OutFile $installerPath
						}
						
						if ($extension -eq ".zip") {
							$destinationPath = Join-Path $env:TEMP $selectedProgram
							Expand-Archive -LiteralPath $installerPath -DestinationPath $destinationPath -Force
							$installerPath = (Get-ChildItem -Path $destinationPath -Recurse -Filter "*.exe" | Select-Object -First 1).FullName
						}
						
						Start-Process -Wait -FilePath $installerPath
						Write-OutputBox " • Installed with URL"
						continue
					} catch {
						Write-OutputBox " • Failed to install with URL"
					}
				}
				
				# If URL fails, try to download and install from mirror URL
				if ($programInfo['mirror']) {
					try {
						$fileName = Split-Path $programInfo['url'] -Leaf
						if (!$fileName.EndsWith(".exe") -and !$fileName.EndsWith(".msi")) {
							$fileName = $selectedProgram + ".exe"
						}
						
						$installerPath = Join-Path $env:TEMP $fileName
						Invoke-WebRequest -Uri $programInfo['mirror'] -OutFile $installerPath
						Start-Process -Wait -FilePath $installerPath
						Write-OutputBox " • Installed with URL (mirror)"
						continue
					} catch {
						Write-OutputBox " • Failed to install with URL (mirror)"
					}
				}
			}
		}
	}
	
	Write-OutputBox ""
}