$detectedPrograms = @()
foreach ($uninstallPath in $uninstallPaths) {
	$keys = Get-ChildItem -Path $uninstallPath | Where-Object { $_.GetValue("DisplayName") -like "*McAfee*" }
	if ($keys) {
		foreach ($key in $keys) {
			$displayName = $key.GetValue("DisplayName")
			$detectedPrograms += $displayName
		}
	}
}

$folderNames = @("McAfee*", "McInst*")
$searchFolders = @(
	"C:\Program Files",
	"C:\Program Files (x86)",
	"C:\Program Files\Common Files",
	"C:\Program Files (x86)\Common Files",
	"C:\ProgramData",
	"$env:localappdata",
	"$env:appdata"
)
$matchingFolders = Get-ChildItem -Path $searchFolders -Directory | Where-Object { $_.Name -match ($folderNames -join "|") }

if (($detectedPrograms) -Or ($matchingFolders)) {
	if ($detectedPrograms) {
		Write-Host "The following McAfee programs were detected:"
		foreach ($program in $detectedPrograms) {
			Write-Host "- $program" -ForegroundColor DarkGray
		}
	}
	elseif (!($detectedPrograms) -And ($matchingFolders)) {
		Write-Host "No McAfee software is currently installed but remnants remain."
	}
	Write-Host "Would you like to remove McAfee?"
	do { $answer = Read-Host "[Y] Yes [N] No" } until ($answer -match "^(y|n)$")
	if ($answer -eq "y") {
		Remove-McAfee
	}
}
else {
	Write-Host "McAfee not detected."
}