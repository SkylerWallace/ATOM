function Remove-DownloadRecord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Name,

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
