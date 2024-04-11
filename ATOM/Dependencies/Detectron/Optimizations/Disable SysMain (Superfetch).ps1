$tooltip = "SysMain preloads frequently used apps into memory`nWhile sometimes beneficial, often contributes to`n100% disk utilization on older PCs"

Write-OutputBox "Disabling SysMain (Superfetch)"

# Stop SysMain service if it's running
$sysMainRunning = (Get-Service SysMain).Status -eq "Running"

if ($sysMainRunning) {
	try {
		Stop-Service SysMain -ErrorAction Stop
		Write-OutputBox "- SysMain service stopped"
	} catch {
		Write-OutputBox "- Failed to stop SysMain service"
	}
}

# Early exit if SysMain is already disabled
$sysMainDisabled = (Get-Service SysMain).StartType -eq "Disabled"

if ($sysMainDisabled) {
	Write-OutputBox "- SysMain > Unchanged"
	continue
}

# Disable SysMain
try {
	Set-Service SysMain -StartupType Disabled -ErrorAction Stop
	Write-OutputBox "- SysMain > Disabled"
} catch {
	Write-OutputBox "- SysMain > Disabled (FAILED)"
}

Write-OutputBox ""