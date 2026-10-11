function Get-AtomUserPlugin {
    <# .SYNOPSIS
        Discovers non-native scripts in Plugins, with optional registered ownership.
    #>
    param([Parameter(Mandatory)][String]$RootPath, [String[]]$NativeNames)
    if (!$PSBoundParameters.ContainsKey('NativeNames')) { $NativeNames = @(Get-AtomNativePluginName -RootPath $RootPath) }
    $folder = Join-Path $RootPath 'Plugins'
    if (!(Test-Path -LiteralPath $folder -PathType Container)) { return }
    $overrides = Read-AtomPluginOverrides -Path (Join-Path $RootPath 'Config/PluginsUser.ps1')
    foreach ($file in Get-ChildItem -LiteralPath $folder -File) {
        if ($file.Extension -notin '.ps1', '.cmd', '.bat' -or $NativeNames -contains $file.BaseName) { continue }
        $metadata = @{}
        $registrations = @($overrides.GetEnumerator() | Where-Object { $_.Value.UserOwned -eq $true -and $_.Value.FileName -eq $file.Name })
        if ($registrations.Count -gt 1) { throw "Multiple plugin IDs are registered for '$($file.Name)'." }
        if ($registrations.Count) {
            foreach ($key in $registrations[0].Value.Keys) { $metadata[$key] = $registrations[0].Value[$key] }
        }
        $owned = $registrations.Count -eq 1 -and $metadata.Id -eq $registrations[0].Key -and $metadata.Name -eq $file.BaseName
        $metadata.Name = $file.BaseName
        $metadata.Script = 'script' + $file.Extension
        if (!$metadata.Contains('Category')) { $metadata.Category = 'Uncategorized' }
        foreach ($key in 'WorksInOs', 'WorksInPe') { if (!$metadata.Contains($key)) { $metadata[$key] = $true } }
        $iconPath = $metadata.IconPath
        if ($iconPath -and ![IO.Path]::IsPathRooted($iconPath)) { $iconPath = Join-Path $RootPath $iconPath }
        [PSCustomObject]@{
            Id = $(if ($owned) { $metadata.Id } else { 'file:' + $file.Name })
            Name = $file.BaseName; FullName = $file.FullName; Directory = $file.DirectoryName
            IconPath = $iconPath; Metadata = $metadata; IsUserOwned = $owned
        }
    }
}
