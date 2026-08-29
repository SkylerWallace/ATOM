param (
    [ValidateSet('main', 'dev')]
    [String]$Branch = 'main'
)

Write-Host "Updating ATOM from the '$Branch' branch.`n"

$atomPath = Split-Path $PSScriptRoot
$atomParent = Split-Path $atomPath
$configPath = Join-Path $atomPath 'Config'
$dependenciesPath = Join-Path $atomPath 'Dependencies'
$updateStatePath = Join-Path $configPath 'UpdateState.json'

. (Join-Path $atomPath 'Functions\Get-AtomUpdateState.ps1')
. (Join-Path $atomPath 'Functions\Write-AtomUpdateState.ps1')

try {
    $installedState = Get-AtomUpdateState `
        -Path $updateStatePath `
        -LegacyHashPath (Join-Path $configPath 'hash.txt') `
        -LegacyFileListPath (Join-Path $configPath 'files.txt')
    if (!$installedState) { throw 'Unable to determine which files belong to the installed ATOM copy.' }
} catch {
    Write-Host "Unable to read ATOM's update state: $($_.Exception.Message)"
    Write-Host 'Aborting update process...'
    Start-Sleep -Seconds 5
    exit
}

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

    $protectedFiles = @(
        'ATOM/Config/PluginsUser.ps1'
        'ATOM/Config/PluginsParamsUser.ps1'
        'ATOM/Config/ProgramsParamsUser.ps1'
        'ATOM/Config/SettingsUser.ps1'
        'ATOM/Config/UpdateState.json'
    )
    $installRoot = [IO.Path]::GetFullPath($atomParent).TrimEnd('\') + '\'
    $ownedDirectories = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)

    # Delete only files owned by the previously installed ATOM version.
    foreach ($relativePath in @($installedState.OwnedFiles)) {
        $normalizedPath = ([String]$relativePath).Replace('\', '/').TrimStart('/')
        if (!$normalizedPath -or $normalizedPath -in $protectedFiles) { continue }

        $installedPath = [IO.Path]::GetFullPath((Join-Path $atomParent $normalizedPath))
        if (!$installedPath.StartsWith($installRoot, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Update state contains a path outside the ATOM installation: '$relativePath'."
        }
        $ownedDirectory = Split-Path $installedPath
        while ($ownedDirectory -and $ownedDirectory.StartsWith($installRoot, [StringComparison]::OrdinalIgnoreCase)) {
            [void]$ownedDirectories.Add($ownedDirectory)
            $ownedDirectory = Split-Path $ownedDirectory
        }
        if (Test-Path -LiteralPath $installedPath -PathType Leaf) {
            Remove-Item -LiteralPath $installedPath -Force -Confirm:$false
        }
    }
    $ownedDirectories | Sort-Object Length -Descending | ForEach-Object {
        if ((Test-Path -LiteralPath $_ -PathType Container) -and !(Get-ChildItem -LiteralPath $_ -Force)) {
            Remove-Item -LiteralPath $_ -Force -Confirm:$false
        }
    }

    $archiveCleanupPaths = @(
        (Join-Path $release.ReleasePath '.github')
        (Join-Path $release.ReleasePath '.gitignore')
        (Join-Path $release.ReleasePath 'LICENSE')
        (Join-Path $release.ReleasePath 'README.md')
        (Join-Path $release.ReleasePath 'ATOM/Config/PluginsParamsUser.ps1')
        (Join-Path $release.ReleasePath 'ATOM/Config/ProgramsParamsUser.ps1')
        (Join-Path $release.ReleasePath 'ATOM/Config/SavedTheme.ps1')
        (Join-Path $release.ReleasePath 'ATOM/Config/SettingsUser.ps1')
        (Join-Path $release.ReleasePath 'ATOM/Config/UpdateState.json')
    )
    $archiveCleanupPaths | Where-Object { Test-Path -LiteralPath $_ } | ForEach-Object {
        Remove-Item -LiteralPath $_ -Force -Recurse
    }

    $ownedFiles = @(Get-ChildItem -LiteralPath $release.ReleasePath -File -Recurse -Force | ForEach-Object {
        $_.FullName.Substring($release.ReleasePath.Length).TrimStart('\').Replace('\', '/')
    })
    Get-ChildItem -LiteralPath $release.ReleasePath -Force |
        Copy-Item -Destination $atomParent -Force -Recurse

    Write-AtomUpdateState -Path $updateStatePath -Channel $Branch -CommitSha $release.CommitSha -OwnedFiles $ownedFiles

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
