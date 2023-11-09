<#

- ProgramFolder
	Name of programs folder within ATOM's Programs folder.
	If ProgramFolder = 'ExampleProgram', the location is 
	in './Programs/ExampleProgram'.
- ExeName
	Name of the executable within ProgramFolder.
	If ExeName = 'ExampleExe.exe', the location is
	'./Programs/ExampleProgram/ExampleExe.exe'.
- AltPath
	If Start-PortablePrograms does not detect the defined
	ProgramFolder path, it will check the AltPath. Does
	not need to be defined.
- AltExeName
	Name of the executable in AltPath if AltPath is
	defined.
- DownloadUrl
	URL to download program.
	Ex: 'DownloadUrl' = 'https://www.website.net/download.zip'
- Override
	If defined, will override default downloading procedures
	in Start-PortablePrograms & Install-PortablePrograms.
	Ex: 'Override' = { iwr -url $url -outFile $downloadPath }
	IMPORTANT: preAtomPath, programsPath, exePath, extractionPath,
	and exePath variables are inherited.
- Credential
	If download URL requires a username and/or password, this
	parameter must be defined and set to $true.
	Ex: 'Credential' = $true
- UserName
	If Credential is defined and set to $true, this will
	auto-fill the username. If undefined, username will
	not be auto-filled.
	Ex: 'UserName' = abc123
- ArgumentList
	If defined, will arguments with the program's exe if
	called by Start-PortablePrograms.
	Ex: 'ArgumentList' = '/silent'
- PostInstall
	If defined, will run the contents of PostInstall after
	program has been installed.
	Ex: 'PostInstall' = { Remove-Item -Path $removeMe }

#>

