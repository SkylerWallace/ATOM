$tooltip = "SysMain preloads frequently used apps into memory`nWhile sometimes beneficial, often contributes to`n100% disk utilization on older PCs"

Write-Host "Disabling SysMain (Superfetch)"

# Stop SysMain service if it's running
$sysMainRunning = (Get-Service SysMain).Status -eq "Running"

if ($sysMainRunning) {
    try {
        Stop-Service SysMain -ErrorAction Stop
        Write-Host "- SysMain service stopped"
    } catch {
        throw
    }
}

# Early exit if SysMain is already disabled
$sysMainDisabled = (Get-Service SysMain).StartType -eq "Disabled"

if ($sysMainDisabled) {
    Write-Host "- SysMain > Unchanged"
    return
}

# Disable SysMain
try {
    Set-Service SysMain -StartupType Disabled -ErrorAction Stop
    Write-Host "- SysMain > Disabled"
} catch {
    throw
}

Write-Host ""
