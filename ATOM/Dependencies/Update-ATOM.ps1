Write-Host "Updating ATOM.`n"

# Terminate ATOM scripts
$powershellProcesses = Get-CimInstance -Class Win32_Process -Filter "Name = 'powershell.exe'"
$atomProcess = $powershellProcesses | Where { $_.ProcessId -eq $pid } | Select -Expand ParentProcessId
$powerShellProcesses | Where { $_.ParentProcessId -eq $atomProcess -or $_.ProcessId -eq $atomProcess } | ForEach {
    if ($_.ProcessId -eq $pid) { return }
    Stop-Process -Id $_.ProcessId -Force
}

$atomPath = $psScriptRoot | Split-Path
$configPath = "$atomPath\Config"
$filesList = Get-Content "$configPath\files.txt" | ForEach-Object { $_ -replace "ATOM/", "$atomPath\" -replace "/", "\" }

# Get all files in the Plugins and Icons directories
$localFiles = Get-ChildItem $atomPath -Recurse

# Compare to find files in the directories but not in the list
$excludedFiles = New-Object System.Collections.ArrayList(,(Compare-Object -ReferenceObject $localFiles.FullName -DifferenceObject $filesList -PassThru | Where-Object { $_.SideIndicator -eq "<=" }))
$excludedFiles.Add("$configPath\PluginsParamsUser.ps1") | Out-Null
$excludedFiles.Add("$configPath\ProgramsParamsUser.ps1") | Out-Null
$excludedFiles.Add("$configPath\SettingsUser.ps1") | Out-Null

# Delete files and empty directories
Get-ChildItem -Path $atomPath -Recurse -File | Where-Object { $_.FullName -notin $excludedFiles } | Remove-Item -Force -Confirm:$false
Get-ChildItem -Path $atomPath -Directory -Recurse | Sort-Object FullName -Descending | Where-Object { (Get-ChildItem -Path $_.FullName).Count -eq 0 } | Remove-Item -Force -Recurse -Confirm:$false

# If internet connected, download latest ATOM to temp
$internetConnected = (Get-NetConnectionProfile | Where-Object { $_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet' }) -ne $null
if (!$internetConnected) {
    Write-Host "`nNo internet connection detected."
    Write-Host "Aborting update process..."
    Start-Sleep -Seconds 5
    exit
}

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
Write-Host "Updating ATOM...`n"

# Unzip ATOM
$atomUnzipped = Join-Path $env:TEMP "ATOM-main"
if (Test-Path $atomUnzipped) { Remove-Item $atomUnzipped -Recurse }
Expand-Archive -Path $atomDestination -DestinationPath $atomUnzipped

# Clean files
$atomSubDir = Join-Path $atomUnzipped "ATOM-main"
Remove-Item -Path "$atomSubDir\.github" -Force -Recurse
Remove-Item -Path "$atomSubDir\.gitignore" -Force
Remove-Item -Path "$atomSubDir\LICENSE" -Force
Remove-Item -Path "$atomSubDir\README.md" -Force
Remove-Item -Path "$atomSubDir\ATOM\Config\PluginsParamsUser.ps1" -Force
Remove-Item -Path "$atomSubDir\ATOM\Config\ProgramsParamsUser.ps1" -Force
Remove-Item -Path "$atomSubDir\ATOM\Config\SavedTheme.ps1" -Force
Remove-Item -Path "$atomSubDir\ATOM\Config\SettingsUser.ps1" -Force

# Copy files
$atomParent = $atomPath | Split-Path
Copy-Item -Path "$atomSubDir\*" -Destination $atomParent -Force -Recurse

# Convert legacy user settings
$legacyFiles = @{
    "$atomPath\Dependencies\Plugins-Hashtable (Custom).ps1" = "$configPath\PluginsParamsUser.ps1"
    "$atomPath\Dependencies\Programs-Hashtable (Custom).ps1" = "$configPath\ProgramsParamsUser.ps1"
}

$legacyFiles.Keys | ForEach {
    if (Test-Path $_) {
        Move-Item $_ $legacyFiles.$_ -Force
    }
}

# Cleanup
Remove-Item -Path $atomDestination -Force
Remove-Item -Path $atomUnzipped -Recurse

# Restart ATOM
$atomBatDir = Join-Path ($atomPath | Split-Path) "ATOM.bat"
Start-Process $atomBatDir