$programsInfo = [ordered]@{
	
	'7-Zip' 			= @{
		'ProgramFolder'	= '7-Zip'
		'ExeName'		= '7zFM.exe'
		'Override'		= {
			$downloadPath0 = Join-Path $env:TEMP "7zr.exe"
			$downloadPath = Join-Path $env:TEMP "7-Zip.exe"
			$url0 = "https://www.7-zip.org/a/7zr.exe"
			$url = "https://www.7-zip.org/a/7z2301-x64.exe"

			# Download 7-Zip console version
			Invoke-WebRequest $url0 -OutFile $downloadPath0

			# Download 7-Zip exe version & use console version to extract portable files
			Invoke-WebRequest $url -OutFile $downloadPath

			if ($calledFromStartPortableProgram) {
				$installFolder = Join-Path $env:TEMP $programsInfo[$programKey].ProgramFolder

			} else {
				$installFolder = Join-Path $programsPath $programsInfo[$programKey].ProgramFolder
			}

			$extract = "`"$downloadPath0`" x `"$downloadPath`" -o`"$installFolder`" -y"
			Start-Process cmd.exe -ArgumentList "/c `"$extract`"" -Wait
			Remove-Item -Path $downloadPath -Force
			Remove-Item -Path $downloadPath0 -Force
		}
	}
		
	'Autoruns' 			= @{
		'ProgramFolder'	= 'Autoruns'
		'ExeName'		= 'Autoruns.exe'
		'DownloadUrl'	= 'https://download.sysinternals.com/files/Autoruns.zip'
	}

	'BlueScreenView'	= @{
		'ProgramFolder'	= 'BlueScreenView'
		'ExeName'		= 'BlueScreenView.exe'
		'DownloadUrl'	='https://www.nirsoft.net/utils/bluescreenview-x64.zip'
	}

	'CPU-Z'				= @{
		'ProgramFolder'	= 'CPU-Z'
		'ExeName'		= 'cpuz_x64.exe'
		'DownloadUrl'	= 'https://download.cpuid.com/cpu-z/cpu-z_2.08-en.zip'
	}
	
	'CrystalDiskInfo'	= @{
		'ProgramFolder'	= 'CrystalDiskInfo'
		'ExeName'		= 'DiskInfo64.exe'
		'DownloadUrl'	= 'https://crystalmark.info/download/zz/CrystalDiskInfo9_1_1.zip'
	}

	'CrystalDiskMark'	= @{
		'ProgramFolder'	= 'CrystalDiskMark'
		'ExeName'		= 'DiskMark64.exe'
		'DownloadUrl'	= 'https://crystalmark.info/download/zz/CrystalDiskMark8_0_4c.zip'
	}

	'HWMonitor'			= @{
		'ProgramFolder'	= 'HWMonitor'
		'ExeName'		= 'HWMonitor_x64.exe'
		'DownloadUrl'	= 'https://download.cpuid.com/hwmonitor/hwmonitor_1.52.zip'
	}
	
	'McAfee Stinger'	= @{
		'ProgramFolder'	= 'McAfee Stinger'
		'ExeName'		= 'stinger32.exe'
		'DownloadUrl'	= 'https://downloadcenter.trellix.com/products/mcafee-avert/Stinger/stinger32.exe'
		'Override'		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo[$programKey].DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo[$programKey].ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'MSI Kombustor'		= @{
		'ProgramFolder'	= 'MSI Kombustor'
		'ExeName'		= 'MSI-Kombustor-x64.exe'
		'DownloadUrl'	= 'https://www.geeks3d.com/dl/get/725'
		'Override'		= {
			$url = $programsInfo[$programKey].DownloadUrl
			$downloadPath = Join-Path $env:TEMP "KombustorSetup.exe"
			
			Invoke-WebRequest $url -OutFile $downloadPath
			
			$process = Start-Process -FilePath $downloadPath -ArgumentList "/VERYSILENT /DIR=`"$extractionPath`" /NOICONS /NORESTART" -PassThru
			$process.WaitForExit()
			
			$desktopFile = Join-Path -Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)) -ChildPath "MSI Kombustor 4 x64.lnk"
			Remove-Item -Path $desktopFile
			Remove-Item -Path $downloadPath -Force
			Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{F3D3CC6B-9AD7-4F43-8C69-40D5902FDC5C}}_is1"
		}
	}
	
	'Norton Power Eraser' = @{
		'ProgramFolder'	= 'Norton Power Eraser'
		'ExeName'		= 'NPE.exe'
		'DownloadUrl'	= 'https://www.norton.com/npe_latest'
		'Override'		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo[$programKey].DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo[$programKey].ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'Notepad++'			= @{
		'ProgramFolder'	= 'Notepad++'
		'ExeName'		= 'notepad++.exe'
		'DownloadUrl'	= 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.8/npp.8.5.8.portable.x64.zip'
	}
	
	'Opera'				= @{
		'ProgramFolder'	= 'Opera'
		'ExeName'		= 'Opera.exe'
		'DownloadUrl'	= 'https://net.geo.opera.com/opera_portable/stable/windows?utm_tryagain=yes&utm_source=google&utm_medium=ose&utm_campaign=(none)&http_referrer=https%3A%2F%2Fwww.google.com%2F&utm_site=opera_com&'
		'Override'		= {
			$url = $programsInfo[$programKey].DownloadUrl
			$downloadPath = Join-Path $env:TEMP "OperaSetup.exe"
			
			Invoke-WebRequest $url -OutFile $downloadPath
			
			$process = Start-Process -FilePath $downloadPath -ArgumentList "/silent /installfolder=`"$extractionPath`" /launchbrowser=0" -PassThru
			$process.WaitForExit()
			
			Remove-Item -Path $downloadPath -Force
		}
	}

	'PowerShell Core'	= @{
		'ProgramFolder'	= 'PowerShell Core_x64'
		'ExeName'		= 'pwsh.exe'
		'DownloadUrl'	= 'https://github.com/PowerShell/PowerShell/releases/download/v7.3.8/PowerShell-7.3.8-win-x86.zip'
		'PostInstall' 	= {
			$pwshFolder = Join-Path $programsPath $programsInfo[$programKey].ProgramFolder
			$pwshSource = Join-Path $pwshFolder $programsInfo[$programKey].ExeName
			$pwshDestination = Join-Path $pwshFolder "powershell.exe"
			Copy-Item -Path $pwshSource -Destination $pwshDestination -Force
		}
	}

	'Process Monitor'	= @{
		'ProgramFolder'	= 'Process Monitor'
		'ExeName'		= 'ProcMon.exe'
		'DownloadUrl'	= 'https://download.sysinternals.com/files/ProcessMonitor.zip'
	}

	'Prime95'			= @{
		'ProgramFolder'	= 'Prime95'
		'ExeName'		= 'prime95.exe'
		'DownloadUrl'	= 'https://www.mersenne.org/download/software/v30/30.8/p95v308b17.win64.zip'
	}
	
	'Revo Uninstaller'	= @{
		'ProgramFolder'	= 'Revo Uninstaller'
		'ExeName'		= '\RevoUninstaller_Portable\RevoUPort.exe'
		'DownloadUrl'	= 'https://download.revouninstaller.com/download/RevoUninstaller_Portable.zip'
	}
	
	'Webroot'			= @{
		'ProgramFolder'	= 'Webroot'
		'ExeName'		= 'WRSA.exe'
		'DownloadUrl'	= 'https://anywhere.webrootcloudav.com/zerol/wsainstall.exe'
		'ArgumentList'	= "-scandepth=quick"
		'Override'		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo[$programKey].DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo[$programKey].ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}

}