function Get-AtomRelease {
    <#
    .SYNOPSIS
        Downloads and extracts an ATOM release into a unique staging directory.
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('main', 'dev')]
        [String]$Branch = 'main',
        [ValidatePattern('^[0-9a-f]{40}$')]
        [String]$CommitSha,
        [String]$Uri,
        [String]$TemporaryPath = [IO.Path]::GetTempPath()
    )

    if (!$Uri) {
        if (!$CommitSha) {
            $headers = @{ 'User-Agent' = 'ATOM' }
            $commit = Invoke-RestMethod -Uri "https://api.github.com/repos/SkylerWallace/ATOM/commits/$Branch" -Headers $headers -UseBasicParsing -ErrorAction Stop
            $CommitSha = [String]$commit.sha
        }
        if ($CommitSha -notmatch '^[0-9a-f]{40}$') { throw "GitHub returned an invalid ATOM commit SHA." }
        $Uri = "https://github.com/SkylerWallace/ATOM/archive/$CommitSha.zip"
    }

    $workspacePath = Join-Path $TemporaryPath "ATOM-release-$([Guid]::NewGuid().ToString('N'))"
    $archivePath = Join-Path $workspacePath 'ATOM.zip'
    $extractionPath = Join-Path $workspacePath 'Extracted'

    try {
        New-Item -Path $workspacePath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Invoke-WebRequest -Uri $Uri -OutFile $archivePath -UseBasicParsing -ErrorAction Stop
        Expand-Archive -LiteralPath $archivePath -DestinationPath $extractionPath -Force -ErrorAction Stop

        $releasePath = Get-ChildItem -LiteralPath $extractionPath -Directory | Select-Object -First 1 -ExpandProperty FullName
        $entryPoint = Join-Path $releasePath 'ATOM\ATOM.ps1'
        if (!(Test-Path -LiteralPath $entryPoint -PathType Leaf)) {
            throw "The release archive does not contain the expected ATOM entry point: '$entryPoint'."
        }

        [PSCustomObject]@{
            WorkspacePath = $workspacePath
            ArchivePath   = $archivePath
            ReleasePath   = $releasePath
            CommitSha     = $CommitSha
        }
    } catch {
        if (Test-Path -LiteralPath $workspacePath) {
            Remove-Item -LiteralPath $workspacePath -Recurse -Force -ErrorAction SilentlyContinue
        }
        throw
    }
}
