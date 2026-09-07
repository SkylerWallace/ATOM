function Get-ProgramUpdates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Programs,

        [String]$Path = (Join-Path $programsPath 'downloads.json'),

        [Switch]$IncludeCurrent
    )


    $manifest = Get-DownloadManifest -Path $Path

    foreach ($name in $Programs.Keys) {
        $programInfo = $Programs[$name].ProgramInfo
        if (!$programInfo) { continue }

        $configuredPath = Join-Path $programInfo.DestinationPath ([String]$programInfo.RelativePath).TrimStart('\', '/')
        $executablePath = @(Get-Item -Path $configuredPath -ErrorAction SilentlyContinue |
            Where-Object { !$_.PSIsContainer } |
            Sort-Object FullName -Descending |
            Select-Object -First 1).FullName
        if (!$executablePath) { continue }

        $recordProperty = $manifest.Programs.PSObject.Properties[$name]
        $record = if ($recordProperty) { $recordProperty.Value } else { $null }
        $hashChanged = $false

        if ($record -and $record.ExecutableHash) {
            $currentHash = (Get-FileHash -LiteralPath $executablePath -Algorithm SHA256).Hash
            $hashChanged = ![String]::Equals($currentHash, [String]$record.ExecutableHash, [StringComparison]::OrdinalIgnoreCase)
        }

        $latestVersion = $null
        if ($programInfo.Scoop) {
            try {
                $downloads = @(Resolve-ScoopDownload -Scoop $programInfo.Scoop)
                if ($downloads.Count -ne 1) {
                    throw "Scoop returned $($downloads.Count) downloads; custom update handling is required."
                }
                $latestVersion = [String]$downloads[0].Version
            } catch {
                throw "Unable to check '$name' for updates: $($_.Exception.Message)"
            }
        } elseif ($programInfo.VersionScriptBlock) {
            try {
                $latestVersion = [String](& $programInfo.VersionScriptBlock)
            } catch {
                throw "Unable to check '$name' for updates: $($_.Exception.Message)"
            }
        }

        $versionChanged = $latestVersion -and (!$record -or !$record.Version -or $latestVersion -ne [String]$record.Version)
        if ($IncludeCurrent -or $hashChanged -or $versionChanged) {
            [PSCustomObject]@{
                Name          = $name
                Version       = if ($record) { $record.Version } else { $null }
                LatestVersion = $latestVersion
                Reason        = if ($hashChanged) { 'ExecutableHash' } elseif ($versionChanged) { 'Version' } else { $null }
                UpdateAvailable = [bool]($hashChanged -or $versionChanged)
            }
        }
    }
}
