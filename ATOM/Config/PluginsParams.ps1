<#
- Hidden
	Boolean. Default visibility of plugin.
- Silent
	Boolean. Launch plugin in hidden window mode.
- ToolTip
	String. Displays tooltip when mouse is hovered over respective plugin.
- WorksInOs
	Boolean. Specifies if program works in online OS.
- WorksInPe
	Boolean. Specifies if program works in PE (Windows RE/Windows PE).
#>

$script:pluginInfo = [ordered]@{
	
	'7-Zip' = @{
		Silent		= $true
		ToolTip		= "File management, compression, & extraction"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'AnyBurn' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "CD/DVD & ISO burning software"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'ATOM Notes' = @{
		Silent		= $true
		ToolTip		= "Take notes during PC repair"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'ATOM Store' = @{
		Silent		= $true
		ToolTip		= "Install portable programs for ATOM"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'ATOMizer' = @{
		Silent		= $true
		ToolTip		= "Format/update multiple flash drives w/ zip & ISO files"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Autoruns' = @{
		Silent		= $true
		ToolTip		= "View/modify all computer startups"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'BlueScreenView' = @{
		Silent		= $true
		ToolTip		= "View blue screen crash dumps"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Command Prompt' = @{
		Silent		= $true
		ToolTip		= "Windows legacy command-line"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Control Panel' = @{
		Silent		= $true
		ToolTip		= "Windows legacy Control Panel"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'CPU-Z' = @{
		Silent		= $true
		ToolTip		= "View CPU info, benchmarking, & stress testing"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'CrystalDiskInfo' = @{
		Silent		= $true
		ToolTip		= "View drive health & info"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'CrystalDiskMark' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Test drive read/write speeds"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Detectron' = @{
		Silent		= $true
		ToolTip		= "Disable telemetry & uninstall bloatware/malware"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Device Manager' = @{
		Silent		= $true
		ToolTip		= "View & manage device info & drivers"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Disk Management' = @{
		Silent		= $true
		ToolTip		= "Manage local drives"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Display Driver Uninstaller' = @{
		Silent		= $true
		ToolTip		= "Completely remove GPU drivers"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Event Viewer' = @{
		Silent		= $true
		ToolTip		= "View Windows event logs"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Explorer++' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'FreeCommander' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'HCI Design MemTest' = @{
		Silent		= $true
		ToolTip		= "Memory overclock stability test"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'HWMonitor' = @{
		Silent		= $true
		ToolTip		= "Real-time hardware monitoring"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Installed Apps' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Windows Settings app management"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'KeyCutlass' = @{
		Silent		= $true
		ToolTip		= "View Windows product & encryption keys"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'MalwareBytes AdwCleaner' = @{
		Silent		= $true
		ToolTip		= "MBAM malware scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'McAfee Stinger' = @{
		Silent		= $true
		ToolTip		= "McAfee AV scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'MemTest86' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Bootable memory tester"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'MountOS' = @{
		Silent		= $true
		ToolTip		= "Mount offline registry hives for OS modification"
		WorksInOs	= $false
		WorksInPe	= $true
	}
	
	'MSI Kombustor' = @{
		Silent		= $true
		ToolTip		= "GPU stress-tester"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Neutron' = @{
		Silent		= $true
		ToolTip		= "New PC suite: install programs & set common settings"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Norton Power Eraser' = @{
		Silent		= $true
		ToolTip		= "Norton AV scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Notepad++' = @{
		Silent		= $true
		ToolTip		= "Notepad but with two pluses"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'O&O Shutup10++' = @{
		Silent		= $true
		ToolTip		= "Thorough telemetry disabler"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'OCCT' = @{
		Silent		= $true
		ToolTip		= "All-in-one diagnostic, stability, & stress-tester"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'OneCommander' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Opera' = @{
		Silent		= $true
		ToolTip		= "Portable web browser"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Orca' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Official Microsoft tool to analyze and modify MSIs"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Ornstein and S-Mode' = @{
		Silent		= $true
		ToolTip		= "Disable Windows S-Mode"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'PassCrack' = @{
		Silent		= $true
		ToolTip		= "Disable Windows login passwords (requires MountOS ran)"
		WorksInOs	= $false
		WorksInPe	= $true
	}
	
	'PowerShell Core' = @{
		Silent		= $true
		ToolTip		= "Windows modern command-line (non-native)"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'PowerShell' = @{
		Silent		= $true
		ToolTip		= "Windows modern command-line (native)"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Prime95' = @{
		Silent		= $true
		ToolTip		= "CPU stability tester"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Process Monitor' = @{
		Silent		= $true
		ToolTip		= "Real-time process monitoring & snapshotting"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Recuva' = @{
		Silent		= $true
		ToolTip		= "File recovery software"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Registry Editor' = @{
		Silent		= $true
		ToolTip		= "View & modify registry keys & values"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Regshot' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Registry comparison tool"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Reset Default Services' = @{
		Silent		= $true
		ToolTip		= "Restore default services to default states"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Restart to BIOS' = @{
		Silent		= $true
		ToolTip		= "Restart computer to UEFI/BIOS"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Restart to Recovery' = @{
		Silent		= $true
		ToolTip		= "Restart computer to Windows Recovery Environment"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Revo Uninstaller' = @{
		Silent		= $true
		ToolTip		= "Deep program uninstaller"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Rufus' = @{
		Silent		= $true
		ToolTip		= "Create bootable drives, wide file format support"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Settings' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Windows setting app"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Snappy Driver Installer Origin' = @{
		Silent		= $true
		ToolTip		= "Robust driver updating software"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Task Manager' = @{
		Silent		= $true
		ToolTip		= "View & manage all active process"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Task Scheduler' = @{
		Silent		= $true
		ToolTip		= "Windows task automation system"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'TeraCopy' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "Robust file transfer software"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Total Commander' = @{
		Silent		= $true
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Trifecta' = @{
		Silent		= $true
		ToolTip		= "Run SFC, Windows Update, & MS Store updates"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Webroot' = @{
		Silent		= $true
		ToolTip		= "Web-based AV scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'WinMerge' = @{
		Hidden		= $true
		Silent		= $true
		ToolTip		= "File comparison software"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'WinUtil' = @{
		Hidden		= $true
		Silent		= $false
		ToolTip		= "Windows multi-tool from CTT"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'WizTree' = @{
		Silent		= $true
		ToolTip		= "Examine sizes of all local directories"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
}

# Add contents of custom hashtable to main hashtable
. $psScriptRoot\PluginsParamsUser.ps1
foreach ($key in $($customPluginInfo.Keys)) {
	$pluginInfo[$key] = $customPluginInfo[$key]
}