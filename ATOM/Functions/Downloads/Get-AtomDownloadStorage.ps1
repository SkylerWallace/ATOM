function Get-AtomDownloadStorage {
    <#
    .SYNOPSIS
        Measures toolkit files without following junctions or symbolic links.
    #>
    param ([String]$Root, [Hashtable]$Destinations)
    $rootPath = [IO.Path]::GetFullPath($Root).TrimEnd('\', '/')
    $prefixes = @{}
    $sizes = @{}
    foreach ($name in $Destinations.Keys) {
        try {
            $destination = [IO.Path]::GetFullPath($Destinations[$name]).TrimEnd('\', '/')
            if ($destination.StartsWith($rootPath + '\', [StringComparison]::OrdinalIgnoreCase)) {
                $prefixes[$name] = $destination + '\'
                $sizes[$name] = [long]0
            }
        } catch { }
    }
    $total = [long]0
    $partial = $false
    $pending = [Collections.Generic.Stack[String]]::new()
    if ([IO.Directory]::Exists($rootPath)) { $pending.Push($rootPath) }
    while ($pending.Count) {
        $directory = $pending.Pop()
        try {
            $directoryInfo = Get-Item -LiteralPath $directory -Force -ErrorAction Stop
            if ($directoryInfo.Attributes -band [IO.FileAttributes]::ReparsePoint) { $partial = $true; continue }
            foreach ($entry in Get-ChildItem -LiteralPath $directory -Force -ErrorAction Stop) {
                if ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) { $partial = $true; continue }
                if ($entry.PSIsContainer) { $pending.Push($entry.FullName); continue }
                $total += $entry.Length
                foreach ($name in $prefixes.Keys) {
                    if ($entry.FullName.StartsWith($prefixes[$name], [StringComparison]::OrdinalIgnoreCase)) {
                        $sizes[$name] += $entry.Length
                    }
                }
            }
        } catch { $partial = $true }
    }
    $free = $null
    try { $free = [IO.DriveInfo]::new([IO.Path]::GetPathRoot($rootPath)).AvailableFreeSpace } catch { }
    [PSCustomObject]@{ TotalBytes = $total; FreeBytes = $free; Sizes = $sizes; Partial = $partial }
}
