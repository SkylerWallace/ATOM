function Get-AtomUpdateContext {
    <#
    .SYNOPSIS
        Resolves the update branch and local revision for the current ATOM copy.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$StatePath,

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

    $packageRoot = Split-Path (Split-Path (Split-Path $StatePath))
    $isGitCheckout = Test-Path -LiteralPath (Join-Path $packageRoot '.git')
    if ($isGitCheckout) {
        return [PSCustomObject]@{
            Branch = $branch
            LocalHash = $null
            UpdateState = $null
            IsGitCheckout = $true
        }
    }
    $state = $null
    try { $state = Get-AtomUpdateState -Path $StatePath } catch { }
    if (!$state.Files.Count) { $state = $null }

    [PSCustomObject]@{
        IsGitCheckout = $false
        Branch        = $branch
        LocalHash     = $state.CommitSha
        UpdateState   = $state
    }
}
