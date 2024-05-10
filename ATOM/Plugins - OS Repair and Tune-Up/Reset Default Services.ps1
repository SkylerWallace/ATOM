# Launch: Hidden

param([switch]$continue)

# Declaring relative paths needed for rest of script
$scriptPath = $MyInvocation.MyCommand.Path
$atomPath = $scriptPath | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$rdsPath = Join-Path $dependenciesPath "RDS"
$clearTempHive = Join-Path $rdsPath "Clear-TempHive.ps1"

# Clear temp hive upon start and exit of script
if (!$continue) {
	Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$clearTempHive`"" -Wait
	Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" -Continue" -Wait
	Start-Process powershell -WindowStyle Hidden -ArgumentList "-ExecutionPolicy Bypass -File `"$clearTempHive`"" -Wait
	exit
}

# Set window title and CLI colors
$host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(80, 30)
$host.UI.RawUI.WindowTitle = "Reset Default Services"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Determine if using on online/offline OS
$inPE = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Control\MiniNT"
$hiveMounted = Test-Path "HKLM:\RemoteOS-HKLM-SYSTEM"

if($inPE -and $hiveMounted) {
	$softwareHive = "HKLM:\RemoteOS-HKLM-SOFTWARE"
	$systemHive = "HKLM:\RemoteOS-HKLM-SYSTEM"
} elseif ($inPE -and !$hiveMounted) {
	Write-Host "OS is offline!"
	Write-Host "Please mount offline OS with MountOS to proceed."
	Read-Host "Press 'Enter' to exit script"
	exit
} else {
	$softwareHive = "HKLM:\SOFTWARE"
	$systemHive = "HKLM:\SYSTEM"
}

# Windows major version, build number, & feature update
$ntPath = Join-Path $softwareHive "Microsoft\Windows NT\CurrentVersion"
if ($inPE) {
	$winBuild = (Get-ItemProperty $ntPath -Name "CurrentBuild").CurrentBuild
	$winName =	if ($winBuild -ge 22000) { "11" }
				else { (Get-ItemProperty $ntPath -Name "ProductName").ProductName.Split(' ')[1] }
} else {
	$winName = ((Get-CimInstance -ClassName Win32_OperatingSystem).Caption.Split(' ')[-2])
	$winBuild = (Get-CimInstance -ClassName Win32_OperatingSystem).BuildNumber
}

$winVer = (Get-ItemProperty $ntPath -Name DisplayVersion).DisplayVersion
$winId = "Windows" + $winName + '-' + $winVer

# Create temp dir if not detected
$atomTemp = Join-Path $env:TEMP "ATOM Temp"
$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
if (!(Test-Path $atomTemp)) { New-Item -Path $atomTemp -ItemType Directory -Force }

###########################################################
###########################################################

function Invoke-Header {
	Clear-Host
	Write-Host "╔══════════════════════════════════════╗" -ForegroundColor "Cyan"
	Write-Host "║                                      ║" -ForegroundColor "Cyan"
	Write-Host "║        Reset Default Services        ║" -ForegroundColor "Cyan"
	Write-Host "║                                      ║" -ForegroundColor "Cyan"
	Write-Host "╚══════════════════════════════════════╝" -ForegroundColor "Cyan"
	Write-Host ""
}

function RDS-MountHive {
	# Reg paths
	$script:regMount = "HKLM\TempHive"
	$script:regMountPs = Join-Path "HKLM:" (Split-Path $regMount -Leaf)
	
	# Extract RDS zipped resources to ATOM temp
	$rdsZip = Join-Path $rdsPath "RDS.zip"
	$progressPreference = "SilentlyContinue"
	Expand-Archive $rdsZip $atomTemp -Force
	
	# Mount temp hive
	$tempHive = Join-Path $atomTemp "TempHive"
	reg load $regMount $tempHive

	# Import default services reg values
	$servicesReg = Join-Path $atomTemp "Services.reg"
	reg import $servicesReg
}

