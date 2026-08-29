function Get-AtomUpdateContext {
    <#
    .SYNOPSIS
        Resolves the update branch and local revision for the current ATOM copy.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$HashPath,
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

    $localHash = if (Test-Path -LiteralPath $HashPath -PathType Leaf) {
        (Get-Content -LiteralPath $HashPath -Raw).Trim()
    }

    if (!$localHash) { throw "Unable to determine the local ATOM revision." }

    [PSCustomObject]@{
        Branch        = $branch
        LocalHash     = $localHash
    }
}
