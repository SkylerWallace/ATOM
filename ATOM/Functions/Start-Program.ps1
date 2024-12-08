function Start-Program {
	param ($program, [switch]$start)

	# Import functions
	. $psScriptRoot\Expand-With7z.ps1

	if ($start) {
		$atomPath = $psScriptRoot | Split-Path
		$dependenciesPath = "$atomPath\Dependencies"
		. $atomPath\Config\ProgramsParams.ps1
	}

	$preAtomPath = $atomPath | Split-Path
	$programsPath = "$preAtomPath\Programs"
	$config = $programsInfo[$program]

	# Set potential exe paths: 1. Downloaded from ATOM Store 2. Alternate path (defined by hashtable) 3. Temp-downloaded plugin
	$localExePath = Join-Path $programsPath (Join-Path $config.ProgramFolder $config.ExeName)
	$altExePath = if ($config.AltExeName) { Join-Path $preAtomPath (Join-Path $config.AltPath $config.AltExeName) }
	$tempExePath = Join-Path $env:TEMP (Join-Path $config.ProgramFolder $config.ExeName)

	# Set exePath depending on where the program's exe is detected
	$exePath =
		if (!$start -or (Test-Path $localExePath))			{ $localExePath }
		elseif ($altExePath -and (Test-Path $altExePath))	{ $altExePath }
		else												{ $tempExePath }

	# Download logic
	if (!$start -or (($exePath -eq $tempExePath) -and !(Test-Path $exePath))) {
		# Display error message if no internet connection
		$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet' }) -ne $null
		if (!$internetConnected) {
			Add-Type -AssemblyName PresentationFramework
			[System.Windows.MessageBox]::Show("Could not download program. `nResolve using one of two solutions: `n`n 1. Connect computer to internet `n 2. Use the ATOM Store plugin to download program for offline usage", 'ATOM Error', 'OK', 'Warning')
			return
		}
		
		$progressPreference = "SilentlyContinue" # Disable progress bar to prioritize download speed
		$extractionPath = 
			if ($start)	{ Join-Path $env:TEMP $config.ProgramFolder }
			else		{ Join-Path $programsPath $programsInfo[$program].ProgramFolder }
		
		# Download using override scriptblock if specified by hashtable
		if ($config.Override -ne $null) {
			& $config.Override
		# Else use standard download logic
		} else {
			# Configure download parameters
			$downloadPath = Join-Path $env:TEMP ($program + ".zip")
			$downloadParams = @{ Uri = $config.DownloadUrl; OutFile = $downloadPath; UserAgent = 'wget' }
			
			# If program requires credentials, add additional download parameters
			if ($config.Credential) {
				$userName = $config.UserName
				$credential = Get-Credential -Message "Please enter your password for $item" -UserName $userName
				$downloadParams += @{Headers = @{"X-Requested-With" = "XMLHttpRequest"}; Credential = $credential}
			}
			
			# Download program
			Invoke-WebRequest @downloadParams
			
			# Extract zip and cleanup
			Expand-Archive -Path $downloadPath -DestinationPath $extractionPath -Force
			Remove-Item -Path $downloadPath -Force
		}
	}

	# Run post-installation logic if specified by hashtable key
	if ($config.PostInstall -ne $null) {
		& $config.PostInstall
	}

	# If -Start param used, run program
	if ($start) {
		$launchParams = @{ FilePath = "`"$exePath`"" }

		if ($config.ArgumentList) {
			$launchParams += @{ ArgumentList = $config.ArgumentList }
		}

		Start-Process @launchParams
	}
}