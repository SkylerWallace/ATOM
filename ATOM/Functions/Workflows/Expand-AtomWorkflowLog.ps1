function Expand-AtomWorkflowLog {
    <# .SYNOPSIS
        Expands archived reports on demand into a bounded session cache.
    #>
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][hashtable]$Cache)
    $stamp = [IO.File]::GetLastWriteTimeUtc($Path).Ticks
    $key = "$Path|$stamp"
    if ($Cache[$key] -and (Test-Path -LiteralPath (Join-Path $Cache[$key] 'results.json'))) { return $Cache[$key] }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $directory = Join-Path ([IO.Path]::GetTempPath()) ('ATOM-Workflow-' + [guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($directory)
    $prefix = [IO.Path]::GetFullPath($directory).TrimEnd('\') + '\'
    $zip = $null
    try {
        $zip = [IO.Compression.ZipFile]::OpenRead($Path)
        foreach ($entry in $zip.Entries) {
            $target = [IO.Path]::GetFullPath((Join-Path $directory $entry.FullName))
            if (!$target.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Unsafe archive entry path.' }
            if ($entry.FullName.EndsWith('/') -or $entry.FullName.EndsWith('\')) { [void][IO.Directory]::CreateDirectory($target); continue }
            [void][IO.Directory]::CreateDirectory((Split-Path $target))
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$target,$false)
        }
        if (!(Test-Path -LiteralPath (Join-Path $directory 'results.json'))) { throw 'Archive contains no workflow result.' }
        $Cache[$key] = $directory
        return $directory
    }
    catch {
        if ([IO.Path]::GetFullPath($directory).StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath()),[StringComparison]::OrdinalIgnoreCase) -and (Split-Path $directory -Leaf) -match '^ATOM-Workflow-[0-9a-f]{32}$') {
            Remove-Item -LiteralPath $directory -Recurse -Force -ErrorAction SilentlyContinue
        }
        throw
    }
    finally { if ($zip) { $zip.Dispose() } }
}
