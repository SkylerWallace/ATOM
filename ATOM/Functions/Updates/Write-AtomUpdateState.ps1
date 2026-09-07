function Write-AtomUpdateState {
    <#
    .SYNOPSIS
        Atomically writes ATOM's local revision and installed-file ownership state.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,

        [Parameter(Mandatory)]
        [ValidateSet('main', 'dev')]
        [String]$Channel,

        [AllowNull()]
        [ValidatePattern('^$|^[0-9a-f]{40}$')]
        [String]$CommitSha,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [Object[]]$Files
    )

    $state = [ordered]@{
        SchemaVersion = 2
        Channel       = $Channel
        CommitSha     = if ($CommitSha) { $CommitSha.ToLowerInvariant() } else { $null }
        Files         = @($Files | Where-Object { $_.Path } | Sort-Object Path -Unique | ForEach-Object {
            [ordered]@{
                Path   = ([String]$_.Path).Replace('\', '/')
                Sha256 = ([String]$_.Sha256).ToUpperInvariant()
            }
        })
    }

    foreach ($file in $state.Files) {
        if ($file.Sha256 -notmatch '^[0-9A-F]{64}$') { throw "Invalid manifest hash for '$($file.Path)'." }
    }

    # Format the small schema explicitly because Windows PowerShell 5.1 pads
    # ConvertTo-Json values into columns.
    $newLine = [Environment]::NewLine
    $fileLines = @($state.Files | ForEach-Object {
        '    ' + ($_ | ConvertTo-Json -Compress)
    }) -join ",$newLine"
    $channelJson = $state.Channel | ConvertTo-Json -Compress
    $commitShaJson = if ($state.CommitSha) { $state.CommitSha | ConvertTo-Json -Compress } else { 'null' }
    $json = @(
        '{'
        '  "SchemaVersion": 2,'
        "  `"Channel`": $channelJson,"
        "  `"CommitSha`": $commitShaJson,"
        '  "Files": ['
        $fileLines
        '  ]'
        '}'
    ) -join $newLine

    Write-AtomFileAtomic -Path $Path -Content $json
}
