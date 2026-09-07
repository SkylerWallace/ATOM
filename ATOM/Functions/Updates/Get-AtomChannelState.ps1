function Get-AtomChannelState {
    <#
    .SYNOPSIS
        Resolves the latest completed package for an ATOM update channel.

    .DESCRIPTION
        Falls back to the branch tip while channels transition to published
        package metadata.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateSet('main', 'dev')]
        [String]$Channel
    )

    $metadataUri = if ($Channel -eq 'dev') {
        'https://github.com/SkylerWallace/ATOM/releases/download/dev-snapshot/ATOM-dev-channel.json'
    } else {
        'https://github.com/SkylerWallace/ATOM/releases/latest/download/ATOM-channel.json'
    }

    try {
        $state = Invoke-RestMethod -Uri $metadataUri -Headers @{ 'User-Agent' = 'ATOM' } -UseBasicParsing -ErrorAction Stop
        if (
            $state.SchemaVersion -ne 1 -or
            $state.Channel -ne $Channel -or
            $state.CommitSha -notmatch '^[0-9a-f]{40}$' -or
            $state.PackageSha256 -notmatch '^[0-9A-Fa-f]{64}$' -or
            !$state.PackageUri
        ) {
            throw 'Channel metadata is invalid.'
        }
        return $state
    } catch {
        $commit = Invoke-RestMethod -Uri "https://api.github.com/repos/SkylerWallace/ATOM/commits/$Channel" -Headers @{ 'User-Agent' = 'ATOM' } -UseBasicParsing -ErrorAction Stop
        [PSCustomObject]@{
            SchemaVersion  = 1
            Channel        = $Channel
            CommitSha      = [String]$commit.sha
            PackageUri     = $null
            PackageSha256  = $null
            IsBranchFallback = $true
        }
    }
}
