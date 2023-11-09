Clear-Host
Write-InspectorHeader

# Check if the folder exists
if (-not (Test-Path $inspectorOutput)) {
	Write-Host "Folder doesn't exist."
	return
}

# Get all files in the folder
$inspectorFiles = Get-ChildItem -Path $inspectorOutput -File

if ($inspectorFiles.Count -eq 0) {
	Write-Host "No files located in Inspector Output folder."
	Read-Host "Press 'Enter' to continue"
	return
}
	
# Display the files
Write-Host "Files in Inspector Output folder:"
$inspectorFiles | ForEach-Object {
	Write-Host $_.Name -ForegroundColor DarkGray
}

# Prompt the user for deletion confirmation
Write-Host "`nDelete all files?"
do { $answer = Read-Host "[Y] Yes [N] No" } until ($answer -match "^(y|n)$")

if ($answer -eq 'y') {
	# Delete each file
	$inspectorFiles | ForEach-Object {
		Remove-Item -Path $_.FullName -Force
	}

	Write-Host "`nAll files have been deleted."
	Read-Host "Press 'Enter' to continue"
}
else {
	return
}