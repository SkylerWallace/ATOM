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
. (Join-Path $atomPath 'Functions\Get-AtomChannelState.ps1')
. (Join-Path $atomPath 'Functions\Get-AtomFileHash.ps1')
. (Join-Path $atomPath 'Functions\New-AtomFileManifest.ps1')
. (Join-Path $atomPath 'Functions\Test-AtomFileManifest.ps1')
. (Join-Path $atomPath 'Functions\Write-AtomUpdateState.ps1')

try {
    $installedState = Get-AtomUpdateState -Path $updateStatePath
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
    $channelState = Get-AtomChannelState -Channel $Branch
    $releaseParameters = @{
        Branch    = $Branch
        CommitSha = $channelState.CommitSha
    }
    if ($channelState.PackageUri) {
        $releaseParameters.Uri = $channelState.PackageUri
        $releaseParameters.PackageSha256 = $channelState.PackageSha256
    }
    $release = Get-AtomRelease @releaseParameters

    $releaseStatePath = Join-Path $release.ReleasePath 'ATOM\Config\UpdateState.json'
    if (Test-Path -LiteralPath $releaseStatePath -PathType Leaf) {
        $releaseState = Get-AtomUpdateState -Path $releaseStatePath
        if ($releaseState.CommitSha -ne $release.CommitSha) { throw 'The package manifest identifies a different commit.' }
        $releaseIntegrity = Test-AtomFileManifest -RootPath $release.ReleasePath -Files $releaseState.Files
        if (!$releaseIntegrity.IsHealthy) { throw 'The downloaded ATOM package failed file validation.' }
        $releaseFiles = @($releaseState.Files)
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
    $files = if ($releaseFiles) {
        $releaseFiles
    } else {
        New-AtomFileManifest -RootPath $release.ReleasePath -Exclude 'ATOM/Config/UpdateState.json'
    }
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
    $oldOwnedFiles = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    $newOwnedFiles = [Collections.Generic.HashSet[String]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($path in @($installedState.Files.Path)) { [void]$oldOwnedFiles.Add(([String]$path).Replace('\', '/').TrimStart('/')) }
    foreach ($file in @($files)) { [void]$newOwnedFiles.Add(([String]$file.Path).Replace('\', '/').TrimStart('/')) }
    $isManagedInstall = [Boolean]$installedState.CommitSha

    # Preserve every existing file that the update may remove or replace. This
    # also protects a user file that collides with a newly introduced ATOM path.
    $backupRoot = Join-Path $atomPath "Backups\Updates\$(Get-Date -Format 'yyyy-MM-dd_HHmmss')"
    $backupCandidates = [Collections.Generic.HashSet[String]]::new($newOwnedFiles, [StringComparer]::OrdinalIgnoreCase)
    if ($isManagedInstall) { $backupCandidates.UnionWith($oldOwnedFiles) }
    $rollbackRemovePaths = [Collections.Generic.List[String]]::new()
    $collisionPaths = [Collections.Generic.List[String]]::new()
    $collisionDirectories = [Collections.Generic.List[String]]::new()
    foreach ($relativePath in $backupCandidates) {
        if (!$relativePath -or $relativePath -in $protectedFiles) { continue }
        $installedPath = [IO.Path]::GetFullPath((Join-Path $atomParent $relativePath))
        if (!$installedPath.StartsWith($installRoot, [StringComparison]::OrdinalIgnoreCase)) {
            throw "Update manifest contains a path outside the ATOM installation: '$relativePath'."
        }

        if (Test-Path -LiteralPath $installedPath -PathType Leaf) {
            $backupPath = Join-Path $backupRoot $relativePath
            New-Item -Path (Split-Path $backupPath) -ItemType Directory -Force | Out-Null
            Copy-Item -LiteralPath $installedPath -Destination $backupPath -Force
            if ($newOwnedFiles.Contains($relativePath) -and !$oldOwnedFiles.Contains($relativePath)) {
                $collisionPaths.Add($relativePath)
            }
        } elseif (Test-Path -LiteralPath $installedPath -PathType Container) {
            $backupPath = Join-Path $backupRoot $relativePath
            New-Item -Path (Split-Path $backupPath) -ItemType Directory -Force | Out-Null
            Copy-Item -LiteralPath $installedPath -Destination (Split-Path $backupPath) -Force -Recurse
            $collisionPaths.Add($relativePath)
            $collisionDirectories.Add($installedPath)
        } elseif ($newOwnedFiles.Contains($relativePath)) {
            $rollbackRemovePaths.Add($relativePath)
        }
    }
    if ($collisionPaths.Count) {
        $collisionPaths | Set-Content -LiteralPath (Join-Path $backupRoot 'UserFileCollisions.txt')
    }
    $updateMutationStarted = $true
    foreach ($directoryPath in $collisionDirectories) {
        Remove-Item -LiteralPath $directoryPath -Recurse -Force
    }

    # Delete only files owned by the previously installed ATOM version.
    foreach ($relativePath in @($installedState.Files.Path)) {
        $normalizedPath = ([String]$relativePath).Replace('\', '/').TrimStart('/')
        if (!$normalizedPath -or $normalizedPath -in $protectedFiles) { continue }
        if (!$isManagedInstall -and !$newOwnedFiles.Contains($normalizedPath)) { continue }

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

    Get-ChildItem -LiteralPath $release.ReleasePath -Force |
        Copy-Item -Destination $atomParent -Force -Recurse

    $installedIntegrity = Test-AtomFileManifest -RootPath $atomParent -Files $files
    if (!$installedIntegrity.IsHealthy) { throw 'The updated ATOM installation failed file validation.' }

    Write-AtomUpdateState -Path $updateStatePath -Channel $Branch -CommitSha $release.CommitSha -Files $files
    if (Test-Path -LiteralPath $backupRoot -PathType Container) {
        Write-Host "Previous ATOM files were backed up to '$backupRoot'."
    }
    if ($collisionPaths.Count) {
        Write-Host "$($collisionPaths.Count) user file collision(s) were preserved in the update backup."
    }

} catch {
    Write-Host "`nATOM could not be updated: $($_.Exception.Message)"
    if ($updateMutationStarted) {
        Write-Host 'Restoring the previous ATOM files...'
        foreach ($relativePath in $rollbackRemovePaths) {
            $installedPath = [IO.Path]::GetFullPath((Join-Path $atomParent $relativePath))
            if ($installedPath.StartsWith($installRoot, [StringComparison]::OrdinalIgnoreCase) -and (Test-Path -LiteralPath $installedPath -PathType Leaf)) {
                Remove-Item -LiteralPath $installedPath -Force -ErrorAction SilentlyContinue
            }
        }
        if (Test-Path -LiteralPath $backupRoot -PathType Container) {
            Get-ChildItem -LiteralPath $backupRoot -Force | Where-Object Name -ne 'UserFileCollisions.txt' |
                Copy-Item -Destination $atomParent -Force -Recurse
            Write-Host "The previous files were restored from '$backupRoot'."
        }
    }
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
