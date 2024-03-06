$tooltip = "Windows has a LOT of ad-tracking services..."

Write-OutputBox "Disabling Telemetry"

function Adjust-Settings {
	$counter = 0
	foreach ($registrySetting in $registrySettings) {
		$registryPath = $registrySetting[0]
		$registryName = $registrySetting[1]
		$registryType = $registrySetting[2]
		$registryValue = $registrySetting[3]
		
		$keyDetected = $null
		$keyDetected = Get-ItemPropertyValue -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
		if ($keyDetected -eq $null) {
			if (!(Test-Path $registryPath)) { New-Item -Path $registryPath -Force }
			New-ItemProperty -Path $registryPath -Name $registryName -Type $registryType -Value $registryValue -Force | Out-Null
			$counter++
		} elseif ($keyDetected -ne $registryValue) {
			Set-ItemProperty -Path $registryPath -Name $registryName -Type $registryType -Value $registryValue
			$counter++
		}
	}
	
	Write-OutputBox "- Disabled $counter $settingsGroup"
}

function Disable-Tasks {
	$counter = 0
	foreach ($task in $scheduledTasks) {
		$taskPath = $task[0]
		$taskName = $task[1]
		
		$taskDetected = Get-ScheduledTask -TaskPath $taskPath -TaskName $taskName -ErrorAction SilentlyContinue
		if ($taskDetected -and $taskDetected.State -ne 'Disabled') {
			$taskFullPath = Join-Path $taskPath $taskName
			Disable-ScheduledTask -TaskName $taskFullPath | Out-Null
			$counter++
		}
	}
	
	Write-OutputBox "- Disabled $counter scheduled tasks"
}

# General privacy options
$settingsGroup = "general privacy options"
$registrySettings = @(
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo", "Enabled", "DWord", "0"),
	@("HKCU:\Control Panel\International\User Profile", "HttpAcceptLanguageOptOut", "DWord", "1"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Start_TrackProgs", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338387Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338388Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338389Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-338393Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353694Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353696Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SubscribedContent-353698Enabled", "DWord", "0")
#	@("HKCU\Software\Policies\Microsoft\Windows\EdgeUI", "DisableMFUTracking", "DWord", "1"),
#	@("HKLM\Software\Policies\Microsoft\Windows\EdgeUI", "DisableMFUTracking", "DWord", "1")
)

Adjust-Settings

# Online speech recognition
$settingsGroup = "online speech recognition settings"
$registrySettings = @(
	@("HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy", "HasAccepted", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy", "HasAccepted", "DWord", "0")
)

Adjust-Settings

# Inking & typing personalization
$settingsGroup = "inking & typing personalization settings"
$registrySettings = @(
	@("HKCU:\Software\Microsoft\InputPersonalization", "RestrictImplicitInkCollection", "DWord", "1"),
	@("HKCU:\Software\Microsoft\InputPersonalization", "RestrictImplicitTextCollection", "DWord", "1"),
	@("HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore", "HarvestContacts", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Personalization\Settings", "AcceptedPrivacyPolicy", "DWord", "0")
)

Adjust-Settings

# Telemetry
$settingsGroup = "telemetry settings"
$registrySettings = @(
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack", "ShowedToastAtLevel", "DWord", "1"),
	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "AllowTelemetry", "DWord", "1"),
	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", "MaximumTelemetry", "DWord", "1"),
	@("HKCU:\Software\Microsoft\Input\TIPC", "Enabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy", "TailoredExperiencesWithDiagnosticDataEnabled", "DWord", "0"),
	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey", "EnableEventTranscript", "DWord", "0"),
	@("HKCU:\SOFTWARE\Microsoft\Siuf\Rules", "NumberOfSIUFInPeriod", "DWord", "0"),
	@("HKCU:\SOFTWARE\Microsoft\Siuf\Rules", "PeriodInNanoSeconds", "DWord", "0")

	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "ContentDeliveryAllowed", "DWord", "0"),
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "OemPreInstalledAppsEnabled", "DWord", "0"),
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "PreInstalledAppsEnabled", "DWord", "0"),
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "PreInstalledAppsEverEnabled", "DWord", "0"),
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SilentInstalledAppsEnabled", "DWord", "0"),
	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager", "SystemPaneSuggestionsEnabled", "DWord", "0"),
	@("HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting", "Disabled", "DWord", "1")

#	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent", "DisableWindowsConsumerFeatures", "DWord", "1"),
#	@("HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent", "DisableTailoredExperiencesWithDiagnosticData", "DWord", "1"),
#	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection", "DoNotShowFeedbackNotifications", "DWord", "1"),
#	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo", "DisabledByGroupPolicy", "DWord", "1")
)

Adjust-Settings

# Activity history
$settingsGroup = "activity history settings"
$registrySettings = @(
	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System", "EnableActivityFeed", "DWord", "0"),
	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System", "PublishUserActivities", "DWord", "0"),
	@("HKLM:\SOFTWARE\Policies\Microsoft\Windows\System", "UploadUserActivities", "DWord", "0")
)

Adjust-Settings

# Search permissions
$settingsGroup = "search permissions settings"
$registrySettings = @(
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsAADCloudSearchEnabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsDeviceSearchHistoryEnabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsDynamicSearchBoxEnabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "IsMSACloudSearchEnabled", "DWord", "0"),
	@("HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings", "SafeSearchMode", "DWord", "0")
)

Adjust-Settings

<#
$settingsGroup = "geolocation settings"
$registrySettings = @(
#	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location", "Value", "String", "Deny", "0"),
#	@("HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}", "SensorPermissionState", "DWord", "0"),
#	@("HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration", "Status", "DWord", "0"),
	@("HKLM:\SYSTEM\Maps", "AutoUpdateEnabled", "DWord", "0")
)

Adjust-Settings
#>

<#
$settingsGroup = "features & other settings"
$registrySettings = @(
#	@("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config", "DODownloadMode", "DWord", "1"),
#	@("HKLM:\SYSTEM\CurrentControlSet\Control\Remote Assistance", "fAllowToGetHelp", "DWord", "0"),
#	@("HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy", "0")
)

Adjust-Settings
#>

$scheduledTasks = @(
	@("\Microsoft\Windows\Application Experience\", "Microsoft Compatibility Appraiser"),
	@("\Microsoft\Windows\Application Experience\", "ProgramDataUpdater"),
	@("\Microsoft\Windows\Autochk\", "Proxy"),
	@("\Microsoft\Windows\Customer Experience Improvement Program\", "Consolidator"),
	@("\Microsoft\Windows\Customer Experience Improvement Program\", "UsbCeip"),
	@("\Microsoft\Windows\DiskDiagnostic\", "Microsoft-Windows-DiskDiagnosticDataCollector"),
	@("\Microsoft\Windows\Feedback\Siuf\", "DmClient"),
	@("\Microsoft\Windows\Feedback\Siuf\", "DmClientOnScenarioDownload"),
	@("\Microsoft\Windows\Windows Error Reporting\", "QueueReporting"),
	@("\Microsoft\Windows\Application Experience\", "MareBackup"),
	@("\Microsoft\Windows\Application Experience\", "StartupAppTask"),
	@("\Microsoft\Windows\Application Experience\", "PcaPatchDbTask"),
	@("\Microsoft\Windows\Maps\", "MapsUpdateTask")
)

Disable-Tasks

Write-OutputBox ""