function Read-AtomWorkflowLog {
    <# .SYNOPSIS
        Reads plain or archived workflow JSON without extracting an archive.
    #>
    param([Parameter(Mandatory)][string]$Path)
    if ([IO.Path]::GetExtension($Path) -ne '.zip') { return [IO.File]::ReadAllText($Path) | ConvertFrom-Json -ErrorAction Stop }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead($Path)
    try {
        $entry = $zip.GetEntry('results.json')
        if (!$entry -or $entry.Length -gt 64MB) { throw 'Invalid workflow archive results.' }
        $reader = [IO.StreamReader]::new($entry.Open())
        try { $reader.ReadToEnd() | ConvertFrom-Json -ErrorAction Stop }
        finally { $reader.Dispose() }
    }
    finally { $zip.Dispose() }
}