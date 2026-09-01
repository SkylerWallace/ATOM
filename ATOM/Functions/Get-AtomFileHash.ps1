function Get-AtomFileHash {
    <#
    .SYNOPSIS
        Produces ATOM's cross-checkout SHA-256 hash for a file.

    .DESCRIPTION
        Text line endings are normalized so Git CRLF conversion does not make an
        otherwise identical installation appear damaged.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path
    )

    $textExtensions = @('.bat', '.cmd', '.json', '.md', '.ps1', '.psd1', '.psm1', '.txt', '.xaml', '.xml', '.yaml', '.yml')
    $isTextFile =
        [IO.Path]::GetExtension($Path).ToLowerInvariant() -in $textExtensions -or
        [IO.Path]::GetFileName($Path) -eq '.gitignore'

    if (!$isTextFile) {
        return (Get-FileHash -LiteralPath $Path -Algorithm SHA256 -ErrorAction Stop).Hash
    }

    $content = [IO.File]::ReadAllText($Path) -replace "`r`n?", "`n"
    $bytes = [Text.UTF8Encoding]::new($false).GetBytes($content)
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try { ([BitConverter]::ToString($algorithm.ComputeHash($bytes))).Replace('-', '') }
    finally { $algorithm.Dispose() }
}
