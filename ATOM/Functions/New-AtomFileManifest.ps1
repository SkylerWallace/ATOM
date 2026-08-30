function New-AtomFileManifest {
    <#
    .SYNOPSIS
        Creates a deterministic per-file manifest beneath an ATOM package root.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$RootPath,
        [String[]]$Exclude = @()
    )

    $root = [IO.Path]::GetFullPath($RootPath).TrimEnd('\') + '\'
    @(Get-ChildItem -LiteralPath $RootPath -File -Recurse -Force | ForEach-Object {
        $relativePath = $_.FullName.Substring($root.Length).Replace('\', '/')
        if ($relativePath -like '.git/*' -or $relativePath -like '.github/*') { return }
        if ($Exclude | Where-Object { $relativePath -like $_ }) { return }

        [PSCustomObject]@{
            Path   = $relativePath
            Sha256 = Get-AtomFileHash -Path $_.FullName
        }
    } | Sort-Object Path)
}