function RDS-InstallService {
	param([string]$service)
	
	$lookupValue = $lookupTable[$service][$winId]
	$sourceKey = Join-Path $regMountPs "${service}\${lookupValue}\$service"
	$destinationPath = Join-Path $systemHive "ControlSet001\Services"
	$destinationKey = Join-Path $destinationPath $service
	
	# Rename current service if detected
	if (Test-Path $destinationKey) {
		$backupKey = $destinationKey + ".bak"
		$backupName = $service + ".bak"
		
		# Remove old key backup if present for any reason
		if (Test-Path $backupKey) {
			Remove-Item $backupKey -Recurse -Force
		}
		
		try {
			$errorActionPreference = "Stop"
			Rename-Item $destinationKey $backupName -Force
		} catch {
			Write-Host "Failed to modify $service" -ForegroundColor Red
			return
		} finally { $errorActionPreference = "Continue" }
	}
	
	# Copy default service
	try {
		$errorActionPreference = "Stop"
		Copy-Item $sourceKey $destinationPath -Recurse -Force
		Remove-Item $backupKey -Recurse -Force
		Write-Host "$service installed" -ForegroundColor Cyan
	} catch {
		# Restore original service if failed
		Rename-Item $backupKey $service -Force
		Write-Host "Failed to modify $service" -ForegroundColor Red
	} finally { $errorActionPreference = "Continue" }
}

function RDS-DefaultServices {
	Invoke-Header
	
	# Import lookup table
	. (Join-Path $atomTemp "Lookup-Table.ps1")
	
	# Table header
	Write-Host "Service              Before               After"				-ForegroundColor Cyan
	Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
	
	$serviceCounter = 0
	$modifiedCounter = 0
	
	foreach ($service in $lookupTable.Keys) {
		# Early exit: invalid service
		$lookupValue = $lookupTable[$service][$winId]
		if ($lookupValue -eq $null) { continue }
		
		$serviceCounter++
		$foregroundColor = "DarkGray"
		
		$currentStartup = Join-Path $systemHive "ControlSet001\Services\$service"
		$defaultStartup = Join-Path $regMountPs "${service}\${lookupValue}\$service"
		
		# Early exit: service missing
		if (!(Test-Path $currentStartup)) {
			Write-Host "$service missing" -ForegroundColor Red
			continue
		}
		
		$currentStartupState = (Get-ItemProperty $currentStartup -Name "Start").Start
		$defaultStartupState = (Get-ItemProperty $defaultStartup -Name "Start").Start
		
		if ($currentStartupState -ne $defaultStartupState) {
			$modifiedCounter++
			$foregroundColor = "Cyan"
			
			try {
				$errorActionPreference = "Stop"
				
				# Update startup value
				Set-ItemProperty -Path $currentStartup -Name "Start" -Value $defaultStartupState
				
				# Set additional registry value for AutomaticDelayedStart
				$defaultDelayed = ($defaultStartupState -eq 2) -and
				((Get-ItemProperty $defaultStartup -Name "DelayedAutostart" -ErrorAction "SilentlyContinue").DelayedAutoStart -eq 1)
				
				if ($defaultDelayed) {
					Set-ItemProperty -Path $currentStartup -Name "DelayedAutostart" -Value 1
				}
			} catch {
				Write-Host "$service - Failed to restore" -ForegroundColor Red
				continue
			} finally { $errorActionPreference = "Continue" }
		}
		
		# Trim length for output
		if ($service.Length -gt 18) { $service = $service.Substring(0,18) }
		
		# Output service result
		$outputFormat = "{0,-20} {1,-20} {2,-20}" -f $service, $currentStartupState, $defaultStartupState
		Write-Host $outputFormat -ForegroundColor $foregroundColor
	}
	
	# Output final results
	Write-Host "`nResults:" -ForegroundColor Cyan
	Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
	Write-Host "Services checked: $serviceCounter" -ForegroundColor White
	Write-Host "Services changed: " -ForegroundColor White -NoNewLine
	Write-Host "$modifiedCounter" -ForegroundColor Cyan
	
	# Return to main menu
	Write-Host "Please restart to apply changes."
	Read-Host "Press 'Enter' to return to Main Menu"
	Invoke-MainMenu
}

