function Format-DownloadManifestJson {
    param ([Parameter(Mandatory)][String]$Json)

    # Windows PowerShell unnecessarily HTML-escapes these JSON-safe characters.
    $Json = $Json.Replace('\u0026', '&').Replace('\u0027', "'").Replace('\u003c', '<').Replace('\u003e', '>')

    $output = [Text.StringBuilder]::new()
    $indent = 0
    $inString = $false
    $escaped = $false

    foreach ($character in $Json.ToCharArray()) {
        if ($inString) {
            [void]$output.Append($character)
            if ($escaped) { $escaped = $false }
            elseif ($character -eq '\') { $escaped = $true }
            elseif ($character -eq '"') { $inString = $false }
            continue
        }

        switch ($character) {
            '"' {
                $inString = $true
                [void]$output.Append($character)
            }
            { $_ -eq '{' -or $_ -eq '[' } {
                [void]$output.Append($character).AppendLine()
                $indent++
                [void]$output.Append(' ' * ($indent * 2))
            }
            { $_ -eq '}' -or $_ -eq ']' } {
                $indent--
                [void]$output.AppendLine().Append(' ' * ($indent * 2)).Append($character)
            }
            ',' {
                [void]$output.Append($character).AppendLine().Append(' ' * ($indent * 2))
            }
            ':' {
                [void]$output.Append(': ')
            }
            default {
                if (![Char]::IsWhiteSpace($character)) { [void]$output.Append($character) }
            }
        }
    }

    $output.ToString()
}

function Get-DownloadManifest {
    [CmdletBinding()]
    param ([String]$Path = (Join-Path $programsPath 'downloads.json'))

    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) {
        return [PSCustomObject]@{ Schema = 1; Programs = [PSCustomObject]@{} }
    }

    try {
        $manifest = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
    } catch {
        throw "Unable to read download manifest '$Path': $($_.Exception.Message)"
    }

    if (!$manifest.Programs) { $manifest | Add-Member NoteProperty Programs ([PSCustomObject]@{}) -Force }
    $manifest
}

function Write-DownloadManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][System.Collections.IDictionary]$Programs,
        [Int]$Schema = 1,
        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

    if (!(Get-Command Write-AtomFileAtomic -CommandType Function -ErrorAction SilentlyContinue)) {
        . (Join-Path $PSScriptRoot 'Write-AtomFileAtomic.ps1')
    }

    $json = [ordered]@{ Schema = $Schema; Programs = $Programs } | ConvertTo-Json -Depth 6 -Compress
    Write-AtomFileAtomic -Path $Path -Content (Format-DownloadManifestJson -Json $json)
}

function Set-DownloadRecord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory)][System.Collections.IDictionary]$ProgramInfo,
        [System.Collections.IDictionary]$ProgressState,
        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

    $executablePath = Join-Path $ProgramInfo.DestinationPath $ProgramInfo.RelativePath
    if (!(Test-Path -LiteralPath $executablePath -PathType Leaf)) {
        throw "Downloaded program was not found at '$executablePath'."
    }

    $executable = Get-Item -LiteralPath $executablePath
    $detectedVersion = $executable.VersionInfo.ProductVersion
    if (!$detectedVersion) { $detectedVersion = $executable.VersionInfo.FileVersion }

    $manifest = Get-DownloadManifest -Path $Path
    $records = [ordered]@{}
    foreach ($property in $manifest.Programs.PSObject.Properties) { $records[$property.Name] = $property.Value }

    $records[$Name] = [ordered]@{
        Version        = if ($ProgressState.Version) { [String]$ProgressState.Version } elseif ($detectedVersion) { [String]$detectedVersion } else { $null }
        Url            = if ($ProgressState.ResolvedUri) { [String]$ProgressState.ResolvedUri } elseif ($ProgressState.Uri) { [String]$ProgressState.Uri } else { [String]$ProgramInfo.Uri }
        Downloaded     = [DateTime]::UtcNow.ToString('o')
        Source         = if ($ProgressState.Source) { [String]$ProgressState.Source } elseif ($ProgramInfo.Scoop) { 'Scoop' } else { 'Configured' }
        DownloadHash   = if ($ProgressState.DownloadHash) { [String]$ProgressState.DownloadHash } else { $null }
        ExecutableHash = (Get-FileHash -LiteralPath $executablePath -Algorithm SHA256).Hash
        RelativePath   = [String]$ProgramInfo.RelativePath
        Scoop          = if ($ProgramInfo.Scoop) { [String]$ProgramInfo.Scoop } else { $null }
    }

    Write-DownloadManifest -Programs $records -Schema 1 -Path $Path

    $records[$Name]
}

function Remove-DownloadRecord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$Name,
        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

    $manifest = Get-DownloadManifest -Path $Path
    $records = [ordered]@{}
    $removed = $false
    foreach ($property in $manifest.Programs.PSObject.Properties) {
        if ($property.Name -eq $Name) {
            $removed = $true
        } else {
            $records[$property.Name] = $property.Value
        }
    }

    if (!$removed) { return $false }
    $schema = if ($manifest.Schema) { [Int]$manifest.Schema } else { 1 }
    Write-DownloadManifest -Programs $records -Schema $schema -Path $Path
    return $true
}

function Sync-DownloadManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][System.Collections.IDictionary]$Programs,
        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return }

    $manifest = Get-DownloadManifest -Path $Path
    $records = [ordered]@{}
    $removed = @()
    foreach ($property in $manifest.Programs.PSObject.Properties) {
        $programInfo = $Programs[$property.Name].ProgramInfo
        $executablePath = if ($programInfo.DestinationPath -and $programInfo.RelativePath) {
            Join-Path $programInfo.DestinationPath ([String]$programInfo.RelativePath).TrimStart('\', '/')
        }

        if (!$executablePath -or !(Test-Path -LiteralPath $executablePath -PathType Leaf)) {
            $removed += $property.Name
        } else {
            $records[$property.Name] = $property.Value
        }
    }

    if ($removed.Count) {
        $schema = if ($manifest.Schema) { [Int]$manifest.Schema } else { 1 }
        Write-DownloadManifest -Programs $records -Schema $schema -Path $Path
    }
    return $removed
}

function Get-ProgramUpdates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][System.Collections.IDictionary]$Programs,
        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

    if (!(Get-Command Resolve-ScoopDownload -CommandType Function -ErrorAction SilentlyContinue)) {
        . (Join-Path $PSScriptRoot 'Resolve-ScoopDownload.ps1')
    }

    $manifest = Get-DownloadManifest -Path $Path

    foreach ($name in $Programs.Keys) {
        $programInfo = $Programs[$name].ProgramInfo
        if (!$programInfo) { continue }

        $executablePath = Join-Path $programInfo.DestinationPath $programInfo.RelativePath
        if (!(Test-Path -LiteralPath $executablePath -PathType Leaf)) { continue }

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
        }

        $versionChanged = $latestVersion -and (!$record -or !$record.Version -or $latestVersion -ne [String]$record.Version)
        if ($hashChanged -or $versionChanged) {
            [PSCustomObject]@{
                Name          = $name
                Version       = if ($record) { $record.Version } else { $null }
                LatestVersion = $latestVersion
                Reason        = if ($hashChanged) { 'ExecutableHash' } else { 'Version' }
            }
        }
    }
}
