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
        $bitmap.UriSource = [Uri]$resolvedPath
        $bitmap.EndInit()
        $bitmap.Freeze()
        $script:ImageCache[$cacheKey] = $bitmap
    }

    return $script:ImageCache[$cacheKey]
}
