function Get-CachedImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [String]$Path,

        [Int]$DecodePixelWidth = 32
    )

    if (!$script:ImageCache) { $script:ImageCache = @{} }

    $resolvedPath = [System.IO.Path]::GetFullPath($Path)
    $cacheKey = "$resolvedPath|$DecodePixelWidth"
    if (!$script:ImageCache.ContainsKey($cacheKey)) {
        $bitmap = [System.Windows.Media.Imaging.BitmapImage]::new()
        $bitmap.BeginInit()
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.DecodePixelWidth = $DecodePixelWidth
        $directory = [IO.Path]::GetDirectoryName($resolvedPath)
        $stream = $null
        try {
            if ([IO.Path]::GetFileName($directory) -eq 'Program Icons' -and ![IO.File]::Exists($resolvedPath)) {
                $icons = Get-AtomProgramIcons -Directory $directory
                $name = [IO.Path]::GetFileName($resolvedPath)
                if (!$icons.ContainsKey($name)) { throw "Program icon missing from archive: $name" }
                $stream = [IO.MemoryStream]::new([byte[]]$icons[$name], $false)
                $bitmap.StreamSource = $stream
            } else {
                $bitmap.UriSource = [Uri]$resolvedPath
            }
            $bitmap.EndInit()
        } finally { if ($stream) { $stream.Dispose() } }
        $bitmap.Freeze()
        $script:ImageCache[$cacheKey] = $bitmap
    }

    return $script:ImageCache[$cacheKey]
}
