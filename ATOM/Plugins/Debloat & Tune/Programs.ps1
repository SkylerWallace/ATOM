# Entries match the complete installed DisplayName unless Match supplies wildcard patterns.
# Detect receives a context with InstalledApps and returns records with Id, DisplayName, and target data.
# Uninstall receives the selected record; omit it to use the registered uninstall command.
$programs = [ordered]@{
    # Remote Access
    'Alpemix' = @{ Category = 'Remote Access'; Match = @('Alpemix*') }
    'AnyDesk' = @{ Category = 'Remote Access'; Match = @('AnyDesk*') }
    'AweSun' = @{ Category = 'Remote Access'; Match = @('AweSun*') }
    'GlanceGuest' = @{ Category = 'Remote Access'; Match = @('GlanceGuest*') }
    'GoToAssist' = @{ Category = 'Remote Access'; Match = @('GoToAssist*') }
    'LogMeIn' = @{ Category = 'Remote Access'; Match = @('LogMeIn*') }
    'OptimumDesk' = @{ Category = 'Remote Access'; Match = @('OptimumDesk*') }
    'Optimum Desk' = @{ Category = 'Remote Access'; Match = @('Optimum Desk*') }
    'Remote Assistance' = @{ Category = 'Remote Access'; Match = @('Remote Assistance*') }
    'RemotePC' = @{ Category = 'Remote Access'; Match = @('RemotePC*') }
    'Remote Utilities' = @{ Category = 'Remote Access'; Match = @('Remote Utilities*') }
    'Splashtop' = @{ Category = 'Remote Access'; Match = @('Splashtop*') }
    'Supremo' = @{ Category = 'Remote Access'; Match = @('Supremo*') }
    'TeamViewer' = @{ Category = 'Remote Access'; Match = @('TeamViewer*') }
    'UltraViewer' = @{ Category = 'Remote Access'; Match = @('UltraViewer*') }
    'UltraVNC' = @{ Category = 'Remote Access'; Match = @('UltraVNC*') }
    'VNC Connect' = @{ Category = 'Remote Access'; Match = @('VNC Connect*') }
    'Zoho Assist' = @{ Category = 'Remote Access'; Match = @('Zoho Assist*') }

    # Anti-Virus
    'McAfee' = @{ Category = 'Anti-Virus'; Match = @('McAfee*') }
    'WebAdvisor by McAfee' = @{ Category = 'Anti-Virus'; Match = @('WebAdvisor by McAfee*') }

    # Unwanted Apps
    'Advanced System Care' = @{ Category = 'Unwanted Apps'; Match = @('Advanced System Care*') }
    'Altruistics' = @{ Category = 'Unwanted Apps'; Match = @('Altruistics*') }
    'Ashampoo WinOptimizer FREE' = @{ Category = 'Unwanted Apps'; Match = @('Ashampoo WinOptimizer FREE*'); ToolTip = 'Malwarebytes documents the FREE edition as a potentially unwanted optimizer. Review whether you use it.' }
    'Ask Toolbar' = @{ Category = 'Unwanted Apps'; Match = @('Ask Toolbar*'); ToolTip = 'Potentially unwanted browser toolbar that can change the search provider.' }
    'Avery Teoma Search App' = @{ Category = 'Unwanted Apps'; Match = @('Avery Teoma Search App*') }
    'BBWC' = @{ Category = 'Unwanted Apps'; Match = @('BBWC*') }
    'Bonefreeze' = @{ Category = 'Unwanted Apps'; Match = @('Bonefreeze*') }
    'Browser Assistant' = @{ Category = 'Unwanted Apps'; Match = @('Browser Assistant*') }
    'Browser Extension' = @{ Category = 'Unwanted Apps' }
    'BrowserAssistant' = @{ Category = 'Unwanted Apps'; Match = @('BrowserAssistant*') }
    'ByteFence Anti-Malware' = @{ Category = 'Unwanted Apps'; Match = @('ByteFence Anti-Malware*'); ToolTip = 'Malwarebytes classifies this product as potentially unwanted due to infection popups and purchase prompts.' }
    'Clear' = @{ Category = 'Unwanted Apps' }
    'ClearBar' = @{ Category = 'Unwanted Apps'; Match = @('ClearBar*') }
    'ClientPCSpeedup' = @{ Category = 'Unwanted Apps'; Match = @('ClientPCSpeedup*') }
    'Deepteep' = @{ Category = 'Unwanted Apps'; Match = @('Deepteep*') }
    'Driver Easy' = @{ Category = 'Unwanted Apps'; Match = @('Driver Easy*') }
    'Driver Support One' = @{ Category = 'Unwanted Apps'; Match = @('Driver Support One*') }
    'Driver Tonic' = @{ Category = 'Unwanted Apps'; Match = @('Driver Tonic*') }
    'Driver Tuner' = @{ Category = 'Unwanted Apps'; Match = @('Driver Tuner*') }
    'DriverEasy' = @{ Category = 'Unwanted Apps'; Match = @('DriverEasy*') }
    'DriverMax' = @{ Category = 'Unwanted Apps'; Match = @('DriverMax*'); ToolTip = 'Driver updater classified as potentially unwanted by Malwarebytes.' }
    'DriverPack Notifier' = @{ Category = 'Unwanted Apps'; Match = @('DriverPack Notifier*'); ToolTip = 'Notification component of the DriverPack software bundler, classified as potentially unwanted by Malwarebytes.' }
    'DriverUpdate' = @{ Category = 'Unwanted Apps'; Match = @('DriverUpdate*') }
    'Easy Radio Player' = @{ Category = 'Unwanted Apps'; Match = @('Easy Radio Player*') }
    'EstimateSpeedUp' = @{ Category = 'Unwanted Apps'; Match = @('EstimateSpeedUp*') }
    'GetMyDrivers' = @{ Category = 'Unwanted Apps'; Match = @('GetMyDrivers*') }
    'Global System Mechanic' = @{ Category = 'Unwanted Apps'; Match = @('Global System Mechanic*'); ToolTip = 'Potentially unwanted optimizer associated with misleading security claims and support prompts.' }
    'iTop Easy Desktop' = @{ Category = 'Unwanted Apps'; Match = @('iTop Easy Desktop*') }
    'iTop Screen Recorder' = @{ Category = 'Unwanted Apps'; Match = @('iTop Screen Recorder*') }
    'iTop VPN' = @{ Category = 'Unwanted Apps'; Match = @('iTop VPN*') }
    'Malware Crusher' = @{ Category = 'Unwanted Apps'; Match = @('Malware Crusher*') }
    'MyPC Backup' = @{ Category = 'Unwanted Apps'; Match = @('MyPC Backup*'); ToolTip = 'Potentially unwanted bundled backup application. Keep it if you intentionally use it and need access to your backups.' }
    'N9 Firewall' = @{ Category = 'Unwanted Apps'; Match = @('N9 Firewall*') }
    'OneLaunch' = @{ Category = 'Unwanted Apps'; Match = @('OneLaunch*') }
    'OneStart' = @{ Category = 'Unwanted Apps'; Match = @('OneStart*') }
    'Outbyte Driver Updater' = @{ Category = 'Unwanted Apps'; Match = @('Outbyte Driver Updater*'); ToolTip = 'Potentially unwanted paid driver updater; review whether you intentionally use it.' }
    'Outbyte PC Repair' = @{ Category = 'Unwanted Apps'; Match = @('Outbyte PC Repair*'); ToolTip = 'Potentially unwanted paid system optimizer; review whether you intentionally use it.' }
    'PC Accelerate Pro' = @{ Category = 'Unwanted Apps'; Match = @('PC Accelerate Pro*','PCAcceleratePro*'); ToolTip = 'Potentially unwanted optimizer marketed using misleading problem reports.' }
    'PC App Store' = @{ Category = 'Unwanted Apps'; Match = @('PC App Store*') }
    'PC Optimizer Pro' = @{ Category = 'Unwanted Apps'; Match = @('PC Optimizer Pro*'); ToolTip = 'System optimizer classified as potentially unwanted by Malwarebytes.' }
    'PC SpeedCAT' = @{ Category = 'Unwanted Apps'; Match = @('PC SpeedCAT*'); ToolTip = 'System optimizer classified as potentially unwanted by Malwarebytes.' }
    'PDFHub' = @{ Category = 'Unwanted Apps'; Match = @('PDFHub*') }
    'PremierOpinion' = @{ Category = 'Unwanted Apps'; Match = @('PremierOpinion*') }
    'PrivDog' = @{ Category = 'Unwanted Apps'; Match = @('PrivDog*') }
    'Quick Driver Updater' = @{ Category = 'Unwanted Apps'; Match = @('Quick Driver Updater*') }
    'RegClean Pro' = @{ Category = 'Unwanted Apps'; Match = @('RegClean Pro*'); ToolTip = 'Potentially unwanted registry cleaner marketed using misleading registry error reports.' }
    'Reimage Repair' = @{ Category = 'Unwanted Apps'; Match = @('Reimage Repair*'); ToolTip = 'Malwarebytes classifies Reimage as a potentially unwanted application.' }
    'RelevantKnowledge' = @{ Category = 'Unwanted Apps'; Match = @('RelevantKnowledge*') }
    'RestMinder' = @{ Category = 'Unwanted Apps'; Match = @('RestMinder*') }
    'Restoro' = @{ Category = 'Unwanted Apps'; Match = @('Restoro*') }
    'screensearchutils' = @{ Category = 'Unwanted Apps'; Match = @('screensearchutils*') }
    'ScreensRecorder' = @{ Category = 'Unwanted Apps'; Match = @('ScreensRecorder*') }
    'Search Protect' = @{ Category = 'Unwanted Apps'; Match = @('Search Protect*','SearchProtect*'); ToolTip = 'Potentially unwanted application that changes browser settings.' }
    'Segurazo Antivirus' = @{ Category = 'Unwanted Apps'; Match = @('Segurazo*','sAntivirus*'); ToolTip = 'Potentially unwanted security application. Its registered uninstaller may not fully remove it; use an antivirus tool if it persists.' }
    'Shift Browser' = @{ Category = 'Unwanted Apps'; Match = @('Shift Browser*'); ToolTip = 'Browser classified as potentially unwanted by Malwarebytes due to misleading promotion.' }
    'Simple PC Optimizer' = @{ Category = 'Unwanted Apps'; Match = @('Simple PC Optimizer*') }
    'SlimCleaner Plus' = @{ Category = 'Unwanted Apps'; Match = @('SlimCleaner Plus*') }
    'Solve iQ' = @{ Category = 'Unwanted Apps'; Match = @('Solve iQ*') }
    'SSOption' = @{ Category = 'Unwanted Apps'; Match = @('SSOption*') }
    'Super Cleanup' = @{ Category = 'Unwanted Apps'; Match = @('Super Cleanup*'); ToolTip = 'System optimizer classified as potentially unwanted by Malwarebytes.' }
    'SweetPacks' = @{ Category = 'Unwanted Apps'; Match = @('SweetPacks*','SweetIM*'); ToolTip = 'Bundled toolbar/messenger family that changes browser homepage and search settings.' }
    'System Mechanic' = @{ Category = 'Unwanted Apps'; Match = @('System Mechanic*') }
    'Universal PC Mechanic' = @{ Category = 'Unwanted Apps'; Match = @('Universal PC Mechanic*'); ToolTip = 'Potentially unwanted optimizer associated with misleading security claims and support prompts.' }
    'Viewndow' = @{ Category = 'Unwanted Apps'; Match = @('Viewndow*') }
    'Wajam' = @{ Category = 'Unwanted Apps'; Match = @('Wajam*'); ToolTip = 'Potentially unwanted social-search application that inserts advertisements into websites.' }
    'WaveBrowser' = @{ Category = 'Unwanted Apps'; Match = @('WaveBrowser*') }
    'WeatherApp' = @{ Category = 'Unwanted Apps'; Match = @('WeatherApp*') }
    'Web Companion' = @{ Category = 'Unwanted Apps'; Match = @('Web Companion*') }
    'WebBar Toolbar' = @{ Category = 'Unwanted Apps'; Match = @('WebBar Toolbar*') }
    'WebDiscover Browser' = @{ Category = 'Unwanted Apps'; Match = @('WebDiscover Browser*') }

    # Bloatware
    'Avast Secure Browser' = @{ Category = 'Bloatware'; Match = @('Avast Secure Browser*'); ToolTip = 'Optional application. Keep it if you intentionally installed and use it.' }
    'WinZip' = @{ Category = 'Bloatware'; Match = @('WinZip*'); ToolTip = 'Optional application. Keep it if you intentionally installed and use it.' }
    'HP Product Improvement Study' = @{ Category = 'Bloatware'; Match = @('HP Product Improvement Study*','HP * Product Improvement Study*'); ToolTip = 'Optional HP product research participation software. Remove if you do not want to participate.' }
    'Google Toolbar for Internet Explorer' = @{ Category = 'Bloatware'; Match = @('Google Toolbar for Internet Explorer*') }
    'Windows PC Health Check' = @{ Category = 'Bloatware'; Match = @('Windows PC Health Check*') }
    'ASUS AI Recovery' = @{ Category = 'Bloatware'; Match = @('ASUS AI Recovery*') }
    'ASUS FancyStart' = @{ Category = 'Bloatware'; Match = @('ASUS FancyStart*') }
    'ASUS Live Update' = @{ Category = 'Bloatware'; Match = @('ASUS Live Update*') }
    'ASUS Power4Gear Hybrid' = @{ Category = 'Bloatware'; Match = @('ASUS Power4Gear Hybrid*') }
    'ASUS SmartLogon' = @{ Category = 'Bloatware'; Match = @('ASUS SmartLogon*') }
    'ASUS Splendid Video Enhancement Technology' = @{ Category = 'Bloatware'; Match = @('ASUS Splendid Video Enhancement Technology*') }
    'ASUS Virtual Camera' = @{ Category = 'Bloatware'; Match = @('ASUS Virtual Camera*') }
    'ASUS WebStorage' = @{ Category = 'Bloatware'; Match = @('ASUS WebStorage*') }
    'ASUS Welcome' = @{ Category = 'Bloatware'; Match = @('ASUS Welcome*') }
    'AsusVibe' = @{ Category = 'Bloatware'; Match = @('AsusVibe*') }
    'Dell Customer Connect' = @{ Category = 'Bloatware'; Match = @('Dell Customer Connect*') }
    'Dell Digital Delivery' = @{ Category = 'Bloatware'; Match = @('Dell Digital Delivery*') }
    'Dell Digital Delivery Services' = @{ Category = 'Bloatware'; Match = @('Dell Digital Delivery Services*') }
    'Dell Help & Support' = @{ Category = 'Bloatware'; Match = @('Dell Help & Support*') }
    'Dell Mobile Connect Driver' = @{ Category = 'Bloatware'; Match = @('Dell Mobile Connect Driver*') }
    'Dell Product Registration' = @{ Category = 'Bloatware'; Match = @('Dell Product Registration*') }
    'Dell Shop' = @{ Category = 'Bloatware'; Match = @('Dell Shop*') }
    'Fusion Service' = @{ Category = 'Bloatware'; Match = @('Fusion Service*') }
    'QuickSet64' = @{ Category = 'Bloatware'; Match = @('QuickSet64*') }
    'SmartByte' = @{ Category = 'Bloatware'; Match = @('SmartByte*') }
    'SmartByte Drivers & Services' = @{ Category = 'Bloatware'; Match = @('SmartByte Drivers & Services*') }
    'Bonjour' = @{ Category = 'Bloatware'; Match = @('Bonjour*') }
    'Duet Display' = @{ Category = 'Bloatware'; Match = @('Duet Display*') }
    'ExpressVPN' = @{ Category = 'Bloatware'; Match = @('ExpressVPN*') }
    'HP Documentation' = @{ Category = 'Bloatware'; Match = @('HP Documentation*') }
    'HP Connection Optimizer' = @{ Category = 'Bloatware'; Match = @('HP Connection Optimizer*') }
    'HP Jumpstart Apps' = @{ Category = 'Bloatware'; Match = @('HP Jumpstart Apps*') }
    'HP Jumpstart Bridge' = @{ Category = 'Bloatware'; Match = @('HP Jumpstart Bridge*') }
    'HP Jumpstart Launch' = @{ Category = 'Bloatware'; Match = @('HP Jumpstart Launch*') }
    'WildTangent Games' = @{ Category = 'Bloatware'; Match = @('WildTangent Games*') }
    'WildTangent Helper' = @{ Category = 'Bloatware'; Match = @('WildTangent Helper*') }
    'WildTangent Shortcut Provider' = @{ Category = 'Bloatware'; Match = @('WildTangent Shortcut Provider*') }
    'Lenovo Smart Appearance Components' = @{ Category = 'Bloatware'; Match = @('Lenovo Smart Appearance Components*') }
    'Lenovo Voice Service' = @{ Category = 'Bloatware'; Match = @('Lenovo Voice Service*') }
    'Lenovo Welcome' = @{ Category = 'Bloatware'; Match = @('Lenovo Welcome*') }
    'Smart Note' = @{ Category = 'Bloatware'; Match = @('Smart Note*') }
    'BatteryLifeExtender' = @{ Category = 'Bloatware'; Match = @('BatteryLifeExtender*') }
    'Easy Content Share' = @{ Category = 'Bloatware'; Match = @('Easy Content Share*') }
    'Easy Display Manager' = @{ Category = 'Bloatware'; Match = @('Easy Display Manager*') }
    'Easy Display Manager Option' = @{ Category = 'Bloatware'; Match = @('Easy Display Manager Option*') }
    'Easy Migration' = @{ Category = 'Bloatware'; Match = @('Easy Migration*') }
    'Easy Network Manager' = @{ Category = 'Bloatware'; Match = @('Easy Network Manager*') }
    'Easy Network Manager Help' = @{ Category = 'Bloatware'; Match = @('Easy Network Manager Help*') }
    'EasyFileShare' = @{ Category = 'Bloatware'; Match = @('EasyFileShare*') }
    'Fast Start' = @{ Category = 'Bloatware'; Match = @('Fast Start*') }
    'Movie Color Enhancer' = @{ Category = 'Bloatware'; Match = @('Movie Color Enhancer*') }
    'Movie Color Enhancer Option' = @{ Category = 'Bloatware'; Match = @('Movie Color Enhancer Option*') }
    'Samsung Support Center' = @{ Category = 'Bloatware'; Match = @('Samsung Support Center*') }
    'Samsung Update Plus' = @{ Category = 'Bloatware'; Match = @('Samsung Update Plus*') }
    'Samsung Update Plust Help' = @{ Category = 'Bloatware'; Match = @('Samsung Update Plust Help*') }

    'ScreenConnect Client (ConnectWise)' = @{
        Category = 'Remote Access'
        ToolTip = 'Common "invisible" remote access software used by scammers.'
        Detect = {
            param($Context)
            $root = Join-Path $env:LOCALAPPDATA 'Apps\2.0'
            if (![IO.Directory]::Exists($root)) { return }
            $directories = Get-ChildItem -LiteralPath $root -Filter 'ScreenConnect*.exe' -Recurse -File -ErrorAction Stop |
                ForEach-Object { $_.Directory.FullName } | Sort-Object -Unique
            foreach ($directory in $directories) {
                [PSCustomObject]@{ Id = $directory; DisplayName = 'ScreenConnect (cached client)'; Path = $directory }
            }
        }
        Uninstall = {
            param($Target)
            $root = [IO.Path]::GetFullPath((Join-Path $env:LOCALAPPDATA 'Apps\2.0')).TrimEnd('\')
            $directory = Get-Item -LiteralPath $Target.Path -ErrorAction Stop
            $path = $directory.FullName.TrimEnd('\')
            if (!$directory.PSIsContainer -or !$path.StartsWith($root + '\', [StringComparison]::OrdinalIgnoreCase)) {
                throw 'ScreenConnect target is outside the ClickOnce cache.'
            }
            $ancestor = $directory
            while ($ancestor -and $ancestor.FullName.Length -ge $root.Length) {
                if ($ancestor.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Target uses a filesystem link.' }
                $ancestor = $ancestor.Parent
            }
            if (Get-ChildItem -LiteralPath $path -Recurse -Force -Attributes ReparsePoint -ErrorAction Stop) {
                throw 'Target contains a filesystem link.'
            }
            if (!(Get-ChildItem -LiteralPath $path -Filter 'ScreenConnect*.exe' -File -ErrorAction Stop)) {
                throw 'ScreenConnect client is no longer present.'
            }
            Get-Process -Name 'ScreenConnect*' -ErrorAction SilentlyContinue | Where-Object {
                $_.Path -and [IO.Path]::GetDirectoryName($_.Path) -eq $path
            } | Stop-Process -Force -ErrorAction Stop
            Remove-Item -LiteralPath $path -Recurse -Force -ErrorAction Stop
        }
    }
}
