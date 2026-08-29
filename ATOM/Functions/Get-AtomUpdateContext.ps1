function Get-AtomUpdateContext {
    <#
    .SYNOPSIS
        Resolves the update branch and local revision for the current ATOM copy.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$StatePath,
        [String]$LegacyHashPath,
        [String]$LegacyFileListPath,
        [ValidateSet('main', 'dev')]
        [String]$UpdateChannel = 'main'
    )

    if ($env:ATOM_UPDATE_BRANCH) {
        if ($env:ATOM_UPDATE_BRANCH -notin 'main', 'dev') {
            throw "ATOM_UPDATE_BRANCH must be 'main' or 'dev'."
        }
        $branch = $env:ATOM_UPDATE_BRANCH
    } else {
        $branch = $UpdateChannel
    }

    $state = Get-AtomUpdateState -Path $StatePath -LegacyHashPath $LegacyHashPath -LegacyFileListPath $LegacyFileListPath
    if (!$state) { throw "Unable to determine the local ATOM revision." }

    [PSCustomObject]@{
        Branch        = $branch
        LocalHash     = $state.CommitSha
        UpdateState   = $state
    }
}
