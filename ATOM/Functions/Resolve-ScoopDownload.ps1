function Resolve-ScoopDownload {
    <#
    .SYNOPSIS
    Resolves current download metadata from a Scoop manifest.

    .DESCRIPTION
    Reads a manifest directly from a known Scoop bucket repository and returns
    the download URL, version, hash, filename hint, and extraction directory for
    the requested architecture. Manifests are cached for the current runspace.

    .PARAMETER Scoop
    Scoop manifest identifier in bucket/app form, such as extras/cpu-z.

    .PARAMETER Architecture
    Manifest architecture to resolve. Defaults to 64bit.

    .OUTPUTS
    PSCustomObject containing Scoop download metadata.
    #>

    [CmdletBinding()]

    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidatePattern('^[^/]+/[^/]+$')]
        [String]$Scoop,

        [ValidateSet('32bit', '64bit', 'arm64')]
        [String]$Architecture = '64bit'
    )

    $bucket, $app = $Scoop -split '/', 2
    $repositories = @{
        main         = 'ScoopInstaller/Main'
        extras       = 'ScoopInstaller/Extras'
        nonportable  = 'ScoopInstaller/Nonportable'
        nirsoft      = 'ScoopInstaller/Nirsoft'
        sysinternals = 'niheaven/scoop-sysinternals'
    }

    if (!$repositories.ContainsKey($bucket)) {
        throw "Scoop bucket '$bucket' is not supported."
    }

    if (!$script:scoopManifestCache) {
        $script:scoopManifestCache = @{}
    }

    $manifestUri = "https://raw.githubusercontent.com/$($repositories[$bucket])/master/bucket/$app.json"
    $cacheKey = $Scoop

    if (!$script:scoopManifestCache.ContainsKey($cacheKey)) {
        Write-Verbose "Resolving Scoop manifest '$Scoop'."
        $script:scoopManifestCache[$cacheKey] = Invoke-RestMethod -Uri $manifestUri -Headers @{ 'User-Agent' = 'ATOM' } -UseBasicParsing
    }

    $manifest = $script:scoopManifestCache[$cacheKey]
    $architectureInfo = $null

    if ($manifest.architecture) {
        $architectureProperty = $manifest.architecture.PSObject.Properties[$Architecture]
        if ($architectureProperty) { $architectureInfo = $architectureProperty.Value }
    }

    $urlData = if ($architectureInfo -and $architectureInfo.url) { $architectureInfo.url } else { $manifest.url }
    $hashData = if ($architectureInfo -and $architectureInfo.hash) { $architectureInfo.hash } else { $manifest.hash }
    $extractDir = if ($architectureInfo -and $architectureInfo.extract_dir) { $architectureInfo.extract_dir } else { $manifest.extract_dir }

    if (!$urlData) {
        throw "Scoop manifest '$Scoop' does not contain a download URL for $Architecture."
    }

    $urls = @($urlData)
    $hashes = @($hashData)

    for ($index = 0; $index -lt $urls.Count; $index++) {
        $urlParts = [String]$urls[$index] -split '#/', 2
        $downloadUri = $urlParts[0]
        $hasRenameHint = $urlParts.Count -eq 2
        $fileName = if ($hasRenameHint) {
            $urlParts[1]
        } else {
            [IO.Path]::GetFileName(([Uri]$downloadUri).AbsolutePath)
        }

        [PSCustomObject]@{
            Source       = 'Scoop'
            Scoop        = $Scoop
            Version      = [String]$manifest.version
            Uri          = $downloadUri
            FileName     = $fileName
            HasRenameHint = $hasRenameHint
            Hash         = if ($index -lt $hashes.Count) { $hashes[$index] } else { $null }
            ExtractDir   = $extractDir
            ManifestUri  = $manifestUri
        }
    }
}
