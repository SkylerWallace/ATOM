Write-OutputBox "Disabling Telemetry"

function Adjust-Settings {
	$counter = 0
	foreach ($registrySetting in $registrySettings) {
		$registryPath = $registrySetting[0]
		$registryName = $registrySetting[1]
		$registryType = $registrySetting[2]
		$registryValue = $registrySetting[3]
		$createOrDelete = $registrySetting[4]
		if (Test-Path -Path $registryPath) {
			if ((Get-ItemProperty -Path $registryPath).PSObject.Properties.Name -Contains $registryName) {
				if (((Get-ItemProperty -Path $registryPath -Name $registryName).$registryName -ne $registryValue) -And ($createOrDelete -ne 2)) {
					Set-ItemProperty -Path $registryPath -Name $registryName -Type $registryType -Value $registryValue 
					$counter++
				} elseif ($createOrDelete -eq 2) {
					Remove-ItemProperty -Path $registryPath -Name $registryName -Force | Out-Null
					$counter++
				}
			} elseif ($createOrDelete -eq 1) {
				New-ItemProperty -Path $registryPath -Name $registryName -Type $registryType -Value $registryValue -Force | Out-Null
				$counter++
			}
		}
	}
	if ($counter -ge 1) {
		Write-OutputBox "- Disabled $($counter) $($settingsGroup)."
	} else {
		Write-OutputBox "- All $($settingsGroup) already set."
	}
}

function Set-Services {
	$counter = 0
	foreach ($service in $services) {
		$serviceName = $service[0]
		$serviceValue = $service[1]
		if ((Get-Service -Name $serviceName -ErrorAction SilentlyContinue) -ne $null) {
			if ((Get-Service -Name $serviceName).StartType -ne $serviceValue) {
				if ($serviceValue -ne "Manual") {
					Stop-Service "$serviceName" -ErrorAction SilentlyContinue
				}
				Set-Service "$serviceName" -StartupType $serviceValue -ErrorAction SilentlyContinue
				$counter++
			}
		}
	}
		
	if ($counter -ge 1) {
		Write-OutputBox "- Adjusted $($counter) services."
	} else {
		Write-OutputBox "- All $($settingsGroup) already set."
	}
}

<# 
	Beginning of registry setting arrays
	{0, 1, 2, 3, 4, 5}
	Element 0 = registry path
	Element 1 = registry name
	Element 2 = registry type
	Element 3 = registry value
	Element 4 = set, create, or delete registry name (0 = set, 1 = create, 2 = delete)
#>

# General privacy options
$settingsGroup = "general privacy options"
$registrySettings = @(
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", "DWord", "0", "0", "1"),
	@("HKCU:\Control Panel\International\User Profile", "HttpAcceptLanguageOptOut", "DWord", "1", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Start_TrackProgs", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338389Enabled", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338393Enabled", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353694Enabled", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353696Enabled", "DWord", "0", "0", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353696Enabled", "DWord", "0", "1", "1")
#	@("HKCU\Software\Policies\Microsoft\Windows\EdgeUI", "DisableMFUTracking", "DWord", "1", "0", "1"),
#	@("HKLM\Software\Policies\Microsoft\Windows\EdgeUI", "DisableMFUTracking", "DWord", "1", "0", "1")
)

Adjust-Settings

# Online speech recognition
$settingsGroup = "online speech recognition settings"
$registrySettings = @(
	@("HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy", "HasAccepted", "DWord", "0", "0", "1"),
	@("HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy", "HasAccepted", "DWord", "0", "0", "1")
)

Adjust-Settings

# Inking & typing personalization
$settingsGroup = "inking & typing personalization settings"
$registrySettings = @(
	@("HKCU:\Software\Microsoft\InputPersonalization", "RestrictImplicitInkCollection", "DWord", "1", "0", "1"),
	@("HKCU:\Software\Microsoft\InputPersonalization", "RestrictImplicitTextCollection", "DWord", "1", "0", "1"),
	@("HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore", "HarvestContacts", "DWord", "0", "0", "1"),
	@("HKCU:\Software\Microsoft\Personalization\Settings", "AcceptedPrivacyPolicy", "DWord", "0", "0", "1")
)

