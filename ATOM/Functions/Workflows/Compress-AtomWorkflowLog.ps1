function Compress-AtomWorkflowLog {
    <# .SYNOPSIS
        Archives a completed run, retaining plain logs if compression fails.
    #>
    param([Parameter(Mandatory)][string]$ResultPath)
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $directory = [IO.Path]::GetFullPath((Split-Path $ResultPath)).TrimEnd('\')
    $root = [IO.Path]::GetFullPath((Split-Path $directory)).TrimEnd('\') + '\'
    if (!$directory.StartsWith($root,[StringComparison]::OrdinalIgnoreCase) -or (Split-Path $directory -Leaf) -notmatch '^(?:[0-9a-f]{32}|\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}_[a-z0-9]{4})$') { throw 'Invalid workflow archive directory.' }
    if ((Get-Item -LiteralPath $directory).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw 'Cannot archive a redirected workflow directory.' }
    $files = @(Get-ChildItem -LiteralPath $directory -File -Recurse -Force -ErrorAction Stop)
    if (@(Get-ChildItem -LiteralPath $directory -Recurse -Force | Where-Object { $_.Attributes -band [IO.FileAttributes]::ReparsePoint }).Count) { throw 'Cannot archive redirected log entries.' }
    $destination = $directory + '.zip'
    if (Test-Path -LiteralPath $destination) { throw 'Workflow archive already exists.' }
    $temporary = $destination + '.tmp'
    try {
        [IO.Compression.ZipFile]::CreateFromDirectory($directory,$temporary,[IO.Compression.CompressionLevel]::Optimal,$false)
        $zip = [IO.Compression.ZipFile]::OpenRead($temporary)
        try {
            if (!$zip.GetEntry('results.json') -or $zip.Entries.Count -ne $files.Count) { throw 'Archive verification failed.' }
            foreach ($file in $files) {
                $name = $file.FullName.Substring($directory.Length + 1).Replace('\','/')
                $entry = $zip.GetEntry($name)
                if (!$entry) { $entry = $zip.GetEntry($name.Replace('/', '\')) }
                if (!$entry -or $entry.Length -ne $file.Length) { throw 'Archive entry verification failed.' }
                $hash = [Security.Cryptography.SHA256]::Create()
                $source = [IO.File]::OpenRead($file.FullName); $archived = $entry.Open()
                try {
                    $sourceHash = [Convert]::ToBase64String($hash.ComputeHash($source))
                    $archiveHash = [Convert]::ToBase64String($hash.ComputeHash($archived))
                    if ($sourceHash -ne $archiveHash) { throw 'Archive content verification failed.' }
                }
                finally { $source.Dispose(); $archived.Dispose(); $hash.Dispose() }
            }
        }
        finally { $zip.Dispose() }
        if ((Get-Item -LiteralPath $temporary).Length -ge ($files | Measure-Object Length -Sum).Sum) { return }
        [IO.File]::Move($temporary, $destination)
        # The verified target is one named run beneath its original log root.
        Remove-Item -LiteralPath $directory -Recurse -Force -ErrorAction Stop
    }
    finally { if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force } }
}
