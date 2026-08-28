function Get-AtomRelease {
    <#
    .SYNOPSIS
        Downloads and extracts an ATOM release into a unique staging directory.
    #>
    [CmdletBinding()]
    param (
        [ValidateSet('main', 'dev')]
        [String]$Branch = 'main',
        [String]$Uri,
        [String]$TemporaryPath = [IO.Path]::GetTempPath()
    )

    if (!$Uri) {
        $Uri = "https://github.com/SkylerWallace/ATOM/archive/refs/heads/$Branch.zip"
    }

    $workspacePath = Join-Path $TemporaryPath "ATOM-release-$([Guid]::NewGuid().ToString('N'))"
    $archivePath = Join-Path $workspacePath 'ATOM.zip'
    $extractionPath = Join-Path $workspacePath 'Extracted'

    try {
        New-Item -Path $workspacePath -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Invoke-WebRequest -Uri $Uri -OutFile $archivePath -UseBasicParsing -ErrorAction Stop
        Expand-Archive -LiteralPath $archivePath -DestinationPath $extractionPath -Force -ErrorAction Stop

        $releasePath = Join-Path $extractionPath "ATOM-$Branch"
        $entryPoint = Join-Path $releasePath 'ATOM\ATOM.ps1'
        if (!(Test-Path -LiteralPath $entryPoint -PathType Leaf)) {
            throw "The release archive does not contain the expected ATOM entry point: '$entryPoint'."
        }

        [PSCustomObject]@{
            WorkspacePath = $workspacePath
            ArchivePath   = $archivePath
            ReleasePath   = $releasePath
        }
    } catch {
        if (Test-Path -LiteralPath $workspacePath) {
            Remove-Item -LiteralPath $workspacePath -Recurse -Force -ErrorAction SilentlyContinue
        }
        throw
    }
}