Adjust-Settings

# Telemetry
$settingsGroup = "telemetry settings"
$registrySettings = @(
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack", "ShowedToastAtLevel", "DWord", "1", "0", "1"),
	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "AllowTelemetry", "DWord", "1", "0", "1"),
	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "MaximumTelemetry", "DWord", "1", "0", "1"),
	@("HKCU:\Software\Microsoft\Input\TIPC", "Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy", "TailoredExperiencesWithDiagnosticDataEnabled", "DWord", "0", "0", "1"),
	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey", "EnableEventTranscript", "DWord", "0", "0", "1"),
	@("HKCU:\SOFTWARE\Microsoft\Siuf\Rules", "NumberOfSIUFInPeriod", "DWord", "0", "1", "1"),
	@("HKCU:\SOFTWARE\Microsoft\Siuf\Rules", "PeriodInNanoSeconds", "DWord", "0", "2", "1")
# Balanced registry settings
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "ContentDeliveryAllowed", "DWord", "0", "0", "2"),
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "OemPreInstalledAppsEnabled", "DWord", "0", "0", "2"),
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "PreInstalledAppsEnabled", "DWord", "0", "0", "2"),
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "PreInstalledAppsEverEnabled", "DWord", "0", "0", "2"),
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SilentInstalledAppsEnabled", "DWord", "0", "0", "2"),
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SystemPaneSuggestionsEnabled", "DWord", "0", "0", "2"),
#	@("HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting", "Disabled", "DWord", "1", "0", "2"),
# Aggressive registry settings
#	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent", "DisableWindowsConsumerFeatures", "DWord", "1", "0", "3"),
#	@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent", "DisableTailoredExperiencesWithDiagnosticData", "DWord", "1", "1", "3"),
#	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection", "DoNotShowFeedbackNotifications", "DWord", "1", "0", "3"),
#	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo", "DisabledByGroupPolicy", "DWord", "1", "1", "3")
)

Adjust-Settings

# Activity history
$settingsGroup = "activity history settings"
$registrySettings = @(
	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System", "EnableActivityFeed", "DWord", "0", "0", "1"),
	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System", "PublishUserActivities", "DWord", "0", "0", "1"),
	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System", "UploadUserActivities", "DWord", "0", "0", "1")
)

Adjust-Settings

# Search permissions
$settingsGroup = "search permissions settings"
$registrySettings = @(
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsAADCloudSearchEnabled", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsDeviceSearchHistoryEnabled", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsDynamicSearchBoxEnabled", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsMSACloudSearchEnabled", "DWord", "0", "1", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "SafeSearchMode", "DWord", "0", "1", "1")
)

Adjust-Settings

$settingsGroup = "geolocation settings"
$registrySettings = @(
# Balanced registry settings
#	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location", "Value", "String", "Deny", "0", "1"),
#	@("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}", "SensorPermissionState", "DWord", "0", "0", "2"),
#	@("HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration", "Status", "DWord", "0", "0", "2"),
#	@("HKLM:\SYSTEM\Maps", "AutoUpdateEnabled", "DWord", "Value", "0", "0", "2")
)

Adjust-Settings

$settingsGroup = "features & other settings"
$registrySettings = @(
# Aggressive registry settings
#	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config", "DODownloadMode", "DWord", "1", "1", "3"),
#	@("HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance", "fAllowToGetHelp", "DWord", "0", "0", "3"),
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy", "0", "0", "0", "2", "3")
)

Adjust-Settings

<#
	Services settings array
	{0, 1, 2)
	Element 0 = service name
	Element 1 = service startup value (Disabled, Manual, Automatic)
	Element 2 = debloat mode threshold (1 = safe, 2 = balanced, 3 = aggressive)
 #>
 
