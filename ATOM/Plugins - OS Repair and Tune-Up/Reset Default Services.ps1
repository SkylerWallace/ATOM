# Determine if using on online/offline OS
$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$hiveMounted = Test-Path "HKLM:\RemoteOS-HKLM-SYSTEM"

if($inPE -and $hiveMounted) {
	$systemHive = "HKLM:\RemoteOS-HKLM-SYSTEM"
#	$atomTemp = ...
#	$logPath = ...
} elseif ($inPE -and !$hiveMounted) {
	Write-Host "OS is offline!"
	Write-Host "Please mount offline OS with MountOS to proceed."
	Read-Host "Press 'Enter' to exit script"
} else {
	$systemHive = "HKLM:\SYSTEM"
#	$atomTemp = Join-Path $env:TEMP "ATOM Temp"
#	$logPath = Join-Path $atomTemp "rds-$dateTime.txt"
}

# Start logging
$atomTemp = Join-Path $env:TEMP "ATOM Temp"
$logPath = Join-Path $atomTemp "rds-$dateTime.txt"
if (!(Test-Path $atomTemp)) { New-Item -Path $atomTemp -ItemType Directory -Force }
$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path $logPath | Out-Null

# Set window title and CLI colors
$host.UI.RawUI.WindowTitle = "Reset Default Services"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Header
Write-Host "╔══════════════════════════════════╗" -ForegroundColor "Cyan"
Write-Host "║                                  ║" -ForegroundColor "Cyan"
Write-Host "║      Reset Default Services      ║" -ForegroundColor "Cyan"
Write-Host "║                                  ║" -ForegroundColor "Cyan"
Write-Host "╚══════════════════════════════════╝" -ForegroundColor "Cyan"
Write-Host ""

# Windows major version, build number, & feature update
$winName = ((Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Split(' ')[-2])
$winVer = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name DisplayVersion).DisplayVersion
$winBuild = (Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber

Write-Host "Windows $winName $winVer (Build $winBuild)"
Write-Host ""

# Press 'Enter' to continue script
Read-Host "Press 'Enter' to reset default services"
Write-Host ""

$currentStartups = [ordered]@{}
Get-ChildItem "$systemHive\ControlSet001\Services" | Where-Object { $_.Property -contains "Start" -and $_.Property -contains "ObjectName" } | ForEach-Object {
	$name = $_.Name.Split('\')[-1]
	$regPath = $_.PsPath
	$start = $_.GetValue("Start")
	$isDelayed = $_.GetValue("DelayedAutostart")
	
	$startup = switch ($start) {
		1 { "System" }
		2 { "Automatic" }
		3 { "Manual" }
		4 { "Disabled" }
	}
	
	if ($isDelayed -and $startup -eq "Automatic") {
		$startup = "AutomaticDelayedStart"
	}
	
	$currentStartups[$name] = @{
		RegPath = $regPath
		Start = $start
		StartupType = $startup
	}
}

# Import hashtable
$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$rdsPath = Join-Path $dependenciesPath "RDS"
$hashtablePath = Join-Path $rdsPath "$winName-$winVer.ps1"

# Early exit if Windows version is not supported
if (!(Test-Path $hashtablePath)) {
	Write-Host "This Windows version is not supported!"
	Read-Host "Press 'Enter' to exit script"
	exit
}

# Import hashtable
. $hashtablePath

# Table header
Write-Host "Service              Before               After"				-ForegroundColor Cyan
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan

# Restore default service startup states
$counter = 0
$defaultStartups.Keys | ForEach-Object {
	$service = $_
	$currentStartup = $currentStartups[$service]['StartupType']
	$defaultStartup = $defaultStartups[$service]
	
	# Early exit if service not detected
	if (!$currentStartup) {
		Write-Error "$service not detected!"
		return
	}
	
	$foregroundColor = "DarkGray"
	$servicesCounter++
	
	# If service startup is not default value
	if ($currentStartup -ne $defaultStartup) {
		$counter++
		$foregroundColor = "White"
		
		$regPath = $currentStartups[$service]['RegPath']
		$regValue = switch ($defaultStartup) {
			"System"				{ 1 }
			"Automatic"				{ 2 }
			"AutomaticDelayedStart"	{ 2 }
			"Manual"				{ 3 }
			"Disabled"				{ 4 }
		}
		
		# Change startup type
		Set-ItemProperty -Path $regPath -Name "Start" -Value $regValue
		
		# Set additional registry value for AutomaticDelayedStart
		if ($defaultStartup -eq "AutomaticDelayedStart") {
			Set-ItemProperty -Path $regPath -Name "DelayedAutostart" -Value 1
		}
	}
	
	# Trim length for output
	if ($service.Length -gt 18) { $service = $service.Substring(0,18) }
	if ($currentStartup.Length -gt 18) { $currentStartup = $currentStartup.Substring(0,18) }
	if ($defaultStartup.Length -gt 18) { $defaultStartup = $defaultStartup.Substring(0,18) }
	
	# Output results
    $outputFormat = "{0,-20} {1,-20} {2,-20}" -f $service, $currentStartup, $defaultStartup
    Write-Host $outputFormat -ForegroundColor $foregroundColor
}

# Output results
$serviceCounter = $defaultStartups.Count
Write-Host ""
Write-Host "Results:" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Services checked: $serviceCounter" -ForegroundColor White
Write-Host "Services changed: " -ForegroundColor White -NoNewLine
Write-Host "$counter" -ForegroundColor Cyan
Write-Host ""

# End logging
Stop-Transcript | Out-Null
Write-Host "Log saved to:"
Write-Host $logPath
Write-Host ""

# End script
Write-Host "Please restart to apply changes."
Read-Host "Press 'Enter' to exit script"

<# Output all current services to .txt file

$output = ""

$currentStartups.Keys | ForEach-Object {
	$name = $_
	$startupType = $currentStartups[$name]['StartupType']
	
	$output += "`"$name`" = `"$startupType`"`n"
}

Write-Host $output

Set-Content -Path "$env:TEMP\rds.txt" -Value $output

#>