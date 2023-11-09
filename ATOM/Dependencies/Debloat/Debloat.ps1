##################
# Debloat Script #
#       v4       #
##################

# Get path to Debloat.ps1 script
$scriptPath = Split-Path $MyInvocation.MyCommand.Path -Parent

# Variables needed throughout rest of script
$driveLetter = (Split-Path -Path $MyInvocation.MyCommand.Path -Qualifier)
$debloatDependencies = "$scriptPath\Debloat Dependencies"
$inspectorDependencies = "$scriptPath\Inspector Dependencies"
$inspectorOutput = "$scriptPath\Inspector Output"
$dateTime = Get-Date -Format "yyyyMMdd_HHmmss"
$tempPath = $env:TEMP
$restartRequired = 0
$uninstallPaths = @(
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", # 64-bit programs
	"HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall", # 32-bit programs
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" # User programs
)

# Import functions and variables from Debloat Dependencies folder
Get-ChildItem -Path "$scriptPath\Debloat Dependencies" -Filter *.ps1 | ForEach-Object {. $_.FullName}
$logFiles = Get-ChildItem -Path $tempPath -Filter "debloat_*.txt"
$logCount = $logFiles.Count

# Mode Select
do {
	Clear-Host
	Write-DebloatHeader
	if ($logCount -gt 0) {
		Write-Host "`n$logCount log file(s) detected." -ForegroundColor Yellow
	}
	
	Write-Host "`nSelect an option, then press 'Enter'.`n"
		Write-Host "-------Debloat Modes-------"
		Write-Host "|                         |"
 Write-ColoredLine "[1] Safe               " -ForegroundColor Cyan
 Write-ColoredLine "[2] Balanced           " -ForegroundColor Green
 Write-ColoredLine "[3] Aggressive         " -ForegroundColor Magenta
		Write-Host "|                         |"
		Write-Host "---------------------------"
		Write-Host ""
		Write-Host "-------Other Options-------"
		Write-Host "|                         |"
 Write-ColoredLine "[I] Inspector          " -ForegroundColor Blue
 Write-ColoredLine "[T] Tools              " -ForegroundColor DarkGreen
 Write-ColoredLine "[?] Info               " -ForegroundColor DarkYellow
 Write-ColoredLine "[X] Exit               " -ForegroundColor Red
		Write-Host "|                         |"
		Write-Host "---------------------------"
		Write-Host ""
	$debloatMode = Read-Host "Option"
	
	if ($debloatMode -eq '?') {
		Clear-Host
		Write-Host "[1] Safe Mode" -ForegroundColor Cyan
		Write-Host "---------------------------------------------"
		Write-Host "Safe Mode conservatively uninstalls bloatware"
		Write-Host "if user data is not present and performs"
		Write-Host "general OS optimizations.  Safe Mode is"
		Write-Host "recommended for most computers.`n"
		
		Write-Host "[2] Balanced Mode" -ForegroundColor Green
		Write-Host "---------------------------------------------"
		Write-Host "Balanced Mode flags more apps as bloatware"
		Write-Host "and performs additional OS optimizations."
		Write-Host "Balanced Mode is recommended for slower PCS,"
		Write-Host "PCs that have lots of programs installed,"
		Write-Host "or for users who prefer a stock experience.`n"
		
		Write-Host "[3] Aggressive Mode" -ForegroundColor Magenta
		Write-Host "---------------------------------------------"
		Write-Host "Aggressive Mode flags even more apps as"
		Write-Host "bloatware, performs strong OS"
		Write-Host "optimizations, and disables several"
		Write-Host "services to decrease CPU & drive load."
		Write-Host "This mode is recommended for computers that"
		Write-Host "are struggling to run Windows or for users"
		Write-Host "who need maximum performance.  This mode will"
		Write-Host "create a restore point prior to running.`n"
		
		Write-Host "[I] Inspector" -ForegroundColor Blue
		Write-Host "---------------------------------------------"
		Write-Host "Inspector has multiple features that help"
		Write-Host "maintain the main Debloat script.  This"
		Write-Host "includes reading logs & finding uninstall"
		Write-Host "strings for programs.`n"
		
		Write-Host "[T] Tools" -ForegroundColor DarkGreen
		Write-Host "---------------------------------------------"
		Write-Host "Currently WIP.`n"
		
		Read-Host "Press 'Enter' to return to Mode Select"
	}
	if ($debloatMode -eq 'I') {
		Clear-Host
		Invoke-Expression -Command (Get-Content $scriptPath\Inspector.ps1 | Out-String)
	}
	if ($debloatMode -eq 'T') {
		Clear-Host
		Write-Warning "UNDER CONSTRUCTION"
		Read-Host "Press 'Enter' to continue"
	}
	if ($debloatMode -eq 'X') {
		exit
	}
}	until ($debloatMode -match "^(1|2|3)$")

