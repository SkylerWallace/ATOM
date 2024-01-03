Write-Host "Updating ATOM.`n"

# Terminate PowerShell scripts
$currentProcessId = $PID
$powershellProcesses = Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $currentProcessId }
foreach ($process in $powershellProcesses) {
	Stop-Process -Id $process.Id -Force
}

$atomPath = $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$dependenciesPath = Join-Path $atomPath "Dependencies"
$settingsPath = Join-Path $dependenciesPath "Settings"
$filesPath = Join-Path $atomPath "Dependencies\Settings\files.txt"
$filesList = Get-Content $filesPath | ForEach-Object { $_ -replace "ATOM/", "$atomPath\" -replace "/", "\" }

# Get all files in the Plugins and Icons directories
$localFiles = Get-ChildItem $atomPath -Recurse

# Compare to find files in the directories but not in the list
$excludedFiles = Compare-Object -ReferenceObject $localFiles.FullName -DifferenceObject $filesList -PassThru | Where-Object { $_.SideIndicator -eq "<=" }
$excludedFiles += "$dependenciesPath\Programs-Hashtable (Custom).ps1"
$excludedFiles += "$settingsPath\Colors-Custom.ps1"
$excludedFiles += "$settingsPath\Settings-Custom.ps1"

# Delete files and empty directories
Get-ChildItem -Path $atomPath -Recurse -File | Where-Object { $_.FullName -notin $excludedFiles } | Remove-Item -Force -Confirm:$false
Get-ChildItem -Path $atomPath -Directory -Recurse | Sort-Object FullName -Descending | Where-Object { (Get-ChildItem -Path $_.FullName).Count -eq 0 } | Remove-Item -Force -Recurse -Confirm:$false

# If internet connected, download latest ATOM to temp
$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'Public' -or $_.NetworkCategory -eq 'Private' }) -ne $null
if ($internetConnected) {
	Write-Host "Downloading ATOM..."
	
	try {
		$atomUrl = "https://github.com/SkylerWallace/ATOM/archive/refs/heads/main.zip"
		$atomDestination = Join-Path $env:TEMP "ATOM-main.zip"
		$progressPreference = "SilentlyContinue"
		Invoke-WebRequest -Uri $atomUrl -OutFile $atomDestination
	} catch {
		Write-Host "`nUnable to download latest ATOM."
		Write-Host "Potential issue with ATOM host or internet connection."
		Write-Host "Aborting update process..."
		Start-Sleep -Seconds 5
		exit	
	}
	
	Write-Host "ATOM downloaded!`n"
} else {
	Write-Host "`nNo internet connection detected."
	Write-Host "Aborting update process..."
	Start-Sleep -Seconds 5
	exit
}

Write-Host "Updating ATOM...`n"
Start-Sleep -Seconds 2

# Unzip ATOM
$atomUnzipped = Join-Path $env:TEMP "ATOM-main"
if (Test-Path $atomUnzipped) { Remove-Item $atomUnzipped -Recurse }
Expand-Archive -Path $atomDestination -DestinationPath $atomUnzipped

# Clean files
$atomSubDir = Join-Path $atomUnzipped "ATOM-main"
Remove-Item -Path "$atomSubDir\.github" -Force -Recurse
Remove-Item -Path "$atomSubDir\LICENSE" -Force
Remove-Item -Path "$atomSubDir\README.md" -Force
Remove-Item -Path "$atomSubDir\ATOM\Dependencies\Programs-Hashtable (Custom).ps1" -Force
Remove-Item -Path "$atomSubDir\ATOM\Dependencies\Settings\Colors-Custom.ps1" -Force
Remove-Item -Path "$atomSubDir\ATOM\Dependencies\Settings\Settings-Custom.ps1" -Force

# Copy files
$atomParent = $atomPath | Split-Path
Copy-Item -Path "$atomSubDir\*" -Destination $atomParent -Force -Recurse

# Cleanup
Remove-Item -Path $atomDestination -Force
Remove-Item -Path $atomUnzipped -Recurse

# Finish update
Write-Host "Update complete!"
Write-Host "Relaunching ATOM..."
Start-Sleep -Seconds 2

$atomBatDir = Join-Path ($atomPath | Split-Path) "ATOM.bat"
Start-Process $atomBatDir