$settingsGroup = "services"
$services = @(
	@("DiagTrack", "Disabled", "1")
# Balanced mode
#	@("dmwappushservice", "Disabled", "2"),
# Aggressive mode
#	@("HomeGroupListener", "Disabled", "3"),
#	@("HomeGroupProvider", "Disabled", "3"),
#	@("ALG", "Manual", "3"),
#	@("AJRouter", "Manual", "3"),
#	@("BcastDVRUserService_48486de", "Manual", "3"),
#	@("Browser", "Manual", "3"),
#	@("BthAvctpSvc", "Manual", "3"),
#	@("CaptureService_48486de", "Manual", "3"),
#	@("cbdhsvc_48486de", "Manual", "3"),
#	@("diagnosticshub.standardcollector.service", "Manual", "3"),
#	@("DiagTrack", "Manual", "3"),
#	@("dmwappushservice", "Manual", "3"),
#	@("DPS", "Manual", "3"),
#	@("edgeupdate", "Manual", "3"),
#	@("edgeupdatem", "Manual", "3"),
#	@("EntAppSvc", "Manual", "3"),
#	@("Fax", "Manual", "3"),
#	@("fhsvc", "Manual", "3"),
#	@("FontCache", "Manual", "3"),
#	@("gupdate", "Manual", "3"),
#	@("gupdatem", "Manual", "3"),
#	@("iphlpsvc", "Manual", "3"),
#	@("lfsvc", "Manual", "3"),
#	@("lmhosts", "Manual", "3"),
#	@("MapsBroker", "Manual", "3"),
#	@("MicrosoftEdgeElevationService", "Manual", "3"),
#	@("MSDTC", "Manual", "3"),
#	@("ndu", "Manual", "3"),
#	@("NetTcpPortSharing", "Manual", "3"),
#	@("PcaSvc", "Manual", "3"),
#	@("PerfHost", "Manual", "3"),
#	@("PhoneSvc", "Manual", "3"),
#	@("PrintNotify", "Manual", "3"),
#	@("QWAVE", "Manual", "3"),
#	@("RemoteAccess", "Manual", "3"),
#	@("RemoteRegistry", "Manual", "3"),
#	@("RetailDemo", "Manual", "3"),
#	@("RtkBtManServ", "Manual", "3"),
#	@("SCardSvr", "Manual", "3"),
#	@("seclogon", "Manual", "3"),
#	@("SEMgrSvc", "Manual", "3"),
#	@("SharedAccess", "Manual", "3"),
#	@("stisvc", "Manual", "3"),
#	@("SysMain", "Manual", "3"),
#	@("TrkWks", "Manual", "3"),
#	@("WerSvc", "Manual", "3"),
#	@("wisvc", "Manual", "3"),
#	@("WMPNetworkSvc", "Manual", "3"),
#	@("WpcMonSvc", "Manual", "3"),
#	@("WPDBusEnum", "Manual", "3"),
#	@("WpnService", "Manual", "3"),
#	@("XblAuthManager", "Manual", "3"),
#	@("XblGameSave", "Manual", "3"),
#	@("XboxNetApiSvc", "Manual", "3"),
#	@("XboxGipSvc", "Manual", "3"),
#	@("HPAppHelperCap", "Manual", "3"),
#	@("HPDiagsCap", "Manual", "3"),
#	@("HPNetworkCap", "Manual", "3"),
#	@("HPSysInfoCap", "Manual", "3"),
#	@("HpTouchpointAnalyticsService", "Manual", "3"),
#	@("HvHost", "Manual", "3"),
#	@("vmicguestinterface", "Manual", "3"),
#	@("vmicheartbeat", "Manual", "3"),
#	@("vmickvpexchange", "Manual", "3"),
#	@("vmicrdv", "Manual", "3"),
#	@("vmicshutdown", "Manual", "3"),
#	@("vmictimesync", "Manual", "3"),
#	@("vmicvmsession", "Manual", "3")
)

Set-Services

Write-OutputBox ""