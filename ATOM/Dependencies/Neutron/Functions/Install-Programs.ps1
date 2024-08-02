. $hashtable

function Update-ProgressBar {
	param ($installerPath, $fileSizeMb)
	
	do {
		Start-Sleep -Milliseconds 1000
		$downloadedMb = [math]::Round((Get-Item $installerPath).Length / 1MB, 2)
		$percentComplete = [int]($downloadedMb * 100 / $fileSizeMb)
		Invoke-Ui {
			$progressBarText.Text = "$selectedProgram | $percentComplete % | $downloadedMb / $fileSizeMb MB"
			$progressBar.Value = $percentComplete
		}
	} until (($percentComplete -ge 100) -or ($downloadJob.State -ne "Running") -or !(Test-Path $installerPath))
}

function Install-WithPackageManager {
	param ($filePath, $arguments, $successMessage, $failMessage)
	
	# Set installation parameters
	$installParams = @{ FilePath = $filePath; ArgumentList = $arguments; Wait = $true; PassThru = $true }
	if ($programInfo.NoAdmin) {
		$batFile = Join-Path $env:TEMP "${selectedProgram}.bat"
		
		Set-Content -Force -Path $batFile -Value $(
			if ($filePath -eq 'winget')			{ "winget install --id $($programInfo.Winget) --accept-package-agreements --accept-source-agreements --force" }
			elseif ($filePath -eq 'choco')		{ "choco install $($programInfo.Choco) -y" }
			elseif ($filePath -eq 'powershell')	{ "scoop install $($programInfo.Scoop)" })
		
		$installParams.FilePath = explorer
		$installParams.ArgumentList = $batFile
	}
	
	# Download installer in background job
	$downloadJob = Start-Job -ScriptBlock {
		param ($installParams)
		$process = Start-Process @installParams
		return $process.ExitCode
	} -ArgumentList $installParams
	
	if ($filePath -eq 'winget') {
		# Get download file size, use installer url string
		$url = ((winget show $programInfo.Winget) | Select-String "Installer Url").Line.Replace("Installer Url: ", "").Trim()
		$fileSizeMb = [math]::Round((Invoke-WebRequest -Uri $url -Method Head).Headers."Content-Length" / 1MB, 2)
		
		# Search for parent path
		do { $parentPath = Get-ChildItem (Join-Path $env:TEMP Winget) -Filter "$($programInfo.Winget)*" | Select -Expand FullName }
		until ($parentPath -or $downloadJob.State -ne "Running")
		
		# Search for temp file
		do { $tmpPath = Get-ChildItem $parentPath -Filter *.tmp -Recurse | Select -Expand FullName -First 1 }
		until ($tmpPath -or $downloadJob.State -ne "Running")

		Update-ProgressBar -InstallerPath $tmpPath -FileSizeMb $fileSizeMb
	} elseif ($filePath -eq 'choco') {
		# PLACEHOLDER FOR CHOCOLATEY
	} elseif ($filePath -eq 'powershell') {
		# Get download file size, use json from scoop bucket
		$manifest = Get-Content (scoop info $programInfo.Scoop --verbose).Manifest -Raw | ConvertFrom-Json
		$url = $manifest.architecture.'64bit'.url
		if ($url -eq $null) { $url = $manifest.architecture.'32bit'.url }
		$fileSizeMb = [math]::Round((Invoke-WebRequest -Uri $url -Method Head).Headers."Content-Length" / 1MB, 2)

		$scoopPath = Join-Path (scoop config).root_path 'cache'
		do { $tmpPath = Get-ChildItem $scoopPath -Filter "$($programInfo.Scoop)*" | Select -Expand FullName -First 1 }
		until ($tmpPath -or $downloadJob.State -ne "Running")
		
		Update-ProgressBar -InstallerPath $tmpPath -FileSizeMb $fileSizeMb
	} elseif ($filePath -eq 'explorer') {
		# PLACEHOLDER FOR NON-ADMIN
	}
	
	Invoke-Ui { $progressBarText.Text = "$selectedProgram - Installing" }
	$exitCode = Wait-Job $downloadJob | Receive-Job
	
	# Output results
	Invoke-Ui { $progressBarText.Text = ""; $progressBar.Value = 0 }
	if (($exitCode -eq 0) -or ($exitCode -eq 1)) {
		Write-OutputBox $successMessage
		continue
	} else {
		Write-OutputBox $failMessage
	}
}

