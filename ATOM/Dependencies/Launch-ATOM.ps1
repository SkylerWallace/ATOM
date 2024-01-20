# Launch ATOM if already downloaded to temp
$atomBat = Join-Path $env:TEMP "ATOM\ATOM.bat"
if (Test-Path $atomBat) {
	Start-Process $atomBat
	exit
}

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


# Unzip ATOM
$atomUnzipped = Join-Path $env:TEMP "ATOM-main"
if (Test-Path $atomUnzipped) { Remove-Item $atomUnzipped -Recurse }
Expand-Archive -Path $atomDestination -DestinationPath $atomUnzipped

# Copy files
$atomSubDir = Join-Path $atomUnzipped "ATOM-main"
$atomPath = Join-Path $env:TEMP "ATOM"
Copy-Item -Path $atomSubDir -Destination $atomPath -Force -Recurse

# Cleanup
Remove-Item -Path $atomDestination -Force
Remove-Item -Path $atomUnzipped -Recurse

Start-Process $atomBat