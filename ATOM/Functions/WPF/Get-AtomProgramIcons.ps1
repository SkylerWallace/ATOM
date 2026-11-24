function Get-AtomProgramIcons {
    <# .SYNOPSIS
        Reads the bundled PNG entries once without keeping the archive locked.
    #>
    param([Parameter(Mandatory)][string]$Directory, [switch]$NamesOnly)

    if (!$script:ProgramIconCache) { $script:ProgramIconCache = @{} }
    $archivePath = [IO.Path]::GetFullPath($Directory.TrimEnd('\', '/') + '.zip')
    if ($NamesOnly -and $script:ProgramIconCache.ContainsKey($archivePath)) {
        $script:ProgramIconCache[$archivePath].Keys
        return
    }
    if ($NamesOnly -or !$script:ProgramIconCache.ContainsKey($archivePath)) {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $icons = @{}
        $archive = [IO.Compression.ZipFile]::OpenRead($archivePath)
        try {
            foreach ($entry in $archive.Entries) {
                if ($entry.FullName -ne $entry.Name -or $entry.Name -notlike '*.png') { continue }
                if ($NamesOnly) { $entry.Name; continue }
                $stream = $entry.Open()
                $buffer = [IO.MemoryStream]::new()
                try {
                    $stream.CopyTo($buffer)
                    $icons[$entry.Name] = $buffer.ToArray()
                } finally { $stream.Dispose(); $buffer.Dispose() }
            }
        } finally { $archive.Dispose() }
        if ($NamesOnly) { return }
        $script:ProgramIconCache[$archivePath] = $icons
    }
    return $script:ProgramIconCache[$archivePath]
}
