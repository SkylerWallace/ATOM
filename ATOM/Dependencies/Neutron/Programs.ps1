$installPrograms = [ordered]@{
	'Anti-Virus' = [ordered]@{
		'Bitdefender' = @{
			Winget	= 'Bitdefender.Bitdefender'
			Choco	= $null
			Url		= 'https://download.bitdefender.com/windows/bp/agent/en-us/bitdefender_online.exe'
		}
		'MalwareBytes' = @{
			Winget	= 'MalwareBytes.MalwareBytes'
			Choco	= 'malwarebytes'
			Url		= 'https://data-cdn.mbamupdates.com/web/mb4-setup-consumer/MBSetup.exe'
		}
		'Norton' = @{
			Winget	= 'XPFNZKWN35KD6Z'
			Choco	= $null
			Url		= 'https://buy-download.norton.com/downloads/MSFT/DSP-N360-TW-MSFT-Def-22.23.4.6.exe'
		}
		'Trend Micro' = @{
			#Winget	= 'XPFMN72PV2VHD1'
			Choco	= $null
			Url		= 'https://files.trendmicro.com/products/Titanium/17.8/BBY/TTi_17.8_MR_Full.exe'
		}
		'Webroot' = @{
			Winget	= 'Webroot.SecureAnywhere'
			Choco	= $null
			Url		= 'https://anywhere.webrootcloudav.com/zerol/wsabbs2.exe'
		}
	}
	
	'Browsers' = [ordered]@{
		'Brave' = @{
			Winget	= 'Brave.Brave'
			Choco	= 'brave'
			Scoop	= 'brave'
			Url		= 'https://updates-cdn.bravesoftware.com/build/Brave-Release/x64-rel/win/120.1.61.116/brave_installer-x64.exe'
		}
		'Chromium' = @{
			Winget	= 'Hibbiki.Chromium'
			Choco	= 'chromium'
			Scoop	= 'chromium'
			Url		= 'https://github.com/Hibbiki/chromium-win64/releases/latest/download/mini_installer.sync.exe'
		}
		'Google Chrome' = @{
			Winget	= 'Google.Chrome'
			Choco	= 'googlechrome'
			Scoop	= 'googlechrome'
			Url		= 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
		}
		'Microsoft Edge' = @{
			Winget	= 'Microsoft.Edge'
			Choco	= 'microsoft-edge'
			Url		= 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/47c03a8a-b015-43b1-b174-80dd7c909367/MicrosoftEdgeEnterpriseX64.msi'
		}
		'Mozilla Firefox' = @{
			Winget	= 'Mozilla.Firefox'
			Choco	= 'firefox'
			Scoop 	= 'firefox'
			Url		= 'https://download-installer.cdn.mozilla.net/pub/firefox/releases/121.0.1/win64/en-US/Firefox%20Setup%20121.0.1.exe'
		}
		'Opera' = @{
			Winget	= 'Opera.Opera'
			Choco	= 'opera'
			Scoop 	= 'opera'
			Url		= 'https://get.geo.opera.com/pub/opera/desktop/106.0.4998.52/win/Opera_106.0.4998.52_Setup_x64.exe'
		}
		'Opera GX' = @{
			Winget	= 'Opera.OperaGX'
			Choco	= 'opera-gx'
			Scoop 	= 'opera-gx'
			Url		= 'https://ftp.opera.com/ftp/pub/opera_gx/106.0.4998.49/win/Opera_GX_106.0.4998.49_Setup_x64.exe'
		}
		'Thorium' = @{
			Winget	= 'Alex313031.Thorium'
			Choco	= $null
			Url		= 'https://github.com/Alex313031/Thorium-Win/releases/latest/download/thorium_mini_installer.exe'
		}		
		'Tor Browser' = @{
			Winget	= 'TorProject.TorBrowser'
			Choco	= 'torbrowser'
			Scoop 	= 'tor'
			Url		= 'https://www.torproject.org/dist/torbrowser/13.0.8/tor-browser-windows-x86_64-portable-13.0.8.exe'
		}
		'Waterfox' = @{
			Winget	= 'Waterfox.Waterfox'
			Choco	= 'waterfox'
			Scoop 	= 'waterfox'
			Url		= 'https://cdn1.waterfox.net/waterfox/releases/G6.0.7/WINNT_x86_64/Waterfox%20Setup%20G6.0.7.exe'
		}
	}
	
	'Cloud Services' = [ordered]@{
		'Dropbox' = @{
			Winget	= 'Dropbox.Dropbox'
			Choco	= 'dropbox'
			Scoop 	= 'dropbox-np'
			Url		= 'https://edge.dropboxstatic.com/dbx-releng/client/Dropbox%20191.4.4995%20Offline%20Installer.x64.exe'
		}
		'Google Drive' = @{
			Winget	= 'Google.GoogleDrive'
			Choco	= 'googledrive'
			Url		= 'https://dl.google.com/release2/drive-file-stream/owj3bgilke5kw7xfeyfcz5tazu_85.0.37.0/setup.exe'
		}
		'iCloud' = @{
			Winget	= '9PKTQ5699M62'
			Choco	= 'icloud'
			Url		= $null
		}
		'OneDrive' = @{
			Winget	= 'Microsoft.OneDrive'
			Choco	= 'onedrive'
			Url		= 'https://oneclient.sfx.ms/Win/Prod/22.131.0619.0001/amd64/OneDriveSetup.exe'
		}
	}
	
	'Development' = [ordered]@{
		'Git' = @{
			Winget	= 'Git.Git'
			Choco	= 'git'
			Url		= 'https://github.com/git-for-windows/git/releases/download/v2.47.0.windows.2/Git-2.47.0.2-64-bit.exe'
		}
		'GitHub Desktop' = @{
			Winget	= 'GitHub.GitHubDesktop'
			Choco	= 'github-desktop'
			Url		= 'https://desktop.githubusercontent.com/releases/3.4.9-5be94b37/GitHubDesktopSetup-x64.exe'
		}
		'Python Launcher' = @{
			Winget	= 'Python.Launcher'
			Choco	= $null
			Url		= 'https://www.python.org/ftp/python/3.12.0/win32/launcher.msi'
		}
		'Visual Studio Code' = @{
			Winget	= 'Microsoft.VisualStudioCode'
			Choco	= 'vscode-install'
			Url		= 'https://vscode.download.prss.microsoft.com/dbazure/download/stable/65edc4939843c90c34d61f4ce11704f09d3e5cb6/VSCodeUserSetup-x64-1.95.1.exe'
		}
	}
	
	'Gaming' = [ordered]@{
		'AMD Auto Detect' = @{
			Winget	= $null
			Choco	= $null
			Url		= 'https://drivers.amd.com/drivers/installer/23.30/whql/amd-software-adrenalin-edition-23.12.1-minimalsetup-231205_web.exe'
			Headers = @{"Referer"="https://www.amd.com/"}
		}
		'AMD Ryzen Chipset' = @{
			Winget	= $null
			Choco	= 'amd-ryzen-chipset'
			Url		= 'https://drivers.amd.com/drivers/amd_chipset_software_5.08.02.027.exe'
			Headers = @{"Referer"="https://www.amd.com/"}
		}
		'AMD Ryzen Master' = @{
			Winget	= $null
			Choco	= 'amd-ryzen-master'
			Url		= 'https://download.amd.com/Desktop/amd-ryzen-master.exe'
		}
		'Battle.net' = @{
			Winget	= $null
			Choco	= $null
			Url		= 'https://downloader.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP&version=Live'
		}
		'Corsair iCUE' = @{
			Winget	= 'Corsair.iCUE.5'
			Choco	= $null #'icue'
			Url		= 'https://www3.corsair.com/software/CUE_V5/public/modules/windows/installer/Install%20iCUE.exe'
		}
		'Discord' = @{
			Winget	= 'Discord.Discord'
			Choco	= 'discord'
			Scoop 	= 'discord'
			Url		= 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9034/DiscordSetup.exe'
		}
		'EA Desktop App' = @{
			Winget	= 'ElectronicArts.EADesktop'
			Choco	= 'ea-app'
			Url		= 'https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe'
		}
		'Epic Games Launcher' = @{
			Winget	= 'EpicGames.EpicGamesLauncher'
			Choco	= 'epicgameslauncher'
			Scoop 	= 'epic-games-launcher'
			Url		= 'https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-15.17.1.msi'
		}
		'GeForce Experience' = @{
			Winget	= 'Nvidia.GeForceExperience'
			Choco	= 'geforce-experience'
			Url		= 'https://us.download.nvidia.com/GFE/GFEClient/3.27.0.120/GeForce_Experience_v3.27.0.120.exe'
		}
		'GeForce Game Ready Driver' = @{
			Winget	= $null
			Choco	= 'geforce-game-ready-driver'
			Url		= 'https://us.download.nvidia.com/Windows/546.65/546.65-desktop-win10-win11-64bit-international-dch-whql.exe'
		}
		'GOG Galaxy' = @{
			Winget	= 'GOG.Galaxy'
			Choco	= 'goggalaxy'
			Scoop 	= 'goggalaxy'
			Url		= 'https://gog-cdn-fastly.gog.com/open/galaxy/client/2.0.73.27/setup_galaxy_2.0.73.27.exe'
		}
		'Intel XTU' = @{
			Winget	= $null
			Choco	= 'intel-xtu'
			Url		= 'https://downloadmirror.intel.com/29183/XTUSetup.exe'
		}
		'Logitech G HUB' = @{
			Winget	= 'Logitech.GHUB'
			Choco	= 'lghub'
			Url		= 'https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe'
		}
		'MSI Afterburner' = @{
			Winget	= 'Guru3D.Afterburner'
			Choco	= 'msiafterburner'
			Scoop 	= 'msiafterburner'
			Url		= 'https://download-1.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip'
		}
		'Nvidia App (Beta)' = @{
			Winget	= $null
			Choco	= $null
			Url		= 'https://us.download.nvidia.com/nvapp/client/10.0.0.535/NVIDIA_app_beta_v10.0.0.535.exe'
		}
		'NZXT CAM' = @{
			Winget	= 'NZXT.CAM'
			Choco	= 'nzxt-cam'
			Url		= 'https://nzxt-app.nzxt.com/NZXT-CAM-Setup.exe'
		}
		'Razer Synapse 3' = @{
			Winget	= 'RazerInc.RazerInstaller'
			Choco	= 'razer-synapse-3'
			Url		= 'https://dl.razerzone.com/drivers/Synapse3/win/RazerSynapseInstaller_V1.15.0.504.exe'
		}
		'SignalRGB' = @{
			Winget	= 'WhirlwindFX.SignalRgb'
			Choco	= $null
			Url		= 'https://release.signalrgb.com/Install_SignalRgb.exe'
		}
		'Steam' = @{
			Winget	= 'Valve.Steam'
			Choco	= 'steam'
			Scoop 	= 'steam'
			Url		= 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
		}
	}
	
	'Media' = [ordered]@{
		'Amazon Music' = @{
			Winget	= 'Amazon.Music'
			Choco	= $null
			Url		= 'https://d2j9xt6n9dg5d3.cloudfront.net/win/23861115_85d5deb94597adc2d891a921c0bf51c9/AmazonMusicInstaller.exe'
		}
		'foobar2000' = @{
			Winget	= 'PeterPawlowski.foobar2000'
			Choco	= 'foobar2000'
			Scoop 	= 'foobar2000'
			Url		= 'https://www.foobar2000.org/files/foobar2000-x64_v2.1.1.exe'
		}
		'iTunes' = @{
			Winget	= 'Apple.iTunes'
			Choco	= 'itunes'
			Url		= 'https://www.apple.com/itunes/download/win64/'
		}
		'Spotify' = @{
			Winget	= 'Spotify.Spotify'
			Choco	= 'spotify'
			Scoop 	= 'spotify'
			Url		= 'https://upgrade.scdn.co/upgrade/client/win32-x86_64/spotify_installer-1.2.29.605.g66a43ceb-1229.exe'
			NoAdmin	= $true
		}
		'TIDAL' = @{
			Winget	= 'TIDALMusicAS.TIDAL'
			Choco	= 'tidal'
			Url		= 'https://download.tidal.com/desktop/TIDALSetup.exe'
		}
		'VLC' = @{
			Winget	= 'VideoLAN.VLC'
			Choco	= 'vlc'
			Scoop 	= 'vlc'
			Url		= 'https://opencolo.mm.fcix.net/videolan-ftp/vlc/3.0.20/win32/vlc-3.0.20-win32.exe'
		}
	}
	
	'Miscellaneous' = [ordered]@{
		'Visual C++ 2015-2022 64-bit' = @{
			Winget	= 'Microsoft.VCRedist.2015+.x64'
			Choco	= 'vcredist140'
			Scoop 	= 'vcredist'
			Url		= 'https://download.visualstudio.microsoft.com/download/pr/09ee6168-4ebc-4886-a058-a668f573a552/CAA8369F99545E84E0EA83CBE0C202408F3B3A038B2E1786BB048A837A9D1522/VC_redist.x64.exe'
		}
		'Visual C++ 2015-2022 32-bit' = @{
			Winget	= 'Microsoft.VCRedist.2015+.x32'
			Choco	= 'vcredist140 --x86'
			Scoop 	= 'vcredist -a x86'
			Url		= 'https://download.visualstudio.microsoft.com/download/pr/09ee6168-4ebc-4886-a058-a668f573a552/E13808974666DACAAEA5C748E1CA3B39992541FE9FE393DA6FBAACF21273CF1A/VC_redist.x86.exe'
		}
	}
	
	'Productivity (Business)' = [ordered]@{
		'Adobe Acrobat Reader' = @{
			Winget	= 'Adobe.Acrobat.Reader.64-bit'
			Choco	= 'adobereader'
			Url		= 'https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300320244/AcroRdrDCx642300320244_MUI.exe'
		}
		'Garmin Express' = @{
			Winget	= 'Garmin.Express'
			Choco	= 'garmin-express'
			Url		= 'https://download.garmin.com/omt/express/GarminExpress.exe'
		}
		'Grammarly' = @{
			Winget	= 'Grammarly.Grammarly'
			Choco	= 'grammarly-for-windows'
			Scoop 	= 'grammarly-np'
			Url		= 'https://download-windows.grammarly.com/versions/1.0.51.1141/GrammarlyInstaller.exe'
		}
		'LibreOffice' = @{
			Winget	= 'TheDocumentFoundation.LibreOffice'
			Choco	= 'libreoffice-fresh'
			Scoop 	= 'libreoffice'
			Url		= 'https://download.documentfoundation.org/libreoffice/stable/7.6.4/win/x86_64/LibreOffice_7.6.4_Win_x86-64.msi'
		}
		'Microsoft Office' = @{
			Winget	= 'Microsoft.Office'
			Choco	= 'office365homepremium'
			Scoop 	= 'office-365-apps-np'
			Url		= 'https://officecdn.microsoft.com/pr/wsus/setup.exe'
		}
		'Microsoft Teams' = @{
			Winget	= 'Microsoft.Teams'
			Choco	= 'microsoft-teams'
			Scoop 	= 'microsoft-teams'
			Url		= 'https://statics.teams.cdn.office.net/production-windows-x64/1.6.00.6754/Teams_windows_x64.exe'
		}
		'OpenOffice' = @{
			Winget	= 'Apache.OpenOffice'
			Choco	= 'openoffice'
			Scoop 	= 'openoffice'
			Url		= 'https://phoenixnap.dl.sourceforge.net/project/openofficeorg.mirror/4.1.14/binaries/en-GB/Apache_OpenOffice_4.1.14_Win_x86_install_en-GB.exe'
		}
		'Quicken' = @{
			Winget	= 'Quicken.Quicken'
			Choco	= $null
			Url		= 'https://download.quicken.com/windows/Quicken.exe'
		}
		'Slack' = @{
			Winget	= 'SlackTechnologies.Slack'
			Choco	= 'slack'
			Scoop 	= 'slack'
			Url		= 'https://downloads.slack-edge.com/releases/windows/4.35.126/prod/x64/slack-standalone-4.35.126.0.msi'
		}
		'Webex' = @{
			Winget	= 'Cisco.WebexTeams'
			Choco	= 'webex'
			Scoop 	= 'webex'
			Url		= 'https://binaries.webex.com/WebexTeamsDesktop-Windows-Web-Installer/Webex.exe'
		}
		'WPS Office' = @{
			Winget	= 'Kingsoft.WPSOffice.CN'
			Choco	= 'wps-office-free'
			Scoop 	= 'wpsoffice'
			Url		= 'https://official-package.wpscdn.cn/wps/download/WPS_Setup_15712.exe'
		}
		'Zoom' = @{
			Winget	= 'Zoom.Zoom'
			Choco	= 'zoom'
			Scoop 	= 'zoom'
			Url		= 'https://cdn.zoom.us/prod/5.17.2.29988/x64/ZoomInstallerFull.exe'
		}
	}
	
	'Productivity (Creative)' = [ordered]@{
		'Adobe Creative Cloud' = @{
			Winget	= 'XPDLPKWG9SW2WD'
			Choco	= $null
			Url		= 'https://ffc-static-cdn.oobesaas.adobe.com/wam/2.10.0.17/win/Creative_Cloud_Set-Up.exe' #'https://ffc-static-cdn.oobesaas.adobe.com/wam/2.10.0.17/win/Creative_Cloud_Set-Up.exe?api_key=CreativeCloudStoreInstaller_v1_0'
		}
		'Audacity' = @{
			Winget	= 'Audacity.Audacity'
			Choco	= 'audacity'
			Scoop 	= 'audacity'
			Url		= 'https://github.com/audacity/audacity/releases/download/Audacity-3.4.2/audacity-win-3.4.2-64bit.exe'
		}
		'CorelDRAW' = @{
			Winget	= 'XPDM28CQSPXTWQ'
			Choco	= $null
			Url		= 'https://www.corel.com/akdlm/6763/downloads/free/trials/GraphicsSuite/22H1/JL83s3fG/msstore_sf/CorelDRAWGraphicsSuiteInstaller.exe'
		}
		'FL Studio' = @{
			Winget	= 'ImageLine.FLStudio'
			Choco	= $null
			Url		= 'https://install.image-line.com/flstudio/flstudio_win64_21.2.2.3914.exe'
		}
		'GIMP' = @{
			Winget	= 'GIMP.GIMP'
			Choco	= 'gimp'
			Scoop 	= 'gimp'
			Url		= 'https://download.gimp.org/gimp/v2.10/windows/gimp-2.10.36-setup.exe'
		}
		'OBS Studio' = @{
			Winget	= 'OBSProject.OBSStudio'
			Choco	= 'obs-studio'
			Scoop 	= 'obs-studio'
			Url		= 'https://github.com/obsproject/obs-studio/releases/download/30.0.2/OBS-Studio-30.0.2-Full-Installer-x64.exe'
		}
		'paint.net' = @{
			Winget	= 'dotPDN.PaintDotNet'
			Choco	= 'paint.net'
			Scoop 	= 'paint.net'
			Url		= 'https://github.com/paintdotnet/release/releases/download/v5.0.13/paint.net.5.0.13.install.anycpu.web.zip'
		}
		'REAPER' = @{
			Winget	= 'Cockos.REAPER'
			Choco	= 'reaper'
			Scoop 	= 'reaper'
			Url		= 'https://www.reaper.fm/files/7.x/reaper707_x64-install.exe'
		}
		'Streamlabs Desktop' = @{
			Winget	= 'Streamlabs.Streamlabs'
			Choco	= 'streamlabs-obs'
			Scoop 	= 'streamlabs-obs'
			Url		= 'https://slobs-cdn.streamlabs.com/Streamlabs+Desktop+Setup+1.13.3.exe'
		}
	}
	
	'System Utility' = [ordered]@{
		'AsRock Live Update' = @{
			Winget	= $null
			Choco	= $null #'app-shop'
			Url		= 'https://www.asrock.com/feature/appshop/dl.asp'
		}
		'ASUS Armoury Crate' = @{
			Winget	= 'ASUS.ArmouryCrate'
			Choco	= $null
			Url		= 'https://dlcdnets.asus.com/pub/ASUS/mb/14Utilities/ArmouryCrateInstallTool.zip'
		}
		'Dell Command Update' = @{
			Winget	= 'Dell.CommandUpdate.Universal'
			Choco	= 'dellcommandupdate-uwp'
			Url		= 'https://dl.dell.com/FOLDER11914128M/1/Dell-Command-Update-Windows-Universal-Application_9M35M_WIN_5.4.0_A00.EXE'
		}
		'Dell SupportAssist' = @{
			Winget	= $null
			Choco	= 'supportassist'
			Url		= 'https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe'
		}
		'Gigabyte Control Center' = @{
			Winget	= $null
			Choco	= $null
			Url		= 'https://download.gigabyte.com/FileList/Utility/GCC_23.12.13.01.zip'
		}
		'HP Image Assistant' = @{
			Winget	= 'HP.ImageAssistant'
			Choco	= $null
			Scoop	= $null
			Url		= 'https://hpia.hpcloud.hp.com/downloads/hpia/hp-hpia-5.2.1.exe'
		}
		'HP Support Assistant' = @{
			Winget	= $null
			Choco	= $null #'hpsupportassistant'
			Scoop 	= 'hp-support-assistant-np'
			Url		= 'https://ftp.hp.com/pub/softpaq/sp148501-149000/sp148716.exe'
		}
		'Lenovo System Update' = @{
			Winget	= 'Lenovo.SystemUpdate'
			Choco	= 'lenovo-thinkvantage-system-update'
			Url		= 'https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.03.59.exe'
		}
		'Lenovo Thin Installer' = @{
			Winget	= 'Lenovo.ThinInstaller'
			Choco	= $null
			Url		= 'https://download.lenovo.com/pccbbs/thinkvantage_en/lenovo_thininstaller_1.04.02.00024.exe'
		}
		'Lenovo Update Retriever' = @{
			Winget	= 'Lenovo.UpdateRetriever'
			Choco	= $null
			Url		= 'https://download.lenovo.com/pccbbs/thinkvantage_en/updateretriever_5.08.01.30.exe'
		}
		'Lenovo Vantage' = @{
			Winget	= '9WZDNCRFJ4MV'
			Choco	= $null
			Url		= $null
		}
		'MSI Center' = @{
			Winget	= '9NVMNJCR03XV'
			Choco	= $null
			Url		= 'https://download.msi.com/uti_exe/vga/MSI-Center.zip'
		}
		'MyASUS' = @{
			Winget	= '9N7R5S6B0ZZH'
			Choco	= $null
			Url		= $null
		}
	}
	
	'Tools' = [ordered]@{
		'7-Zip' = @{
			Winget	= '7Zip.7Zip'
			Choco	= '7zip'
			Scoop 	= '7zip'
			Url		= 'https://www.7-zip.org/a/7z2301-x64.exe'
		}
		'CPU-Z' = @{
			Winget	= 'CPUID.CPU-Z'
			Choco	= 'cpu-z'
			Scoop 	= 'cpu-z'
			Url		= 'https://download.cpuid.com/cpu-z/cpu-z_2.08-en.exe'
		}
		'HWiNFO' = @{
			Winget	= 'REALiX.HWiNFO'
			Choco	= 'hwinfo'
			Scoop 	= 'hwinfo'
			Url		= 'https://www.sac.sk/download/utildiag/hwi_768.exe'
		}
		'HWMonitor' = @{
			Winget	= 'CPUID.HWMonitor'
			Choco	= 'hwmonitor'
			Scoop 	= 'hwmonitor'
			Url		= 'https://download.cpuid.com/hwmonitor/hwmonitor_1.52.exe'
		}
		'Notepad++' = @{
			Winget	= 'Notepad++.Notepad++'
			Choco	= 'notepadplusplus'
			Scoop 	= 'notepadplusplus'
			Url		= 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.2/npp.8.6.2.Installer.x64.exe'
		}
		'Samsung Data Migration' = @{
			Winget	= $null
			Choco	= $null
			Url		= 'https://semiconductor.samsung.com/resources/software-resources/Samsung_Data_Migration_Setup_4.0.0.18.exe'
		}
		'Samsung Magician' = @{
			Winget	= $null #'Samsung.SamsungMagician'
			Choco	= 'samsung-magician'
			Url		= 'https://download.semiconductor.samsung.com/resources/software-resources/Samsung_Magician_Installer_Official_8.0.1.1000.exe'
		}
		'Speccy' = @{
			Winget	= 'Piriform.Speccy'
			Choco	= 'speccy'
			Scoop 	= 'speccy'
			Url		= 'https://download.ccleaner.com/spsetup132.exe'
		}
	}
}