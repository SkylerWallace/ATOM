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
        if ($overrides.Contains($file.BaseName)) {
            foreach ($key in $overrides[$file.BaseName].Keys) { $metadata[$key] = $overrides[$file.BaseName][$key] }
        }
        $owned = $metadata.UserOwned -eq $true -and $metadata.PluginId -match '^[a-f0-9]{32}$' -and $metadata.FileName -eq $file.Name
        $metadata.Name = $file.BaseName
        $metadata.Script = 'script' + $file.Extension
        if (!$metadata.Contains('Category')) { $metadata.Category = 'Uncategorized' }
        foreach ($key in 'WorksInOs', 'WorksInPe') { if (!$metadata.Contains($key)) { $metadata[$key] = $true } }
        $iconPath = $metadata.IconPath
        if ($iconPath -and ![IO.Path]::IsPathRooted($iconPath)) { $iconPath = Join-Path $RootPath $iconPath }
        [PSCustomObject]@{
            Id = $(if ($owned) { $metadata.PluginId } else { 'file:' + $file.Name })
            Name = $file.BaseName; FullName = $file.FullName; Directory = $file.DirectoryName
            IconPath = $iconPath; Metadata = $metadata; IsUserOwned = $owned
        }
    }
}