function RDS-MissingServices {
	Invoke-Header
	
	# Import lookup table
	. (Join-Path $atomTemp "Lookup-Table.ps1")
	
	# Table header
	Write-Host "Service"				                                        -ForegroundColor Cyan
	Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
	
	$serviceCounter = 0
	$modifiedCounter = 0
	
	foreach ($service in $lookupTable.Keys) {
		# Early exit: invalid service
		if ($lookupTable[$service][$winId] -eq $null) { continue }
		
		$serviceCounter++
		
		# Early exit: service present
		$servicePath = Join-Path $systemHive "ControlSet001\Services\$service"
		if (Test-Path $servicePath) {
			Write-Host $service -ForegroundColor DarkGray
			continue
		}
		
		$modifiedCounter++
		
		# Install missing service
		RDS-InstallService $service
	}
	
	# Output results
	Write-Host "`nResults:" -ForegroundColor Cyan
	Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
	Write-Host "Services checked: $serviceCounter" -ForegroundColor White
	Write-Host "Services changed: " -ForegroundColor White -NoNewLine
	Write-Host "$modifiedCounter" -ForegroundColor Cyan
	
	# Return to main menu
	Write-Host "Please restart to apply changes."
	Read-Host "Press 'Enter' to return to Main Menu"
	Invoke-MainMenu
}

function RDS-SpecificService {	
	# Import lookup table
	. (Join-Path $atomTemp "Lookup-Table.ps1")
	
	# Loop until user specifies a valid service
	do {
		Invoke-Header
		
		if ($invalidService) {
			Write-Host "Invalid service" -ForegroundColor Red
			Write-Host "- Windows version may not contain specified service`n"
		} elseif ($unsupportedService) {
			Write-Host "Unsupported service" -ForegroundColor Red
			Write-Host "- RDS does not support this service for this version of Windows`n"
		}
		
		$selectedService = Read-Host "Enter the service name to reinstall"
		
		if ($lookupTable[$selectedService] -eq $null) {
			$invalidService = $true
		} else {
			$invalidService = $false
			
			if ($lookupTable[$selectedService][$winId] -ne $null) {
				$supportedService = $true
			} else {
				$unsupportedService = $true
			}
		}
	} until ($supportedService)
	
	# Install service
	$service = $lookupTable.Keys | Where { $_.ToLower() -eq $selectedService }
	RDS-InstallService $service
	
	# Return to main menu
	Write-Host "Please restart to apply changes."
	Read-Host "Press 'Enter' to return to Main Menu"
	Invoke-MainMenu
}

function Invoke-MainMenu {
	do {
		Invoke-Header
		
		Write-Host "Windows $winName $winVer (Build $winBuild)`n"
		
		Write-Host "╔═ OPTIONS ════════════════════════════╗"
		Write-Host "║                                      ║"
		Write-Host "║ - [1] Restore Default Startup States ║"
		Write-Host "║ - [2] Reinstall Missing Services     ║"
		Write-Host "║ - [3] Reinstall Specific Service     ║"
		Write-Host "║ - [X] Exit                           ║"
		Write-Host "║                                      ║"
		Write-Host "╚══════════════════════════════════════╝"
		Write-Host ""
		
		$answer = Read-Host "Select an option and press Enter"
	} until ( $answer -in @(1, 2, 3, 'X') )
	
	switch ($answer) {
		1   { RDS-DefaultServices }
		2   { RDS-MissingServices }
		3   { RDS-SpecificService }
		'X' { exit }
	}
}

RDS-MountHive
Invoke-MainMenu