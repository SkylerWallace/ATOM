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
. (Join-Path (Split-Path $PSScriptRoot) 'Functions\Get-AtomChannelState.ps1')

# Check if ATOM is already downloaded to temp
$atomDetected = Test-Path $atomBat

# Get revisions for the installed and latest ATOM copies.
if (!$internetConnected) {
    Write-Host "`nNo internet connection detected."
    $failState = $true
} elseif ($atomDetected -and $internetConnected) {
    # Get the revision recorded by the local installation.
    $localAtomPath = Join-Path $tempPath 'ATOM\ATOM'
    $stateFunctionPath = Join-Path $localAtomPath 'Functions\Get-AtomUpdateState.ps1'
    if (Test-Path -LiteralPath $stateFunctionPath) {
        try {
            . $stateFunctionPath
            $localHash = (Get-AtomUpdateState -Path (Join-Path $localAtomPath 'Config\UpdateState.json')).CommitSha
        } catch {
            $localHash = $null
        }
    }
    
    # Resolve the current main-branch revision directly from GitHub.
    try {
        $channelState = Get-AtomChannelState -Channel main
        $onlineHash = $channelState.CommitSha
    } catch {
        Write-Host 'Failed to determine the latest ATOM revision from GitHub.'
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
    $releaseParameters = @{
        Branch        = 'main'
        CommitSha     = $onlineHash
        TemporaryPath = $tempPath
    }
    if ($channelState.PackageUri) {
        $releaseParameters.Uri = $channelState.PackageUri
        $releaseParameters.PackageSha256 = $channelState.PackageSha256
    }
    $release = Get-AtomRelease @releaseParameters
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

$installedAtomPath = Join-Path $atomPath 'ATOM'
. (Join-Path $installedAtomPath 'Functions\Get-AtomFileHash.ps1')
. (Join-Path $installedAtomPath 'Functions\New-AtomFileManifest.ps1')
. (Join-Path $installedAtomPath 'Functions\Write-AtomUpdateState.ps1')
$files = New-AtomFileManifest -RootPath $atomPath -Exclude 'ATOM/Config/UpdateState.json'
Write-AtomUpdateState `
    -Path (Join-Path $installedAtomPath 'Config\UpdateState.json') `
    -Channel main `
    -CommitSha $release.CommitSha `
    -Files $files

# Cleanup
Remove-Item -LiteralPath $release.WorkspacePath -Recurse -Force

# Final launch
Launch-ATOM
