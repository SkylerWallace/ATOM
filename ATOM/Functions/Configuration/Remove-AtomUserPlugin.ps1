function Remove-AtomUserPlugin {
    <# .SYNOPSIS
        Requests Windows recycling for an owned bundle, retaining shell warnings.
    #>
    param([Parameter(Mandatory)][String]$RootPath, [Parameter(Mandatory)][String]$Id)
    if ($Id -notmatch '^[a-f0-9]{32}$') { throw 'Invalid user plugin ID.' }
    $plugin = Get-AtomUserPlugin -RootPath $RootPath | Where-Object Id -eq $Id | Select-Object -First 1
    if (!$plugin) { throw 'This user plugin no longer exists.' }
    $root = [IO.Path]::GetFullPath($RootPath).TrimEnd('\') + '\'
    $target = [IO.Path]::GetFullPath($plugin.Directory)
    if (!$target.StartsWith($root, [StringComparison]::OrdinalIgnoreCase) -or [IO.Path]::GetDirectoryName($target) + '\' -ne $root) { throw 'Plugin path is outside user storage.' }
    if (@(Get-ChildItem -LiteralPath $target -Recurse -Force | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count) { throw 'Remove links from the plugin folder before deleting it.' }
    Add-Type -AssemblyName Microsoft.VisualBasic
    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($target, 'AllDialogs', 'SendToRecycleBin', 'ThrowException')
}
