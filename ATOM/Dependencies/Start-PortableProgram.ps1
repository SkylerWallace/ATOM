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

function Extract-With7z {
	param ([switch]$consoleExtract, [scriptblock]$scriptBlock)
	
	function Cleanup-7z {
		@($7zConsolePath, $7zInstallerPath, $7zPortablePath, $appPath) | ForEach {
			if ($_ -ne $null) { Remove-Item $_ -Recurse -Force }
		}
	}
	
	# Download app
	$url = $programsInfo.$programKey.DownloadUrl
	$appPath = Join-Path $env:TEMP $programsInfo.$programKey.ExeName
	Invoke-WebRequest $url -OutFile $appPath -UserAgent "wget"
	
	# Download 7-Zip console version
	$7zConsoleUrl = "https://www.7-zip.org/a/7zr.exe"
	$7zConsolePath = Join-Path $env:TEMP "7zr.exe"
	Invoke-WebRequest $7zConsoleUrl -OutFile $7zConsolePath
	
	# Extract app with console version if -ConsoleExtract switch used
	if ($consoleExtract) {
		$extractArgs = "`"$7zConsolePath`" x `"$appPath`" -o`"$extractionPath`" -y"
		Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
		Cleanup-7z; return
	}
	
	# Download 7-Zip exe version
	$7zInstallerUrl = $programsInfo['7-Zip'].DownloadUrl
	$7zInstallerPath = Join-Path $env:TEMP "7-Zip.exe"
	Invoke-WebRequest $7zInstallerUrl -OutFile $7zInstallerPath
	
	# Use 7z console to extract 7z exe version
	$7zPortablePath = Join-Path $env:TEMP "7-Zip"
	$extractArgs = "`"$7zConsolePath`" x `"$7zInstallerPath`" -o`"$7zPortablePath`" -y"
	Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
	
	# Extract app using 7z exe
	$7zExe = Join-Path $7zPortablePath "7z.exe"
	$extractArgs = "`"$7zExe`" x `"$appPath`" -o`"$extractionPath`" -y"
	Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
	
	# Run scriptblock if -ScriptBlock parameter is defined
	if ($scriptBlock) { Invoke-Command -ScriptBlock $scriptBlock -NoNewScope }
	
	# Cleanup
	Cleanup-7z
}