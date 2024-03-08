. $hashtable

function Install-Programs {
	param (
		[Parameter(Mandatory=$true)]
		[System.Collections.ArrayList]$selectedInstallPrograms
	)
	
	# Disable progress bar to prioritize download speeds
	$progressPreference = "SilentlyContinue"
	
	# Install Winget if not detected
	if ($useWinget -or $useWingetAlt) {
		$wingetExists = Get-Command -Name winget -ErrorAction SilentlyContinue
		if ($wingetExists) {
			$wingetVersion = [System.Version]::Parse((winget --version).Trim("v"))
			$minimumWingetVersion = [System.Version]::new(1,2,10691) # Win 11 23H2 comes with bad winget v1.2.10691
			$wingetOutdated = $wingetVersion -le $minimumWingetVersion
			
			Write-OutputBox "Winget v$wingetVersion"
		}
		
		if (!$wingetExists -or $wingetOutdated) {
			if (!$wingetExists) {
				Write-OutputBox "Winget not detected"
			} else {
				Write-OutputBox "- Winget out-dated"
			}
			
			try {
				Write-OutputBox "- Attempting first install method..."
				
				$wingetURL = "https://aka.ms/getwinget"
				$altWingetURL = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
				$wingetFileName = Split-Path $wingetURL -Leaf
				$wingetInstallerPath = Join-Path $env:TEMP $wingetFileName
				
				Invoke-WebRequest -Uri $wingetURL -OutFile $wingetInstallerPath
				Add-AppxPackage -Path $wingetInstallerPath
			} catch {
				Write-OutputBox "- Attempting second install method..."
				
				Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
				Install-Script -Name winget-install -Force
				$wingetArgument = "-ExecutionPolicy Bypass winget-install.ps1"
				Start-Process powershell -ArgumentList $wingetArgument -Wait
			}
			
			$wingetExists = Get-Command -Name winget -ErrorAction SilentlyContinue
			if ($wingetExists) {
				$wingetVersion = [System.Version]::Parse((winget --version).Trim("v"))
				Write-OutputBox "- Installed Winget v$wingetVersion"
			} else {
				Write-OutputBox "- Failed to install Winget"
			}
		}
		Write-OutputBox ""
	}
	
	# Install Chocolatey if not detected
	if ($useChoco) {
		$chocoPath = Join-Path $env:PROGRAMDATA "chocolatey\choco.exe"
		$chocoExists = Test-Path $chocoPath

		if ($chocoExists) {
			$chocoVersion = [System.Version]::Parse((choco --version))
			Write-OutputBox "Chocolatey v$chocoVersion"
		}
		
		if (!$chocoExists) {
			Write-OutputBox "Chocolatey not detected"
			
			try {
				Write-OutputBox "- Attempting first install method..."
				
				$chocoArgument = "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
				Start-Process powershell -ArgumentList $chocoArgument -Wait
			} catch {
				Write-OutputBox "- Attempting second install method..."
				
				$chocoArgument = "install --id Chocolatey.Chocolatey --accept-package-agreements --accept-source-agreements --force"
				Start-Process winget -ArgumentList $chocoArgument -Wait -PassThru
			}
			
			$chocoExists = Test-Path $chocoPath
			if ($chocoExists) {
				$chocoVersion = [System.Version]::Parse((choco --version))
				Write-OutputBox "- Installed Chocolatey v$chocoVersion"
			} else {
				Write-OutputBox "- Failed to install Chocolatey"
			}
		}
		Write-OutputBox ""
	}
	
	# Install Scoop if not detected
	if ($useScoop) {
		# Import user path and then check for Scoop
		$env:Path += ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
		$scoopExists = Get-Command -Name scoop -ErrorAction SilentlyContinue
		if ($scoopExists) {
			Write-OutputBox "Scoop"
		}
		
		if (!$scoopExists) {
			Write-OutputBox "Scoop not detected"
			
			# Download Scoop
			$scriptPath = Join-Path $env:TEMP "install.ps1"
			try {
				Invoke-WebRequest -Uri "https://get.scoop.sh" -OutFile $scriptPath
				powershell $scriptPath -RunAsAdmin
				$env:Path += ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
			} catch {
				Write-OutputBox "- Failed to download Scoop"
			}
			
			# Check if Scoop installed
			$scoopExists = Get-Command -Name scoop -ErrorAction SilentlyContinue
			if (!$scoopExists) {
				Write-OutputBox "- Failed to install Scoop"
			} else {
				Write-OutputBox "- Installed Scoop"
				
				$process = Start-Process powershell "scoop bucket add extras; scoop bucket add games; scoop bucket add nonportable" -Wait -PassThru
				if ($process.ExitCode -eq 0) {
					Write-OutputBox "- Installed extras, games, and `n  nonportable buckets"
				} else {
					Write-OutputBox "- Issue installing extra Scoop buckets"
					Write-OutputBox "- Some apps may not install via Scoop"
				}
			}
		}
		
		Write-OutputBox ""
	}
	
	# Install all selected programs
	Write-OutputBox "Programs:"
	
	foreach ($selectedProgram in $selectedInstallPrograms) {

		foreach ($category in $installPrograms.Keys) {
			
			if ($installPrograms[$category].Keys -contains $selectedProgram) {
				$programInfo = $installPrograms[$category][$selectedProgram]
				Write-OutputBox "- $selectedProgram"
				
				# Try to install with Winget
				if ($programInfo["winget"] -and $wingetExists -and $useWinget) {
					$process = Start-Process winget -ArgumentList "install --id $($programInfo['winget']) --accept-package-agreements --accept-source-agreements --force" -Wait -PassThru
					if ($process.ExitCode -eq 0) {
						Write-OutputBox " • Installed w/ Winget"
						continue
					}
					
					Write-OutputBox " • Failed to install with Winget"
				}

				# If Winget fails, try to install with Chocolatey
				if ($programInfo["choco"] -and $chocoExists  -and $script:useChoco) {
					$process = Start-Process choco -ArgumentList "install $($programInfo['choco']) -y" -Wait -PassThru
					if ($process.ExitCode -eq 0) {
						Write-OutputBox " • Installed w/ Chocolatey"
						continue
					} else {
						Write-OutputBox " • Failed to install w/ Chocolatey"
					}
				}
				
				# If Chocolatey fails, try to install with Scoop
				if ($programInfo["scoop"] -and $scoopExists  -and $script:useScoop) {
					$process = Start-Process powershell -ArgumentList "scoop install $($programInfo['scoop'])" -Wait -PassThru
					if ($process.ExitCode -eq 0) {
						Write-OutputBox " • Installed w/ Scoop"
						continue
					} else {
						Write-OutputBox " • Failed to install w/ Scoop"
					}
				}
				
				# If Scoop fails, try to use "Installer Url" from Winget (bypasses hash check)
				if ($programInfo["winget"] -and $wingetExists  -and $useWingetAlt) {
					$installerUrl = (winget show $programInfo["winget"] | Select-String "Installer Url").Line.Replace("Installer Url: ", "")
					$fileName = Split-Path $installerUrl -Leaf
					$extension = if ($fileName.EndsWith(".zip") -or $fileName.EndsWith(".asp")) { ".zip" }
								 elseif (!$fileName.EndsWith(".exe") -and !$fileName.EndsWith(".msi")) { ".exe" }
								 else { [System.IO.Path]::GetExtension($fileName) }
					$fileName = $selectedProgram + $extension
					$installerPath = Join-Path $env:TEMP $fileName
					
					try {
						$installerUrl = (winget show $programInfo["winget"] | Select-String "Installer Url").Line.Replace("Installer Url: ", "")
						
						if ($programInfo["headers"]) {
							Invoke-WebRequest -Uri $installerUrl -Headers $programInfo["headers"] -OutFile $installerPath
						} else {
							Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
						}
						
						if ($extension -eq ".zip") {
							$destinationPath = Join-Path $env:TEMP $selectedProgram
							Expand-Archive -LiteralPath $installerPath -DestinationPath $destinationPath -Force
							$installerPath = (Get-ChildItem -Path $destinationPath -Recurse -Filter "*.exe" | Select-Object -First 1).FullName
						}
						
						Start-Process -Wait -FilePath $installerPath
						Write-OutputBox " • Installed w/ Winget URL (hash bypass)"
						continue
					} catch {
						Write-OutputBox " • Failed to install w/ Winget URL (hash bypass)"
					}
				}

				# If Winget Installer Url fails, try to download and install from URL
				if ($programInfo["url"] -and $useUrl) {
					$fileName = Split-Path $programInfo["url"] -Leaf
					$extension = if ($fileName.EndsWith(".zip") -or $fileName.EndsWith(".asp")) { ".zip" }
								 elseif (!$fileName.EndsWith(".exe") -and !$fileName.EndsWith(".msi")) { ".exe" }
								 else { [System.IO.Path]::GetExtension($fileName) }
					$fileName = $selectedProgram + $extension
					$installerPath = Join-Path $env:TEMP $fileName
					
					try {						
						if ($programInfo["headers"]) {
							Invoke-WebRequest -Uri $programInfo["url"] -Headers $programInfo["headers"] -OutFile $installerPath
						} else {
							Invoke-WebRequest -Uri $programInfo["url"] -OutFile $installerPath
						}
						
						if ($extension -eq ".zip") {
							$destinationPath = Join-Path $env:TEMP $selectedProgram
							Expand-Archive -LiteralPath $installerPath -DestinationPath $destinationPath -Force
							$installerPath = (Get-ChildItem -Path $destinationPath -Recurse -Filter "*.exe" | Select-Object -First 1).FullName
						}
						
						Start-Process -Wait -FilePath $installerPath
						Write-OutputBox " • Installed w/ URL"
						continue
					} catch {
						Write-OutputBox " • Failed to install w/ URL"
					}
				}
				
				# If URL fails, try to download and install from mirror URL
				if ($programInfo["mirror"] -and $useMirror) {
					try {
						$fileName = Split-Path $programInfo["url"] -Leaf
						if (!$fileName.EndsWith(".exe") -and !$fileName.EndsWith(".msi")) {
							$fileName = $selectedProgram + ".exe"
						}
						
						$installerPath = Join-Path $env:TEMP $fileName
						Invoke-WebRequest -Uri $programInfo["mirror"] -OutFile $installerPath
						Start-Process -Wait -FilePath $installerPath
						Write-OutputBox " • Installed w/ URL (mirror)"
						continue
					} catch {
						Write-OutputBox " • Failed to install w/ URL (mirror)"
					}
				}
			}
		}
	}
	
	Write-OutputBox ""
}