function Get-StartupInfo {
	foreach ($path in $startupPaths) {
		if (Test-Path $path) {
			$registryKeys = Get-ItemProperty -Path $path | Select-Object -Property *
			"Registry Path: $path", "-------------------------" +
			($registryKeys.PSObject.Properties | ForEach-Object { "Name: $($_.Name)", "Binary Value: $($_.Value)", "-------------------------" }) + ""
		}
		else {
			"Registry path not found: $path", ""
		}
	}
}

function DisplayOrExportStartupInfo {
	param($exportPath)
	$info = Get-StartupInfo

	if ($exportPath) {
		$info | Out-File -FilePath $exportPath -Force
		Write-Host "Output has been exported to: $exportPath"
	} else {
		$info | Write-Host
	}
}

$startupPaths = @(
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
	"HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32",
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run",
	"HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32"
)

Clear-Host
Write-InspectorHeader
Write-Host "[1] Display startup values in window."
Write-Host "[2] Export startup values to Inspector Output."
Write-Host "[X] Exit (return to Debloat)" -ForegroundColor Red

do {
	$selectedOption = Read-Host "`nSelect an option"
} until (($selectedOption -in 1..2) -or ($selectedOption -eq 'X'))

switch ($selectedOption) {
	1 {
		Clear-Host
		Write-InspectorHeader
		DisplayOrExportStartupInfo
		Read-Host "Press 'Enter' to continue"
	}
	2 {
		Clear-Host
		Write-InspectorHeader
		DisplayOrExportStartupInfo -exportPath $inspectorOutput\startups_$dateTime.txt
		Read-Host "Press 'Enter' to continue"
	}
	X {
		return
	}
}