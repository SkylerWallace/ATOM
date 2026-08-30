function Test-AtomFileManifest {
    <#
    .SYNOPSIS
        Verifies a directory against an ATOM v2 file manifest.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$RootPath,
        [Parameter(Mandatory)][AllowEmptyCollection()][Object[]]$Files
    )

    $root = [IO.Path]::GetFullPath($RootPath).TrimEnd('\') + '\'
    $missingFiles = [Collections.Generic.List[String]]::new()
    $modifiedFiles = [Collections.Generic.List[String]]::new()
    $unverifiableFiles = [Collections.Generic.List[String]]::new()
    $verifiedCount = 0

    foreach ($entry in @($Files | Sort-Object Path -Unique)) {
        $relativePath = ([String]$entry.Path).Replace('\', '/').TrimStart('/')
        try {
            $filePath = [IO.Path]::GetFullPath((Join-Path $RootPath $relativePath))
            if (!$relativePath -or !$filePath.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) {
                throw "Manifest path escapes its package root."
            }

            if (!(Test-Path -LiteralPath $filePath -PathType Leaf)) {
                $missingFiles.Add($relativePath)
            } elseif ((Get-AtomFileHash -Path $filePath) -ne $entry.Sha256) {
                $modifiedFiles.Add($relativePath)
            } else {
                $verifiedCount++
            }
        } catch {
            $unverifiableFiles.Add($relativePath)
        }
    }

    [PSCustomObject]@{
        IsHealthy         = !$missingFiles.Count -and !$modifiedFiles.Count -and !$unverifiableFiles.Count
        VerifiedCount     = $verifiedCount
        MissingFiles      = @($missingFiles)
        ModifiedFiles     = @($modifiedFiles)
        UnverifiableFiles = @($unverifiableFiles)
        CheckedCount      = $verifiedCount + $missingFiles.Count + $modifiedFiles.Count + $unverifiableFiles.Count
    }
}
