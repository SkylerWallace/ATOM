function Write-AtomFileAtomic {
    <#
    .SYNOPSIS
        Writes text to a file without exposing partially written content.

    .DESCRIPTION
        Writes content to a unique temporary file in the destination directory,
        then moves it over the destination. The temporary file is removed if the
        write or replacement fails.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [String]$Content,

        [Text.Encoding]$Encoding = [Text.UTF8Encoding]::new($false)
    )

    $fullPath = [IO.Path]::GetFullPath($Path)
    $directory = [IO.Path]::GetDirectoryName($fullPath)
    if (!(Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -Path $directory -ItemType Directory -Force -ErrorAction Stop | Out-Null
    }

    $temporaryPath = Join-Path $directory ".$([IO.Path]::GetFileName($fullPath)).$([Guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temporaryPath, $Content, $Encoding)
        Move-Item -LiteralPath $temporaryPath -Destination $fullPath -Force -ErrorAction Stop
    } finally {
        if (Test-Path -LiteralPath $temporaryPath) {
            Remove-Item -LiteralPath $temporaryPath -Force -ErrorAction SilentlyContinue
        }
    }
}
