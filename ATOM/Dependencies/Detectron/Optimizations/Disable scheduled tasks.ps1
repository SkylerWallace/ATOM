$tooltip = "Disables unnecessary scheduled tasks in Task Scheduler (mostly telemetry)"

Write-OutputBox "Disabling Scheduled Tasks"

$tasks = [ordered]@{
	'MS Compatibility Appraiser' = @{
		path = "\Microsoft\Windows\Application Experience\"
		name = "Microsoft Compatibility Appraiser"
	}
	'ProgramDataUpdater' = @{
		path = "\Microsoft\Windows\Application Experience\"
		name = "ProgramDataUpdater"
	}
	'Proxy' = @{
		path = "\Microsoft\Windows\Autochk\"
		name = "Proxy"
	}
	'Consolidator' = @{
		path = "\Microsoft\Windows\Customer Experience Improvement Program\"
		name = "Consolidator"
	}
	'UsbCeip' = @{
		path = "\Microsoft\Windows\Customer Experience Improvement Program\"
		name = "UsbCeip"
	}
	'DiskDiagnosticDataCollector' = @{
		path = "\Microsoft\Windows\DiskDiagnostic\"
		name = "Microsoft-Windows-DiskDiagnosticDataCollector"
	}
	'DmClient' = @{
		path = "\Microsoft\Windows\Feedback\Siuf\"
		name = "DmClient"
	}
	'DmClientOnScenarioDownload' = @{
		path = "\Microsoft\Windows\Feedback\Siuf\"
		name = "DmClientOnScenarioDownload"
	}
	'QueueReporting' = @{
		path = "\Microsoft\Windows\Windows Error Reporting\"
		name = "QueueReporting"
	}
	'MareBackup' = @{
		path = "\Microsoft\Windows\Application Experience\"
		name = "MareBackup"
	}
	'StartupAppTask' = @{
		path = "\Microsoft\Windows\Application Experience\"
		name = "StartupAppTask"
	}
	'PcaPatchDbTask' = @{
		path = "\Microsoft\Windows\Application Experience\"
		name = "PcaPatchDbTask"
	}
	'MapsUpdateTask' = @{
		path = "\Microsoft\Windows\Maps\"
		name = "MapsUpdateTask"
	}
}

# Load all scheduled tasks w/ Get-ScheduledTask (quicker than individual calls)
$allTasks = Get-ScheduledTask

# Disable all tasks that aren't already disabled
foreach ($task in $tasks.Keys) {
	$taskPath = $tasks[$task]["path"]
	$taskName = $tasks[$task]["name"]
	
	# Search for specific task
	$taskDetected = $allTasks | Where-Object { $_.TaskPath -eq $taskPath -and $_.TaskName -eq $taskName }
	
	if ($taskDetected -and $taskDetected.State -ne "Disabled") {
		$taskFullPath = Join-Path $taskPath $taskName
		Disable-ScheduledTask -TaskName $taskFullPath | Out-Null
		Write-OutputBox "- $task > Disabled"
	} elseif ($taskDetected.State -eq "Disabled") {
		Write-OutputBox "- $task > Unchanged"
	} else {
		Write-OutputBox "- $task > Undetected"
	}
}

Write-OutputBox ""