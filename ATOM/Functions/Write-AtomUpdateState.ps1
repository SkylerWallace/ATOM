function Write-AtomUpdateState {
    <#
    .SYNOPSIS
        Atomically writes ATOM's local revision and installed-file ownership state.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$Path,
        [Parameter(Mandatory)][ValidateSet('main', 'dev')][String]$Channel,
        [Parameter(Mandatory)][ValidatePattern('^[0-9a-f]{40}$')][String]$CommitSha,
        [Parameter(Mandatory)][AllowEmptyCollection()][String[]]$OwnedFiles
    )

    $state = [ordered]@{
        SchemaVersion = 1
        Channel       = $Channel
        CommitSha     = $CommitSha.ToLowerInvariant()
        OwnedFiles    = @($OwnedFiles | Where-Object { $_ } | Sort-Object -Unique)
    }
    # Windows PowerShell 5.1 pads ConvertTo-Json values into columns. Format the
    # small, fixed schema explicitly while retaining JSON-safe string escaping.
    $newLine = [Environment]::NewLine
    $ownedFileLines = @($state.OwnedFiles | ForEach-Object {
        '    ' + ($_ | ConvertTo-Json -Compress)
    }) -join ",$newLine"
    $channelJson = $state.Channel | ConvertTo-Json -Compress
    $commitShaJson = $state.CommitSha | ConvertTo-Json -Compress
    $json = @(
        '{'
        '  "SchemaVersion": 1,'
        "  `"Channel`": $channelJson,"
        "  `"CommitSha`": $commitShaJson,"
        '  "OwnedFiles": ['
        $ownedFileLines
        '  ]'
        '}'
    ) -join $newLine

    if (Get-Command Write-AtomFileAtomic -ErrorAction SilentlyContinue) {
        Write-AtomFileAtomic -Path $Path -Content $json
    } else {
        $directory = Split-Path $Path
        if (!(Test-Path -LiteralPath $directory -PathType Container)) {
            New-Item -Path $directory -ItemType Directory -Force -ErrorAction Stop | Out-Null
        }
        $temporaryPath = Join-Path $directory ".$([IO.Path]::GetFileName($Path)).$([Guid]::NewGuid().ToString('N')).tmp"
        try {
            [IO.File]::WriteAllText($temporaryPath, $json, [Text.UTF8Encoding]::new($false))
            Move-Item -LiteralPath $temporaryPath -Destination $Path -Force -ErrorAction Stop
        } finally {
            if (Test-Path -LiteralPath $temporaryPath) {
                Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
