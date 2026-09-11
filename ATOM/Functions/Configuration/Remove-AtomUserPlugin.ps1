function Remove-AtomUserPlugin {
    param([Parameter(Mandatory)][String]$RootPath, [Parameter(Mandatory)][String]$Id)
    $plugin = Get-AtomUserPlugin -RootPath $RootPath | Where-Object { $_.IsUserOwned -and $_.Id -eq $Id } | Select-Object -First 1
    if (!$plugin) { throw 'Only a registered, non-native plugin can be deleted.' }
    $folder = [IO.Path]::GetFullPath((Join-Path $RootPath 'Plugins'))
    $target = [IO.Path]::GetFullPath($plugin.FullName)
    if ([IO.Path]::GetDirectoryName($target) -ne $folder) { throw 'Plugin path is outside Plugins.' }
    foreach ($path in $folder, $target) {
        if ((Get-Item -LiteralPath $path).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Linked plugin files cannot be deleted by ATOM.' }
    }
    $overridePath = Join-Path $RootPath 'Config/PluginsUser.ps1'
    $overrides = Read-AtomPluginOverrides -Path $overridePath
    Write-AtomPluginOverrides -Path (Join-Path $RootPath ("Backups/DeletedPlugins/$Id.ps1")) -Overrides ([ordered]@{ $plugin.Name = $overrides[$plugin.Name] })
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($target, 'AllDialogs', 'SendToRecycleBin', 'ThrowException')
    [void]$overrides.Remove($plugin.Name)
    Write-AtomPluginOverrides -Path $overridePath -Overrides $overrides
    $ownedIcon = [String]$plugin.Metadata.OwnedIcon
    if ($ownedIcon -match '^Resources/Icons/User Icons/[a-f0-9]{32}\.(png|jpg|jpeg|ico)$' -and $plugin.Metadata.IconPath -eq $ownedIcon) {
        $iconPath = [IO.Path]::GetFullPath((Join-Path $RootPath $ownedIcon))
        $shared = @($overrides.Values | Where-Object {
            $_.IconPath -and [IO.Path]::GetFullPath($(if ([IO.Path]::IsPathRooted($_.IconPath)) { $_.IconPath } else { Join-Path $RootPath $_.IconPath })) -eq $iconPath
        }).Count
        if (!$shared -and (Test-Path -LiteralPath $iconPath -PathType Leaf)) {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($iconPath, 'AllDialogs', 'SendToRecycleBin', 'ThrowException')
        }
    }
}
