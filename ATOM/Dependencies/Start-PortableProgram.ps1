function Start-PortableProgram {
	param ($programKey)
	
	$preAtomPath = $atomPath | Split-Path
	$programsPath = Join-Path $preAtomPath "Programs"
	$config = $programsInfo[$programKey]
	
	# Set potential exe paths: 1. Downloaded from ATOM Store 2. Alternate path (defined by hashtable) 3. Temp-downloaded plugin
	$localExePath = Join-Path $programsPath (Join-Path $config.ProgramFolder $config.ExeName)
	$altExePath = if ($config.AltExeName) { Join-Path $preAtomPath (Join-Path $config.AltPath $config.AltExeName) }
	$tempExePath = Join-Path $env:TEMP (Join-Path $config.ProgramFolder $config.ExeName)
	
	# Set exePath depending on where the program's exe is detected
	$exePath =
		if (Test-Path $localExePath)						{ $localExePath }
		elseif ($altExePath -and (Test-Path $altExePath))	{ $altExePath }
		else												{ $tempExePath }
	
	# Download program if not detected
	if (($exePath -eq $tempExePath) -and !(Test-Path $exePath)) {
		# Display error message if no internet connection
		$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet' }) -ne $null
		if (!$internetConnected) {
			Add-Type -AssemblyName PresentationFramework
			[System.Windows.MessageBox]::Show("Could not download program. `nResolve using one of two solutions: `n`n 1. Connect computer to internet `n 2. Use the ATOM Store plugin to download program for offline usage", 'ATOM Error', 'OK', 'Warning')
			return
		}
		
		$progressPreference = "SilentlyContinue" # Disable progress bar to prioritize download speed
		$extractionPath = Join-Path $env:TEMP $config.ProgramFolder
		
		# Download using override scriptblock if specified by hashtable
		if ($config.Override -ne $null) {
			& $config.Override
		# Else use standard download logic
		} else {
			# Configure download parameters
			$downloadPath = Join-Path $env:TEMP ($programKey + ".zip")
			$downloadParams = @{Uri = $config.DownloadUrl; OutFile = $downloadPath }
			
			# If program requires credentials, add additional download parameters
			if ($config.Credential) {
				$userName = $config.UserName
				$credential = Get-Credential -Message "Please enter your password for $item" -UserName $userName
				$downloadParams += @{Headers = @{"X-Requested-With" = "XMLHttpRequest"}; Credential = $credential}
			}
			
			# Download program
			Invoke-RestMethod @downloadParams
			
			# Extract zip and cleanup
			Expand-Archive -Path $downloadPath -DestinationPath $extractionPath -Force
			Remove-Item -Path $downloadPath -Force
		}
		
		# Run post-installation logic if specified by hashtable key
		if ($config.PostInstall -ne $null) {
			& $config.PostInstall
		}
	}
	
	# Configure launch params and run program
	$launchParams = @{ FilePath = "`"$exePath`"" }
	
	if ($config.ArgumentList) {
		$launchParams += @{ ArgumentList = $config.ArgumentList }
	}
	
	Start-Process @launchParams
}