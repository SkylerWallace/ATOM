function Test-AtomGitCheckout {
    <#
    .SYNOPSIS
        Compares tracked ATOM files with the checkout's current Git commit.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$RootPath
    )

    $git = (Get-Command git -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $commit = & $git -C $RootPath rev-parse --verify HEAD 2>&1
    if ($LASTEXITCODE -ne 0 -or $commit -notmatch '^[0-9a-f]{40}$') { throw 'Unable to read the checkout revision.' }
    $files = @(& $git -c core.quotepath=false -C $RootPath ls-tree -r --name-only $commit -- ATOM ATOM.bat 2>&1)
    if ($LASTEXITCODE -ne 0 -or !$files.Count) { throw 'Unable to read tracked ATOM files.' }
    $changes = @(& $git -c core.quotepath=false -C $RootPath diff --no-ext-diff --no-textconv --no-renames --name-only $commit -- ATOM ATOM.bat 2>&1)
    if ($LASTEXITCODE -ne 0) { throw 'Unable to compare tracked ATOM files.' }

    $missing = @($files | Where-Object { !(Test-Path -LiteralPath (Join-Path $RootPath $_) -PathType Leaf) })
    $modified = @($files | Where-Object { $_ -in $changes -and $_ -notin $missing })
    [PSCustomObject]@{
        CommitSha         = [String]$commit
        IsHealthy         = !$missing.Count -and !$modified.Count
        CheckedCount      = $files.Count
        VerifiedCount     = $files.Count - $missing.Count - $modified.Count
        MissingFiles      = $missing
        ModifiedFiles     = $modified
        UnverifiableFiles = @()
    }
}
