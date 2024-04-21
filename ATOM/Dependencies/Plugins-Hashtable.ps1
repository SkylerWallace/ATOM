<#

- ToolTip
	String. Displays tooltip when mouse is hovered over respective plugin.
- WorksInOs
	Boolean. 
- WorksInPe
	Boolean.
#>

$pluginInfo = [ordered]@{
	
	'7-Zip' = @{
		ToolTip		= "File management, compression, & extraction"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'AnyBurn' = @{
		ToolTip		= "CD/DVD & ISO burning software"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'ATOM Notes' = @{
		ToolTip		= "Take notes during PC repair"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'ATOM Store' = @{
		ToolTip		= "Install portable programs for ATOM"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'ATOMizer' = @{
		ToolTip		= "Format/update multiple flash drives w/ zip & ISO files"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Autoruns' = @{
		ToolTip		= "View/modify all computer startups"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'BlueScreenView' = @{
		ToolTip		= "View blue screen crash dumps"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Command Prompt' = @{
		ToolTip		= "Windows legacy command-line"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Control Panel' = @{
		ToolTip		= "Windows legacy Control Panel"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'CPU-Z' = @{
		ToolTip		= "View CPU info, benchmarking, & stress testing"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'CrystalDiskInfo' = @{
		ToolTip		= "View drive health & info"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'CrystalDiskMark' = @{
		ToolTip		= "Test drive read/write speeds"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Detectron' = @{
		ToolTip		= "Disable telemetry & uninstall bloatware/malware"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Device Manager' = @{
		ToolTip		= "View & manage device info & drivers"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Disk Management' = @{
		ToolTip		= "Manage local drives"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Display Driver Uninstaller' = @{
		ToolTip		= "Completely remove GPU drivers"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Event Viewer' = @{
		ToolTip		= "View Windows event logs"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Explorer++' = @{
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'FreeCommander' = @{
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'HCI Design MemTest' = @{
		ToolTip		= "Memory overclock stability test"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'HWMonitor' = @{
		ToolTip		= "Real-time hardware monitoring"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Installed Apps' = @{
		ToolTip		= "Windows Settings app management"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Kaspersky Virus Removal Tool' = @{
		ToolTip		= "Kaspersky AV scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'KeyCutlass' = @{
		ToolTip		= "View Windows product & encryption keys"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'MalwareBytes AdwCleaner' = @{
		ToolTip		= "MBAM malware scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'McAfee Stinger' = @{
		ToolTip		= "McAfee AV scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'MemTest86' = @{
		ToolTip		= "Bootable memory tester"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'MSI Kombustor' = @{
		ToolTip		= "GPU stress-tester"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Neutron' = @{
		ToolTip		= "New PC suite: install programs & set common settings"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Norton Power Eraser' = @{
		ToolTip		= "Norton AV scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Notepad++' = @{
		ToolTip		= "Notepad but with two pluses"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'O&O Shutup10++' = @{
		ToolTip		= "Thorough telemetry disabler"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'OCCT' = @{
		ToolTip		= "All-in-one diagnostic, stability, & stress-tester"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'OneCommander' = @{
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Opera' = @{
		ToolTip		= "Portable web browser"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Ornstein and S-Mode' = @{
		ToolTip		= "Disable Windows S-Mode"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'PassCrack' = @{
		ToolTip		= "Disable Windows login passwords (requires MountOS ran)"
		WorksInOs	= $false
		WorksInPe	= $true
	}
	
	'PowerShell Core' = @{
		ToolTip		= "Windows modern command-line (non-native)"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'PowerShell' = @{
		ToolTip		= "Windows modern command-line (native)"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Prime95' = @{
		ToolTip		= "CPU stability tester"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Process Monitor' = @{
		ToolTip		= "Real-time process monitoring & snapshotting"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Recuva' = @{
		ToolTip		= "File recovery software"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Registry Editor' = @{
		ToolTip		= "View & modify registry keys & values"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Regshot' = @{
		ToolTip		= "Registry comparison tool"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Reset Default Services' = @{
		ToolTip		= "Restore default services to default states"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Restart to BIOS' = @{
		ToolTip		= "Restart computer to UEFI/BIOS"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Restart to Recovery' = @{
		ToolTip		= "Restart computer to Windows Recovery Environment"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Revo Uninstaller' = @{
		ToolTip		= "Deep program uninstaller"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Rufus' = @{
		ToolTip		= "Create bootable drives, wide file format support"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Settings' = @{
		ToolTip		= "Windows setting app"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Snappy Driver Installer Origin' = @{
		ToolTip		= "Robust driver updating software"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Task Manager' = @{
		ToolTip		= "View & manage all active process"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Task Scheduler' = @{
		ToolTip		= "Windows task automation system"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'TeraCopy' = @{
		ToolTip		= "Robust file transfer software"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Total Commander' = @{
		ToolTip		= "Alternative file explorer"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'Trifecta' = @{
		ToolTip		= "Run SFC, Windows Update, & MS Store updates"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'Webroot' = @{
		ToolTip		= "Web-based AV scanner"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'WinMerge' = @{
		ToolTip		= "File comparison software"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
	'WinUtil' = @{
		ToolTip		= "Windows multi-tool from CTT"
		WorksInOs	= $true
		WorksInPe	= $false
	}
	
	'WizTree' = @{
		ToolTip		= "Examine sizes of all local directories"
		WorksInOs	= $true
		WorksInPe	= $true
	}
	
}

# Add contents of custom hashtable to main hashtable
$customHashtable = Join-Path ($MyInvocation.MyCommand.Path | Split-Path) "Plugins-Hashtable (Custom).ps1"
. $customHashtable
$pluginInfo += $customPluginInfo
