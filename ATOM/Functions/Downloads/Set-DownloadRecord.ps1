function Set-DownloadRecord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$ProgramInfo,

        [System.Collections.IDictionary]$ProgressState,

        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

    $configuredPath = Join-Path $ProgramInfo.DestinationPath $ProgramInfo.RelativePath.TrimStart('\', '/')
    $executablePath = @(Get-Item -Path $configuredPath -ErrorAction SilentlyContinue |
        Where-Object { !$_.PSIsContainer } |
        Sort-Object FullName -Descending |
        Select-Object -First 1).FullName
    if (!$executablePath) {
        throw "Downloaded program was not found at '$configuredPath'."
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
        DownloadBytes  = if ($null -ne $ProgressState.TotalBytes) { [long]$ProgressState.TotalBytes } else { $null }
        ExecutableHash = (Get-FileHash -LiteralPath $executablePath -Algorithm SHA256).Hash
        RelativePath   = [String]$ProgramInfo.RelativePath
        Scoop          = if ($ProgramInfo.Scoop) { [String]$ProgramInfo.Scoop } else { $null }
    }

    Write-DownloadManifest -Programs $records -Schema 1 -Path $Path

    $records[$Name]
}