Clear-Host
Start-Transcript "$env:TEMP\debloat_$dateTime.txt"
Write-DebloatHeader
if ($debloatMode -eq 1)
{
	Write-Host "---------------------------" -ForegroundColor Cyan
	Write-Host "|        Safe Mode        |" -ForegroundColor Cyan
	Write-Host "---------------------------" -ForegroundColor Cyan
}
elseif ($debloatMode -eq 2)
{
	Write-Host "---------------------------" -ForegroundColor Green
	Write-Host "|      Balanced Mode      |" -ForegroundColor Green
	Write-Host "---------------------------" -ForegroundColor Green
}
elseif ($debloatMode -eq 3)
{
	Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor Magenta
	Write-Host "X AGGRESSIVE MODE ENGAGED X" -ForegroundColor Magenta
	Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXX" -ForegroundColor Magenta
	Write-Host "Aggressive Mode selected, creating restore point."
	Enable-ComputerRestore -Drive "C:\"
	REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /V "SystemRestorePointCreationFrequency" /T REG_DWORD /D 0 /F
	Checkpoint-Computer -Description "Aggressive Debloat" -RestorePointType "MODIFY_SETTINGS"
	Write-Host "Restore point has been created." -ForegroundColor Green
}

"---------------------------"
"|     AV Uninstallers     |"
"---------------------------"

Write-Progress -Activity "Running AV Uninstallers" -Status "[ 1 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\Uninstallers-AntiVirus.ps1 | Out-String)

"---------------------------"
"|  Standard Uninstallers  |"
"---------------------------"

Write-Progress -Activity "Running Standard Uninstallers" -Status "[ 2 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\Uninstallers-Standard.ps1 | Out-String)

"---------------------------"
"|  Malware Uninstallers   |"
"---------------------------"

Write-Progress -Activity "Running Malware Uninstallers" -Status "[ 3 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\Uninstallers-Malware.ps1 | Out-String)

"---------------------------"
"|    Store Uninstallers   |"
"---------------------------"

Write-Progress -Activity "Running Store Uninstallers" -Status "[ 4 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\Uninstallers-MSStore.ps1 | Out-String)

"---------------------------"
"| Online Services Removal |"
"---------------------------"

Write-Progress -Activity "Running Online Services Removal" -Status "[ 5 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\Removal-OnlineServices.ps1 | Out-String)

"---------------------------"
"|   Optimizing Settings   |"
"---------------------------"

Write-Progress -Activity "Running Optimizations" -Status "[ 6 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\Optimize-Settings.ps1 | Out-String)

"---------------------------"
"|   Optimizing Startups   |"
"---------------------------"

Write-Progress -Activity "Running Optimizations" -Status "[ 7 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\Optimize-Startups.ps1 | Out-String)

"---------------------------"
"|  Browser Notifications  |"
"---------------------------"

Write-Progress -Activity "Running Browser Notification Check" -Status "[ 8 / 8 ]"
Invoke-Expression -Command (Get-Content $scriptPath\BrowserNotifications.ps1 | Out-String)

if ($restartRequired -eq 1) {
		Write-Host "Restart required to fully uninstall program(s)." -ForegroundColor Red
}

Stop-Transcript

if ($debloatMode -eq 1)
{
Write-Host "------------------------------------" -Foregroundcolor Cyan
Write-Host "| Computer debloated successfully. |" -Foregroundcolor Cyan
Write-Host "|   Press 'Enter' to continue...   |" -Foregroundcolor Cyan
Write-Host "------------------------------------" -Foregroundcolor Cyan
Read-Host  ":::::::::::::::ENTER:::::::::::::::"
}
if ($debloatMode -eq 2)
{
Write-Host "------------------------------------" -Foregroundcolor Green
Write-Host "| Computer debloated successfully. |" -Foregroundcolor Green
Write-Host "|   Press 'Enter' to continue...   |" -Foregroundcolor Green
Write-Host "------------------------------------" -Foregroundcolor Green
Read-Host  ":::::::::::::::ENTER:::::::::::::::"
}
if ($debloatMode -eq 3)
{
Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -Foregroundcolor Magenta
Write-Host "X         PAYLOAD EXECUTED.        X" -Foregroundcolor Magenta
Write-Host "X   PRESS 'ENTER' TO CONTINUE...   X" -Foregroundcolor Magenta
Write-Host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" -Foregroundcolor Magenta
Read-Host  ":::::::::::::::ENTER:::::::::::::::"
}