function Resolve-GitHubDownload {
    <#
    .SYNOPSIS
    Resolves a named asset from the latest published GitHub release.

    .PARAMETER GitHub
    Repository in owner/repository form.

    .PARAMETER Asset
    Exact release asset filename. Missing or ambiguous assets cause an error.

    .OUTPUTS
    PSCustomObject containing the release tag, asset URL, and filename.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidatePattern('^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$')]
        [String]$GitHub,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Asset
    )

    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/$GitHub/releases/latest" `
        -Headers @{ 'User-Agent' = 'ATOM' } -TimeoutSec 20 -ErrorAction Stop
    if (!$release.tag_name) { throw "GitHub repository '$GitHub' did not return a release tag." }

    $assets = @($release.assets | Where-Object { $_.name -eq $Asset })
    if ($assets.Count -ne 1 -or !$assets[0].browser_download_url) {
        throw "GitHub release '$GitHub/$($release.tag_name)' must contain exactly one '$Asset' asset."
    }

    [PSCustomObject]@{
        Source        = 'GitHub'
        Scoop         = $null
        Version       = [String]$release.tag_name
        Uri           = [String]$assets[0].browser_download_url
        FileName      = [String]$assets[0].name
        HasRenameHint = $true
        Hash          = $null
    }
}
