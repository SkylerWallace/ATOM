function Write-DownloadManifest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.IDictionary]$Programs,

        [Int]$Schema = 1,

        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )


    $json = [ordered]@{ Schema = $Schema; Programs = $Programs } | ConvertTo-Json -Depth 6 -Compress
    Write-AtomFileAtomic -Path $Path -Content (Format-DownloadManifestJson -Json $json)
}