function Install-WithUrl {
	param ($installerUrl, $successMessage, $failMessage)
	
	$extension = [System.IO.Path]::GetExtension($installerUrl)
	$supportedExtensions = '.exe', '.msi', '.zip'
	$installerPath = Join-Path $env:TEMP $(
		if ($extension -in $supportedExtensions)	{ Split-Path $installerUrl -Leaf }
		elseif ($extension -eq '.asp')				{ $selectedProgram + '.zip' }
		else										{ $selectedProgram + '.exe' })
	
	# Delete existing installerPath if detected
	if (Test-Path $installerPath) {
		Remove-Item $installerPath -Recurse -Force
	}
	
	# Set download parameters for Invoke-WebRequest
	$downloadParams = @{ Uri = $installerUrl; OutFile = $installerPath }
	if ($programInfo.Headers) {
		$downloadParams.Headers = $programInfo.Headers
	}
	
	# Get file size of installer in MB
	$fileSizeMb = [math]::Round((Invoke-WebRequest -Uri $downloadParams.Uri -Method Head).Headers."Content-Length" / 1MB, 2)
	
	# Download installer in background job
	$downloadJob = Start-Job -ScriptBlock {
		param ($downloadParams)
		Invoke-WebRequest @downloadParams
	} -ArgumentList $downloadParams
	
	# Display download progress
	Update-ProgressBar -InstallerPath $installerPath -FileSizeMb $fileSizeMb
	
	# Early return: download job failed
	if ($downloadJob.State -eq "Failed") {
		Invoke-Ui { $progressBarText.Text = ""; $progressBar.Value = 0 }
		Write-OutputBox " • Failed to download"
		return
	}
	
	# Extract if installer is in zip
	if ($extension -eq '.zip') {
		Invoke-Ui { $progressBarText.Text = "$selectedProgram | Extracting"}
		$destinationPath = Join-Path $env:TEMP $selectedProgram
		Expand-Archive -LiteralPath $installerPath -DestinationPath $destinationPath -Force
		$installerPath = (Get-ChildItem -Path $destinationPath -Recurse -Filter "*.exe" | Select-Object -First 1).FullName
	}
	
	# Set installation parameters
	$installParams = @{ FilePath = $installerPath; Wait = $true; PassThru = $true }
	if ($programInfo.NoAdmin) {
		$installParams.FilePath = 'explorer'
		$installParams.ArgumentList = $installerPath
	}
	
	# Run installer
	Invoke-Ui { $progressBarText.Text = "$selectedProgram | Installing"}
	$process = Start-Process @installParams
	
	# Output results
	Invoke-Ui { $progressBarText.Text = ""; $progressBar.Value = 0 }
	if ($process.ExitCode -eq 0) { Write-OutputBox $successMessage; continue }
	else { Write-OutputBox $failMessage }
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
			if ($programInfo.Winget -and $wingetExists -and $useWinget) {
				$wingetArgument = "install --id $($programInfo.Winget) --accept-package-agreements --accept-source-agreements --force"
				Install-WithPackageManager winget -Argument $wingetArgument -SuccessMessage " • Installed w/ Winget" -FailMessage " • Failed to install with Winget"
			}

			# If Winget fails, try to install with Chocolatey
			if ($programInfo.Choco -and $chocoExists  -and $script:useChoco) {
				$chocoArgument = "install $($programInfo.Choco) -y"
				Install-WithPackageManager choco -Argument $chocoArgument -SuccessMessage " • Installed w/ Chocolatey" -FailMessage " • Failed to install w/ Chocolatey"
			}
			
			# If Chocolatey fails, try to install with Scoop
			if ($programInfo.Scoop -and $scoopExists  -and $script:useScoop) {
				$scoopArgument = "scoop install $($programInfo.Scoop)"
				Install-WithPackageManager powershell -Argument $scoopArgument -SuccessMessage " • Installed w/ Scoop" -FailMessage " • Failed to install w/ Scoop"
			}
			
			# If Scoop fails, try to use "Installer Url" from Winget (bypasses hash check)
			if ($programInfo.Winget -and $wingetExists  -and $useWingetAlt) {
				$installerUrl = (winget show $programInfo.Winget | Select-String "Installer Url").Line.Replace("Installer Url: ", "").Trim()
				Install-WithUrl $installerUrl -SuccessMessage " • Installed w/ Winget URL (hash bypass)" -FailMessage " • Failed to install w/ Winget URL (hash bypass)"
			}

			# If Winget Installer Url fails, try to download and install from URL
			if ($programInfo.Url -and $useUrl) {
				$installerUrl = $programInfo.Url
				Install-WithUrl $installerUrl -SuccessMessage " • Installed w/ URL" -FailMessage " • Failed to install w/ URL"
			}
			
			# If URL fails, try to download and install from mirror URL
			if ($programInfo.Mirror -and $useMirror) {
				$installerUrl = $programInfo.Mirror
				Install-WithUrl $installerUrl -SuccessMessage " • Installed w/ URL (mirror)" -FailMessage " • Failed to install w/ URL (mirror)"
			}
		}
	}}
	
	Write-OutputBox ""
}