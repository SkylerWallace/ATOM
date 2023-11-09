Write-OutputBox "Disable Startups"

# Standard programs
$startupEnabled = @([byte[]](2,0,0,0,0,0,0,0,0,0,0,0), [byte[]](6,0,0,0,0,0,0,0,0,0,0,0))
$startupDisabled = @([byte[]](3,0,0,0,0,0,0,0,0,0,0,0), [byte[]](7,0,0,0,0,0,0,0,0,0,0,0))
$startupPaths = @(
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"
)
$startups = @(
	"com.squirrel.Teams.Teams"
	"Discord",
	"Duet Display",
	"EADM",
	"EpicGamesLauncher",
	"ExpressVPNNotificationService",
	"GogGalaxy",
	"HPSEU_Host_Launcher",
#	"MicrosoftEdgeAutoLaunch_D492595374A346645D73EE4DEA733813",
	"Steam",
	"TeamsMachineInstaller"
)

foreach ($startup in $startups) {
	foreach ($startupPath in $startupPaths) {
		if (($startupValue = (Get-ItemProperty -Path $startupPath -Name $startup -ErrorAction SilentlyContinue).$startup) -ne $null) {
			for ($i = 0; $i -lt 2; $i++) {
				if ((Compare-Object $startupValue $startupEnabled[$i] -SyncWindow 12) -eq $null) {
					Set-ItemProperty -Path $startupPath -Name $startup -Type Binary -Value $startupDisabled[$i]
					Write-OutputBox "- $startup has been disabled."
					break
				}
			}
			if ($i -eq 2) {
				Write-OutputBox "- $startup already disabled."
				}
		}
	}
}

# Microsoft Store apps
$startupPath = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData"
$startups = @(
	@("Cortana", "Microsoft.549981C3F5F10_8wekyb3d8bbwe\CortanaStartupID"),
	@("Microsoft Teams", "MicrosoftTeams_8wekyb3d8bbwe\TeamsStartupTask"),
	@("Spotify", "SpotifyAB.SpotifyMusic_zpdnekdrzrea0\Spotify")
)

foreach ($startup in $startups) {
	$startupName = $startup[0]
	$startupKey = "$startupPath\$($startup[1])"
	if ((Get-ItemProperty -Path $startupKey -ErrorAction SilentlyContinue) -ne $null) {
		if ((Get-ItemPropertyValue -Path $startupKey -Name "State") -eq 2){
			Set-ItemProperty -Path $startupKey -Name "State" -Type DWord -Value 1
			Write-OutputBox "- $startupName has been disabled."
		}
		else {
			Write-OutputBox "- $startupName already disabled."
		}
	}
}

Write-OutputBox ""