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
    $hashPath = Join-Path $tempPath "ATOM\ATOM\Config\hash.txt"
    if (Test-Path $hashPath) {
        $localHash = (Get-Content -Path $hashPath).TrimEnd()
    } else {
        Write-Host "Failed to get hash from the following path:"
        Write-Host $hashPath
        $failState = $true
    }
    
    # Get online hash
    $hashUrl = "https://raw.githubusercontent.com/SkylerWallace/ATOM/main/ATOM/Config/hash.txt"
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

try {
    . (Join-Path $PSScriptRoot 'Get-AtomRelease.ps1')
    $release = Get-AtomRelease -TemporaryPath $tempPath
} catch {
    Write-Host "`nUnable to download latest ATOM."
    Write-Host $_.Exception.Message
    Write-Host "`nProcess aborted.`n"
    return
}

Write-Host "ATOM downloaded!`n"

# Remove existing ATOM from temp if detected
$atomPath = Join-Path $tempPath "ATOM"
if (Test-Path $atomPath) {
    Get-Process | Where-Object { $_.ProcessName -in "powershell", "pwsh" } | Where-Object { $_.MainWindowTitle -like "ATOM*" } | Stop-Process -Force | Wait-Process
    Start-Sleep -Seconds 3
    Remove-Item $atomPath -Force -Recurse
}

# Copy files
Copy-Item -LiteralPath $release.ReleasePath -Destination $atomPath -Force -Recurse

# Cleanup
Remove-Item -LiteralPath $release.WorkspacePath -Recurse -Force

# Final launch
Launch-ATOM
