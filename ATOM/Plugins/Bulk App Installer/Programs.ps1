$installPrograms = [ordered]@{

    '1Password' = @{
        Category = 'Security'
        ToolTip  = 'Encrypted password manager and secure vault'
        Winget = 'AgileBits.1Password'
        Choco  = '1password'
        Scoop  = $null
        Url    = $null
    }

    'Proton Pass' = @{
        Category = 'Security'
        ToolTip  = 'End-to-end encrypted password manager'
        Winget = $null
        Choco  = 'protonpass'
        Scoop  = 'extras/proton-pass'
        Url    = 'https://proton.me/download/PassDesktop/win32/x64/ProtonPass_Setup.exe'
    }

    'NordVPN' = @{
        Category = 'Remote Access & VPN'
        ToolTip  = 'VPN client for encrypted private browsing'
        Winget = 'NordVPN.NordVPN'
        Choco  = 'nordvpn'
        Scoop  = $null
        Url    = $null
    }

    'NordPass' = @{
        Category = 'Security'
        ToolTip  = 'Password manager from Nord Security'
        Winget = 'NordPassTeam.NordPass'
        Choco  = 'nordpass'
        Scoop  = 'extras/nordpass'
        Url    = $null
    }

    'EmulationStation' = @{
        Category = 'Gaming'
        ToolTip  = 'Themeable front-end for organizing emulator libraries; emulators and games are not included'
        Winget = 'Emulationstation.Emulationstation'
        Choco  = 'emulationstation'
        Scoop  = 'games/es-de'
        Url    = $null
    }

    'Avast Free Antivirus' = @{
        Category = 'Security'
        ToolTip  = 'Free real-time antivirus protection; choose one primary antivirus'
        Winget = 'XP8BX2DWV7TF50'
        Choco  = 'avastfreeantivirus'
        Scoop  = $null
        Url    = 'https://bits.avcdn.net/productfamily_ANTIVIRUS/insttype_FREE/platform_WIN_AVG/installertype_ONLINE/build_RELEASE'
    }

    'ESET Security' = @{
        Category = 'Security'
        ToolTip  = 'Real-time antivirus suite; requires activation or a trial'
        Winget = 'ESET.Security'
        Choco  = 'eset-internet-security'
        Scoop  = $null
        Url    = $null
    }

    'Emsisoft Emergency Kit' = @{
        Category = 'Security'
        ToolTip  = 'On-demand malware scanner; not a replacement for real-time antivirus'
        Winget = 'Emsisoft.EmergencyKit'
        Choco  = 'emsisoft-emergency-kit'
        Scoop  = $null
        Url    = $null
    }

    'Microsoft Safety Scanner' = @{
        Category = 'Security'
        ToolTip  = 'On-demand malware scanner; download a fresh copy before use; expires after 10 days'
        Winget = 'Microsoft.SafetyScanner'
        Choco  = $null
        Scoop  = $null
        Url    = $null
    }


    'Playnite' = @{
        Category = 'Gaming'
        ToolTip  = 'Unified PC game library manager'
        Winget = 'Playnite.Playnite'
        Choco  = 'playnite'
        Scoop  = 'extras/playnite'
        Url    = $null
    }

    'Ubisoft Connect' = @{
        Category = 'Gaming'
        ToolTip  = 'Ubisoft game launcher and library'
        Winget = 'Ubisoft.Connect'
        Choco  = 'ubisoft-connect'
        Scoop  = $null
        Url    = $null
    }

    'Xbox' = @{
        Category = 'Gaming'
        ToolTip  = 'Xbox PC app and Game Pass; requires Microsoft Store'
        Winget = '9MV0B5HZVK9Z'
        Choco  = $null
        Scoop  = $null
        Url    = $null
    }

    'Amazon Games' = @{
        Category = 'Gaming'
        ToolTip  = 'Amazon Games launcher and library'
        Winget = 'Amazon.Games'
        Choco  = 'amazongames'
        Scoop  = $null
        Url    = $null
    }

    'itch.io' = @{
        Category = 'Gaming'
        ToolTip  = 'Independent game storefront and launcher'
        Winget = 'ItchIo.Itch'
        Choco  = 'itch'
        Scoop  = 'games/itch'
        Url    = $null
    }

    'Heroic Games Launcher' = @{
        Category = 'Gaming'
        ToolTip  = 'Alternative launcher for Epic Games, GOG, and Amazon games'
        Winget = 'HeroicGamesLauncher.HeroicGamesLauncher'
        Choco  = 'heroic-games-launcher'
        Scoop  = 'games/heroic-games-launcher'
        Url    = $null
    }

    'RetroArch' = @{
        Category = 'Gaming'
        ToolTip  = 'Multi-system emulation frontend; games are not included'
        Winget = 'Libretro.RetroArch'
        Choco  = 'retroarch'
        Scoop  = 'extras/retroarch'
        Url    = $null
    }

    'Dolphin' = @{
        Category = 'Gaming'
        ToolTip  = 'Nintendo GameCube and Wii emulator; games are not included'
        Winget = 'DolphinEmulator.Dolphin'
        Choco  = 'dolphin'
        Scoop  = 'games/dolphin'
        Url    = $null
    }

    'PCSX2' = @{
        Category = 'Gaming'
        ToolTip  = 'PlayStation 2 emulator; requires your own BIOS and games'
        Winget = 'PCSX2Team.PCSX2'
        Choco  = 'pcsx2'
        Scoop  = 'games/pcsx2'
        Url    = $null
    }

    'PPSSPP' = @{
        Category = 'Gaming'
        ToolTip  = 'PlayStation Portable emulator; games are not included'
        Winget = 'PPSSPPTeam.PPSSPP'
        Choco  = 'ppsspp'
        Scoop  = 'games/ppsspp'
        Url    = $null
    }

    'RPCS3' = @{
        Category = 'Gaming'
        ToolTip  = 'PlayStation 3 emulator; Scoop downloads official firmware requiring manual setup; games are not included'
        Winget = $null
        Choco  = 'rpcs3'
        Scoop  = 'games/rpcs3'
        Url    = $null
    }

    'Sunshine' = @{
        Category = 'Gaming'
        ToolTip  = 'Game streaming host for Moonlight clients'
        Winget = 'LizardByte.Sunshine'
        Choco  = 'sunshine'
        Scoop  = 'extras/sunshine'
        Url    = $null
    }

    'MEGA' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'MEGA cloud storage synchronization'
        Winget = 'Mega.MEGASync'
        Choco  = 'megasync'
        Scoop  = 'extras/megasync'
        Url    = $null
    }

    'pCloud' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'pCloud virtual drive and cloud storage'
        Winget = 'pCloudAG.pCloudDrive'
        Choco  = 'pcloud'
        Scoop  = $null
        Url    = $null
    }

    'Nextcloud Desktop' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'Synchronize files with a Nextcloud server'
        Winget = 'Nextcloud.NextcloudDesktop'
        Choco  = 'nextcloud-client'
        Scoop  = 'extras/nextcloud'
        Url    = $null
    }

    'ownCloud Desktop' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'Synchronize files with an ownCloud server'
        Winget = 'ownCloud.ownCloudDesktop'
        Choco  = 'owncloud-client'
        Scoop  = 'extras/owncloud'
        Url    = $null
    }


    '.NET Desktop Runtime 8' = @{
        Category = 'Runtimes'
        ToolTip  = 'Run Windows desktop applications targeting .NET 8'
        Winget = 'Microsoft.DotNet.DesktopRuntime.8'
        Choco  = 'dotnet-8.0-desktopruntime'
        Scoop  = 'versions/windowsdesktop-runtime-8.0'
        Url    = $null
    }

    '.NET Desktop Runtime 10' = @{
        Category = 'Runtimes'
        ToolTip  = 'Run Windows desktop applications targeting .NET 10'
        Winget = 'Microsoft.DotNet.DesktopRuntime.10'
        Choco  = 'dotnet-10.0-desktopruntime'
        Scoop  = 'versions/windowsdesktop-runtime-10.0'
        Url    = $null
    }

    '.NET Framework 4.8.1' = @{
        Category = 'Runtimes'
        ToolTip  = 'Microsoft .NET Framework runtime for compatible Windows versions'
        Winget = 'Microsoft.DotNet.Framework.Runtime'
        Choco  = 'dotnetfx'
        Scoop  = $null
        Url    = $null
    }

    'Microsoft Edge WebView2 Runtime' = @{
        Category = 'Runtimes'
        ToolTip  = 'Web rendering runtime used by desktop applications'
        Winget = 'Microsoft.EdgeWebView2Runtime'
        Choco  = 'webview2-runtime'
        Scoop  = $null
        Url    = $null
    }

    'DirectX End-User Runtime (Legacy)' = @{
        Category = 'Runtimes'
        ToolTip  = 'Legacy DirectX libraries required by older games and applications'
        Winget = 'Microsoft.DirectX'
        Choco  = 'directx'
        Scoop  = $null
        Url    = $null
    }

    'Visual C++ 2013 64-bit (Legacy)' = @{
        Category = 'Runtimes'
        ToolTip  = 'Legacy 64-bit Visual C++ 2013 runtime; install only when required'
        Winget = 'Microsoft.VCRedist.2013.x64'
        Choco  = 'vcredist2013'
        Scoop  = $null
        Url    = $null
    }

    'Visual C++ 2013 32-bit (Legacy)' = @{
        Category = 'Runtimes'
        ToolTip  = 'Legacy 32-bit Visual C++ 2013 runtime; also needed by some apps on 64-bit Windows'
        Winget = 'Microsoft.VCRedist.2013.x86'
        Choco  = 'vcredist2013'
        Scoop  = $null
        Url    = $null
    }

    'Java Runtime 21 (Temurin)' = @{
        Category = 'Development'
        ToolTip  = 'OpenJDK Java 21 runtime for Java applications'
        Winget = 'EclipseAdoptium.Temurin.21.JRE'
        Choco  = 'temurin21jre'
        Scoop  = 'java/temurin21-jre'
        Url    = $null
    }

    'Java Runtime 25 (Temurin)' = @{
        Category = 'Development'
        ToolTip  = 'OpenJDK Java 25 runtime for Java applications'
        Winget = 'EclipseAdoptium.Temurin.25.JRE'
        Choco  = $null
        Scoop  = 'java/temurin25-jre'
        Url    = $null
    }

    'Node.js LTS' = @{
        Category = 'Development'
        ToolTip  = 'Long-term support JavaScript runtime with npm'
        Winget = 'OpenJS.NodeJS.LTS'
        Choco  = 'nodejs-lts'
        Scoop  = 'main/nodejs-lts'
        Url    = $null
    }

    'Python 3.14' = @{
        Category = 'Development'
        ToolTip  = 'Python interpreter and standard library'
        Winget = 'Python.Python.3.14'
        Choco  = 'python'
        Scoop  = 'versions/python314'
        Url    = $null
    }


    'Bitwarden' = @{
        Category = 'Security'
        ToolTip  = 'Password manager with synchronized vaults'
        Winget = 'Bitwarden.Bitwarden'
        Choco  = 'bitwarden'
        Scoop  = 'extras/bitwarden'
        Url    = $null
    }

    'KeePassXC' = @{
        Category = 'Security'
        ToolTip  = 'Offline password manager with an encrypted local database'
        Winget = 'KeePassXCTeam.KeePassXC'
        Choco  = 'keepassxc'
        Scoop  = 'extras/keepassxc'
        Url    = $null
    }

    'Thunderbird' = @{
        Category = 'Communication'
        ToolTip  = 'Email, calendar, and contacts client'
        Winget = 'Mozilla.Thunderbird'
        Choco  = 'thunderbird'
        Scoop  = 'extras/thunderbird'
        Url    = $null
    }

    'PowerToys' = @{
        Category = 'System Utilities'
        ToolTip  = 'Windows productivity and customization utilities'
        Winget = 'Microsoft.PowerToys'
        Choco  = 'powertoys'
        Scoop  = 'extras/powertoys'
        Url    = $null
    }

    'WinSCP' = @{
        Category = 'Development'
        ToolTip  = 'Secure file transfers using SFTP, SCP, and other protocols'
        Winget = 'WinSCP.WinSCP'
        Choco  = 'winscp'
        Scoop  = 'extras/winscp'
        Url    = $null
    }

    'SumatraPDF' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Lightweight PDF and ebook reader'
        Winget = 'SumatraPDF.SumatraPDF'
        Choco  = 'sumatrapdf'
        Scoop  = 'extras/sumatrapdf'
        Url    = $null
    }

    'HandBrake' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Video conversion and encoding'
        Winget = 'HandBrake.HandBrake'
        Choco  = 'handbrake'
        Scoop  = 'extras/handbrake'
        Url    = $null
    }

    'CrystalDiskInfo' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Drive health and temperature monitoring'
        Winget = 'CrystalDewWorld.CrystalDiskInfo'
        Choco  = 'crystaldiskinfo'
        Scoop  = 'extras/crystaldiskinfo'
        Url    = $null
    }

    'Bitdefender' = @{
        Category = 'Security'
        ToolTip  = 'Antivirus and malware protection'
        Winget = 'Bitdefender.Bitdefender'
        Choco  = $null
        Url    = 'https://download.bitdefender.com/windows/bp/agent/en-us/bitdefender_online.exe'
    }

    'MalwareBytes' = @{
        Category = 'Security'
        ToolTip  = 'Malware detection and removal'
        Winget = 'MalwareBytes.MalwareBytes'
        Choco  = 'malwarebytes'
        Url    = 'https://data-cdn.mbamupdates.com/web/mb5-setup-consumer/offline/MBSetup.exe'
    }

    'Norton' = @{
        Category = 'Security'
        ToolTip  = 'Antivirus and security suite'
        Winget = 'XPFNZKWN35KD6Z'
        Choco  = $null
        Url    = 'https://buy-download.norton.com/downloads/MSFT/DSP-N360-TW-MSFT-Def-22.23.4.6.exe'
    }

    'Trend Micro' = @{
        Category = 'Security'
        ToolTip  = 'Antivirus and malware protection'
        #Winget = 'XPFMN72PV2VHD1'
        Choco  = $null
        Url    = 'https://files.trendmicro.com/products/Titanium/17.8/BBY/TTi_17.8_MR_Full.exe'
    }

    'Webroot' = @{
        Category = 'Security'
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
        Scoop  = 'extras/brave'
        Url    = 'https://updates-cdn.bravesoftware.com/build/Brave-Release/x64-rel/win/131.1.73.97/brave_installer-x64.exe'
    }

    'Chromium' = @{
        Category = 'Browsers'
        ToolTip  = 'Open-source Chromium web browser'
        Winget = 'Hibbiki.Chromium'
        Choco  = 'chromium'
        Scoop  = 'extras/chromium'
        Url    = 'https://github.com/Hibbiki/chromium-win64/releases/download/v130.0.6723.92-r1356013/mini_installer.sync.exe'
    }

    'Google Chrome' = @{
        Category = 'Browsers'
        ToolTip  = 'Google web browser'
        Winget = 'Google.Chrome'
        Choco  = 'googlechrome'
        Scoop  = 'extras/googlechrome'
        Url    = 'https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi'
    }

    'LibreWolf' = @{
        Category = 'Browsers'
        ToolTip  = 'Privacy-focused Firefox'
        Winget = 'LibreWolf.LibreWolf'
        Choco  = 'librewolf'
        Scoop  = 'extras/librewolf'
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
        Scoop  = 'extras/firefox'
        Url    = 'https://download-installer.cdn.mozilla.net/pub/firefox/releases/133.0/win64/en-US/Firefox%20Setup%20133.0.exe'
    }

    'Opera' = @{
        Category = 'Browsers'
        ToolTip  = 'Feature-rich web browser'
        Winget = 'Opera.Opera'
        Choco  = 'opera'
        Scoop  = 'extras/opera'
        Url    = 'https://get.geo.opera.com/pub/opera/desktop/115.0.5322.77/win/Opera_115.0.5322.77_Setup_x64.exe'
    }

    'Opera GX' = @{
        Category = 'Browsers'
        ToolTip  = 'Gaming-focused Opera web browser'
        Winget = 'Opera.OperaGX'
        Choco  = 'opera-gx'
        Scoop  = 'extras/opera-gx'
        Url    = 'https://get.geo.opera.com/pub/opera_gx/114.0.5282.248/win/Opera_GX_114.0.5282.248_Setup_x64.exe'
    }

    'Vivaldi' = @{
        Category = 'Browsers'
        ToolTip  = 'Customizable web browser with advanced tab management'
        Winget = 'Vivaldi.Vivaldi'
        Choco  = 'vivaldi'
        Scoop  = 'extras/vivaldi'
        Url    = $null
    }

    'Tor Browser' = @{
        Category = 'Browsers'
        ToolTip  = 'Privacy-focused Tor web browser'
        Winget = 'TorProject.TorBrowser'
        Choco  = 'torbrowser'
        Scoop  = 'extras/tor-browser'
        Url    = 'https://archive.torproject.org/tor-package-archive/torbrowser/14.0.3/tor-browser-windows-x86_64-portable-14.0.3.exe'
    }

    'Waterfox' = @{
        Category = 'Browsers'
        ToolTip  = 'Privacy-focused Firefox-based browser'
        Winget = 'Waterfox.Waterfox'
        Choco  = 'waterfox'
        Scoop  = 'extras/waterfox'
        Url    = 'https://cdn1.waterfox.net/waterfox/releases/G6.0.19/WINNT_x86_64/Waterfox%20Setup%20G6.0.19.exe'
    }

    'Zen Browser' = @{
        Category = 'Browsers'
        ToolTip  = 'Producivity-focused Firefox-based browser'
        Winget = 'Zen-Team.Zen-Browser'
        Choco  = 'zen-browser'
        Scoop  = 'extras/zen-browser'
    }

    'Dropbox' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'Cloud file sync and storage'
        Winget = 'Dropbox.Dropbox'
        Choco  = 'dropbox'
        Scoop  = 'nonportable/dropbox-np'
        Url    = 'https://edge.dropboxstatic.com/dbx-releng/client/Dropbox%20213.4.4597%20Offline%20Installer.x64.exe'
    }

    'Google Drive' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'Google cloud file sync client'
        Winget = 'Google.GoogleDrive'
        Choco  = 'googledrive'
        Url    = 'https://dl.google.com/release2/drive-file-stream/ohigjqf3a7wmhcvqdlpdhw26ja_100.0.2.0/setup.exe'
    }

    'iCloud' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'Apple cloud sync client for Windows'
        Winget = '9PKTQ5699M62'
        Choco  = 'icloud'
        Url    = $null
    }

    'OneDrive' = @{
        Category = 'Cloud Storage'
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

    'Visual Studio Code' = @{
        Category = 'Development'
        ToolTip  = 'Code editor and development environment'
        Winget = 'Microsoft.VisualStudioCode'
        Choco  = 'vscode-install'
        Url    = 'https://vscode.download.prss.microsoft.com/dbazure/download/stable/f1a4fb101478ce6ec82fe9627c43efbf9e98c813/VSCodeUserSetup-x64-1.95.3.exe'
    }

    'AMD Auto Detect' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Detects and installs AMD drivers'
        Winget = $null
        Choco  = $null
        Url    = 'https://drivers.amd.com/drivers/installer/24.20/whql/amd-software-adrenalin-edition-24.12.1-minimalsetup-241204_web.exe'
        Headers = @{"Referer"="https://www.amd.com/"}
    }

    'AMD Ryzen Chipset' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'AMD chipset driver package'
        Winget = $null
        Choco  = 'amd-ryzen-chipset'
        Url    = 'https://drivers.amd.com/drivers/amd_chipset_software_6.10.17.152.exe'
        Headers = @{"Referer"="https://www.amd.com/"}
    }

    'AMD Ryzen Master' = @{
        Category = 'Hardware Monitoring & Control'
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
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Corsair RGB and device control'
        Winget = 'Corsair.iCUE.5'
        Choco  = $null #'icue'
        Url    = 'https://www3.corsair.com/software/CUE_V5/public/modules/windows/installer/Install%20iCUE.exe'
    }

    'TeamSpeak' = @{
        Category = 'Communication'
        ToolTip  = 'TeamSpeak 3 voice chat client for gaming and group communication'
        Winget = 'TeamSpeakSystems.TeamSpeakClient'
        Choco  = 'teamspeak'
        Scoop  = 'extras/teamspeak3'
        Url    = $null
    }

    'Mumble' = @{
        Category = 'Communication'
        ToolTip  = 'Open-source, low-latency voice chat client'
        Winget = 'Mumble.Mumble.Client'
        Choco  = 'mumble'
        Scoop  = 'extras/mumble'
        Url    = $null
    }

    'Element' = @{
        Category = 'Communication'
        ToolTip  = 'Matrix-based messaging with group chats, voice, and video calls'
        Winget = 'Element.Element'
        Choco  = 'element-desktop'
        Scoop  = 'extras/element'
        Url    = $null
    }

    'Discord' = @{
        Category = 'Communication'
        ToolTip  = 'Voice, video, and text chat'
        Winget = 'Discord.Discord'
        Choco  = 'discord'
        Scoop  = 'extras/discord'
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
        Scoop  = 'games/epic-games-launcher'
        Url    = 'https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-15.17.1.msi'
    }

    'GeForce Experience' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'NVIDIA driver and game optimization utility'
        Winget = 'Nvidia.GeForceExperience'
        Choco  = 'geforce-experience'
        Url    = 'https://us.download.nvidia.com/GFE/GFEClient/3.28.0.417/GeForce_Experience_v3.28.0.417.exe'
    }

    'GeForce Game Ready Driver' = @{
        Category = 'Drivers & Device Management'
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
        Scoop  = 'games/goggalaxy'
        Url    = 'https://gog-cdn-fastly.gog.com/open/galaxy/client/2.0.80.33/setup_galaxy_2.0.80.33.exe'
    }

    'Intel XTU' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Intel CPU tuning and monitoring utility'
        Winget = $null
        Choco  = 'intel-xtu'
        Url    = 'https://downloadmirror.intel.com/29183/XTUSetup.exe'
    }

    'Logi Options+' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Customize supported Logitech mice and keyboards, buttons, gestures, and app-specific settings'
        Winget = 'Logitech.OptionsPlus'
        Choco  = 'logioptionsplus'
        Scoop  = $null
        Url    = 'https://download01.logi.com/web/ftp/pub/techsupport/optionsplus/logioptionsplus_installer.exe'
    }

    'Logitech G HUB' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Logitech gaming device configuration'
        Winget = 'Logitech.GHUB'
        Choco  = 'lghub'
        Url    = 'https://download01.logi.com/web/ftp/pub/techsupport/gaming/lghub_installer.exe'
    }

    'MSI Afterburner' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'GPU overclocking and monitoring utility'
        Winget = 'Guru3D.Afterburner'
        Choco  = 'msiafterburner'
        Scoop  = 'extras/msiafterburner'
        Url    = 'https://download-1.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip'
    }

    'Nvidia App (Beta)' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'NVIDIA driver and graphics management app'
        Winget = $null
        Choco  = $null
        Url    = 'https://us.download.nvidia.com/nvapp/client/11.0.1.184/NVIDIA_app_v11.0.1.184.exe'
    }

    'NZXT CAM' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'NZXT hardware monitoring and control'
        Winget = 'NZXT.CAM'
        Choco  = 'nzxt-cam'
        Url    = 'https://nzxt-app.nzxt.com/NZXT-CAM-Setup.exe'
    }

    'Razer Synapse 3' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Razer device configuration and RGB control'
        Winget = 'RazerInc.RazerInstaller'
        Choco  = 'razer-synapse-3'
        Url    = 'https://dl.razerzone.com/drivers/Synapse3/win/RazerSynapseInstaller_V1.15.0.504.exe'
    }

    'SignalRGB' = @{
        Category = 'Hardware Monitoring & Control'
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
        Scoop  = 'games/steam'
        Url    = 'https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe'
    }

    'Amazon Music' = @{
        Category = 'Media Players'
        ToolTip  = 'Music streaming desktop app'
        Winget = 'Amazon.Music'
        Choco  = $null
        Url    = 'https://d2j9xt6n9dg5d3.cloudfront.net/win/23861115_85d5deb94597adc2d891a921c0bf51c9/AmazonMusicInstaller.exe'
    }

    'foobar2000' = @{
        Category = 'Media Players'
        ToolTip  = 'Lightweight audio player'
        Winget = 'PeterPawlowski.foobar2000'
        Choco  = 'foobar2000'
        Scoop  = 'extras/foobar2000'
        Url    = 'https://www.foobar2000.org/files/foobar2000-x64_v2.24.exe'
    }

    'iTunes' = @{
        Category = 'Media Players'
        ToolTip  = 'Apple media library and device manager'
        Winget = 'Apple.iTunes'
        Choco  = 'itunes'
        Url    = 'https://www.apple.com/itunes/download/win64/'
    }

    'Spotify' = @{
        Category = 'Media Players'
        ToolTip  = 'Music streaming desktop app'
        Winget = 'Spotify.Spotify'
        Choco  = 'spotify'
        Scoop  = 'extras/spotify'
        Url    = 'https://upgrade.scdn.co/upgrade/client/win32-x86_64/spotify_installer-1.2.52.442.g01893f92-588.exe'
        NoAdmin= $true
    }

    'TIDAL' = @{
        Category = 'Media Players'
        ToolTip  = 'High-fidelity music streaming app'
        Winget = 'TIDALMusicAS.TIDAL'
        Choco  = 'tidal'
        Url    = 'https://download.tidal.com/desktop/TIDALSetup.exe'
    }

    'VLC' = @{
        Category = 'Media Players'
        ToolTip  = 'Multimedia player for audio and video'
        Winget = 'VideoLAN.VLC'
        Choco  = 'vlc'
        Scoop  = 'extras/vlc'
        Url    = 'https://download.videolan.org/videolan/vlc/3.0.21/win64/vlc-3.0.21-win64.exe'
    }

    'Visual C++ v14 Redistributable (64-bit)' = @{
        Category = 'Runtimes'
        ToolTip  = '64-bit Microsoft Visual C++ runtime'
        Winget = 'Microsoft.VCRedist.2015+.x64'
        Choco  = 'vcredist140'
        Scoop  = 'extras/vcredist'
        Url    = 'https://aka.ms/vc14/vc_redist.x64.exe'
    }

    'Visual C++ v14 Redistributable (32-bit)' = @{
        Category = 'Runtimes'
        ToolTip  = '32-bit Microsoft Visual C++ runtime'
        Winget = 'Microsoft.VCRedist.2015+.x86'
        Choco  = 'vcredist140 --x86'
        Scoop  = 'extras/vcredist -a x86'
        Url    = 'https://aka.ms/vc14/vc_redist.x86.exe'
    }

    'Adobe Acrobat Reader' = @{
        Category = 'Productivity & Office'
        ToolTip  = '64-bit PDF reader and document viewer'
        Winget = 'Adobe.Acrobat.Reader.64-bit'
        Choco  = 'adobereader'
        Url    = 'https://ardownload3.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2600121771/AcroRdrDCx642600121771_MUI.exe'
    }

    'Garmin Express' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Garmin device update and sync utility'
        Winget = 'Garmin.Express'
        Choco  = 'garmin-express'
        Url    = 'https://download.garmin.com/omt/express/GarminExpress.exe'
    }

    'Grammarly' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Writing and grammar assistant'
        Winget = 'Grammarly.Grammarly'
        Choco  = 'grammarly-for-windows'
        Scoop  = 'nonportable/grammarly-np'
        Url    = 'https://download-windows.grammarly.com/versions/1.2.120.1558/GrammarlyInstaller.exe'
    }

    'LibreOffice' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Free office productivity suite'
        Winget = 'TheDocumentFoundation.LibreOffice'
        Choco  = 'libreoffice-fresh'
        Scoop  = 'extras/libreoffice'
        Url    = 'https://download.documentfoundation.org/libreoffice/stable/24.8.3/win/x86_64/LibreOffice_24.8.3_Win_x86-64.msi'
    }

    'Microsoft Office' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Microsoft productivity suite'
        Winget = 'Microsoft.Office'
        Choco  = 'office365homepremium'
        Scoop  = 'nonportable/office-365-apps-np'
        Url    = 'https://officecdn.microsoft.com/pr/wsus/setup.exe'
    }

    'Microsoft Teams' = @{
        Category = 'Communication'
        ToolTip  = 'Work chat and video meetings'
        Winget = 'Microsoft.Teams'
        Choco  = 'microsoft-teams'
        Scoop  = $null
        Url    = 'https://installer.teams.static.microsoft/production-windows-x64/24295.605.3225.8804/MSTeams-x64.msix'
    }

    'OpenOffice' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Free office productivity suite'
        Winget = 'Apache.OpenOffice'
        Choco  = 'openoffice'
        Scoop  = 'extras/openoffice'
        Url    = 'https://downloads.apache.org/openoffice/4.1.15/binaries/en-US/Apache_OpenOffice_4.1.15_Win_x86_install_en-US.exe'
    }

    'Quicken' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Personal finance management software'
        Winget = 'Quicken.Quicken'
        Choco  = $null
        Url    = 'https://download.quicken.com/windows/Quicken.exe'
    }

    'Slack' = @{
        Category = 'Communication'
        ToolTip  = 'Team messaging and collaboration app'
        Winget = 'SlackTechnologies.Slack'
        Choco  = 'slack'
        Scoop  = 'extras/slack'
        Url    = 'https://downloads.slack-edge.com/desktop-releases/windows/x64/4.41.104/SlackSetup.exe'
    }

    'Webex' = @{
        Category = 'Communication'
        ToolTip  = 'Video meetings and collaboration app'
        Winget = 'Cisco.CiscoWebexMeetings'
        Choco  = 'webex'
        Scoop  = 'extras/webex'
        Url    = 'https://akamaicdn.webex.com/client/webexapp.msi'
    }

    'WPS Office' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Office productivity suite'
        Winget = 'Kingsoft.WPSOffice.CN'
        Choco  = 'wps-office-free'
        Scoop  = 'extras/wpsoffice'
        Url    = 'https://official-package.wpscdn.cn/wps/download/WPS_Setup_19302.exe'
    }

    'Zoom' = @{
        Category = 'Communication'
        ToolTip  = 'Video meetings and conferencing app'
        Winget = 'Zoom.Zoom'
        Choco  = 'zoom'
        Scoop  = 'extras/zoom'
        Url    = 'https://zoom.us/client/6.2.11.50939/ZoomInstallerFull.msi?archType=x64'
    }

    'Adobe Creative Cloud' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Adobe app installer and manager'
        Winget = 'XPDLPKWG9SW2WD'
        Choco  = $null
        Url    = 'https://ffc-static-cdn.oobesaas.adobe.com/wam/2.10.0.17/win/Creative_Cloud_Set-Up.exe?api_key=CreativeCloudStoreInstaller_v1_0'
    }

    'Audacity' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Audio recording and editing software'
        Winget = 'Audacity.Audacity'
        Choco  = 'audacity'
        Scoop  = 'extras/audacity'
        Url    = 'https://github.com/audacity/audacity/releases/download/Audacity-3.7.0/audacity-win-3.7.0-64bit.exe'
    }

    'CorelDRAW' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Vector graphics and design suite'
        Winget = 'XPDM28CQSPXTWQ'
        Choco  = $null
        Url    = 'https://www.corel.com/akdlm/6763/downloads/free/trials/GraphicsSuite/22H1/JL83s3fG/msstore_sf/CorelDRAWGraphicsSuiteInstaller.exe'
    }

    'FL Studio' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Digital audio workstation for music production'
        Winget = 'ImageLine.FLStudio'
        Choco  = $null
        Url    = 'https://install.image-line.com/flstudio/flstudio_win64_24.2.0.4503.exe'
    }

    'GIMP' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Image editing and graphics software'
        Winget = 'GIMP.GIMP'
        Choco  = 'gimp'
        Scoop  = 'extras/gimp'
        Url    = 'https://download.gimp.org/gimp/v2.10/windows/gimp-2.10.38-setup-1.exe'
    }

    'OBS Studio' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Video recording and live streaming'
        Winget = 'OBSProject.OBSStudio'
        Choco  = 'obs-studio'
        Scoop  = 'extras/obs-studio'
        Url    = 'https://github.com/obsproject/obs-studio/releases/download/31.0.0/OBS-Studio-31.0.0-Windows-Installer.exe'
    }

    'paint.net' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Lightweight image editor'
        Winget = 'dotPDN.PaintDotNet'
        Choco  = 'paint.net'
        Scoop  = 'extras/paint.net'
        Url    = 'https://github.com/paintdotnet/release/releases/download/v5.1.1/paint.net.5.1.1.install.x64.zip'
    }

    'REAPER' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Digital audio workstation'
        Winget = 'Cockos.REAPER'
        Choco  = 'reaper'
        Scoop  = 'extras/reaper'
        Url    = 'https://www.reaper.fm/files/7.x/reaper727_x64-install.exe'
    }

    'Streamlabs Desktop' = @{
        Category = 'Creative & Streaming'
        ToolTip  = 'Live streaming and recording software'
        Winget = 'Streamlabs.Streamlabs'
        Choco  = 'streamlabs-obs'
        Scoop  = 'extras/streamlabs-obs'
        Url    = 'https://slobs-cdn.streamlabs.com/Streamlabs+Desktop+Setup+1.16.4.exe'
    }

    'AsRock Live Update' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'ASRock driver and utility updater'
        Winget = $null
        Choco  = $null #'app-shop'
        Url    = 'https://www.asrock.com/feature/appshop/dl.asp'
    }

    'ASUS Armoury Crate' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'ASUS hardware control and updates'
        Winget = 'ASUS.ArmouryCrate'
        Choco  = $null
        Url    = 'https://dlcdnets.asus.com/pub/ASUS/mb/14Utilities/ArmouryCrateInstallTool.zip'
    }

    'Dell Command Update' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Dell driver and firmware updater'
        Winget = 'Dell.CommandUpdate.Universal'
        Choco  = 'dellcommandupdate-uwp'
        Url    = 'https://dl.dell.com/FOLDER11914128M/1/Dell-Command-Update-Windows-Universal-Application_9M35M_WIN_5.4.0_A00.EXE'
    }

    'Dell SupportAssist' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Dell diagnostics and support utility'
        Winget = $null
        Choco  = 'supportassist'
        Url    = 'https://downloads.dell.com/serviceability/catalog/SupportAssistInstaller.exe'
    }

    'Gigabyte Control Center' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Gigabyte hardware control and updates'
        Winget = $null
        Choco  = $null
        Url    = 'https://download.gigabyte.com/FileList/Utility/GCC_23.12.13.01.zip'
    }

    'HP Image Assistant' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'HP driver and image maintenance utility'
        Winget = 'HP.ImageAssistant'
        Choco  = $null
        Scoop  = $null
        Url    = 'https://hpia.hpcloud.hp.com/downloads/hpia/hp-hpia-5.3.0.exe'
    }

    'HP Support Assistant' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'HP diagnostics and support utility'
        Winget = $null
        Choco  = $null #'hpsupportassistant'
        Scoop  = 'nonportable/hp-support-assistant-np'
        Url    = 'https://ftp.hp.com/pub/softpaq/sp148501-149000/sp148716.exe'
    }

    'Lenovo System Update' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Lenovo driver and firmware updater'
        Winget = 'Lenovo.SystemUpdate'
        Choco  = 'lenovo-thinkvantage-system-update'
        Url    = 'https://download.lenovo.com/pccbbs/thinkvantage_en/system_update_5.08.03.59.exe'
    }

    'Lenovo Thin Installer' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Lenovo unattended update installer'
        Winget = 'Lenovo.ThinInstaller'
        Choco  = $null
        Url    = 'https://download.lenovo.com/pccbbs/thinkvantage_en/lenovo_thininstaller_1.04.02.00024.exe'
    }

    'Lenovo Update Retriever' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Lenovo update repository manager'
        Winget = 'Lenovo.UpdateRetriever'
        Choco  = $null
        Url    = 'https://download.lenovo.com/pccbbs/thinkvantage_en/updateretriever_5.08.01.30.exe'
    }

    'Lenovo Vantage' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Lenovo device settings and support'
        Winget = '9WZDNCRFJ4MV'
        Choco  = $null
        Url    = $null
    }

    'MSI Center' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'MSI hardware control and updates'
        Winget = '9NVMNJCR03XV'
        Choco  = $null
        Url    = 'https://download.msi.com/uti_exe/vga/MSI-Center.zip'
    }

    'MyASUS' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'ASUS device support and settings'
        Winget = '9N7R5S6B0ZZH'
        Choco  = $null
        Url    = $null
    }

    '7-Zip' = @{
        Category = 'System Utilities'
        ToolTip  = 'File archiver and compression utility'
        Winget = '7Zip.7Zip'
        Choco  = '7zip'
        Scoop  = 'main/7zip'
        Url    = 'https://7-zip.org/a/7z2409-x64.exe'
    }

    'CPU-Z' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'CPU and hardware information utility'
        Winget = 'CPUID.CPU-Z'
        Choco  = 'cpu-z'
        Scoop  = 'extras/cpu-z'
        Url    = 'https://download.cpuid.com/cpu-z/cpu-z_2.12-en.exe'
    }

    'HWiNFO' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Detailed hardware monitoring and information'
        Winget = 'REALiX.HWiNFO'
        Choco  = 'hwinfo'
        Scoop  = 'extras/hwinfo'
        Url    = 'https://www.sac.sk/download/utildiag/hwi_816x.exe'
    }

    'HWMonitor' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Hardware temperature and voltage monitor'
        Winget = 'CPUID.HWMonitor'
        Choco  = 'hwmonitor'
        Scoop  = 'extras/hwmonitor'
        Url    = 'https://download.cpuid.com/hwmonitor/hwmonitor_1.55.exe'
    }

    'Notepad++' = @{
        Category = 'Development'
        ToolTip  = 'Advanced text and code editor'
        Winget = 'Notepad++.Notepad++'
        Choco  = 'notepadplusplus'
        Scoop  = 'extras/notepadplusplus'
        Url    = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.7.4/npp.8.7.4.Installer.x64.exe'
    }

    'Samsung Data Migration' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Clone data to Samsung SSDs'
        Winget = $null
        Choco  = $null
        Url    = 'https://semiconductor.samsung.com/resources/software-resources/Samsung_Data_Migration_Setup_4.0.0.18.exe'
    }

    'Samsung Magician' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Samsung SSD management and diagnostics'
        Winget = $null #'Samsung.SamsungMagician'
        Choco  = 'samsung-magician'
        Url    = 'https://download.semiconductor.samsung.com/resources/software-resources/Samsung_Magician_Installer_Official_8.0.1.1000.exe'
    }

    'Speccy' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'System hardware information utility'
        Winget = 'Piriform.Speccy'
        Choco  = 'speccy'
        Scoop  = 'extras/speccy'
        Url    = 'https://download.ccleaner.com/spsetup133.exe'
    }

    'Signal' = @{
        Category = 'Communication'
        ToolTip  = 'Private messaging and calling'
        Winget = 'OpenWhisperSystems.Signal'
        Choco  = 'signal'
        Scoop  = 'extras/signal'
        Url    = $null
    }

    'Telegram' = @{
        Category = 'Communication'
        ToolTip  = 'Cloud-based messaging client'
        Winget = 'Telegram.Telegram'
        Choco  = 'telegram'
        Scoop  = 'extras/telegram'
        Url    = $null
    }

    'WhatsApp' = @{
        Category = 'Communication'
        ToolTip  = 'Messaging and calling client'
        Winget = 'WhatsApp.WhatsApp'
        Choco  = $null
        Scoop  = $null
        Url    = $null
    }

    'ChatGPT Desktop' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'OpenAI ChatGPT desktop application'
        Winget = 'OpenAI.ChatGPT'
        Choco  = 'chatgpt'
        Scoop  = 'extras/chatgpt'
        Url    = $null
    }

    'Claude Desktop' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Anthropic Claude desktop application'
        Winget = 'Anthropic.Claude'
        Choco  = 'claude'
        Scoop  = 'extras/claude'
        Url    = $null
    }

    'Docker Desktop' = @{
        Category = 'Development'
        ToolTip  = 'Container development environment'
        Winget = 'Docker.DockerDesktop'
        Choco  = 'docker-desktop'
        Scoop  = $null
        Url    = $null
    }

    'Visual Studio 2022' = @{
        Category = 'Development'
        ToolTip  = 'Microsoft Visual Studio 2022 Community'
        Winget = 'Microsoft.VisualStudio.2022.Community'
        Choco  = 'visualstudio2022community'
        Scoop  = $null
        Url    = $null
    }

    'Visual Studio 2026' = @{
        Category = 'Development'
        ToolTip  = 'Microsoft Visual Studio 2026 Community'
        Winget = 'Microsoft.VisualStudio.2026.Community'
        Choco  = 'visualstudio2026community'
        Scoop  = $null
        Url    = $null
    }

    'NAPS2' = @{
        Category = 'Productivity & Office'
        ToolTip  = 'Document scanning and PDF creation'
        Winget = 'NAPS2.NAPS2'
        Choco  = 'naps2'
        Scoop  = 'extras/naps2'
        Url    = $null
    }

    'GeForce NOW' = @{
        Category = 'Gaming'
        ToolTip  = 'NVIDIA cloud gaming client'
        Winget = 'NVIDIA.GeForceNOW'
        Choco  = 'nvidia-geforce-now'
        Scoop  = $null
        Url    = $null
    }

    'Autoruns' = @{
        Category = 'System Utilities'
        ToolTip  = 'View programs configured to run at startup'
        Winget = 'Microsoft.Sysinternals.Autoruns'
        Choco  = 'autoruns'
        Scoop  = 'sysinternals/autoruns'
        Url    = 'https://download.sysinternals.com/files/Autoruns.zip'
    }

    'Process Explorer' = @{
        Category = 'System Utilities'
        ToolTip  = 'Advanced process and system monitor'
        Winget = 'Microsoft.Sysinternals.ProcessExplorer'
        Choco  = 'procexp'
        Scoop  = 'sysinternals/process-explorer'
        Url    = 'https://download.sysinternals.com/files/ProcessExplorer.zip'
    }

    'Process Monitor' = @{
        Category = 'System Utilities'
        ToolTip  = 'Real-time file system and registry monitor'
        Winget = 'Microsoft.Sysinternals.ProcessMonitor'
        Choco  = 'procmon'
        Scoop  = 'sysinternals/procmon'
        Url    = 'https://download.sysinternals.com/files/ProcessMonitor.zip'
    }

    'Blender' = @{
        Category = 'Creative & Streaming'
        ToolTip  = '3D modeling and animation suite'
        Winget = 'BlenderFoundation.Blender'
        Choco  = 'blender'
        Scoop  = 'extras/blender'
        Url    = $null
    }

    'Display Driver Uninstaller' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Cleanly remove graphics drivers'
        Winget = 'Wagnardsoft.DisplayDriverUninstaller'
        Choco  = 'display-driver-uninstaller'
        Scoop  = 'extras/ddu'
        Url    = $null
    }

    'GPU-Z' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Graphics card information utility'
        Winget = 'TechPowerUp.GPU-Z'
        Choco  = 'gpu-z'
        Scoop  = 'extras/gpu-z'
        Url    = $null
    }

    'OpenVPN' = @{
        Category = 'Remote Access & VPN'
        ToolTip  = 'Open-source VPN client'
        Winget = 'OpenVPNTechnologies.OpenVPN'
        Choco  = 'openvpn'
        Scoop  = 'extras/openvpn'
        Url    = $null
    }

    'ProtonVPN' = @{
        Category = 'Remote Access & VPN'
        ToolTip  = 'Privacy-focused VPN client'
        Winget = 'ProtonTechnologies.ProtonVPN'
        Choco  = 'protonvpn'
        Scoop  = 'nonportable/protonvpn-np'
        Url    = $null
    }

    'VyprVPN' = @{
        Category = 'Remote Access & VPN'
        ToolTip  = 'VPN client from Golden Frog'
        Winget = 'GoldenFrog.VyprVPN'
        Choco  = 'vyprvpn'
        Scoop  = $null
        Url    = $null
    }

    'WireGuard' = @{
        Category = 'Remote Access & VPN'
        ToolTip  = 'Modern VPN tunnel client'
        Winget = 'WireGuard.WireGuard'
        Choco  = 'wireguard'
        Scoop  = 'nonportable/wireguard-np'
        Url    = $null
    }

    'Ventoy' = @{
        Category = 'System Utilities'
        ToolTip  = 'Create bootable USB drives with multiple ISO images'
        Winget = 'Ventoy.Ventoy'
        Choco  = 'ventoy'
        Scoop  = 'extras/ventoy'
        Url    = 'https://github.com/ventoy/Ventoy/releases/download/v1.1.17/ventoy-1.1.17-windows.zip'
    }

    'Moonlight' = @{
        Category = 'Gaming'
        ToolTip  = 'Game streaming client'
        Winget = 'MoonlightGameStreamingProject.Moonlight'
        Choco  = 'moonlight-qt'
        Scoop  = 'extras/moonlight'
        Url    = $null
    }

    'OpenRGB' = @{
        Category = 'Hardware Monitoring & Control'
        ToolTip  = 'Open-source RGB lighting control'
        Winget = 'OpenRGB.OpenRGB'
        Choco  = 'openrgb'
        Scoop  = 'extras/openrgb'
        Url    = $null
    }

    'Parsec' = @{
        Category = 'Remote Access & VPN'
        ToolTip  = 'Low-latency remote desktop and game streaming'
        Winget = 'Parsec.Parsec'
        Choco  = 'parsec'
        Scoop  = 'extras/parsec'
        Url    = $null
    }

    'Proton Drive' = @{
        Category = 'Cloud Storage'
        ToolTip  = 'Encrypted cloud storage client'
        Winget = 'Proton.ProtonDrive'
        Choco  = $null
        Scoop  = 'extras/proton-drive'
        Url    = $null
    }

    'Tailscale' = @{
        Category = 'Remote Access & VPN'
        ToolTip  = 'Private mesh networking client'
        Winget = 'Tailscale.Tailscale'
        Choco  = 'tailscale'
        Scoop  = 'extras/tailscale'
        Url    = $null
    }

    'UniGetUI' = @{
        Category = 'System Utilities'
        ToolTip  = 'Graphical interface for Windows package managers'
        Winget = 'MartiCliment.UniGetUI'
        Choco  = 'unigetui'
        Scoop  = 'extras/unigetui'
        Url    = $null
    }

    'Everything' = @{
        Category = 'System Utilities'
        ToolTip  = 'Fast file name search utility'
        Winget = 'voidtools.Everything'
        Choco  = 'everything'
        Scoop  = 'extras/everything'
        Url    = 'https://www.voidtools.com/Everything-1.4.1.1032.x64.zip'
    }

    'Revo Uninstaller' = @{
        Category = 'System Utilities'
        ToolTip  = 'Advanced software uninstaller'
        Winget = 'RevoUninstaller.RevoUninstaller'
        Choco  = 'revo-uninstaller'
        Scoop  = 'extras/revouninstaller'
        Url    = 'https://download.revouninstaller.com/download/RevoUninstaller_Portable.zip'
    }

    'Snappy Driver Installer Origin' = @{
        Category = 'Drivers & Device Management'
        ToolTip  = 'Install and update hardware drivers'
        Winget = 'GlennDelahoy.SnappyDriverInstallerOrigin'
        Choco  = 'snappy-driver-installer-origin'
        Scoop  = 'extras/snappy-driver-installer-origin'
        Url    = 'https://www.glenn.delahoy.com/downloads/sdio/SDIO_1.13.5.772.zip'
    }

    'WizTree' = @{
        Category = 'System Utilities'
        ToolTip  = 'Fast disk space analyzer'
        Winget = 'AntibodySoftware.WizTree'
        Choco  = 'wiztree'
        Scoop  = 'extras/wiztree'
        Url    = 'https://diskanalyzer.com/files/wiztree_4_23_portable.zip'
    }

}
