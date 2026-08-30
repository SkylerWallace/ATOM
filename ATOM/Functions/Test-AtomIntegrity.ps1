function Test-AtomIntegrity {
    <#
    .SYNOPSIS
        Compares ATOM-owned files with a reference copy of the installed commit.

    .DESCRIPTION
        Only paths recorded as ATOM-owned are checked. User-created files and
        user-specific configuration files are intentionally ignored.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)][String]$InstalledRoot,
        [Parameter(Mandatory)][String]$ReferenceRoot,
        [Parameter(Mandatory)][AllowEmptyCollection()][String[]]$OwnedFiles
    )

    $installedRootPath = [IO.Path]::GetFullPath($InstalledRoot).TrimEnd('\') + '\'
    $referenceRootPath = [IO.Path]::GetFullPath($ReferenceRoot).TrimEnd('\') + '\'
    $ignoredFiles = @(
        'ATOM/Config/PluginsUser.ps1'
        'ATOM/Config/PluginsParamsUser.ps1'
        'ATOM/Config/ProgramsParamsUser.ps1'
        'ATOM/Config/SettingsUser.ps1'
        'ATOM/Config/UpdateState.json'
    )
    $missingFiles = [Collections.Generic.List[String]]::new()
    $modifiedFiles = [Collections.Generic.List[String]]::new()
    $unverifiableFiles = [Collections.Generic.List[String]]::new()
    $verifiedCount = 0
    $textExtensions = @('.bat', '.cmd', '.gitignore', '.json', '.md', '.ps1', '.psd1', '.psm1', '.txt', '.xaml', '.xml', '.yaml', '.yml')

    function Get-ComparableAtomFileHash {
        param ([Parameter(Mandatory)][String]$Path)

        if (
            [IO.Path]::GetExtension($Path).ToLowerInvariant() -in $textExtensions -or
            [IO.Path]::GetFileName($Path) -eq '.gitignore'
        ) {
            $content = [IO.File]::ReadAllText($Path) -replace "`r`n?", "`n"
            $bytes = [Text.UTF8Encoding]::new($false).GetBytes($content)
            $algorithm = [Security.Cryptography.SHA256]::Create()
            try { return ([BitConverter]::ToString($algorithm.ComputeHash($bytes))).Replace('-', '') }
            finally { $algorithm.Dispose() }
        }

        (Get-FileHash -LiteralPath $Path -Algorithm SHA256 -ErrorAction Stop).Hash
    }

    foreach ($relativePath in @($OwnedFiles | Where-Object { $_ } | Sort-Object -Unique)) {
        $normalizedPath = ([String]$relativePath).Replace('\', '/').TrimStart('/')
        if ($normalizedPath -in $ignoredFiles) { continue }

        $installedPath = [IO.Path]::GetFullPath((Join-Path $InstalledRoot $normalizedPath))
        $referencePath = [IO.Path]::GetFullPath((Join-Path $ReferenceRoot $normalizedPath))
        if (
            !$installedPath.StartsWith($installedRootPath, [StringComparison]::OrdinalIgnoreCase) -or
            !$referencePath.StartsWith($referenceRootPath, [StringComparison]::OrdinalIgnoreCase)
        ) {
            $unverifiableFiles.Add($normalizedPath)
            continue
        }

        if (!(Test-Path -LiteralPath $referencePath -PathType Leaf)) {
            $unverifiableFiles.Add($normalizedPath)
        } elseif (!(Test-Path -LiteralPath $installedPath -PathType Leaf)) {
            $missingFiles.Add($normalizedPath)
        } else {
            try {
                $installedHash = Get-ComparableAtomFileHash -Path $installedPath
                $referenceHash = Get-ComparableAtomFileHash -Path $referencePath
                if ($installedHash -ne $referenceHash) {
                    $modifiedFiles.Add($normalizedPath)
                } else {
                    $verifiedCount++
                }
            } catch {
                $unverifiableFiles.Add($normalizedPath)
            }
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
