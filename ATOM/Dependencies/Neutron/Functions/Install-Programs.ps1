. $hashtable

function Install-WithPackageManager {
	param (
		[Parameter(Mandatory=$true)]
		[string]$filePath,
		[string]$arguments,
		[string]$successMessage,
		[string]$failMessage,
		[switch]$continue
	)
	
	$process = Start-Process $filePath -ArgumentList $arguments -Wait -PassThru
	if ($process.ExitCode -eq 0) {
		Write-OutputBox $successMessage
		if ($continue) { continue }
	} else {
		Write-OutputBox $failMessage
	}
}

function Install-WithUrl {
	param (
		[Parameter(Mandatory=$true)]
		[string]$installerUrl,
		[string]$successMessage,
		[string]$failMessage,
		[switch]$continue
	)
	
	$installerUrl = (winget show $programInfo["winget"] | Select-String "Installer Url").Line.Replace("Installer Url: ", "")
	$fileName = Split-Path $installerUrl -Leaf
	$extension = if ($fileName.EndsWith(".zip") -or $fileName.EndsWith(".asp")) { ".zip" }
				 elseif (!$fileName.EndsWith(".exe") -and !$fileName.EndsWith(".msi")) { ".exe" }
				 else { [System.IO.Path]::GetExtension($fileName) }
	$fileName = $selectedProgram + $extension
	$installerPath = Join-Path $env:TEMP $fileName

	try {
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
		
		Start-Process $installerPath -Wait
		Write-OutputBox $successMessage
		if ($continue) { continue }
	} catch {
		Write-OutputBox $failMessage
	}
}

function Install-PackageManagers {
	# Disable progress bar to prioritize download speeds
	$progressPreference = "SilentlyContinue"
	
	# Install Winget if not detected
	if ($useWinget -or $useWingetAlt) {
		$script:wingetExists = Get-Command -Name winget -ErrorAction SilentlyContinue
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
				$wingetInstallerPath = Join-Path $env:TEMP "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
				
				Invoke-WebRequest -Uri $wingetURL -OutFile $wingetInstallerPath
				Add-AppxPackage -Path $wingetInstallerPath
			} catch {
				Write-OutputBox "- Attempting second install method..."
				
				Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
				Install-Script -Name winget-install -Force
				$wingetArgument = "-ExecutionPolicy Bypass winget-install.ps1"
				Start-Process powershell -ArgumentList $wingetArgument -Wait
			}
			
			$script:wingetExists = Get-Command -Name winget -ErrorAction SilentlyContinue
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
		$script:chocoExists = Test-Path $chocoPath

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
			
			$script:chocoExists = Test-Path $chocoPath
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
	function Install-ScoopBuckets {
		# Install git (dependency for Scoop)
		$env:Path += ";" + [System.Environment]::GetEnvironmentVariable("Path","Machine") # Add git to path for buckets
		$gitMissing = !(Get-Command git -ErrorAction SilentlyContinue)
		if ($gitMissing) {
			# Install git w/ Scoop
			scoop install git
			
			# Test if git installed
			$gitInstalled = scoop list | Where-Object { $_.Name -contains "git" } | ForEach-Object { $true }
			if ($gitInstalled) {
				Write-OutputBox "- Git installed"
			} else {
				Write-OutputBox "- Failed to install git"
				Write-OutputBox "  Cannot install buckets"
				Write-OutputBox "  Some apps may not install"
				return
			}
		}
		
		# Adding "buckets" for Scoop
		$buckets = @("main", "extras", "games", "nonportable")
		$installedBuckets = scoop bucket list | ForEach-Object { $_.Name }
		$buckets | Where-Object { $installedBuckets -notcontains $_ } | ForEach-Object {
			scoop bucket add $_
		}
		
		# Verify all buckets were added
		$installedBuckets = scoop bucket list | ForEach-Object { $_.Name }
		$missingBuckets = $buckets | Where-Object { $installedBuckets -notcontains $_ }

		if ($missingBuckets) {
			Write-OutputBox "- Missing buckets"
			Write-OutputBox "  Some apps may not install"
		} else {
			Write-OutputBox "- All buckets installed"
		}
	}
	
	if ($useScoop) {
		# Import user path and then check for Scoop
		$env:Path += ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
		$script:scoopExists = Get-Command -Name scoop -ErrorAction SilentlyContinue
		if ($scoopExists) {
			Write-OutputBox "Scoop"
			Install-ScoopBuckets
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
			$script:scoopExists = Get-Command -Name scoop -ErrorAction SilentlyContinue
			if (!$scoopExists) {
				Write-OutputBox "- Failed to install Scoop"
			} else {
				Write-OutputBox "- Installed Scoop"
				Install-ScoopBuckets
			}
		}
		
		Write-OutputBox ""
	}
}

