function Sync-DownloadManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Programs,

        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

    if (!(Test-Path -LiteralPath $Path -PathType Leaf)) { return }

    $manifest = Get-DownloadManifest -Path $Path
    $records = [ordered]@{}
    $removed = @()
    foreach ($property in $manifest.Programs.PSObject.Properties) {
        $programInfo = $Programs[$property.Name].ProgramInfo
        $executablePath = if ($programInfo.DestinationPath -and $programInfo.RelativePath) {
            $configuredPath = Join-Path $programInfo.DestinationPath ([String]$programInfo.RelativePath).TrimStart('\', '/')
            @(Get-Item -Path $configuredPath -ErrorAction SilentlyContinue |
                Where-Object { !$_.PSIsContainer } |
                Sort-Object FullName -Descending |
                Select-Object -First 1).FullName
        }

        if (!$executablePath) {
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
