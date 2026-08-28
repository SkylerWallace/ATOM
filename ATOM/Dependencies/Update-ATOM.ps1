param (
    [ValidateSet('main', 'dev')]
    [String]$Branch = 'main'
)

Write-Host "Updating ATOM from the '$Branch' branch.`n"

$atomPath = Split-Path $PSScriptRoot
$configPath = Join-Path $atomPath 'Config'
$dependenciesPath = Join-Path $atomPath 'Dependencies'

# Stage and validate the replacement before changing the installed copy.
$internetConnected = (Get-NetConnectionProfile | Where-Object {
    $_.IPv4Connectivity -eq 'Internet' -or $_.IPv6Connectivity -eq 'Internet'
}) -ne $null

if (!$internetConnected) {
    Write-Host "`nNo internet connection detected."
    Write-Host 'Aborting update process...'
    Start-Sleep -Seconds 5
    exit
}

Write-Host 'Downloading ATOM...'
$ProgressPreference = 'SilentlyContinue'

try {
    . (Join-Path $PSScriptRoot 'Get-AtomRelease.ps1')
    $release = Get-AtomRelease -Branch $Branch
} catch {
    Write-Host "`nUnable to download and prepare the latest ATOM release."
    Write-Host $_.Exception.Message
    Write-Host 'Aborting update process...'
    Start-Sleep -Seconds 5
    exit
}

Write-Host "ATOM downloaded!`n"
Write-Host "Updating ATOM...`n"

try {
    # Terminate the current ATOM process tree only after staging succeeds.
    $powershellProcesses = Get-CimInstance -Class Win32_Process -Filter "Name = 'powershell.exe' OR Name = 'pwsh.exe'"
    $atomProcess = $powershellProcesses | Where-Object ProcessId -eq $PID | Select-Object -ExpandProperty ParentProcessId
    $powershellProcesses | Where-Object {
        $_.ParentProcessId -eq $atomProcess -or $_.ProcessId -eq $atomProcess
    } | ForEach-Object {
        if ($_.ProcessId -ne $PID) { Stop-Process -Id $_.ProcessId -Force }
    }

    $filesList = Get-Content (Join-Path $configPath 'files.txt') | ForEach-Object {
        $_ -replace 'ATOM/', "$atomPath\" -replace '/', '\'
    }
    $localFiles = Get-ChildItem -LiteralPath $atomPath -Recurse
    $excludedFiles = [System.Collections.ArrayList]@(
        Compare-Object -ReferenceObject $localFiles.FullName -DifferenceObject $filesList -PassThru |
            Where-Object SideIndicator -eq '<='
    )

    @(
        'PluginsUser.ps1'
        'PluginsParamsUser.ps1'
        'ProgramsParamsUser.ps1'
        'SettingsUser.ps1'
    ) | ForEach-Object {
        [void]$excludedFiles.Add((Join-Path $configPath $_))
    }

    # Remove tracked files while preserving user-created and user-configuration files.
    Get-ChildItem -LiteralPath $atomPath -Recurse -File |
        Where-Object FullName -notin $excludedFiles |
        Remove-Item -Force -Confirm:$false
    Get-ChildItem -LiteralPath $atomPath -Directory -Recurse |
        Sort-Object FullName -Descending |
        Where-Object { (Get-ChildItem -LiteralPath $_.FullName).Count -eq 0 } |
        Remove-Item -Force -Recurse -Confirm:$false

    $archiveCleanupPaths = @(
        (Join-Path $release.ReleasePath '.github')
        (Join-Path $release.ReleasePath '.gitignore')
        (Join-Path $release.ReleasePath 'LICENSE')
        (Join-Path $release.ReleasePath 'README.md')
        (Join-Path $release.ReleasePath 'ATOM/Config/PluginsParamsUser.ps1')
        (Join-Path $release.ReleasePath 'ATOM/Config/ProgramsParamsUser.ps1')
        (Join-Path $release.ReleasePath 'ATOM/Config/SavedTheme.ps1')
        (Join-Path $release.ReleasePath 'ATOM/Config/SettingsUser.ps1')
    )
    $archiveCleanupPaths | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object {
        Remove-Item -LiteralPath $_ -Force -Recurse
    }

    $atomParent = Split-Path $atomPath
    Get-ChildItem -LiteralPath $release.ReleasePath -Force |
        Copy-Item -Destination $atomParent -Force -Recurse

    # Convert legacy user settings when upgrading an older ATOM installation.
    $legacyFiles = @(
        (Join-Path $dependenciesPath 'Plugins-Hashtable (Custom).ps1')
        (Join-Path $dependenciesPath 'Programs-Hashtable (Custom).ps1')
        (Join-Path $configPath 'PluginsParamsUser.ps1')
        (Join-Path $configPath 'ProgramsParamsUser.ps1')
    )
    if ((Test-Path $legacyFiles) -contains $true) {
        $mergeScript = Join-Path $dependenciesPath 'Merge-PluginInfo.ps1'
        if (Test-Path -LiteralPath $mergeScript) { . $mergeScript }
    }
} catch {
    Write-Host "`nATOM could not be updated: $($_.Exception.Message)"
    Write-Host 'The staged release has been cleaned up.'
    Start-Sleep -Seconds 5
    exit
} finally {
    if ($release -and (Test-Path -LiteralPath $release.WorkspacePath)) {
        Remove-Item -LiteralPath $release.WorkspacePath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Restart ATOM.
$atomBatPath = Join-Path (Split-Path $atomPath) 'ATOM.bat'
Start-Process $atomBatPath
