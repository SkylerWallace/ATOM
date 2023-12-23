function Start-PortableProgram {
	param (
		[Parameter(Mandatory=$true)]
		[string]$programKey
	)
	
	$preAtomPath = $atomPath | Split-Path
	$programsPath = Join-Path $preAtomPath "Programs"
	$exePath = Join-Path $programsPath ($programsInfo[$programKey].ProgramFolder + "\" + $programsInfo[$programKey].ExeName)
	
	if (!(Test-Path $exePath) -and $programsInfo[$programKey].AltPath) {
		$exePath = Join-Path $preAtomPath ($programsInfo[$programKey].AltPath + "\" + $programsInfo[$programKey].AltExeName)
	}

	if (!(Test-Path $exePath)) {
		$progressPreference = 'SilentlyContinue'
		$extractionPath = Join-Path $env:TEMP $programsInfo[$programKey].ProgramFolder
		$exePath = Join-Path $extractionPath $programsInfo[$programKey].ExeName
		
		if (!(Test-Path $exePath)) {
			$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' -or $_.NetworkCategory -eq 'Private' }) -ne $null
			if (!$internetConnected) {
				Add-Type -AssemblyName PresentationFramework
				[System.Windows.MessageBox]::Show("Could not download program. `nResolve using one of two solutions: `n`n 1. Connect computer to internet `n 2. Use the ATOM Store plugin to download program for offline usage", 'ATOM Error', 'OK', 'Warning')
				return
			}
			
			if ($programsInfo[$programKey].Override -ne $null) {
				& $programsInfo[$programKey].Override
			} else {
				$downloadPath = Join-Path $env:TEMP ($programKey + ".zip")
				
				if ($programsInfo[$programKey].Credential) {
					$userName = $programsInfo[$programKey].UserName
					$credential = Get-Credential -Message "Please enter your password for $item" -UserName $userName
					$downloadURL = $programsInfo[$programKey].DownloadUrl
					Invoke-RestMethod -Uri $downloadURL -Headers @{"X-Requested-With" = "XMLHttpRequest"} -Credential $credential -OutFile $downloadPath
				} else {
					Invoke-WebRequest $programsInfo[$programKey].DownloadUrl -OutFile $downloadPath
				}
				
				Expand-Archive -Path $downloadPath -DestinationPath $extractionPath -Force
				Remove-Item -Path $downloadPath -Force
			}
		}
	}
	
	if (!$programsInfo[$programKey].ArgumentList) {
		Start-Process -FilePath "`"$exePath`""
	} else {
		$arguments = $programsInfo[$programKey].ArgumentList
		Start-Process -FilePath "`"$exePath`"" -ArgumentList $arguments
	}
}