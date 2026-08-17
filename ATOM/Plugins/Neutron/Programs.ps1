$installPrograms = [ordered]@{

    'Bitdefender' = @{
        Category = 'Anti-Virus'
        ToolTip  = 'Antivirus and malware protection'
        Winget = 'Bitdefender.Bitdefender'
        Choco  = $null
        Url    = 'https://download.bitdefender.com/windows/bp/agent/en-us/bitdefender_online.exe'
    }

    'MalwareBytes' = @{
        Category = 'Anti-Virus'
        ToolTip  = 'Malware detection and removal'
        Winget = 'MalwareBytes.MalwareBytes'
        Choco  = 'malwarebytes'
        Url    = 'https://data-cdn.mbamupdates.com/web/mb5-setup-consumer/offline/MBSetup.exe'
    }

    'Norton' = @{
        Category = 'Anti-Virus'
        ToolTip  = 'Antivirus and security suite'
        Winget = 'XPFNZKWN35KD6Z'
        Choco  = $null
        Url    = 'https://buy-download.norton.com/downloads/MSFT/DSP-N360-TW-MSFT-Def-22.23.4.6.exe'
    }

    'Trend Micro' = @{
        Category = 'Anti-Virus'
        ToolTip  = 'Antivirus and malware protection'
        #Winget = 'XPFMN72PV2VHD1'
        Choco  = $null
        Url    = 'https://files.trendmicro.com/products/Titanium/17.8/BBY/TTi_17.8_MR_Full.exe'
    }

    'Webroot' = @{
        Category = 'Anti-Virus'
        ToolTip  = 'Lightweight antivirus and security software'
        Winget = 'Webroot.SecureAnywhere'
        Choco  = $null
        Url    = 'https://anywhere.webrootcloudav.com/zerol/wsabbs2.exe'
    }

    'Brave' = @{
        Category = 'Browsers'
        ToolTip  = 'Privacy-focused web browser'
        Winget = 'Brave.Brave'
        Choco  = 'brave'
        Scoop  = 'brave'
        Url    = 'https://updates-cdn.bravesoftware.com/build/Brave-Release/x64-rel/win/131.1.73.97/brave_installer-x64.exe'
    }

    'Chromium' = @{
        Category = 'Browsers'
        ToolTip  = 'Open-source Chromium web browser'
        Winget = 'Hibbiki.Chromium'
        Choco  = 'chromium'
        Scoop  = 'chromium'
        Url    = 'https://github.com/Hibbiki/chromium-win64/releases/download/v130.0.6723.92-r1356013/mini_installer.sync.exe'
    }

    'Google Chrome' = @{
        Category = 'Browsers'
        ToolTip  = 'Google web browser'
        Winget = 'Google.Chrome'
        Choco  = 'googlechrome'
        Scoop  = 'googlechrome'
        Url    = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
    }

    'Microsoft Edge' = @{
        Category = 'Browsers'
        ToolTip  = 'Microsoft web browser'
        Winget = 'Microsoft.Edge'
        Choco  = 'microsoft-edge'
        Url    = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/a98e1079-88e9-4466-a014-6b9263129d5a/MicrosoftEdgeEnterpriseX64.msi'
    }

    'Mozilla Firefox' = @{
        Category = 'Browsers'
        ToolTip  = 'Open-source web browser'
        Winget = 'Mozilla.Firefox'
        Choco  = 'firefox'
        Scoop  = 'firefox'
        Url    = 'https://download-installer.cdn.mozilla.net/pub/firefox/releases/133.0/win64/en-US/Firefox%20Setup%20133.0.exe'
    }

    'Opera' = @{
        Category = 'Browsers'
        ToolTip  = 'Feature-rich web browser'
        Winget = 'Opera.Opera'
        Choco  = 'opera'
        Scoop  = 'opera'
        Url    = 'https://get.geo.opera.com/pub/opera/desktop/115.0.5322.77/win/Opera_115.0.5322.77_Setup_x64.exe'
    }

    'Opera GX' = @{
        Category = 'Browsers'
        ToolTip  = 'Gaming-focused Opera web browser'
        Winget = 'Opera.OperaGX'
        Choco  = 'opera-gx'
        Scoop  = 'opera-gx'
        Url    = 'https://get.geo.opera.com/pub/opera_gx/114.0.5282.248/win/Opera_GX_114.0.5282.248_Setup_x64.exe'
    }

    'Thorium' = @{
        Category = 'Browsers'
        ToolTip  = 'Performance-focused Chromium browser'
        Winget = 'Alex313031.Thorium'
        Choco  = $null
        Url    = 'https://github.com/Alex313031/Thorium-Win/releases/latest/download/thorium_mini_installer.exe'
    }

    'Tor Browser' = @{
        Category = 'Browsers'
        ToolTip  = 'Privacy-focused Tor web browser'
        Winget = 'TorProject.TorBrowser'
        Choco  = 'torbrowser'
        Scoop  = 'tor'
        Url    = 'https://archive.torproject.org/tor-package-archive/torbrowser/14.0.3/tor-browser-windows-x86_64-portable-14.0.3.exe'
    }

    'Waterfox' = @{
        Category = 'Browsers'
        ToolTip  = 'Privacy-focused Firefox-based browser'
        Winget = 'Waterfox.Waterfox'
        Choco  = 'waterfox'
        Scoop  = 'waterfox'
        Url    = 'https://cdn1.waterfox.net/waterfox/releases/G6.0.19/WINNT_x86_64/Waterfox%20Setup%20G6.0.19.exe'
    }

    'Dropbox' = @{
        Category = 'Cloud Services'
        ToolTip  = 'Cloud file sync and storage'
        Winget = 'Dropbox.Dropbox'
        Choco  = 'dropbox'
        Scoop  = 'dropbox-np'
        Url    = 'https://edge.dropboxstatic.com/dbx-releng/client/Dropbox%20213.4.4597%20Offline%20Installer.x64.exe'
    }

    'Google Drive' = @{
        Category = 'Cloud Services'
        ToolTip  = 'Google cloud file sync client'
        Winget = 'Google.GoogleDrive'
        Choco  = 'googledrive'
        Url    = 'https://dl.google.com/release2/drive-file-stream/ohigjqf3a7wmhcvqdlpdhw26ja_100.0.2.0/setup.exe'
    }

    'iCloud' = @{
        Category = 'Cloud Services'
        ToolTip  = 'Apple cloud sync client for Windows'
        Winget = '9PKTQ5699M62'
        Choco  = 'icloud'
        Url    = $null
    }

    'OneDrive' = @{
        Category = 'Cloud Services'
        ToolTip  = 'Microsoft cloud file sync client'
        Winget = 'Microsoft.OneDrive'
        Choco  = 'onedrive'
        Url    = 'https://oneclient.sfx.ms/Win/Installers/24.221.1103.0003/amd64/OneDriveSetup.exe'
    }

    'Git' = @{
        Category = 'Development'
        ToolTip  = 'Distributed version control system'
        Winget = 'Git.Git'
        Choco  = 'git'
        Url    = 'https://github.com/git-for-windows/git/releases/download/v2.47.1.windows.1/Git-2.47.1-64-bit.exe'
    }

    'GitHub Desktop' = @{
        Category = 'Development'
        ToolTip  = 'Desktop Git and GitHub client'
        Winget = 'GitHub.GitHubDesktop'
        Choco  = 'github-desktop'
        Url    = 'https://desktop.githubusercontent.com/releases/3.4.9-5be94b37/GitHubDesktopSetup-x64.exe'
    }

    'Python Launcher' = @{
        Category = 'Development'
        ToolTip  = 'Python version launcher for Windows'
        Winget = 'Python.Launcher'
        Choco  = $null
        Url    = 'https://www.python.org/ftp/python/3.12.0/win32/launcher.msi'
    }

    'Visual Studio Code' = @{
        Category = 'Development'
        ToolTip  = 'Code editor and development environment'
        Winget = 'Microsoft.VisualStudioCode'
        Choco  = 'vscode-install'
        Url    = 'https://vscode.download.prss.microsoft.com/dbazure/download/stable/f1a4fb101478ce6ec82fe9627c43efbf9e98c813/VSCodeUserSetup-x64-1.95.3.exe'
    }

    'AMD Auto Detect' = @{
        Category = 'Gaming'
        ToolTip  = 'Detects and installs AMD drivers'
        Winget = $null
        Choco  = $null
        Url    = 'https://drivers.amd.com/drivers/installer/24.20/whql/amd-software-adrenalin-edition-24.12.1-minimalsetup-241204_web.exe'
        Headers = @{"Referer"="https://www.amd.com/"}
    }

    'AMD Ryzen Chipset' = @{
        Category = 'Gaming'
        ToolTip  = 'AMD chipset driver package'
        Winget = $null
        Choco  = 'amd-ryzen-chipset'
        Url    = 'https://drivers.amd.com/drivers/amd_chipset_software_6.10.17.152.exe'
        Headers = @{"Referer"="https://www.amd.com/"}
    }

    'AMD Ryzen Master' = @{
        Category = 'Gaming'
        ToolTip  = 'AMD Ryzen CPU tuning and monitoring'
        Winget = $null
        Choco  = 'amd-ryzen-master'
        Url    = 'https://download.amd.com/Desktop/amd-ryzen-master.exe'
    }

    'Battle.net' = @{
        Category = 'Gaming'
        ToolTip  = 'Blizzard game launcher and client'
        Winget = $null #Blizzard.BattleNet
        Choco  = $null
        Url    = 'https://downloader.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP&version=Live'
    }

    'Corsair iCUE' = @{
        Category = 'Gaming'
        ToolTip  = 'Corsair RGB and device control'
        Winget = 'Corsair.iCUE.5'
        Choco  = $null #'icue'
        Url    = 'https://www3.corsair.com/software/CUE_V5/public/modules/windows/installer/Install%20iCUE.exe'
    }

    'Discord' = @{
        Category = 'Gaming'
        ToolTip  = 'Voice, video, and text chat'
        Winget = 'Discord.Discord'
        Choco  = 'discord'
        Scoop  = 'discord'
        Url    = 'https://stable.dl2.discordapp.net/distro/app/stable/win/x64/1.0.9173/DiscordSetup.exe'
    }

    'EA Desktop App' = @{
        Category = 'Gaming'
        ToolTip  = 'EA game launcher and client'
        Winget = 'ElectronicArts.EADesktop'
        Choco  = 'ea-app'
        Url    = 'https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller-13.356.0.5869-3421.exe'
    }

    'Epic Games Launcher' = @{
        Category = 'Gaming'
        ToolTip  = 'Epic game launcher and store'
        Winget = 'EpicGames.EpicGamesLauncher'
        Choco  = 'epicgameslauncher'
        Scoop  = 'epic-games-launcher'
        Url    = 'https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-15.17.1.msi'
    }

    'GeForce Experience' = @{
        Category = 'Gaming'
        ToolTip  = 'NVIDIA driver and game optimization utility'
        Winget = 'Nvidia.GeForceExperience'
        Choco  = 'geforce-experience'
        Url    = 'https://us.download.nvidia.com/GFE/GFEClient/3.28.0.417/GeForce_Experience_v3.28.0.417.exe'
    }

    'GeForce Game Ready Driver' = @{
        Category = 'Gaming'
        ToolTip  = 'NVIDIA gaming graphics driver'
        Winget = $null
        Choco  = 'geforce-game-ready-driver'
        Url    = 'https://us.download.nvidia.com/Windows/546.65/546.65-desktop-win10-win11-64bit-international-dch-whql.exe'
    }

    'GOG Galaxy' = @{
        Category = 'Gaming'
        ToolTip  = 'GOG game launcher and library manager'
        Winget = 'GOG.Galaxy'
        Choco  = 'goggalaxy'
        Scoop  = 'goggalaxy'
        Url    = 'https://gog-cdn-fastly.gog.com/open/galaxy/client/2.0.80.33/setup_galaxy_2.0.80.33.exe'
    }

    'Intel XTU' = @{
        Category = 'Gaming'
        ToolTip  = 'Intel CPU tuning and monitoring utility'
        Winget = $null
        Choco  = 'intel-xtu'
        Url    = 'https://downloadmirror.intel.com/29183/XTUSetup.exe'
    }

    'Logitech G HUB' = @{
        Category = 'Gaming'
        ToolTip  = 'Logitech gaming device configuration'
        Winget = 'Logitech.GHUB'
        Choco  = 'lghub'
        Url    = 'https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe'
    }

    'MSI Afterburner' = @{
        Category = 'Gaming'
        ToolTip  = 'GPU overclocking and monitoring utility'
        Winget = 'Guru3D.Afterburner'
        Choco  = 'msiafterburner'
        Scoop  = 'msiafterburner'
        Url    = 'https://download-1.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip'
    }

    'Nvidia App (Beta)' = @{
        Category = 'Gaming'
        ToolTip  = 'NVIDIA driver and graphics management app'
        Winget = $null
        Choco  = $null
        Url    = 'https://us.download.nvidia.com/nvapp/client/11.0.1.184/NVIDIA_app_v11.0.1.184.exe'
    }

    'NZXT CAM' = @{
        Category = 'Gaming'
        ToolTip  = 'NZXT hardware monitoring and control'
        Winget = 'NZXT.CAM'
        Choco  = 'nzxt-cam'
        Url    = 'https://nzxt-app.nzxt.com/NZXT-CAM-Setup.exe'
    }

    'Razer Synapse 3' = @{
        Category = 'Gaming'
        ToolTip  = 'Razer device configuration and RGB control'
        Winget = 'RazerInc.RazerInstaller'
        Choco  = 'razer-synapse-3'
        Url    = 'https://dl.razerzone.com/drivers/Synapse3/win/RazerSynapseInstaller_V1.15.0.504.exe'
    }

    'SignalRGB' = @{
        Category = 'Gaming'
        ToolTip  = 'Unified RGB lighting control'
        Winget = 'WhirlwindFX.SignalRgb'
        Choco  = $null
        Url    = 'https://release.signalrgb.com/Install_SignalRgb.exe'
    }

    'Steam' = @{
        Category = 'Gaming'
        ToolTip  = 'PC game launcher and store'
        Winget = 'Valve.Steam'
        Choco  = 'steam'
        Scoop  = 'steam'
        Url    = 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
    }

    'Amazon Music' = @{
        Category = 'Media'
        ToolTip  = 'Music streaming desktop app'
        Winget = 'Amazon.Music'
        Choco  = $null
        Url    = 'https://d2j9xt6n9dg5d3.cloudfront.net/win/23861115_85d5deb94597adc2d891a921c0bf51c9/AmazonMusicInstaller.exe'
    }

    'foobar2000' = @{
        Category = 'Media'
        ToolTip  = 'Lightweight audio player'
        Winget = 'PeterPawlowski.foobar2000'
        Choco  = 'foobar2000'
        Scoop  = 'foobar2000'
        Url    = 'https://www.foobar2000.org/files/foobar2000-x64_v2.24.exe'
    }

    'iTunes' = @{
        Category = 'Media'
        ToolTip  = 'Apple media library and device manager'
        Winget = 'Apple.iTunes'
        Choco  = 'itunes'
        Url    = 'https://www.apple.com/itunes/download/win64/'
    }

    'Spotify' = @{
        Category = 'Media'
        ToolTip  = 'Music streaming desktop app'
        Winget = 'Spotify.Spotify'
        Choco  = 'spotify'
        Scoop  = 'spotify'
        Url    = 'https://upgrade.scdn.co/upgrade/client/win32-x86_64/spotify_installer-1.2.52.442.g01893f92-588.exe'
        NoAdmin= $true
    }

    'TIDAL' = @{
        Category = 'Media'
        ToolTip  = 'High-fidelity music streaming app'
        Winget = 'TIDALMusicAS.TIDAL'
        Choco  = 'tidal'
        Url    = 'https://download.tidal.com/desktop/TIDALSetup.exe'
    }

    'VLC' = @{
        Category = 'Media'
        ToolTip  = 'Multimedia player for audio and video'
        Winget = 'VideoLAN.VLC'
        Choco  = 'vlc'
        Scoop  = 'vlc'
        Url    = 'https://download.videolan.org/videolan/vlc/3.0.21/win64/vlc-3.0.21-win64.exe'
    }

    'Visual C++ 2015-2022 64-bit' = @{
        Category = 'Miscellaneous'
        ToolTip  = '64-bit Microsoft Visual C++ runtime'
        Winget = 'Microsoft.VCRedist.2015+.x64'
        Choco  = 'vcredist140'
        Scoop  = 'vcredist'
        Url    = 'https://download.visualstudio.microsoft.com/download/pr/c7dac50a-e3e8-40f6-bbb2-9cc4e3dfcabe/1821577409C35B2B9505AC833E246376CC68A8262972100444010B57226F0940/VC_redist.x64.exe'
    }

    'Visual C++ 2015-2022 32-bit' = @{
        Category = 'Miscellaneous'
        ToolTip  = '32-bit Microsoft Visual C++ runtime'
        Winget = 'Microsoft.VCRedist.2015+.x86'
        Choco  = 'vcredist140 --x86'
        Scoop  = 'vcredist -a x86'
        Url    = 'https://download.visualstudio.microsoft.com/download/pr/5319f718-2a84-4aff-86be-8dbdefd92ca1/DD1A8BE03398367745A87A5E35BEBDAB00FDAD080CF42AF0C3F20802D08C25D4/VC_redist.x86.exe'
    }

    'Adobe Acrobat Reader' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'PDF reader and document viewer'
        Winget = 'Adobe.Acrobat.Reader.64-bit'
        Choco  = 'adobereader'
        Url    = 'https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2400520307/AcroRdrDCx642400520307_MUI.exe'
    }

    'Garmin Express' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Garmin device update and sync utility'
        Winget = 'Garmin.Express'
        Choco  = 'garmin-express'
        Url    = 'https://download.garmin.com/omt/express/GarminExpress.exe'
    }

    'Grammarly' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Writing and grammar assistant'
        Winget = 'Grammarly.Grammarly'
        Choco  = 'grammarly-for-windows'
        Scoop  = 'grammarly-np'
        Url    = 'https://download-windows.grammarly.com/versions/1.2.120.1558/GrammarlyInstaller.exe'
    }

    'LibreOffice' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Free office productivity suite'
        Winget = 'TheDocumentFoundation.LibreOffice'
        Choco  = 'libreoffice-fresh'
        Scoop  = 'libreoffice'
        Url    = 'https://download.documentfoundation.org/libreoffice/stable/24.8.3/win/x86_64/LibreOffice_24.8.3_Win_x86-64.msi'
    }

    'Microsoft Office' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Microsoft productivity suite'
        Winget = 'Microsoft.Office'
        Choco  = 'office365homepremium'
        Scoop  = 'office-365-apps-np'
        Url    = 'https://officecdn.microsoft.com/pr/wsus/setup.exe'
    }

    'Microsoft Teams' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Work chat and video meetings'
        Winget = 'Microsoft.Teams'
        Choco  = 'microsoft-teams'
        Scoop  = 'microsoft-teams'
        Url    = 'https://installer.teams.static.microsoft/production-windows-x64/24295.605.3225.8804/MSTeams-x64.msix'
    }

    'OpenOffice' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Free office productivity suite'
        Winget = 'Apache.OpenOffice'
        Choco  = 'openoffice'
        Scoop  = 'openoffice'
        Url    = 'https://downloads.apache.org/openoffice/4.1.15/binaries/en-US/Apache_OpenOffice_4.1.15_Win_x86_install_en-US.exe'
    }

    'Quicken' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Personal finance management software'
        Winget = 'Quicken.Quicken'
        Choco  = $null
        Url    = 'https://download.quicken.com/windows/Quicken.exe'
    }

    'Slack' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Team messaging and collaboration app'
        Winget = 'SlackTechnologies.Slack'
        Choco  = 'slack'
        Scoop  = 'slack'
        Url    = 'https://downloads.slack-edge.com/desktop-releases/windows/x64/4.41.104/SlackSetup.exe'
    }

    'Webex' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Video meetings and collaboration app'
        Winget = 'Cisco.CiscoWebexMeetings'
        Choco  = 'webex'
        Scoop  = 'webex'
        Url    = 'https://akamaicdn.webex.com/client/webexapp.msi'
    }

    'WPS Office' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Office productivity suite'
        Winget = 'Kingsoft.WPSOffice.CN'
        Choco  = 'wps-office-free'
        Scoop  = 'wpsoffice'
        Url    = 'https://official-package.wpscdn.cn/wps/download/WPS_Setup_19302.exe'
    }

    'Zoom' = @{
        Category = 'Productivity (Business)'
        ToolTip  = 'Video meetings and conferencing app'
        Winget = 'Zoom.Zoom'
        Choco  = 'zoom'
        Scoop  = 'zoom'
        Url    = 'https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=x64'
    }

    'Adobe Creative Cloud' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Adobe app installer and manager'
        Winget = 'XPDLPKWG9SW2WD'
        Choco  = $null
        Url    = 'https://ffc-static-cdn.oobesaas.adobe.com/wam/2.10.0.17/win/Creative_Cloud_Set-Up.exe?api_key=CreativeCloudStoreInstaller_v1_0'
    }

    'Audacity' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Audio recording and editing software'
        Winget = 'Audacity.Audacity'
        Choco  = 'audacity'
        Scoop  = 'audacity'
        Url    = 'https://github.com/audacity/audacity/releases/download/Audacity-3.7.0/audacity-win-3.7.0-64bit.exe'
    }

    'CorelDRAW' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Vector graphics and design suite'
        Winget = 'XPDM28CQSPXTWQ'
        Choco  = $null
        Url    = 'https://www.corel.com/akdlm/6763/downloads/free/trials/GraphicsSuite/22H1/JL83s3fG/msstore_sf/CorelDRAWGraphicsSuiteInstaller.exe'
    }

    'FL Studio' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Digital audio workstation for music production'
        Winget = 'ImageLine.FLStudio'
        Choco  = $null
        Url    = 'https://install.image-line.com/flstudio/flstudio_win64_24.2.0.4503.exe'
    }

    'GIMP' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Image editing and graphics software'
        Winget = 'GIMP.GIMP'
        Choco  = 'gimp'
        Scoop  = 'gimp'
        Url    = 'https://download.gimp.org/gimp/v2.10/windows/gimp-2.10.38-setup-1.exe'
    }

    'OBS Studio' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Video recording and live streaming'
        Winget = 'OBSProject.OBSStudio'
        Choco  = 'obs-studio'
        Scoop  = 'obs-studio'
        Url    = 'https://github.com/obsproject/obs-studio/releases/download/31.0.0/OBS-Studio-31.0.0-Windows-Installer.exe'
    }

    'paint.net' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Lightweight image editor'
        Winget = 'dotPDN.PaintDotNet'
        Choco  = 'paint.net'
        Scoop  = 'paint.net'
        Url    = 'https://github.com/paintdotnet/release/releases/download/v5.1.1/paint.net.5.1.1.install.x64.zip'
    }

    'REAPER' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Digital audio workstation'
        Winget = 'Cockos.REAPER'
        Choco  = 'reaper'
        Scoop  = 'reaper'
        Url    = 'https://www.reaper.fm/files/7.x/reaper727_x64-install.exe'
    }

    'Streamlabs Desktop' = @{
        Category = 'Productivity (Creative)'
        ToolTip  = 'Live streaming and recording software'
        Winget = 'Streamlabs.Streamlabs'
        Choco  = 'streamlabs-obs'
        Scoop  = 'streamlabs-obs'
        Url    = 'https://slobs-cdn.streamlabs.com/Streamlabs+Desktop+Setup+1.16.4.exe'
    }

    'AsRock Live Update' = @{
        Category = 'System Utility'
        ToolTip  = 'ASRock driver and utility updater'
        Winget = $null
        Choco  = $null #'app-shop'
        Url    = 'https://www.asrock.com/feature/appshop/dl.asp'
    }

    'ASUS Armoury Crate' = @{
        Category = 'System Utility'
        ToolTip  = 'ASUS hardware control and updates'
        Winget = 'ASUS.ArmouryCrate'
        Choco  = $null
        Url    = 'https://dlcdnets.asus.com/pub/ASUS/mb/14Utilities/ArmouryCrateInstallTool.zip'
    }

    'Dell Command Update' = @{
        Category = 'System Utility'
        ToolTip  = 'Dell driver and firmware updater'
        Winget = 'Dell.CommandUpdate.Universal'
        Choco  = 'dellcommandupdate-uwp'
        Url    = 'https://dl.dell.com/FOLDER11914128M/1/Dell-Command-Update-Windows-Universal-Application_9M35M_WIN_5.4.0_A00.EXE'
    }

    'Dell SupportAssist' = @{
        Category = 'System Utility'
        ToolTip  = 'Dell diagnostics and support utility'
        Winget = $null
        Choco  = 'supportassist'
        Url    = 'https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe'
    }

    'Gigabyte Control Center' = @{
        Category = 'System Utility'
        ToolTip  = 'Gigabyte hardware control and updates'
        Winget = $null
        Choco  = $null
        Url    = 'https://download.gigabyte.com/FileList/Utility/GCC_23.12.13.01.zip'
    }

    'HP Image Assistant' = @{
        Category = 'System Utility'
        ToolTip  = 'HP driver and image maintenance utility'
        Winget = 'HP.ImageAssistant'
        Choco  = $null
        Scoop  = $null
        Url    = 'https://hpia.hpcloud.hp.com/downloads/hpia/hp-hpia-5.3.0.exe'
    }

    'HP Support Assistant' = @{
        Category = 'System Utility'
        ToolTip  = 'HP diagnostics and support utility'
        Winget = $null
        Choco  = $null #'hpsupportassistant'
        Scoop  = 'hp-support-assistant-np'
        Url    = 'https://ftp.hp.com/pub/softpaq/sp148501-149000/sp148716.exe'
    }

    'Lenovo System Update' = @{
        Category = 'System Utility'
        ToolTip  = 'Lenovo driver and firmware updater'
        Winget = 'Lenovo.SystemUpdate'
        Choco  = 'lenovo-thinkvantage-system-update'
        Url    = 'https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.03.59.exe'
    }

    'Lenovo Thin Installer' = @{
        Category = 'System Utility'
        ToolTip  = 'Lenovo unattended update installer'
        Winget = 'Lenovo.ThinInstaller'
        Choco  = $null
        Url    = 'https://download.lenovo.com/pccbbs/thinkvantage_en/lenovo_thininstaller_1.04.02.00024.exe'
    }

    'Lenovo Update Retriever' = @{
        Category = 'System Utility'
        ToolTip  = 'Lenovo update repository manager'
        Winget = 'Lenovo.UpdateRetriever'
        Choco  = $null
        Url    = 'https://download.lenovo.com/pccbbs/thinkvantage_en/updateretriever_5.08.01.30.exe'
    }

    'Lenovo Vantage' = @{
        Category = 'System Utility'
        ToolTip  = 'Lenovo device settings and support'
        Winget = '9WZDNCRFJ4MV'
        Choco  = $null
        Url    = $null
    }

    'MSI Center' = @{
        Category = 'System Utility'
        ToolTip  = 'MSI hardware control and updates'
        Winget = '9NVMNJCR03XV'
        Choco  = $null
        Url    = 'https://download.msi.com/uti_exe/vga/MSI-Center.zip'
    }

    'MyASUS' = @{
        Category = 'System Utility'
        ToolTip  = 'ASUS device support and settings'
        Winget = '9N7R5S6B0ZZH'
        Choco  = $null
        Url    = $null
    }

    '7-Zip' = @{
        Category = 'Tools'
        ToolTip  = 'File archiver and compression utility'
        Winget = '7Zip.7Zip'
        Choco  = '7zip'
        Scoop  = '7zip'
        Url    = 'https://7-zip.org/a/7z2409-x64.exe'
    }

    'CPU-Z' = @{
        Category = 'Tools'
        ToolTip  = 'CPU and hardware information utility'
        Winget = 'CPUID.CPU-Z'
        Choco  = 'cpu-z'
        Scoop  = 'cpu-z'
        Url    = 'https://download.cpuid.com/cpu-z/cpu-z_2.12-en.exe'
    }

    'HWiNFO' = @{
        Category = 'Tools'
        ToolTip  = 'Detailed hardware monitoring and information'
        Winget = 'REALiX.HWiNFO'
        Choco  = 'hwinfo'
        Scoop  = 'hwinfo'
        Url    = 'https://www.sac.sk/download/utildiag/hwi_816x.exe'
    }

    'HWMonitor' = @{
        Category = 'Tools'
        ToolTip  = 'Hardware temperature and voltage monitor'
        Winget = 'CPUID.HWMonitor'
        Choco  = 'hwmonitor'
        Scoop  = 'hwmonitor'
        Url    = 'https://download.cpuid.com/hwmonitor/hwmonitor_1.55.exe'
    }

    'Notepad++' = @{
        Category = 'Tools'
        ToolTip  = 'Advanced text and code editor'
        Winget = 'Notepad++.Notepad++'
        Choco  = 'notepadplusplus'
        Scoop  = 'notepadplusplus'
        Url    = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.Installer.x64.exe'
    }

    'Samsung Data Migration' = @{
        Category = 'Tools'
        ToolTip  = 'Clone data to Samsung SSDs'
        Winget = $null
        Choco  = $null
        Url    = 'https://semiconductor.samsung.com/resources/software-resources/Samsung_Data_Migration_Setup_4.0.0.18.exe'
    }

    'Samsung Magician' = @{
        Category = 'Tools'
        ToolTip  = 'Samsung SSD management and diagnostics'
        Winget = $null #'Samsung.SamsungMagician'
        Choco  = 'samsung-magician'
        Url    = 'https://download.semiconductor.samsung.com/resources/software-resources/Samsung_Magician_Installer_Official_8.0.1.1000.exe'
    }

    'Speccy' = @{
        Category = 'Tools'
        ToolTip  = 'System hardware information utility'
        Winget = 'Piriform.Speccy'
        Choco  = 'speccy'
        Scoop  = 'speccy'
        Url    = 'https://download.ccleaner.com/spsetup133.exe'
    }

}
