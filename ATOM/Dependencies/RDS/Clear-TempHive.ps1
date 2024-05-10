# Reg paths
$regMount = "HKLM\TempHive"
$regMountPs = Join-Path "HKLM:" (Split-Path $regMount -Leaf)

# Unmount temp reg hive if detected
if (Test-Path $regMountPs) {
	reg unload $regMount
}

# Remove any residual files
$rdsFiles = @("LookupTable", "Services.reg", "TempHive")

foreach ($file in $rdsFiles) {
	$filePath = Join-Path $atomTemp $file
	if (Test-Path $filePath) {
		Remove-Item $filePath -Force
	}
}

# Early exit: if in PE
$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
if ($inPE) { exit }

# Early exit: launched from ProgramData + success!
$scriptPath = $MyInvocation.MyCommand.Path
$destinationPath = Join-Path $env:ProgramData "Clear-TempHive"

if ($scriptPath -eq $destinationPath) {
	if (!(Test-Path $regMountPs)) {
		exit
	}
}

# Run Clear-TempHive on reboot
Copy-Item $scriptPath $destinationPath -Force | Out-Null

$runOncePath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
$registryValue = "cmd /c `"start /b powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$destinationPath`"`""
New-ItemProperty -Path $runOncePath -Name "Clear-TempHive" -Value $registryValue -Force | Out-Null