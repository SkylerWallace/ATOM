$installPrograms = [ordered]@{
	'Anti-Virus' = [ordered]@{
		'Norton' = @{
			'winget' = 'XPFNZKWN35KD6Z'
			'choco' = $null
			'url' = 'https://buy-download.norton.com/downloads/MSFT/DSP-N360-TW-MSFT-Def-22.23.3.8.exe'
		}
		'Trend Micro' = @{
			'winget' = 'XPFMN72PV2VHD1'
			'choco' = $null
			'url' = 'https://ti-res.trendmicro.com/ti-res/mss/ti177/global/mr/1634_9/TrendMicro_17.7_22Q3_MR_64bit.exe'
		}
		'Webroot' = @{
			'winget' = 'Webroot.SecureAnywhere'
			'choco' = $null
			'url' = 'https://anywhere.webrootcloudav.com/zerol/wsabbs2.exe'
		}
	}
	'Browsers' = [ordered]@{
		'Brave' = @{
			'winget' = 'Brave.Brave'
			'choco' = 'brave'
			'url' = 'https://updates-cdn.bravesoftware.com/build/Brave-Release/x64-rel/win/115.1.56.9/brave_installer-x64.exe'
		}
		'Google Chrome' = @{
			'winget' = 'Google.Chrome'
			'choco' = 'googlechrome'
			'url' = 'https://dl.google.com/dl/chrome/install/ChromeStandaloneSetup64.exe'
		}
		'Mozilla Firefox' = @{
			'winget' = 'Mozilla.Firefox'
			'choco' = 'firefox'
			'url' = 'https://download-installer.cdn.mozilla.net/pub/firefox/releases/115.0.2/win64/en-US/Firefox%20Setup%20115.0.2.exe'
		}
		'Opera' = @{
			'winget' = 'Opera.Opera'
			'choco' = 'opera'
			'url' = 'https://get.geo.opera.com/pub/opera/desktop/99.0.4788.77/win/Opera_99.0.4788.77_Setup.exe'
		}
		'Opera GX' = @{
			'winget' = 'Opera.OperaGX'
			'choco' = 'opera-gx'
			'url' = 'https://ftp.opera.com/ftp/pub/opera_gx/100.0.4815.44/win/Opera_GX_100.0.4815.44_Setup_x64.exe'
		}
	}
	'Gaming' = [ordered]@{
		'AMD Auto Detect' = @{
			'winget' = $null
			'choco' = $null
			'url' = $null
			'mirror' = 'https://drive.google.com/uc?export=download&id=13N1GqQ78BqXNiWHEC5O7E9VfGzwxTLh7'
		}
		'AMD Ryzen Chipset' = @{
			'winget' = $null
			'choco' = 'amd-ryzen-chipset'
			'url' = $null
		}
		'Battle.net' = @{
			'winget' = $null
			'choco' = $null
			'url' = 'https://downloader.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP&version=Live'
		}
		'Corsair iCUE' = @{
			'winget' = $null
			'choco' = 'icue'
			'url' = 'https://downloads.corsair.com/Files/icue/Install-iCUE-5.3.exe'
		}
		'Discord' = @{
			'winget' = 'Discord.Discord'
			'choco' = 'discord'
			'url' = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9015/DiscordSetup.exe'
		}
		'EA Desktop App' = @{
			'winget' = 'ElectronicArts.EADesktop'
			'choco' = 'ea-app'
			'url' = 'https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe'
		}
		'Epic Games Launcher' = @{
			'winget' = 'EpicGames.EpicGamesLauncher'
			'choco' = 'epicgameslauncher'
			'url' = 'https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-15.3.0.msi'
		}
		'GeForce Experience' = @{
			'winget' = 'Nvidia.GeForceExperience'
			'choco' = 'geforce-experience'
			'url' = 'https://us.download.nvidia.com/GFE/GFEClient/3.27.0.112/GeForce_Experience_v3.27.0.112.exe'
		}
		'GeForce Game Ready Driver' = @{
			'winget' = $null
			'choco' = 'geforce-game-ready-driver'
			'url' = 'https://us.download.nvidia.com/Windows/537.13/537.13-desktop-win10-win11-64bit-international-dch-whql.exe'
		}
		'GOG Galaxy' = @{
			'winget' = 'GOG.Galaxy'
			'choco' = 'goggalaxy'
			'url' = 'https://content-system.gog.com/open_link/download?path=/open/galaxy/client/2.0.65.11/setup_galaxy_2.0.65.11.exe'
		}
		'Intel XTU' = @{
			'winget' = $null;
			'choco' = 'intel-xtu'
			'url' = 'https://downloadmirror.intel.com/29183/XTUSetup.exe'
		}
		'MSI Afterburner' = @{
			'winget' = 'Guru3D.Afterburner'
			'choco' = 'msiafterburner'
			'url' = 'https://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip'
		}
		'NZXT CAM' = @{
			'winget' = 'NZXT.CAM'
			'choco' = 'nzxt-cam'
			'url' = 'https://nzxt-app.nzxt.com/NZXT-CAM-Setup.exe'
		}
		'Steam' = @{
			'winget' = 'Valve.Steam'
			'choco' = 'steam'
			'url' = 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
		}
	}
	'Media' = [ordered]@{
		'iTunes' = @{
			'winget' = 'Apple.iTunes'
			'choco' = 'itunes'
			'url' = 'https://www.apple.com/itunes/download/win64/'
		}
		'Spotify' = @{
			'winget' = 'Spotify.Spotify'
			'choco' = 'spotify'
			'url' = 'https://download.scdn.co/SpotifySetup.exe'
		}
		'VLC' = @{
			'winget' = 'VideoLAN.VLC'
			'choco' = 'vlc'
			'url' = 'https://opencolo.mm.fcix.net/videolan-ftp/vlc/3.0.18/win32/vlc-3.0.18-win32.exe'
		}
	}
	'Productivity' = [ordered]@{
		'Adobe Acrobat Reader' = @{
			'winget' = 'Adobe.Acrobat.Reader.64-bit'
			'choco' = 'adobereader'
			'url' = 'https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300320244/AcroRdrDCx642300320244_MUI.exe'
		}
		'Microsoft Office' = @{
			'winget' = 'Microsoft.Office'
			'choco' = 'office365homepremium'
			'url' = 'https://officecdn.microsoft.com/pr/wsus/setup.exe'
		}
		'Microsoft Teams' = @{
			'winget' = 'Microsoft.Teams'
			'choco' = 'microsoft-teams'
			'url' = 'https://statics.teams.cdn.office.net/production-windows-x64/1.6.00.6754/Teams_windows_x64.exe'
		}
		'Webex' = @{
			'winget' = 'Cisco.WebexTeams'
			'choco' = 'webex'
			'url' = 'https://binaries.webex.com/WebexTeamsDesktop-Windows-Web-Installer/Webex.exe'
		}
		'Zoom' = @{
			'winget' = 'Zoom.Zoom'
			'choco' = 'zoom'
			'url' = 'https://cdn.zoom.us/prod/5.15.5.19404/x64/ZoomInstallerFull.exe'
		}
	}
	'System Utility' = [ordered]@{
		'Dell SupportAssist' = @{
			'winget' = $null
			'choco' = 'supportassist'
			'url' = 'https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe'
		}
		'HP Support Assistant' = @{
			'winget' = $null
			'choco' = 'hpsupportassistant'
			'url' = 'https://ftp.hp.com/pub/softpaq/sp148501-149000/sp148716.exe'
		}
		'Lenovo Vantage' = @{
			'winget' = '9WZDNCRFJ4MV'
			'choco' = $null
			'url' = $null
			'mirror' = $null
		}
		'MyASUS' = @{
			'winget' = '9N7R5S6B0ZZH'
			'choco' = $null
			'url' = $null
			'mirror' = $null
		}
	}
	'Tools' = [ordered]@{
		'7-Zip' = @{
			'winget' = '7Zip.7Zip'
			'choco' = '7zip'
			'url' = 'https://www.7-zip.org/a/7z2301-x64.exe'
		}
		'CPU-Z' = @{
			'winget' = 'CPUID.CPU-Z'
			'choco' = 'cpu-z'
			'url' = 'https://download.cpuid.com/cpu-z/cpu-z_2.06-en.exe'
		}
		'HWiNFO' = @{
			'winget' = 'REALiX.HWiNFO'
			'choco' = 'hwinfo'
			'url' = 'https://www.sac.sk/download/utildiag/hwi_750.exe'
		}
		'HWMonitor' = @{
			'winget' = 'CPUID.HWMonitor'
			'choco' = 'hwmonitor'
			'url' = 'https://download.cpuid.com/hwmonitor/hwmonitor_1.50.exe'
		}
		'Notepad++' = @{
			'winget' = 'Notepad++.Notepad++'
			'choco' = 'notepadplusplus'
			'url' = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.5.7/npp.8.5.7.Installer.x64.exe'
		}
		'Samsung Data Migration' = @{
			'winget' = $null
			'choco' = $null
			'url' = 'https://semiconductor.samsung.com/resources/software-resources/Samsung_Data_Migration_Setup_4.0.0.18.exe'
		}
		'Samsung Magician' = @{
			'winget' = 'Samsung.SamsungMagician'
			'choco' = 'samsung-magician'
			'url' = 'https://download.semiconductor.samsung.com/resources/software-resources/Samsung_Magician_Installer_Official_7.3.0.1100.zip'
		}
	}
}
