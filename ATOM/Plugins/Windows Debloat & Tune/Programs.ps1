# Entries use their name as a literal installed-app match unless Match supplies regex patterns.
# Detect receives a context with InstalledApps and returns records with Id, DisplayName, and target data.
# Uninstall receives the selected record; omit it to use the registered uninstall command.
$programs = [ordered]@{
    # Remote Access
    'Alpemix' = @{ Category = 'Remote Access' }
    'AnyDesk' = @{ Category = 'Remote Access' }
    'AweSun' = @{ Category = 'Remote Access' }
    'GlanceGuest' = @{ Category = 'Remote Access' }
    'GoToAssist' = @{ Category = 'Remote Access' }
    'LogMeIn' = @{ Category = 'Remote Access' }
    'OptimumDesk' = @{ Category = 'Remote Access' }
    'Optimum Desk' = @{ Category = 'Remote Access' }
    'Remote Assistance' = @{ Category = 'Remote Access' }
    'RemotePC' = @{ Category = 'Remote Access' }
    'Remote Utilities' = @{ Category = 'Remote Access' }
    'Splashtop' = @{ Category = 'Remote Access' }
    'Supremo' = @{ Category = 'Remote Access' }
    'TeamViewer' = @{ Category = 'Remote Access' }
    'UltraViewer' = @{ Category = 'Remote Access' }
    'UltraVNC' = @{ Category = 'Remote Access' }
    'VNC Connect' = @{ Category = 'Remote Access' }
    'Zoho Assist' = @{ Category = 'Remote Access' }

    # Anti-Virus
    'McAfee' = @{ Category = 'Anti-Virus' }
    'WebAdvisor by McAfee' = @{ Category = 'Anti-Virus' }

    # Malware
    'Advanced System Care' = @{ Category = 'Malware' }
    'Altruistics' = @{ Category = 'Malware' }
    'Avast Secure Browser' = @{ Category = 'Malware' }
    'Avery Teoma Search App' = @{ Category = 'Malware' }
    'BBWC' = @{ Category = 'Malware' }
    'Bonefreeze' = @{ Category = 'Malware' }
    'Browser Assistant' = @{ Category = 'Malware' }
    'BrowserAssistant' = @{ Category = 'Malware' }
    'Browser Extension' = @{ Category = 'Malware' }
    'Clear' = @{ Category = 'Malware' }
    'ClearBar' = @{ Category = 'Malware' }
    'ClientPCSpeedup' = @{ Category = 'Malware' }
    'Deepteep' = @{ Category = 'Malware' }
    'Driver Easy' = @{ Category = 'Malware' }
    'DriverEasy' = @{ Category = 'Malware' }
    'Driver Support One' = @{ Category = 'Malware' }
    'Driver Tonic' = @{ Category = 'Malware' }
    'Driver Tuner' = @{ Category = 'Malware' }
    'DriverUpdate' = @{ Category = 'Malware' }
    'Easy Radio Player' = @{ Category = 'Malware' }
    'EstimateSpeedUp' = @{ Category = 'Malware' }
    'GetMyDrivers' = @{ Category = 'Malware' }
    'iTop Easy Desktop' = @{ Category = 'Malware' }
    'iTop VPN' = @{ Category = 'Malware' }
    'iTop Screen Recorder' = @{ Category = 'Malware' }
    'Malware Crusher' = @{ Category = 'Malware' }
    'N9 Firewall' = @{ Category = 'Malware' }
    'OneLaunch' = @{ Category = 'Malware' }
    'OneStart' = @{ Category = 'Malware' }
    'PC App Store' = @{ Category = 'Malware' }
    'PDFHub' = @{ Category = 'Malware' }
    'PremierOpinion' = @{ Category = 'Malware' }
    'PrivDog' = @{ Category = 'Malware' }
    'Quick Driver Updater' = @{ Category = 'Malware' }
    'RelevantKnowledge' = @{ Category = 'Malware' }
    'RestMinder' = @{ Category = 'Malware' }
    'Restoro' = @{ Category = 'Malware' }
    'screensearchutils' = @{ Category = 'Malware' }
    'ScreensRecorder' = @{ Category = 'Malware' }
    'Simple PC Optimizer' = @{ Category = 'Malware' }
    'Solve iQ' = @{ Category = 'Malware' }
    'SSOption' = @{ Category = 'Malware' }
    'SlimCleaner Plus' = @{ Category = 'Malware' }
    'System Mechanic' = @{ Category = 'Malware' }
    'Viewndow' = @{ Category = 'Malware' }
    'WaveBrowser' = @{ Category = 'Malware' }
    'WeatherApp' = @{ Category = 'Malware' }
    'Web Companion' = @{ Category = 'Malware' }
    'WebDiscover Browser' = @{ Category = 'Malware' }
    'WebBar Toolbar' = @{ Category = 'Malware' }
    'WinZip' = @{ Category = 'Malware' }

    # Bloatware
    'Google Toolbar for Internet Explorer' = @{ Category = 'Bloatware' }
    'Windows PC Health Check' = @{ Category = 'Bloatware' }
    'ASUS AI Recovery' = @{ Category = 'Bloatware' }
    'ASUS FancyStart' = @{ Category = 'Bloatware' }
    'ASUS Live Update' = @{ Category = 'Bloatware' }
    'ASUS Power4Gear Hybrid' = @{ Category = 'Bloatware' }
    'ASUS SmartLogon' = @{ Category = 'Bloatware' }
    'ASUS Splendid Video Enhancement Technology' = @{ Category = 'Bloatware' }
    'ASUS Virtual Camera' = @{ Category = 'Bloatware' }
    'ASUS WebStorage' = @{ Category = 'Bloatware' }
    'ASUS Welcome' = @{ Category = 'Bloatware' }
    'AsusVibe' = @{ Category = 'Bloatware' }
    'Dell Customer Connect' = @{ Category = 'Bloatware' }
    'Dell Digital Delivery' = @{ Category = 'Bloatware' }
    'Dell Digital Delivery Services' = @{ Category = 'Bloatware' }
    'Dell Help & Support' = @{ Category = 'Bloatware' }
    'Dell Mobile Connect Driver' = @{ Category = 'Bloatware' }
    'Dell Product Registration' = @{ Category = 'Bloatware' }
    'Dell Shop' = @{ Category = 'Bloatware' }
    'Fusion Service' = @{ Category = 'Bloatware' }
    'QuickSet64' = @{ Category = 'Bloatware' }
    'SmartByte' = @{ Category = 'Bloatware' }
    'SmartByte Drivers & Services' = @{ Category = 'Bloatware' }
    'Bonjour' = @{ Category = 'Bloatware' }
    'Duet Display' = @{ Category = 'Bloatware' }
    'ExpressVPN' = @{ Category = 'Bloatware' }
    'HP Documentation' = @{ Category = 'Bloatware' }
    'HP Connection Optimizer' = @{ Category = 'Bloatware' }
    'HP Jumpstart Apps' = @{ Category = 'Bloatware' }
    'HP Jumpstart Bridge' = @{ Category = 'Bloatware' }
    'HP Jumpstart Launch' = @{ Category = 'Bloatware' }
    'WildTangent Games' = @{ Category = 'Bloatware' }
    'WildTangent Helper' = @{ Category = 'Bloatware' }
    'WildTangent Shortcut Provider' = @{ Category = 'Bloatware' }
    'Lenovo Smart Appearance Components' = @{ Category = 'Bloatware' }
    'Lenovo Voice Service' = @{ Category = 'Bloatware' }
    'Lenovo Welcome' = @{ Category = 'Bloatware' }
    'Smart Note' = @{ Category = 'Bloatware' }
    'BatteryLifeExtender' = @{ Category = 'Bloatware' }
    'Easy Content Share' = @{ Category = 'Bloatware' }
    'Easy Display Manager' = @{ Category = 'Bloatware' }
    'Easy Display Manager Option' = @{ Category = 'Bloatware' }
    'Easy Migration' = @{ Category = 'Bloatware' }
    'Easy Network Manager' = @{ Category = 'Bloatware' }
    'Easy Network Manager Help' = @{ Category = 'Bloatware' }
    'EasyFileShare' = @{ Category = 'Bloatware' }
    'Fast Start' = @{ Category = 'Bloatware' }
    'Movie Color Enhancer' = @{ Category = 'Bloatware' }
    'Movie Color Enhancer Option' = @{ Category = 'Bloatware' }
    'Samsung Support Center' = @{ Category = 'Bloatware' }
    'Samsung Update Plus' = @{ Category = 'Bloatware' }
    'Samsung Update Plust Help' = @{ Category = 'Bloatware' }

    'ScreenConnect Client (ConnectWise)' = @{
        Category = 'Remote Access'
        ToolTip = 'Common "invisible" remote access software used by scammers.'
        Detect = {
            param($Context)
            $root = Join-Path $env:LOCALAPPDATA 'Apps\2.0'
            if (![IO.Directory]::Exists($root)) { return }
            $directories = Get-ChildItem -LiteralPath $root -Filter 'ScreenConnect*.exe' -Recurse -File -ErrorAction SilentlyContinue |
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
