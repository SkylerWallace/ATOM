$installPrograms = [ordered]@{
	'Anti-Virus' = [ordered]@{
		'Bitdefender' = @{
			'winget' = 'Bitdefender.Bitdefender'
			'choco' = $null
			'url' = 'https://download.bitdefender.com/windows/bp/agent/en-us/bitdefender_online.exe'
		}
		'MalwareBytes' = @{
			'winget' = 'MalwareBytes.MalwareBytes'
			'choco' = 'malwarebytes'
			'url' = 'https://data-cdn.mbamupdates.com/web/mb4-setup-consumer/MBSetup.exe'
		}
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
		'Chromium' = @{
			'winget' = 'Hibbiki.Chromium'
			'choco' = 'chromium'
			'url' = 'https://github.com/Hibbiki/chromium-win64/releases/latest/download/mini_installer.sync.exe'
		}
		'Google Chrome' = @{
			'winget' = 'Google.Chrome'
			'choco' = 'googlechrome'
			'url' = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
		}
		'Microsoft Edge' = @{
			'winget' = 'Microsoft.Edge'
			'choco' = 'microsoft-edge'
			'url' = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/47c03a8a-b015-43b1-b174-80dd7c909367/MicrosoftEdgeEnterpriseX64.msi'
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
		'Thorium' = @{
			'winget' = 'Alex313031.Thorium'
			'choco' = $null
			'url' = 'https://github.com/Alex313031/Thorium-Win/releases/latest/download/thorium_mini_installer.exe'
		}		
		'Tor Browser' = @{
			'winget' = 'TorProject.TorBrowser'
			'choco' = 'torbrowser'
			'url' = 'https://archive.torproject.org/tor-package-archive/torbrowser/13.0.1/tor-browser-windows-x86_64-portable-13.0.1.exe'
		}
		'Waterfox' = @{
			'winget' = 'Waterfox.Waterfox'
			'choco' = 'waterfox'
			'url' = 'https://cdn1.waterfox.net/waterfox/releases/G6.0.5/WINNT_x86_64/Waterfox%20Setup%20G6.0.5.exe'
		}
	}
	'Gaming' = [ordered]@{
		'AMD Auto Detect' = @{
			'winget' = $null
			'choco' = $null
			'url' = 'https://drivers.amd.com/drivers/installer/23.30/whql/amd-software-adrenalin-edition-23.12.1-minimalsetup-231205_web.exe'
			'headers' = @{"Referer"="https://www.amd.com/"}
		}
		'AMD Ryzen Chipset' = @{
			'winget' = $null
			'choco' = 'amd-ryzen-chipset'
			'url' = 'https://drivers.amd.com/drivers/amd_chipset_software_5.08.02.027.exe'
			'headers' = @{"Referer"="https://www.amd.com/"}
		}
		'AMD Ryzen Master' = @{
			'winget' = $null
			'choco' = 'amd-ryzen-master'
			'url' = 'https://download.amd.com/Desktop/amd-ryzen-master.exe'
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
			'url' = 'https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9025/DiscordSetup.exe'
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
		'SignalRGB' = @{
			'winget' = 'WhirlwindFX.SignalRgb'
			'choco' = $null
			'url' = 'https://release.signalrgb.com/Install_SignalRgb.exe'
		}
		'Steam' = @{
			'winget' = 'Valve.Steam'
			'choco' = 'steam'
			'url' = 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
		}
	}
	'Media' = [ordered]@{
		'Amazon Music' = @{
			'winget' = 'Amazon.Music'
			'choco' = $null
			'url' = 'https://d2j9xt6n9dg5d3.cloudfront.net/win/23861115_85d5deb94597adc2d891a921c0bf51c9/AmazonMusicInstaller.exe'
		}
		'foobar2000' = @{
			'winget' = 'PeterPawlowski.foobar2000'
			'choco' = 'foobar2000'
			'url' = 'https://www.foobar2000.org/files/foobar2000-x64_v2.0.exe'
		}
		'iTunes' = @{
			'winget' = 'Apple.iTunes'
			'choco' = 'itunes'
			'url' = 'https://www.apple.com/itunes/download/win64/'
		}
		'Spotify' = @{
			'winget' = 'Spotify.Spotify'
			'choco' = 'spotify'
			'url' = 'https://upgrade.scdn.co/upgrade/client/win32-x86_64/spotify_installer-1.2.26.1187.g36b715a1-269.exe'
		}
		'TIDAL' = @{
			'winget' = 'TIDALMusicAS.TIDAL'
			'choco' = 'tidal'
			'url' = 'https://download.tidal.com/desktop/TIDALSetup.exe'
		}
		'VLC' = @{
			'winget' = 'VideoLAN.VLC'
			'choco' = 'vlc'
			'url' = 'https://opencolo.mm.fcix.net/videolan-ftp/vlc/3.0.18/win32/vlc-3.0.18-win32.exe'
		}
	}
	'Productivity (Business)' = [ordered]@{
		'Adobe Acrobat Reader' = @{
			'winget' = 'Adobe.Acrobat.Reader.64-bit'
			'choco' = 'adobereader'
			'url' = 'https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300320244/AcroRdrDCx642300320244_MUI.exe'
		} <#
		'Cricut Design Space' = @{
			'winget' = $null
			'choco' = 'cricutdesignspace'
			'url' = ''
		} #>
		'Garmin Express' = @{
			'winget' = 'Garmin.Express'
			'choco' = 'garmin-express'
			'url' = 'https://download.garmin.com/omt/express/GarminExpress.exe'
		}
		'Grammarly' = @{
			'winget' = 'Grammarly.Grammarly'
			'choco' = 'grammarly-for-windows'
			'url' = 'https://download-windows.grammarly.com/versions/1.0.51.1141/GrammarlyInstaller.exe'
		}
		'LibreOffice' = @{
			'winget' = 'TheDocumentFoundation.LibreOffice'
			'choco' = 'libreoffice-fresh'
			'url' = 'http://download.documentfoundation.org/libreoffice/stable/7.6.2/win/x86_64/LibreOffice_7.6.2_Win_x86-64.msi'
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
		'OpenOffice' = @{
			'winget' = 'Apache.OpenOffice'
			'choco' = 'openoffice'
			'url' = 'https://phoenixnap.dl.sourceforge.net/project/openofficeorg.mirror/4.1.14/binaries/en-GB/Apache_OpenOffice_4.1.14_Win_x86_install_en-GB.exe'
		}
		'QuickBooks' = @{
			'winget' = $null
			'choco' = $null
			'url' = 'https://irp.cdn-website.com/38f29423/files/uploaded/QuickBooks%20Desktop%20Setup.msi'
		}
		'Quicken' = @{
			'winget' = 'Quicken.Quicken'
			'choco' = $null
			'url' = 'https://download.quicken.com/windows/Quicken.exe'
		}
		'Slack' = @{
			'winget' = 'SlackTechnologies.Slack'
			'choco' = 'slack'
			'url' = 'https://downloads.slack-edge.com/releases/windows/4.35.126/prod/x64/slack-standalone-4.35.126.0.msi'
		}
		'Webex' = @{
			'winget' = 'Cisco.WebexTeams'
			'choco' = 'webex'
			'url' = 'https://binaries.webex.com/WebexTeamsDesktop-Windows-Web-Installer/Webex.exe'
		}
		'WPS Office' = @{
			'winget' = 'Kingsoft.WPSOffice.CN'
			'choco' = 'wps-office-free'
			'url' = 'https://official-package.wpscdn.cn/wps/download/WPS_Setup_15712.exe'
		}
		'Zoom' = @{
			'winget' = 'Zoom.Zoom'
			'choco' = 'zoom'
			'url' = 'https://cdn.zoom.us/prod/5.15.5.19404/x64/ZoomInstallerFull.exe'
		}
	}
	'Productivity (Creative)' = [ordered]@{
		'Adobe Creative Cloud' = @{
			'winget' = 'XPDLPKWG9SW2WD'
			'choco' = $null
			'url' = 'https://ffc-static-cdn.oobesaas.adobe.com/wam/2.10.0.17/win/Creative_Cloud_Set-Up.exe' #'https://ffc-static-cdn.oobesaas.adobe.com/wam/2.10.0.17/win/Creative_Cloud_Set-Up.exe?api_key=CreativeCloudStoreInstaller_v1_0'
		}
		'Audacity' = @{
			'winget' = 'Audacity.Audacity'
			'choco' = 'audacity'
			'url' = 'https://github.com/audacity/audacity/releases/download/Audacity-3.4.2/audacity-win-3.4.2-64bit.exe'
		}
		'CorelDRAW' = @{
			'winget' = 'XPDM28CQSPXTWQ'
			'choco' = $null
			'url' = 'https://www.corel.com/akdlm/6763/downloads/free/trials/GraphicsSuite/22H1/JL83s3fG/msstore_sf/CorelDRAWGraphicsSuiteInstaller.exe'
		}
		'FL Studio' = @{
			'winget' = 'ImageLine.FLStudio'
			'choco' = $null
			'url' = 'https://install.image-line.com/flstudio/flstudio_win64_21.2.2.3914.exe'
		}
		'GIMP' = @{
			'winget' = 'GIMP.GIMP'
			'choco' = 'gimp'
			'url' = 'https://download.gimp.org/gimp/v2.10/windows/gimp-2.10.36-setup.exe'
		}
		'OBS Studio' = @{
			'winget' = 'OBSProject.OBSStudio'
			'choco' = 'obs-studio'
			'url' = 'https://github.com/obsproject/obs-studio/releases/download/30.0.2/OBS-Studio-30.0.2-Full-Installer-x64.exe'
		}
		'paint.net' = @{
			'winget' = 'dotPDNLLC.paintdotnet'
			'choco' = 'paint.net'
			'url' = 'https://github.com/paintdotnet/release/releases/download/v5.0.12/paint.net.5.0.12.install.anycpu.web.zip'
		}
		'REAPER' = @{
			'winget' = 'Cockos.REAPER'
			'choco' = 'reaper'
			'url' = ' https://www.reaper.fm/files/7.x/reaper707_x64-install.exe'
		}
	}
	'System Utility' = [ordered]@{
		'AsRock Live Update' = @{
			'winget' = $null
			'choco' = $null #'app-shop'
			'url' = 'https://www.asrock.com/feature/appshop/dl.asp'
		}
		'ASUS Armoury Crate' = @{
			'winget' = 'ASUS.ArmouryCrate'
			'choco' = $null
			'url' = 'https://dlcdnets.asus.com/pub/ASUS/mb/14Utilities/ArmouryCrateInstallTool.zip'
		}
		'Dell SupportAssist' = @{
			'winget' = $null
			'choco' = 'supportassist'
			'url' = 'https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe'
		}
		'Gigabyte Control Center' = @{
			'winget' = $null
			'choco' = $null
			'url' = 'https://download.gigabyte.com/FileList/Utility/GCC_23.12.13.01.zip'
		}
		'HP Support Assistant' = @{
			'winget' = $null
			'choco' = $null #'hpsupportassistant'
			'url' = 'https://ftp.hp.com/pub/softpaq/sp148501-149000/sp148716.exe'
		}
		'Lenovo Vantage' = @{
			'winget' = '9WZDNCRFJ4MV'
			'choco' = $null
			'url' = $null
		}
		'MSI Center' = @{
			'winget' = '9NVMNJCR03XV'
			'choco' = $null
			'url' = 'https://download.msi.com/uti_exe/vga/MSI-Center.zip'
		}
		'MyASUS' = @{
			'winget' = '9N7R5S6B0ZZH'
			'choco' = $null
			'url' = $null
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
			'url' = 'https://downloadcenter.samsung.com/content/SW/201306/20130607155213176/Samsung_Magician_Setup_v.4.1.exe' #'https://download.semiconductor.samsung.com/resources/software-resources/Samsung_Magician_Installer_Official_7.3.0.1100.zip'
		}
		'Speccy' = @{
			'winget' = 'Piriform.Speccy'
			'choco' = 'speccy'
			'url' = 'https://download.ccleaner.com/spsetup132.exe'
		}
	}
}