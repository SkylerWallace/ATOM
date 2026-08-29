function Get-AtomUpdateState {
    <#
    .SYNOPSIS
        Reads ATOM's locally managed update state, with legacy migration support.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$Path,
        [String]$LegacyHashPath,
        [String]$LegacyFileListPath
    )

    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        try {
            $state = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        } catch {
            throw "Unable to read ATOM update state '$Path': $($_.Exception.Message)"
        }

        if ($state.SchemaVersion -ne 1 -or $state.CommitSha -notmatch '^[0-9a-f]{40}$') {
            throw "ATOM update state '$Path' is invalid."
        }

        return $state
    }

    $legacyHash = if ($LegacyHashPath -and (Test-Path -LiteralPath $LegacyHashPath -PathType Leaf)) {
        (Get-Content -LiteralPath $LegacyHashPath -Raw).Trim()
    }
    if ($legacyHash -notmatch '^[0-9a-f]{40}$') { return }

    $legacyFiles = if ($LegacyFileListPath -and (Test-Path -LiteralPath $LegacyFileListPath -PathType Leaf)) {
        @(Get-Content -LiteralPath $LegacyFileListPath | Where-Object { $_ })
    } else {
        @()
    }

    [PSCustomObject]@{
        SchemaVersion = 1
        Channel       = $null
        CommitSha     = $legacyHash
        OwnedFiles    = $legacyFiles
        IsLegacy      = $true
    }
}
