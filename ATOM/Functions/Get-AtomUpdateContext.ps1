function Get-AtomUpdateContext {
    <#
    .SYNOPSIS
        Resolves the update branch and local revision for the current ATOM copy.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$RepositoryPath,
        [Parameter(Mandatory)][String]$HashPath
    )

    $branch = 'main'
    $gitBranch = $null
    $gitHash = $null
    $git = Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($git) {
        $branchOutput = @(& $git.Source -C $RepositoryPath branch --show-current 2>$null)
        $branchSucceeded = $LASTEXITCODE -eq 0
        if ($branchSucceeded -and $branchOutput.Count -gt 0) {
            $gitBranch = ([String]$branchOutput[0]).Trim()
            $hashOutput = @(& $git.Source -C $RepositoryPath rev-parse HEAD 2>$null)
            $hashSucceeded = $LASTEXITCODE -eq 0
            if ($hashSucceeded -and $hashOutput.Count -gt 0) {
                $gitHash = ([String]$hashOutput[0]).Trim()
            }
        }
    }

    if ($env:ATOM_UPDATE_BRANCH) {
        if ($env:ATOM_UPDATE_BRANCH -notin 'main', 'dev') {
            throw "ATOM_UPDATE_BRANCH must be 'main' or 'dev'."
        }
        $branch = $env:ATOM_UPDATE_BRANCH
    } elseif ($gitBranch -in 'main', 'dev') {
        $branch = $gitBranch
    }

    $isMatchingGitCheckout = $gitHash -and $gitBranch -eq $branch
    $localHash = if ($isMatchingGitCheckout) {
        $gitHash
    } elseif (Test-Path -LiteralPath $HashPath -PathType Leaf) {
        (Get-Content -LiteralPath $HashPath -Raw).Trim()
    }

    if (!$localHash) { throw "Unable to determine the local ATOM revision." }

    [PSCustomObject]@{
        Branch        = $branch
        LocalHash     = $localHash
        IsGitCheckout = [Boolean]$isMatchingGitCheckout
    }
}
