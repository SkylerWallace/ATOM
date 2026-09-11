function Move-AtomLegacyUserPlugins {
    <# .SYNOPSIS
        Imports legacy bundles, retaining their original files as migration backups.
    #>
    param([Parameter(Mandatory)][String]$RootPath)
    $legacyRoot = Join-Path (Split-Path $RootPath) 'UserPlugins'
    if (!(Test-Path -LiteralPath $legacyRoot -PathType Container)) { return $false }
    $changed = $false
    foreach ($legacy in Get-AtomLegacyUserPlugin -RootPath $legacyRoot) {
        try {
            $registered = @(Get-AtomUserPlugin -RootPath $RootPath | Where-Object { $_.IsUserOwned -and $_.Id -eq $legacy.Id })
            if (!$registered.Count) {
                $legacy.Metadata.PluginId = $legacy.Id
                $parameters = @{ RootPath = $RootPath; Metadata = $legacy.Metadata; SourceScript = $legacy.FullName }
                if ($legacy.IconPath) { $parameters.IconSource = $legacy.IconPath }
                [void](Save-AtomUserPlugin @parameters)
            }
            # Only rename this validated bundle's metadata file, never its directory.
            $source = [IO.Path]::GetFullPath((Join-Path $legacy.Directory 'plugin.json'))
            $boundary = [IO.Path]::GetFullPath($legacyRoot).TrimEnd('\') + '\'
            if (!$source.StartsWith($boundary, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid migration path.' }
            Move-Item -LiteralPath $source -Destination (Join-Path $legacy.Directory 'plugin.migrated.json') -ErrorAction Stop
            $changed = $true
        } catch { Write-Warning "Could not migrate '$($legacy.Name)': $($_.Exception.Message) Original files remain in '$($legacy.Directory)'." }
    }
    return $changed
}