function Install-Programs {
	param (
		[Parameter(Mandatory=$true)]
		[System.Collections.ArrayList]$selectedInstallPrograms
	)
	
	# Install package managers with function
	Install-PackageManagers
	
	# Install all selected programs
	Write-OutputBox "Programs:"
	
	foreach ($selectedProgram in $selectedInstallPrograms) { foreach ($category in $installPrograms.Keys) {
		
		if ($installPrograms[$category].Keys -contains $selectedProgram) {
			$programInfo = $installPrograms[$category][$selectedProgram]
			Write-OutputBox "- $selectedProgram"
			
			# Try to install with Winget
			if ($programInfo["winget"] -and $wingetExists -and $useWinget) {
				$wingetArgument = "install --id $($programInfo['winget']) --accept-package-agreements --accept-source-agreements --force"
				Install-WithPackageManager winget -Argument $wingetArgument -SuccessMessage " • Installed w/ Winget" -FailMessage " • Failed to install with Winget" -Continue
			}

			# If Winget fails, try to install with Chocolatey
			if ($programInfo["choco"] -and $chocoExists  -and $script:useChoco) {
				$chocoArgument = "install $($programInfo['choco']) -y"
				Install-WithPackageManager choco -Argument $chocoArgument -SuccessMessage " • Installed w/ Chocolatey" -FailMessage " • Failed to install w/ Chocolatey" -Continue
			}
			
			# If Chocolatey fails, try to install with Scoop
			if ($programInfo["scoop"] -and $scoopExists  -and $script:useScoop) {
				$scoopArgument = "scoop install $($programInfo['scoop'])"
				Install-WithPackageManager powershell -Argument $scoopArgument -SuccessMessage " • Installed w/ Scoop" -FailMessage " • Failed to install w/ Scoop" -Continue
			}
			
			# If Scoop fails, try to use "Installer Url" from Winget (bypasses hash check)
			if ($programInfo["winget"] -and $wingetExists  -and $useWingetAlt) {
				$installerUrl = (winget show $programInfo["winget"] | Select-String "Installer Url").Line.Replace("Installer Url: ", "")
				Install-WithUrl $installerUrl -SuccessMessage " • Installed w/ Winget URL (hash bypass)" -FailMessage " • Failed to install w/ Winget URL (hash bypass)" -Continue
			}

			# If Winget Installer Url fails, try to download and install from URL
			if ($programInfo["url"] -and $useUrl) {
				$installerUrl = $programInfo["url"]
				Install-WithUrl $installerUrl -SuccessMessage " • Installed w/ URL" -FailMessage " • Failed to install w/ URL" -Continue
			}
			
			# If URL fails, try to download and install from mirror URL
			if ($programInfo["mirror"] -and $useMirror) {
				$installerUrl = $programInfo["mirror"]
				Install-WithUrl $installerUrl -SuccessMessage " • Installed w/ URL (mirror)" -FailMessage " • Failed to install w/ URL (mirror)" -Continue
			}
		}
	}}
	
	Write-OutputBox ""
}