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
	Ex: DownloadUrl = 'https://www.website.net/download.zip'
- Override
	If defined, will override default downloading procedures
	in Start-PortablePrograms & Install-PortablePrograms.
	Ex: Override = { iwr -url $url -outFile $downloadPath }
	IMPORTANT: preAtomPath, programsPath, exePath, extractionPath,
	and exePath variables are inherited.
- Credential
	If download URL requires a username and/or password, this
	parameter must be defined and set to $true.
	Ex: Crediential = $true
- UserName
	If Credential is defined and set to $true, this will
	auto-fill the username. If undefined, username will
	not be auto-filled.
	Ex: UserName = abc123
- ArgumentList
	If defined, will arguments with the program's exe if
	called by Start-PortablePrograms.
	Ex: ArgumentList = '/silent'
- PostInstall
	If defined, will run the contents of PostInstall after
	program has been installed.
	Ex: PostInstall = { Remove-Item -Path $removeMe }

#>

$programsInfo = [ordered]@{
	
	'7-Zip' 			= @{
		ProgramFolder	= '7-Zip'
		ExeName			= '7zFM.exe'
		DownloadUrl		= 'https://www.7-zip.org/a/7z2301-x64.exe'
		Override		= { Expand-With7z -ConsoleExtract }
	}
	
	'AnyBurn'			= @{
		ProgramFolder	= 'AnyBurn'
		ExeName			= '\AnyBurn(64-bit)\AnyBurn.exe'
		DownloadUrl		= 'https://www.anyburn.com/anyburn.zip'
	}
		
	'Autoruns' 			= @{
		ProgramFolder	= 'Autoruns'
		ExeName			= 'Autoruns64.exe'
		DownloadUrl		= 'https://download.sysinternals.com/files/Autoruns.zip'
	}

	'BlueScreenView'	= @{
		ProgramFolder	= 'BlueScreenView'
		ExeName			= 'BlueScreenView.exe'
		DownloadUrl		='https://www.nirsoft.net/utils/bluescreenview-x64.zip'
	}

	'CPU-Z'				= @{
		ProgramFolder	= 'CPU-Z'
		ExeName			= 'cpuz_x64.exe'
		DownloadUrl		= 'https://download.cpuid.com/cpu-z/cpu-z_2.08-en.zip'
	}
	
	'CrystalDiskInfo'	= @{
		ProgramFolder	= 'CrystalDiskInfo'
		ExeName			= 'DiskInfo64.exe'
		DownloadUrl		= 'https://crystalmark.info/download/zz/CrystalDiskInfo9_1_1.zip'
	}

	'CrystalDiskMark'	= @{
		ProgramFolder	= 'CrystalDiskMark'
		ExeName			= 'DiskMark64.exe'
		DownloadUrl		= 'https://crystalmark.info/download/zz/CrystalDiskMark8_0_4c.zip'
	}
	
	'Display Driver Uninstaller'	= @{
		ProgramFolder	= 'Display Driver Uninstaller'
		ExeName			= '\DDU v18.0.7.2\Display Driver Uninstaller.exe'
		DownloadUrl		= 'https://www.wagnardsoft.com/DDU/download/DDU%20v18.0.7.2.exe'
		Override		= { Expand-With7z -ConsoleExtract }
	}
	
	'Explorer++'		= @{
		ProgramFolder	= 'Explorer++'
		ExeName			= 'Explorer++.exe'
		DownloadUrl		= 'https://download.explorerplusplus.com/beta/1.4.0-beta-2/explorerpp_x64.zip'
	}
	
	'FreeCommander'		= @{
		ProgramFolder	= 'FreeCommander'
		ExeName			= 'FreeCommander.exe'
		DownloadUrl		= 'https://freecommander.com/downloads/FreeCommanderXE-32-public_portable.zip'
	}
	
	'HCI Design MemTest' = @{
		ProgramFolder	= 'HCI Design MemTest'
		ExeName			= 'memtest.exe'
		DownloadUrl		= 'https://hcidesign.com/memtest/MemTest.zip'
	}

	'HWMonitor'			= @{
		ProgramFolder	= 'HWMonitor'
		ExeName			= 'HWMonitor_x64.exe'
		DownloadUrl		= 'https://download.cpuid.com/hwmonitor/hwmonitor_1.52.zip'
	}
	
	'Kaspersky Virus Removal Tool' = @{
		ProgramFolder	= 'Kaspersky Virus Removal Tool'
		ExeName			= 'KVRT.exe'
		DownloadUrl		= 'https://devbuilds.s.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo[$program].DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo[$program].ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'MalwareBytes AdwCleaner'	= @{
		ProgramFolder	= 'MalwareBytes AdwCleaner'
		ExeName			= 'adwcleaner.exe'
		DownloadUrl		= 'https://adwcleaner.malwarebytes.com/adwcleaner?channel=release'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo.$program.ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'MemTest86'			= @{
		ProgramFolder	= 'MemTest86'
		ExeName			= 'imageUSB.exe'
		DownloadUrl		= 'https://www.memtest86.com/downloads/memtest86-usb.zip'
	}
	
	'McAfee Stinger'	= @{
		ProgramFolder	= 'McAfee Stinger'
		ExeName			= 'stinger64.exe'
		DownloadUrl		= 'https://downloadcenter.trellix.com/products/mcafee-avert/Stinger/stinger64.exe'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo.$program.ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'MSI Kombustor'		= @{
		ProgramFolder	= 'MSI Kombustor'
		ExeName			= 'MSI-Kombustor-x64.exe'
		DownloadUrl		= 'https://www.geeks3d.com/dl/get/725'
		Override		= {
			$url = $programsInfo.$program.DownloadUrl
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
		ProgramFolder	= 'Norton Power Eraser'
		ExeName			= 'NPE.exe'
		DownloadUrl		= 'https://www.norton.com/npe_latest'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo.$program.ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'Notepad++'			= @{
		ProgramFolder	= 'Notepad++'
		ExeName			= 'notepad++.exe'
		DownloadUrl		= 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.8/npp.8.5.8.portable.x64.zip'
	}
	
	'O&O Shutup10++'	= @{
		ProgramFolder	= 'O&O Shutup10++'
		ExeName			= 'OOSU10.exe'
		DownloadUrl		= 'https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo.$program.ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'OCCT'				= @{
		ProgramFolder	= 'OCCT'
		ExeName			= 'OCCT.exe'
		DownloadUrl		= 'https://www.ocbase.com/download/edition:Personal'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo.$program.ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'OneCommander'		= @{
		ProgramFolder	= 'OneCommander'
		ExeName			= 'OneCommander.exe'
		DownloadUrl		= 'https://www.onecommander.com/OneCommander3.58.0.0.zip'
	}
	
	'Opera'				= @{
		ProgramFolder	= 'Opera'
		ExeName			= 'Opera.exe'
		DownloadUrl		= 'https://net.geo.opera.com/opera_portable/stable/windows?utm_tryagain=yes&utm_source=google&utm_medium=ose&utm_campaign=(none)&http_referrer=https%3A%2F%2Fwww.google.com%2F&utm_site=opera_com&'
		Override		= {
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $env:TEMP "OperaSetup.exe"
			
			Invoke-WebRequest $url -OutFile $downloadPath
			
			$process = Start-Process -FilePath $downloadPath -ArgumentList "/silent /installfolder=`"$extractionPath`" /launchbrowser=0" -PassThru
			$process.WaitForExit()
			
			Remove-Item -Path $downloadPath -Force
		}
	}
	
	'Orca'				= @{
		ProgramFolder	= 'Orca'
		ExeName			= '\Orca\orca.exe'
		DownloadUrl		= 'https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/Orca-x86_en-us.msi'
		Override		= {
			$url = $programsInfo.$program.DownloadUrl
			$cab1 = "https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/838060235bcd28bf40ef7532c50ee032.cab"
			$cab2 = "https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/a35cd6c9233b6ba3da66eecaa9190436.cab"
			$cab3 = "https://download.microsoft.com/download/4/2/2/42245968-6A79-4DA7-A5FB-08C0AD0AE661/windowssdk/Installers/fe38b2fd0d440e3c6740b626f51a22fc.cab"
			
			$downloadPath = Split-Path $url -Leaf
			$cab1Path = Split-Path $cab1 -Leaf
			$cab2Path = Split-Path $cab2 -Leaf
			$cab3Path = Split-Path $cab3 -Leaf
			
			Invoke-WebRequest $url -Outfile (Split-Path $url -Leaf)
			Invoke-WebRequest $cab1 -Outfile $cab1Path
			Invoke-WebRequest $cab2 -Outfile $cab2Path
			Invoke-WebRequest $cab3 -Outfile $cab3Path
			
			Start-Process msiexec -ArgumentList "/a $downloadPath /qn TARGETDIR=$extractionPath" -Wait
			
			Remove-Item -Path $downloadPath -Force
			Remove-Item -Path $cab1Path -Force
			Remove-Item -Path $cab2Path -Force
			Remove-Item -Path $cab3Path -Force
		}
	}

	'PowerShell Core'	= @{
		ProgramFolder	= 'PowerShell Core_x64'
		ExeName			= 'pwsh.exe'
		DownloadUrl		= 'https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/PowerShell-7.4.1-win-x64.zip'
		PostInstall 	= {
			$pwshFolder = Join-Path $programsPath $programsInfo.$program.ProgramFolder
			$pwshSource = Join-Path $pwshFolder $programsInfo.$program.ExeName
			$pwshDestination = Join-Path $pwshFolder "powershell.exe"
			Copy-Item -Path $pwshSource -Destination $pwshDestination -Force
		}
	}
	
	'Prime95'			= @{
		ProgramFolder	= 'Prime95'
		ExeName			= 'prime95.exe'
		DownloadUrl		= 'https://www.mersenne.org/download/software/v30/30.8/p95v308b17.win64.zip'
	}

	'Process Monitor'	= @{
		ProgramFolder	= 'Process Monitor'
		ExeName			= 'ProcMon64.exe'
		DownloadUrl		= 'https://download.sysinternals.com/files/ProcessMonitor.zip'
	}
	
	'Recuva' 			= @{
		ProgramFolder	= 'Recuva'
		ExeName			= 'recuva64.exe'
		DownloadUrl		= 'https://download.ccleaner.com/rcsetup153.exe'
		Override		= { Expand-With7z }
	}
	
	'Regshot'			= @{
		ProgramFolder	= 'Regshot'
		ExeName			= 'Regshot-x64-Unicode.exe'
		DownloadUrl		= 'https://downloads.sourceforge.net/project/regshot/regshot/1.9.0/Regshot-1.9.0.7z'
		Override		= { Expand-With7z -ConsoleExtract }
	}
	
	'Revo Uninstaller'	= @{
		ProgramFolder	= 'Revo Uninstaller'
		ExeName			= '\RevoUninstaller_Portable\RevoUPort.exe'
		DownloadUrl		= 'https://download.revouninstaller.com/download/RevoUninstaller_Portable.zip'
	}
	
	'Rufus' = @{
		ProgramFolder = 'Rufus'
		ExeName			= 'Rufus.exe'
		DownloadUrl		= 'https://github.com/pbatard/rufus/releases/download/v4.3/rufus-4.3p.exe'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo.$program.ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'Snappy Driver Installer Origin' = @{
		ProgramFolder	= 'Snappy Driver Installer Origin'
		ExeName			= 'SDIO_x64.exe'
		DownloadUrl		= 'https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.12.17.757.zip'
		PostInstall		= {
			$detectedExe = Get-ChildItem "$extractionPath\SDIO_x64*.exe"
			Rename-Item -Path $detectedExe -NewName "$extractionPath\SDIO_x64.exe"
		}
	}
	
	'TeraCopy'			= @{
		ProgramFolder	= 'TeraCopy'
		ExeName			= 'TeraCopy.exe'
		DownloadUrl		= 'https://www.codesector.com/files/teracopy.exe'
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo[$program].DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo[$program].ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
			
			$extractArgs = "`"$downloadPath`" /extract `"$extractionPath`""
			Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
			Remove-Item -Path $downloadPath -Force
			
			$subFolder = (Get-ChildItem -Path $extractionPath -Directory | Select-Object -First 1).FullName
			Get-ChildItem -Path $subFolder | Move-Item -Destination $extractionPath
			Remove-Item -Path $subFolder -Force
		}
	}
	
	'Total Commander'	= @{
		ProgramFolder	= 'Total Commander'
		ExeName			= 'TOTALCMD64.EXE'
		DownloadUrl		= 'https://totalcommander.ch/1102/tcmd1102x64.exe'
		Override		= {
			Expand-With7z -ScriptBlock {
				$cabPath = Join-Path $extractionPath "INSTALL.CAB"
				$extractArgs = "`"$7zExe`" x `"$cabPath`" -o`"$extractionPath`" -y"
				Start-Process cmd.exe -ArgumentList "/c `"$extractArgs`"" -Wait
			}
		}
	}
	
	'Webroot'			= @{
		ProgramFolder	= 'Webroot'
		ExeName			= 'WRSA.exe'
		DownloadUrl		= 'https://anywhere.webrootcloudav.com/zerol/wsainstall.exe'
		ArgumentList	= "-scandepth=quick"
		Override		= {
			if (!(Test-Path $extractionPath)) { New-Item -Path $extractionPath -ItemType Directory -Force | Out-Null }
			
			$url = $programsInfo.$program.DownloadUrl
			$downloadPath = Join-Path $extractionPath $programsInfo.$program.ExeName
			Invoke-WebRequest $url -OutFile $downloadPath
		}
	}
	
	'WinMerge'			= @{
		ProgramFolder	= 'WinMerge'
		ExeName			= 'WinMerge\WinMergeU.exe'
		DownloadUrl		= 'https://downloads.sourceforge.net/winmerge/winmerge-2.16.36-x64-exe.zip'
	}
	
	'WizTree'			= @{
		ProgramFolder	= 'WizTree'
		ExeName			= 'WizTree64.exe'
		DownloadUrl		= 'https://www.diskanalyzer.com/files/wiztree_4_18_portable.zip'
	}

}

# Add contents of custom hashtable to main hashtable
. $psScriptRoot\ProgramsParamsUser.ps1
$programsInfo += $customProgramsInfo