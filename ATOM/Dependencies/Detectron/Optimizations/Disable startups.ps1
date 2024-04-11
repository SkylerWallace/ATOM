$tooltip = "Disable unnecessary startups from common programs"

Write-OutputBox "Disable Startups"

# Load registry keys by launching Task Manager silently
Start-Process -FilePath "taskmgr" -WindowStyle Minimized -ArgumentList "/1 /startup"

do {
	$taskMgr = Get-Process "taskmgr" -ErrorAction SilentlyContinue
	Start-Sleep -Milliseconds 100
} until ($taskMgr)

if ($taskMgr) {
	Write-OutputBox "- Loaded startups into registry"
	Start-Sleep -Milliseconds 500
	$taskMgr | Stop-Process -Force
}

# Disable startups for standard programs
$startupEnabled = @([byte[]](2,0,0,0,0,0,0,0,0,0,0,0), [byte[]](6,0,0,0,0,0,0,0,0,0,0,0))
$startupDisabled = @([byte[]](3,0,0,0,0,0,0,0,0,0,0,0), [byte[]](7,0,0,0,0,0,0,0,0,0,0,0))
$startupPaths = @(
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"
)

# Standard program startups
$startups = @(
	"Battle.net",
	"BrHelp",
	"com.squirrel.Teams.Teams",
	"CiscoMeetingDaemon",
	"CiscoSpark",
	"CCleaner Smart Cleaning",
	"Discord",
	"Duet Display",
	"EADM",
	"EpicGamesLauncher",
	"ExpressVPNNotificationService",
	"GogGalaxy",
	"HPOneAgentService",
	"HPSEU_Host_Launcher",
	"IntelGraphicsAGS",
	"iTunesHelper",
	"Lync",
	"Opera Browser Assistant",
	"Overwolf",
	"Parsec.App.0",
	"Skype for Desktop",
	"Spotify",
	"SunJavaUpdateSched",
	"Steam",
	"TeamsMachineInstaller"
)

# Check all four $startupPath keys for matching startups
foreach ($startupPath in $startupPaths) {
	$startupKeys = Get-ItemProperty -Path $startupPath -ErrorAction SilentlyContinue
	foreach ($startup in $startups) {
		$startupValue = $startupKeys.$startup
		if ($startupValue -ne $null) {
			for ($i = 0; $i -lt 2; $i++) {
				if ((Compare-Object $startupValue $startupEnabled[$i] -SyncWindow 12) -eq $null) {
					Set-ItemProperty -Path $startupPath -Name $startup -Type Binary -Value $startupDisabled[$i]
					Write-OutputBox "- $startup > Disabled"
					break
				}
			}
			if ($i -eq 2) {
				Write-OutputBox "- $startup > Unchanged"
			}
		}
	}
}

# Unique logic to disable Microsoft Edge startup
$edgeKey = (Get-ItemProperty -Path $startupPaths[0]).PSObject.Properties.Name | Where-Object { $_ -like "MicrosoftEdgeAutoLaunch_*" }
if ($edgeKey) {
	$edgeValue = (Get-ItemProperty -Path $startupPaths[0]).$edgeKey
	if ((Compare-Object $edgeValue $startupEnabled[0] -SyncWindow 12) -eq $null) {
		Set-ItemProperty -Path $startupPaths[0] -Name $edgeKey -Type Binary -Value $startupDisabled[0]
		Write-OutputBox "- Edge > Disabled"
	} else {
		Write-OutputBox "- Edge > Unchanged"
	}
}

# Startups for Microsoft Store apps
$startupPath = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData"
$startups = @(
	@("Cortana", "Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupID"),
	@("Intel Graphics Command Center", "AppUp.IntelGraphicsExperience_8j3eq9eme6ctt\GCPStartupId"),
	@("Microsoft Teams", "MicrosoftTeams_8wekyb3d8bbwe\TeamsStartupTask"),
	@("Spotify", "SpotifyAB.SpotifyMusic_zpdnekdrzrea0\Spotify"),
	@("Xbox App Service", "Microsoft.GamingApp_8wekyb3d8bbwe\Xbox.App.Tasks.FullTrustComponent")
)

# Disable all Microsoft Store app startups
foreach ($startup in $startups) {
	$startupName = $startup[0]
	$startupKey = "$startupPath\$($startup[1])"
	if ((Get-ItemProperty -Path $startupKey -ErrorAction SilentlyContinue) -ne $null) {
		if ((Get-ItemPropertyValue -Path $startupKey -Name "State") -eq 2){
			Set-ItemProperty -Path $startupKey -Name "State" -Type DWord -Value 1
			Write-OutputBox "- $startupName > Disabled"
		}
		else {
			Write-OutputBox "- $startupName > Unchanged"
		}
	}
}

Write-OutputBox ""