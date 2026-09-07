function Get-DownloadManifest {
    [CmdletBinding()]
    param (
        [String]$Path = (Join-Path $programsPath 'downloads.json')
    )

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
