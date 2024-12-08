# Declare function to launch ATOM
$tempPath = (Get-Item $env:TEMP).FullName
$atomBat = Join-Path $tempPath "ATOM\ATOM.bat"

function Launch-ATOM {
	try {
		Start-Process $atomBat
		exit
	} catch {
		Write-Host "`nFailed to launch ATOM!"
		Write-Host "Try to run launch line again"
		Write-Host "Or try to manually launch at the following directory:"
		Write-Host "$atomBat`n"
		return
	}
}

# Check internet connection
$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet' }) -ne $null

# Suppress progress bar to prioritize download speed
$progressPreference = "SilentlyContinue"

# Check if ATOM is already downloaded to temp
$atomDetected = Test-Path $atomBat

# Get hashes of existing ATOM and from latest ATOM online
if (!$internetConnected) {
	Write-Host "`nNo internet connection detected."
	$failState = $true
} elseif ($atomDetected -and $internetConnected) {
	# Get local hash
	$hashPath = Join-Path $tempPath "ATOM\ATOM\Settings\hash.txt"
	if (Test-Path $hashPath) {
		$localHash = (Get-Content -Path $hashPath).TrimEnd()
	} else {
		Write-Host "Failed to get hash from the following path:"
		Write-Host $hashPath
		$failState = $true
	}
	
	# Get online hash
	$hashUrl = "https://raw.githubusercontent.com/SkylerWallace/ATOM/main/ATOM/Settings/hash.txt"
	try {
		$onlineHash = (Invoke-WebRequest -Uri $hashUrl).Content.TrimEnd()
	} catch {
		Write-Host "Failed to get hash from the following URL:"
		Write-Host $hashUrl
		$failState = $true
	}
}

# Launch existing ATOM or close script if unable to compare hashes
if ($failState) {
	Write-Host "`nUnable to check for new ATOM version."
	
	if ($atomDetected) {
		Write-Host "Launching local ATOM without updating..."
		Start-Sleep -Seconds 5
		Launch-ATOM
	}
	
	Write-Host "`nProcess aborted.`n"
	return
}

# If currentHash and onlineHash are declared and equal, launch local ATOM & exit
if (($localHash -and $onlineHash) -and ($localHash -eq $onlineHash)) {
	Launch-ATOM
}

# Download latest ATOM to temp
Write-Host "Downloading ATOM..."

$atomUrl = "https://github.com/SkylerWallace/ATOM/archive/refs/heads/main.zip"
$atomDestination = Join-Path $tempPath "ATOM-main.zip"

try {
	Invoke-WebRequest -Uri $atomUrl -OutFile $atomDestination
} catch {
	Write-Host "`nUnable to download latest ATOM."
	Write-Host "Potential issue with ATOM download URL:"
	Write-Host $atomUrl
	Write-Host "`nProcess aborted.`n"
	return
}

Write-Host "ATOM downloaded!`n"

# Unzip ATOM
$atomUnzipped = Join-Path $tempPath "ATOM-main"
if (Test-Path $atomUnzipped) { Remove-Item $atomUnzipped -Recurse }
Expand-Archive -Path $atomDestination -DestinationPath $atomUnzipped

# Remove existing ATOM from temp if detected
$atomPath = Join-Path $tempPath "ATOM"
if (Test-Path $atomPath) {
	Get-Process | Where-Object { $_.ProcessName -in "powershell", "pwsh" } | Where-Object { $_.MainWindowTitle -like "ATOM*" } | Stop-Process -Force | Wait-Process
	Start-Sleep -Seconds 3
	Remove-Item $atomPath -Force -Recurse
}

# Copy files
$atomSubDir = Join-Path $atomUnzipped "ATOM-main"
Copy-Item -Path $atomSubDir -Destination $atomPath -Force -Recurse

# Cleanup
Remove-Item -Path $atomDestination -Force
Remove-Item -Path $atomUnzipped -Recurse

# Final launch
Launch-ATOM